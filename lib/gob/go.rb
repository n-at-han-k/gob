require "set"
require "parser"
require "prism"

module Gob
  # Ruby -> Go. Walks the `parser`-format s-expression tree and writes Go
  # source text.
  #
  # Prism is the engine and `parser` is only the AST format: the parser gem
  # refuses Ruby 3.4+ syntax, while Prism::Translation::Parser40 produces the
  # same s-expressions from the parser that actually runs the language. The
  # format is the point -- a flat `(send nil :require (str "fmt"))` is what can
  # be pattern matched, which Prism's own node classes are not.
  #
  # Text, not a tree, because there is no Go printer in Ruby. gofmt is the
  # Go-side counterpart of `rubocop -A`: layout is its business, so nothing
  # here lines anything up.
  #
  # Visibility needs no marker on the way back. The Ruby kept Go's names, and
  # Go's export rule IS the case of the first letter, so `runFmt` is unexported
  # again for free and the `private` sections are dropped.
  class Go
    Unsupported = Class.new(StandardError)

    # Ruby's receiver name for the object a method is called on.
    RECEIVER = "this".freeze

    def initialize(source, path = "source")
      @source = source
      @path = path
      @imports = []
      @package = "main"
      @scopes = [Set.new]
    end

    def emit
      body = statements(root).reject(&:empty?)
      [package_clause, import_block, body.join("\n\n")].reject(&:empty?).join("\n\n") + "\n"
    end

      private

    def root
      buffer = Parser::Source::Buffer.new(@path)
      buffer.source = @source
      Prism::Translation::Parser40.new.parse(buffer)
    end

    def package_clause = "package #{@package}"

    def import_block
      return "" if @imports.empty?
      return "import #{@imports.first}" if @imports.one?

      ["import (", *@imports.map { "\t#{_1}" }, ")"].join("\n")
    end

    def statements(node)
      return [] if node.nil?
      return node.children.flat_map { statements(_1) } if node.type == :begin

      Array(visit(node))
    end

    def visit(node)
      case node.type
      when :module then container(node)
      when :class then type_declaration(node)
      when :def then func(node)
      when :defs then func(node, singleton: true)
      when :send then send_node(node)
      when :lvasgn, :ivasgn, :gvasgn then assignment([node.children[0].to_s], node.children[1])
      when :casgn then "#{node.children[1]} = #{expression(node.children[2])}"
      when :masgn then multiple_assign(node)
      when :op_asgn then op_assign(node)
      when :if then conditional(node)
      when :while then "for #{expression(node.children[0])} #{block_body(node.children[1])}"
      when :until then "for !(#{expression(node.children[0])}) #{block_body(node.children[1])}"
      when :block then block_call(node)
      when :return then "return#{node.children.empty? ? '' : " #{node.children.map { expression(_1) }.join(', ')}"}"
      when :break then "break"
      when :next then "continue"
      # Go has no yield. The Ruby's `yield` came from a Go range-over-func
      # iterator, whose parameter IS the function being called.
      when :yield then "yield(#{node.children.map { expression(_1) }.join(', ')})"
      when :case then switch(node)
      else expression(node)
      end
    end

    # `module Main` is the package. Its body is the file's declarations, and the
    # visibility sections inside it carry nothing Go needs.
    def container(node)
      @package = const_name(node.children[0]).downcase
      declarations = statements_of(node.children[1]).flat_map { package_scope(_1) }

      declarations.reject(&:empty?).join("\n\n")
    end

    # At package scope Go has no bare assignment: `pi = 3.14` is a syntax
    # error there and has to be `var pi = 3.14`.
    ASSIGNMENTS = %i[lvasgn ivasgn gvasgn casgn masgn].freeze

    def package_scope(node)
      emitted = Array(visit(node))
      return emitted unless ASSIGNMENTS.include?(node.type)

      emitted.map { "var #{_1}" }
    end

    def type_declaration(node)
      name = const_name(node.children[0])
      @enclosing = name
      members, methods = class_body(node.children[2])

      ["type #{name} struct {", *members.map { "\t#{_1}" }, "}", *methods].join("\n")
    end

    # attr_accessor declares a field; everything else in a class body is a
    # method, which Go writes outside the type with a receiver.
    def class_body(body)
      members = []
      methods = []

      statements_of(body).each do |child|
        if child.type == :send && child.children[1] == :attr_accessor
          members.concat(child.children[2..].map { "#{symbol_name(_1)} any" })
        elsif %i[def defs].include?(child.type)
          methods << func(child, receiver: const_name_of_enclosing)
        end
      end

      [members, methods]
    end

    def statements_of(body)
      return [] if body.nil?

      body.type == :begin ? body.children : [body]
    end

    def func(node, singleton: false, receiver: nil)
      name = (singleton ? node.children[1] : node.children[0]).to_s
      arguments = singleton ? node.children[2] : node.children[1]
      params = parameters(arguments)
      prefix = receiver ? "func (#{RECEIVER} #{receiver}) " : "func "
      body = scoped(param_names(arguments) + [RECEIVER]) do
        block_body(singleton ? node.children[3] : node.children[2])
      end

      "#{prefix}#{name}(#{params.join(', ')}) #{body}"
    end

    def param_names(args) = (args&.children || []).map { _1.children[0].to_s }

    def parameters(args) = (args&.children || []).map { "#{_1.children[0]} any" }

    def block_body(body)
      lines = statements(body).reject(&:empty?).flat_map { _1.split("\n") }
      return "{\n}" if lines.empty?

      ["{", *lines.map { "\t#{_1}" }, "}"].join("\n")
    end

    def send_node(node)
      receiver, name, *args = node.children

      return import(args) if receiver.nil? && %i[require require_relative].include?(name)
      return "" if receiver.nil? && visibility?(name)
      return channel_arm(args.first) if name == :<< && args.first&.type == :block

      call(receiver, name, args, node)
    end

    def import(args)
      @imports << expression(args.first)
      ""
    end

    def visibility?(name) = %i[private public protected module_function].include?(name)

    def call(receiver, name, args, node = nil)
      return operator(receiver, name, args) if operator?(name)
      return "#{expression(receiver)}[#{expression(args.first)}]" if name == :[]
      # `m["k"] = v` arrives as a `:[]=` send, both as a statement and as a
      # multiple-assignment target, where it carries only the index.
      if name == :[]=
        indexed = "#{expression(receiver)}[#{expression(args.first)}]"
        return args.size < 2 ? indexed : "#{indexed} = #{expression(args[1])}"
      end

      target = receiver ? "#{expression(receiver)}.#{name}" : name.to_s
      return target if args.empty? && !called?(node)

      "#{target}(#{args.map { expression(_1) }.join(', ')})"
    end

    # Whether the source actually wrote `()`. Without it a bare name is a
    # reference -- `log` is a Go package, not a call returning one -- and
    # emitting `log()` put a call on every package qualifier in the corpus.
    # This is what parser's precise source locations are for.
    def called?(node)
      return true if node.nil?

      !node.loc.respond_to?(:begin) || !node.loc.begin.nil?
    end

    OPERATORS = %w[+ - * / % == != < <= > >= << >> & | ^ && ||].freeze

    def operator?(name) = OPERATORS.include?(name.to_s)

    def operator(receiver, name, args)
      return "#{name}#{expression(receiver)}" if args.empty?

      "#{expression(receiver)} #{name} #{expression(args.first)}"
    end

    def multiple_assign(node)
      assignment(node.children[0].children.map { assign_target(_1) }, node.children[1])
    end

    # Ruby does not distinguish declaring a name from assigning to one; Go
    # does, and rejects `=` for a name it has not seen. The first binding in a
    # scope is `:=`, and Go accepts `:=` for a group where ANY name is new.
    #
    # Package scope is the exception: there a declaration is spelled `var`, so
    # nothing at depth 0 uses `:=`.
    def assignment(targets, value)
      fresh = targets.any? { |t| t.match?(/\A\w+\z/) && !declared?(t) }
      targets.each { declare(_1) }
      operator = fresh && @scopes.size > 1 ? ":=" : "="

      "#{targets.join(', ')} #{operator} #{expression(value)}"
    end

    def declared?(name) = @scopes.any? { _1.include?(name) }

    def declare(name)
      return unless name.match?(/\A\w+\z/)

      @scopes.last << name
    end

    def scoped(names = [])
      @scopes.push(Set.new(names))
      yield
    ensure
      @scopes.pop
    end

    def assign_target(node)
      case node.type
      when :lvasgn, :ivasgn, :gvasgn then node.children[0].to_s
      when :send then call(node.children[0], node.children[1], node.children[2..], node)
      when :indexasgn then "#{expression(node.children[0])}[#{expression(node.children[1])}]"
      else expression(node)
      end
    end

    def op_assign(node)
      "#{assign_target(node.children[0])} #{node.children[1]}= #{expression(node.children[2])}"
    end

    def conditional(node)
      condition, consequence, alternative = node.children
      out = "if #{expression(condition)} #{block_body(consequence)}"
      return out if alternative.nil?

      alternative.type == :if ? "#{out} else #{visit(alternative)}" : "#{out} else #{block_body(alternative)}"
    end

    def switch(node)
      subject = node.children[0]
      arms = node.children[1..-2].map { arm(_1) }
      default = node.children[-1]
      arms << "default:\n#{indent_lines(statements(default))}" if default

      ["switch #{subject ? expression(subject) : ''}{".squeeze(" "), *arms, "}"].join("\n")
    end

    def arm(node)
      values = node.children[0..-2].map { expression(_1) }
      "case #{values.join(', ')}:\n#{indent_lines(statements(node.children[-1]))}"
    end

    def indent_lines(lines) = lines.reject(&:empty?).flat_map { _1.split("\n") }.map { "\t#{_1}" }.join("\n")

    # `x.each do |i| ... end` is a range loop.
    def block_call(node)
      send, args, body = node.children
      vars = (args.children || []).map { _1.children[0] }
      receiver, name, *call_args = send.children

      case name
      when :each then each_loop(vars, receiver, body)
      when :times then "for #{vars.first || '_'} := range #{expression(receiver)} #{scoped(vars.map(&:to_s)) { block_body(body) }}"
      when :loop then "for #{scoped { block_body(body) }}"
      # `defer { x }` and `go { x }` wrap a call Go defers or launches. Go
      # takes a call, not a block, so the body becomes a func literal invoked
      # on the spot.
      when :defer, :go then "#{name} func() #{scoped { block_body(body) }}()"
      when :lambda then "func(#{parameters(args).join(', ')}) #{scoped(vars.map(&:to_s)) { block_body(body) }}"
      when :select then "select #{select_body(body)}"
      when :<< then channel_arm(receiver, call_args, body)
      else "#{call(receiver, name, call_args, send)} #{block_body(body)}"
      end
    end

    def loop_vars(vars) = vars.empty? ? "_" : vars.join(", ")

    # `xs.each` ranges over a collection, but `(0...n).each` is a counted loop
    # and `range 0:n` is not Go. From zero it is range-over-int; otherwise it
    # spells the three-clause form out.
    def each_loop(vars, receiver, body)
      inner = scoped(vars.map(&:to_s)) { block_body(body) }
      subject = unwrap(receiver)
      return "for #{loop_vars(vars)} := range #{expression(receiver)} #{inner}" unless range?(subject)

      name = vars.first || "_"
      start, finish = subject.children
      return "for #{name} := range #{expression(finish)} #{inner}" if zero?(start)

      "for #{name} := #{expression(start)}; #{name} < #{expression(finish)}; #{name}++ #{inner}"
    end

    def range?(node) = %i[irange erange].include?(node&.type)

    # A parenthesised expression is a `:begin` with one child. The range in
    # `(0...n).each` arrives wrapped, so matching on it has to look through.
    def unwrap(node)
      return node unless node&.type == :begin && node.children.one?

      unwrap(node.children.first)
    end

    def zero?(node) = node&.type == :int && node.children[0].zero?

    # `select do |c| c << ch { body } end` -- each arm is a receive.
    def select_body(body)
      arms = statements(body).reject(&:empty?).flat_map { _1.split("\n") }
      ["{", *arms, "}"].join("\n")
    end

    # The block binds to the channel expression, not to `<<`, so the arm's
    # body arrives inside the argument.
    def channel_arm(node)
      channel, _args, body = node.children
      lines = scoped { statements(body) }.reject(&:empty?).flat_map { _1.split("\n") }

      ["case <-#{expression(channel)}:", *lines.map { "\t#{_1}" }].join("\n")
    end

    def expression(node)
      return "nil" if node.nil?

      case node.type
      when :str then node.children[0].inspect
      when :sym then symbol_name(node)
      when :int, :float then node.children[0].to_s
      when :true then "true"
      when :false then "false"
      when :nil then "nil"
      when :self then RECEIVER
      when :lvar, :ivar, :gvar then node.children[0].to_s
      when :const then const_name(node)
      when :array then "[]any{#{node.children.map { expression(_1) }.join(', ')}}"
      when :hash then "map[any]any{#{node.children.map { pair(_1) }.join(', ')}}"
      when :pair then pair(node)
      when :index then "#{expression(node.children[0])}[#{expression(node.children[1])}]"
      when :irange then "#{expression(node.children[0])}:#{expression(node.children[1])}"
      when :erange then "#{expression(node.children[0])}:#{expression(node.children[1])}"
      when :and then "#{expression(node.children[0])} && #{expression(node.children[1])}"
      when :or then "#{expression(node.children[0])} || #{expression(node.children[1])}"
      when :not then "!#{expression(node.children[0])}"
      when :begin then node.children.map { expression(_1) }.join("; ")
      when :dstr then interpolated(node)
      when :block_pass then expression(node.children[0])
      when :send then send_node(node)
      when :block then block_call(node)
      when :if then conditional(node)
      when :return, :yield then visit(node)
      else raise Unsupported, "no handler for Ruby node `#{node.type}`"
      end
    end

    def pair(node) = "#{expression(node.children[0])}: #{expression(node.children[1])}"

    def symbol_name(node) = node.children[0].to_s

    def interpolated(node)
      parts = node.children.map do |child|
        child.type == :str ? child.children[0] : "%v"
      end

      format("fmt.Sprintf(%p%s)", parts.join, interpolations(node))
    end

    def interpolations(node)
      values = node.children.reject { _1.type == :str }.map { expression(_1.children[0]) }
      values.empty? ? "" : ", #{values.join(', ')}"
    end

    def const_name(node)
      return "" if node.nil?

      scope, name = node.children
      scope && scope.type == :const ? "#{const_name(scope)}.#{name}" : name.to_s
    end

    # Set by type_declaration before its body is walked, so the methods in it
    # know the type they hang off.
    def const_name_of_enclosing = @enclosing
  end
end
