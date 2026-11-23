require "tree_haver"
require "ast/dsl"

module Gob
  class Emitter
    include Ast::DSL

    Unsupported = Class.new(StandardError)

    # Go declares the package and its imports; Ruby has neither.
    SKIP = %w[package_clause import_declaration].freeze

    CONTAINERS = %w[
      block statement_list expression_statement
      var_declaration const_declaration var_spec_list const_spec_list
    ].freeze

    ASSIGNMENTS = %w[var_spec const_spec short_var_declaration assignment_statement].freeze

    IDENTIFIERS = %w[identifier field_identifier package_identifier type_identifier].freeze

    LITERAL_STRINGS = %w[interpreted_string_literal raw_string_literal].freeze

    RUBY_KEYWORDS = %w[
      alias and begin break case class def defined? do else elsif end ensure
      false for if in module next nil not or redo rescue retry return self
      super then true undef unless until when while yield
    ].freeze

    INTEGER_TYPES = /\A(u?int(8|16|32|64)?|byte|rune)\z/
    FLOAT_TYPES = /\Afloat(32|64)\z/

    def self.register_backend!
      @registered ||= begin
        TreeHaver::BackendRegistry.register(TreeHaver::KREUZBERG_LANGUAGE_PACK_BACKEND)
        TreeHaver::GrammarFinder.new(:go).new do |finder|
          if finder.available?
            finder.register!
          end
        end
        true
      end
    end

    def initialize(source)
      @source = source
    end

    def emit
      self.class.register_backend!
      root = TreeHaver.parser_for(:go, backend_type: :tree_sitter).parse(@source).root_node

      if root.has_error?
        raise Unsupported, "Go source does not parse"
      end

      SyntaxTree::Formatter.format("", Program(StatementList(file(root))))
    end

    def file(root)
      nodes = root.children.select(&:named?)
      at = nodes.find_index { _1.type == "package_clause" }
      header = (at ? nodes.first(at) : []).select { _1.type == "comment" }
      rest = at ? nodes.drop(at + 1) : nodes

      last = rest.rindex { _1.type == "import_declaration" }
      if last && same_line_comment?(rest[last], rest[last + 1])
        last += 1
      end
      preamble = last ? rest.first(last + 1) : []
      tail = last ? rest.drop(last + 1) : rest

      @methods = tail.select { _1.type == "method_declaration" }.group_by { receiver_type(_1) }
      body = tail.reject { _1.type == "method_declaration" }.flat_map { Array(visit(_1)) }
      body += orphan_classes

      header.map { comment(_1) } +
        top_level(preamble) +
        (at ? [Namespace(constant_name(package_name(nodes[at])), body: body)] : body)
    end

    # `func (c *colour) ...` and `func (Arith) ...` -- the receiver may be
    # unnamed and the type may be a pointer; both name the same class.
    def receiver_type(node)
      declaration = named(field(node, "receiver")).first
      text(field(declaration, "type")).delete("*").strip
    end

    def take_methods(go_name) = (@methods.delete(go_name) || []).flat_map { Array(visit(_1)) }

    # A receiver whose type was never declared in this file still needs a home.
    def orphan_classes
      @methods.map do |go_name, nodes|
        ClassDeclaration(ConstRef(const_token(constant_name(go_name))), nil,
                         Body(nodes.flat_map { Array(visit(_1)) }))
      end.tap { @methods = {} }
    end

    # The preamble in source order: comments as comments, imports as requires.
    # A comment on the same line as the import it follows is that import's own
    # doc and is emitted with it instead of on its own.
    def top_level(preamble)
      trailing = preamble.filter_map do |node|
        next unless node.type == "comment"

        previous = preamble.take_while { _1.start_byte < node.start_byte }.last
        node if previous&.type == "import_declaration" && same_line_comment?(previous, node)
      end

      preamble.flat_map do |node|
        case node.type
        when "import_declaration" then requires(node, trailing)
        when "comment" then trailing.any? { _1.start_byte == node.start_byte } ? [] : [comment(node)]
        else Array(visit(node))
        end
      end
    end

    def row(byte) = @source.byteslice(0, byte).count("\n")

    def same_line_comment?(declaration, node)
      node&.type == "comment" && row(declaration.end_byte) == row(node.start_byte)
    end

    def package_name(clause) = text(named(clause).first)

    # `import "fmt"` is one spec; a parenthesised import is a spec_list holding
    # several, with each spec's doc comment as its FOLLOWING sibling. Dropping
    # the declaration whole lost every one of those comments.
    def requires(declaration, trailing = [])
      list = named(declaration).find { _1.type == "import_spec_list" } || declaration
      outer = trailing.find { same_line_comment?(declaration, _1) }

      specs, loose = pair_imports(named(list) + [outer].compact)

      specs.flat_map { |spec| spec[:leading].map { comment(_1) } + require_statement(spec[:node], spec[:doc]) } +
        loose.map { comment(_1) }
    end

    # A comment on the SAME LINE as a spec is that import's doc. One on its own
    # line introduces whatever comes next, so it is held back and emitted above
    # the following require. Attaching every comment to the preceding spec
    # instead overwrote it -- net/http/httptest lost its doc to the two lines
    # explaining the blank import below it.
    def pair_imports(nodes)
      specs = []
      pending = []

      nodes.each do |node|
        case node.type
        when "import_spec"
          specs << { node: node, doc: nil, leading: pending }
          pending = []
        when "comment"
          if specs.any? && specs.last[:doc].nil? && same_line_comment?(specs.last[:node], node)
            specs.last[:doc] = node
          else
            pending << node
          end
        end
      end

      [specs, pending]
    end

    def require_statement(spec, doc)
      note = [doc && text(doc).sub(%r{\A//\s?}, ""), import_alias(spec)].compact.join(" -- ")
      line = send_node(nil, :require, args: [Str(string_body(field(spec, "path")))], parens: false)

      note.empty? ? [line] : [Comment("# #{note}", false), line]
    end

    # `f "fmt"` imports the package under another name. Ruby's require has no
    # equivalent, and uses of it are emitted verbatim as `f.Println`, so the
    # alias is recorded rather than applied.
    def import_alias(spec)
      name = field(spec, "name")
      name && "imported as #{text(name)}"
    end

      private

    def text(node) = @source.byteslice(node.start_byte, node.end_byte - node.start_byte)

    # Named nodes only: a block's children include the `{` and `}` tokens.
    def named(node) = node.children.select(&:named?).reject { SKIP.include?(_1.type) }

    # A body is a flat list, so a node producing several statements splices in.
    def statements(node) = named(node).flat_map { Array(visit(_1)) }

    def field(node, name) = node.child_by_field_name(name)

    def visit(node)
      kind = node.type

      case kind
      when "comment" then comment(node)
      when "function_declaration", "method_declaration" then function(node)
      when "func_literal" then func_literal(node)
      when *CONTAINERS then statements(node)
      when *ASSIGNMENTS then assignment(node)
      when "type_declaration" then statements(node)
      when "type_spec" then type_spec(node)
      when "if_statement" then if_statement(node)
      when "for_statement" then for_statement(node)
      when "defer_statement", "go_statement" then deferred(node)
      when "return_statement" then ReturnNode(Args(values(node)))
      when "call_expression" then call(node)
      when "selector_expression" then selector(node)
      when "type_conversion_expression" then conversion(node)
      when "composite_literal" then composite(node)
      when "index_expression" then ARef(visit(field(node, "operand")), visit(field(node, "index")))
      when "slice_expression" then slice(node)
      when "binary_expression" then binary(node)
      when "unary_expression" then unary(node)
      when "inc_statement" then OpAssign(VarField(Ident(local_name(named(node).first))), Op("+="), Int("1"))
      when "dec_statement" then OpAssign(VarField(Ident(local_name(named(node).first))), Op("-="), Int("1"))
      when "parenthesized_expression" then visit(named(node).first)
      when "literal_value" then composite_body(node)
      when "keyed_element" then assoc(node)
      when "break_statement" then Break(Args([]))
      when "continue_statement" then Next(Args([]))
      when "type_assertion_expression" then visit(field(node, "operand"))
      when "slice_type", "array_type" then ArrayLiteral(LBracket("["), Args([]))
      when "map_type" then HashLiteral(LBrace("{"), [])
      when "expression_switch_statement", "type_switch_statement" then switch(node)
      when "select_statement" then select_statement(node)
      when "receive_statement" then receive(node)
      # `pkg.Type` -- the same shape as a selector, under different fields.
      when "qualified_type" then send_node(visit(field(node, "package")), text(field(node, "name")))
      # Ruby has no pointers: `*Foo` is Foo.
      when "pointer_type" then visit(named(node).first)
      when "expression_list" then list_value(node)
      when *IDENTIFIERS then Var(local_name(node))
      when *LITERAL_STRINGS then Str(string_body(node))
      when "int_literal" then Int(text(node))
      when "float_literal" then FloatLiteral(text(node))
      when "rune_literal" then Str(text(node).delete("'"))
      when "true", "false", "nil" then Keyword(text(node))
      when "iota" then Int("0")
      else raise Unsupported, "no handler for Go node `#{kind}`: #{text(node).lines.first.to_s.strip}"
      end
    end

    def comment(node) = Comment("# #{text(node).sub(%r{\A//\s?}, '')}", false)

    # Ruby constants must start upper case. Only the FIRST letter is raised:
    # String#capitalize downcases the rest, which turned `PrivateKey` into
    # `Privatekey`.
    def constant_name(name) = name.sub(/\A[a-z]/, &:upcase)

    def local_name(node) = local_for(text(node))

    # Inside a method the receiver IS the object. Go names it (`func (c *colour)`)
    # and refers to it as `c`, which is nothing in Ruby, so every use of that
    # name in the body becomes `this`.
    RECEIVER = "this"

    def local_for(name)
      return RECEIVER if name == @receiver
      RUBY_KEYWORDS.include?(name) ? "#{name}_" : name
    end

    # A Go named type becomes a Ruby constant, which must be capitalised --
    # `type point struct` cannot stay `point` because a lowercase assignment is
    # a local variable, not a constant.
    def type_spec(node)
      go_name = text(field(node, "name"))
      name = constant_name(go_name)
      type = field(node, "type")
      methods = take_methods(go_name)

      case type.type
      when "struct_type" then struct_class(name, type, methods)
      when "interface_type" then Namespace(name)
      when "nil" then nil
      else named_type(node, name, methods)
      end
    end

    # `type intHeap []int` is a named slice, not a struct. With no methods
    # there is nothing to build, and it cannot be a constant either -- Go
    # allows the declaration inside a function, and a constant assignment
    # there is a dynamic constant assignment, which does not parse. With
    # methods it is a type after all, so it gets a class to hold them.
    def named_type(node, name, methods)
      underlying = Comment("# #{text(node.parent).strip}", false)
      return underlying if methods.empty?

      ClassDeclaration(ConstRef(const_token(name)), nil, Body([underlying] + methods))
    end

    # A Go struct becomes a class whose fields are attr_accessors, one per
    # line so each can carry its own tag comment.
    def struct_class(name, type, methods = [])
      accessors = struct_members(type).map do |member, note|
        annotate(send_node(nil, :attr_accessor, args: [Sym(member)], parens: false), note)
      end

      ClassDeclaration(ConstRef(const_token(name)), nil, Body(accessors + methods))
    end

    # A Go struct tag -- `json:"tags,omitempty"` -- and a field's trailing
    # comment both document the field and have no Ruby counterpart, so they
    # ride along as an inline comment on the member. Dropping them lost the
    # point of the json/xml examples, whose output is decided by the tags.
    def annotate(node, note)
      return node if note.nil?

      node.comments << SyntaxTree::Comment.new(value: "# #{note}", inline: true,
                                               location: SyntaxTree::Location.default)
      node
    end

    def struct_members(type)
      list = named(type).find { _1.type == "field_declaration_list" }
      return [] if list.nil?

      members = []
      previous = nil

      named(list).each do |node|
        case node.type
        when "field_declaration"
          note = field(node, "tag")&.then { tag_text(_1) }
          node.children.select { _1.type == "field_identifier" }
              .each { members << [text(_1), note] }
          previous = node
        when "comment"
          next unless members.any? && previous && same_line_comment?(previous, node)

          doc = text(node).sub(%r{\A//\s?}, "")
          members.last[1] = [members.last[1], doc].compact.join(" ")
        end
      end

      members
    end

    # The tag's text as written. string_body escapes for a Ruby string literal,
    # which would put backslashes into a comment.
    def tag_text(tag)
      inner = tag.children.find { _1.type.end_with?("_content") }
      inner ? text(inner) : text(tag).delete("`")
    end

    # A switch is a case. Go's `default:` is the else.
    def switch(node)
      clauses = named(node).select { _1.type.end_with?("_case") }
      subject = field(node, "value")
      cases = clauses.reject { _1.type == "default_case" }
      default = clauses.find { _1.type == "default_case" }
      raise Unsupported, "switch with no case clauses" if cases.empty?

      Case(Kw("case"), subject ? visit(subject) : nil, when_chain(cases, default))
    end

    def when_chain(cases, default)
      cases.reverse.inject(default && Else(Kw("else"), StatementList(case_body(default)))) do |consequent, clause|
        When(Args(case_values(clause).map { visit(_1) }), StatementList(case_body(clause)), consequent)
      end
    end

    # Everything in the clause except its body is a value being matched. A
    # type_case can list several, an expression_case wraps them in an
    # expression_list.
    def case_values(clause)
      named(clause).reject { _1.type == "statement_list" }
                   .flat_map { _1.type == "expression_list" ? elements(_1) : [_1] }
    end

    def case_body(clause) = named(clause).select { _1.type == "statement_list" }.flat_map { statements(_1) }

    # Go's select waits on several channel operations and runs whichever is
    # ready first. Ruby has no equivalent statement, so select keeps its Go
    # name and takes the arms as a block, the same choice as defer and go.
    #
    # Each arm is `c << <channel> do ... end`, which keeps the guard attached to
    # its own body. Flattening them instead put every arm's statements in
    # sequence, so the first `return` ran unconditionally and the rest was dead
    # code.
    SELECT_VAR = "c"

    def select_statement(node)
      arms = named(node).select { _1.type.end_with?("_case") }
      MethodAddBlock(send_node(nil, :select), Block([SELECT_VAR], body: arms.map { select_arm(_1) }))
    end

    def select_arm(clause)
      body = Block([], body: case_body(clause))
      guard = case_values(clause).map { visit(select_guard(_1)) }.first || Sym(:default)

      Binary(Var(SELECT_VAR), :<<, MethodAddBlock(guard, body))
    end

    # In a guard the `<-` is what select is waiting ON, so the channel is named
    # bare rather than as a `.receive` call.
    def select_guard(node)
      inner = node.type == "receive_statement" ? named(node).last : node
      return inner unless inner.type == "unary_expression" && text(field(inner, "operator")) == "<-"

      field(inner, "operand")
    end

    # `<-ch`, optionally assigned. The `<-` itself is a unary_expression and is
    # turned into `.receive` there, so this only handles the assignment --
    # applying it here too produced `.receive.receive`.
    def receive(node)
      left = field(node, "left")
      got = visit(named(node).last)
      left ? Local(local_name(elements(left).first || left), got) : got
    end

    # An expression_list reached as a value, not as an assignment side.
    def list_value(node)
      items = elements(node)
      items.one? ? visit(items.first) : array_of(items)
    end

    # Go decides both of these for us. A receiver makes it an instance method
    # and its absence a class method; the case of the first letter decides
    # visibility, since an unexported Go name is unreachable outside its
    # package.
    def function(node)
      outer = @receiver
      @receiver = receiver_name(node)
      name = text(field(node, "name"))
      params = parameters(node)
      body = statements(field(node, "body"))

      Function(name, params: params, body: body,
               visibility: visibility(name), owner: owner(node, name))
    ensure
      @receiver = outer
    end

    # A receiver makes it an instance method and its absence a class method.
    # `main` is the exception: the program's entry point, not a member of the
    # package, so it is neither a class method nor private.
    def owner(node, name)
      field(node, "receiver") || name == ENTRY_POINT ? :instance : :class
    end

    # `private` / `private_class_method` go after the definition rather than
    # opening a section, so each function stays where Go put it with its
    # comment still directly above.
    ENTRY_POINT = "main"

    # Go's case rule: an unexported name is unreachable outside its package.
    def visibility(name)
      return :public if name == ENTRY_POINT

      name.match?(/\A[a-z_]/) ? :private : :public
    end

    # `func (Arith) Multiply` has a receiver with no name, so nothing to swap.
    def receiver_name(node)
      list = field(node, "receiver")
      return nil if list.nil?

      name = field(named(list).first, "name")
      name && text(name)
    end

    # A closure in a value position. lambda, not ->, so it reads as a call.
    def func_literal(node)
      Lambda(parameters(node), body: statements(field(node, "body")))
    end

    def parameters(node)
      list = field(node, "parameters")
      return [] if list.nil?

      list.children.select { _1.type == "parameter_declaration" }
          .flat_map { |p| p.children.select { _1.type == "identifier" }.map { local_name(_1) } }
    end

    # `a = 1` and `a, b = 1, 2` are different SyntaxTree nodes. A var_spec with
    # a type and no value takes that type's Go zero value.
    def assignment(node)
      targets = side(node, %w[left name])
      sources = side(node, %w[right value])
      return zero_valued(node, targets) if sources.empty?

      if targets.one?
        Assign(target(targets.first), visit(sources.first))
      else
        MAssign(MLHS(targets.map { target(_1) }, false), MRHS(sources.map { visit(_1) }))
      end
    end

    # The left of an assignment is a field, not an expression. Ruby has no
    # pointers, so a `*x` target is just x.
    def target(node)
      case node.type
      when "unary_expression" then target(field(node, "operand"))
      when "parenthesized_expression" then target(named(node).first)
      when "index_expression" then ARefField(visit(field(node, "operand")), visit(field(node, "index")))
      when "selector_expression"
        Field(visit(field(node, "operand")), Period("."), Ident(text(field(node, "field"))))
      else VarField(Ident(local_name(node)))
      end
    end

    def zero_valued(node, targets)
      type = field(node, "type")
      raise Unsupported, "assignment with no value: #{text(node).strip}" if type.nil?

      targets.map { Local(local_name(_1), zero(type)) }
    end

    def zero(type)
      case text(type)
      when INTEGER_TYPES then Int("0")
      when FLOAT_TYPES then FloatLiteral("0.0")
      when "string" then Str("")
      when "bool" then Keyword(:false)
      else Keyword(:nil)
      end
    end

    # A field may hold one node or an expression_list of them.
    def side(node, names)
      names.filter_map { field(node, _1) }
           .flat_map { _1.type == "expression_list" ? elements(_1) : [_1] }
    end

    def elements(list) = list.children.select(&:named?)

    def values(node)
      named(node).flat_map do |child|
        child.type == "expression_list" ? elements(child).map { visit(_1) } : [visit(child)]
      end
    end

    def if_statement(node)
      built = IfNode(visit(field(node, "condition")),
                     StatementList(statements(field(node, "consequence"))),
                     alternative(field(node, "alternative")))
      init = field(node, "initializer")
      init ? [visit(init), built].flatten : built
    end

    # `else if` arrives as an if_statement in the alternative slot, which is an
    # Elsif rather than an Else wrapping a nested if.
    def alternative(node)
      return nil if node.nil?

      if node.type == "if_statement"
        Elsif(visit(field(node, "condition")),
              StatementList(statements(field(node, "consequence"))),
              alternative(field(node, "alternative")))
      else
        Else(Kw("else"), StatementList(statements(node)))
      end
    end

    def for_statement(node)
      body = statements(field(node, "body"))
      clause = named(node).find { %w[for_clause range_clause].include?(_1.type) }

      case clause&.type
      when "range_clause" then range_loop(clause, body)
      when "for_clause" then counted_loop(clause, body)
      else condition_loop(node, body)
      end
    end

    # Go 1.22 ranges over an integer as well as over a collection. `each` is
    # wrong for the integer case -- Ruby has no Integer#each -- so a numeric
    # bound becomes `times`.
    def range_loop(clause, body)
      vars = side(clause, %w[left]).map { local_name(_1) }
      right = field(clause, "right")
      iterator = right.type == "int_literal" ? :times : :each
      MethodAddBlock(send_node(visit(right), iterator), Block(vars, body: body))
    end

    # `for i := 0; i < n; i++` is a range in Ruby. Anything else keeps its
    # initialiser as a statement and becomes a while.
    def counted_loop(clause, body)
      init = field(clause, "initializer")
      cond = field(clause, "condition")
      update = field(clause, "update")

      if (counter = counted_range(init, cond, update))
        MethodAddBlock(send_node(counter[:range], :each), Block([counter[:name]], body: body))
      else
        rest = body + Array(update && visit(update))
        [init && visit(init), WhileNode(cond ? visit(cond) : Keyword(:true), StatementList(rest))].flatten.compact
      end
    end

    def counted_range(init, cond, update)
      return nil unless init&.type == "short_var_declaration" && cond&.type == "binary_expression"
      return nil unless %w[inc_statement].include?(update&.type)

      names = side(init, %w[left]).map { text(_1) }
      start = side(init, %w[right])
      return nil unless names.one? && start.one?

      name = names.first
      return nil unless text(field(cond, "left")) == name && text(field(cond, "operator")) == "<"
      return nil unless text(named(update).first) == name

      # Parenthesised, because a range is a looser binding than the `.each`
      # that follows it: `0...n.each do |i|` parses as `0...(n.each { })`, so
      # the loop silently became a range whose end was the block's value. It
      # parsed and rubocop passed it -- only emitting Go back out showed it.
      range = Paren(LParen("("),
                    RangeNode(visit(start.first), Op("..."), visit(field(cond, "right"))))

      { name: local_for(name), range: range }
    end

    def condition_loop(node, body)
      cond = named(node).find { !%w[block comment].include?(_1.type) }
      cond ? WhileNode(visit(cond), StatementList(body)) : MethodAddBlock(send_node(nil, :loop), Block([], body: body))
    end

    # `defer f()` and `go f()` have no Ruby statement. Both keep their Go name
    # and take the call as a block, which reads as the Go intent and is valid
    # Ruby.
    def deferred(node)
      name = node.type.split("_").first
      inner = named(node).first
      literal = inner.type == "call_expression" ? field(inner, "function") : nil

      # `go func(id int) { ... }(i)` is a closure launched with an argument.
      # The closure's parameters become the block's and the Go call's arguments
      # stay a call ON it, so it reads `go do |id| ... end.(i)` -- the shape the
      # Go has, rather than a lambda wrapped and immediately invoked.
      if literal&.type == "func_literal"
        launched = MethodAddBlock(CallNode(nil, nil, Ident(name), Args([])),
                                  Block(parameters(literal), body: statements(field(literal, "body"))))
        CallNode(launched, Period("."), :call, ArgParen(Args(arguments(inner))))
      else
        MethodAddBlock(send_node(nil, name), Block([], body: [visit(inner)]))
      end
    end

    def call(node)
      fn = field(node, "function")
      args = arguments(node)

      if fn.type == "selector_expression"
        send_node(visit(field(fn, "operand")), text(field(fn, "field")), args: args)
      elsif fn.type == "func_literal"
        # `func(id int) { ... }(i)` -- a closure invoked where it is written.
        send_node(func_literal(fn), :call, args: args)
      else
        send_node(nil, text(fn), args: args)
      end
    end

    def selector(node)
      send_node(visit(field(node, "operand")), text(field(node, "field")))
    end

    def arguments(node)
      list = field(node, "arguments")
      return [] if list.nil?

      list.children.select(&:named?).map { visit(_1) }
    end

    # A Go conversion is a type assertion, not a call. `[]byte(s)` is the one
    # with a Ruby equivalent; the rest keep the Go type name as the call.
    def conversion(node)
      type = text(field(node, "type"))
      operand = visit(field(node, "operand"))

      case type
      when "[]byte" then send_node(operand, :bytes)
      when "string" then send_node(operand, :to_s)
      else send_node(nil, type, args: [operand])
      end
    end

    def composite(node)
      type = field(node, "type")
      body = field(node, "body")
      entries = body ? named(body) : []
      keyed = entries.any? { _1.type == "keyed_element" }

      case type&.type
      when "map_type" then HashLiteral(LBrace("{"), entries.map { assoc(_1) })
      when "struct_type" then anonymous_struct(type, entries)
      when "type_identifier", "qualified_type"
        struct_literal(type, entries, keyed)
      else
        keyed ? HashLiteral(LBrace("{"), entries.map { assoc(_1) }) : array_of(entries)
      end
    end

    # `struct{ a, b int }{1, 2}` has no name to declare a class under, so this
    # one stays an inline Struct.
    def anonymous_struct(type, entries)
      members = struct_members(type).map { |member, note| annotate(Sym(member), note) }
      members << Kwargs(keyword_init: Keyword(:true)) unless members.empty?
      inline = send_node(ConstPath("Struct"), :new, args: members)

      send_node(inline, :new, args: entries.map { visit(literal_body(_1)) })
    end

    # `point{1, 2}` is positional, `point{X: 1}` is by field name.
    def struct_literal(type, entries, keyed)
      name = ConstPath(constant_name(text(type).split(".").last))
      return send_node(name, :new, args: [Kwargs(keyed_pairs(entries))]) if keyed

      send_node(name, :new, args: entries.map { visit(literal_body(_1)) })
    end

    def keyed_pairs(entries)
      entries.to_h { |e| [text(literal_body(field(e, "key"))), visit(literal_body(field(e, "value")))] }
    end

    def array_of(entries) = ArrayLiteral(LBracket("["), Args(entries.map { visit(literal_body(_1)) }))

    # A nested `{...}` with no type of its own, as in [][]int{{1, 2}}.
    def composite_body(node)
      entries = named(node)
      return HashLiteral(LBrace("{"), entries.map { assoc(_1) }) if entries.any? { _1.type == "keyed_element" }

      array_of(entries)
    end

    def assoc(entry)
      Assoc(visit(literal_body(field(entry, "key"))), visit(literal_body(field(entry, "value"))))
    end

    # literal_element wraps the value it holds.
    def literal_body(node) = node.type == "literal_element" ? named(node).first : node

    def slice(node)
      from = field(node, "start")
      to = field(node, "end")
      operand = visit(field(node, "operand"))
      # `x[:]` is the whole slice, and a bare `...` is not a valid index.
      return operand if from.nil? && to.nil?

      ARef(operand, RangeNode(from && visit(from), Op("..."), to && visit(to)))
    end

    def binary(node)
      Binary(visit(field(node, "left")), text(field(node, "operator")).to_sym, visit(field(node, "right")))
    end

    # Ruby has no address-of or dereference; both collapse to the operand.
    def unary(node)
      operand = visit(field(node, "operand"))

      case text(field(node, "operator"))
      when "!" then Not(operand, false)
      when "&", "*" then operand
      # A channel receive, which has no Ruby operator.
      when "<-" then send_node(operand, :receive)
      else Unary(text(field(node, "operator")), operand)
      end
    end

    RAW_ESCAPES = { "\\" => "\\\\", '"' => '\\"', "\n" => '\\n', "\t" => '\\t', "\r" => '\\r' }.freeze

    # tree-sitter splits a string into alternating content and escape_sequence
    # children, so taking only the first `_content` dropped every escape --
    # `"%d = %d\n"` came out without its newline. The delimiters are the
    # unnamed children and are the only ones skipped.
    def string_body(node)
      parts = node.children.reject { %w[" `].include?(text(_1)) }
      return "" if parts.empty?

      raw = parts.map { text(_1) }.join
      # A backtick string is literal text, so every Ruby metacharacter in it
      # has to be escaped. A double-quoted Go string is already escaped the
      # same way Ruby would be, and only needs protecting from interpolation.
      escaped = node.type == "raw_string_literal" ? raw.gsub(/[\\"\n\t\r]/) { RAW_ESCAPES[_1] } : raw
      escaped.gsub(/#(?=[{@$])/, '\\#')
    end
  end
end
