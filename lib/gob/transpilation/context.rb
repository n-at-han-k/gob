#!/usr/bin/env ruby
#
# context.rb
# Copyright (C) 2026 nathan <nathan@elitedesk>
#
# Distributed under terms of the MIT license.
#

module Gob
  module Transpilation
    Hoist = Struct.new(:nodes)

    class Context
      class << self
        def global
          @global
        end

        def global=(value)
          @global = value
        end

        def global_for(path)
          dir = File.dirname(path)
          self.global = {
            uppercase_constants: Dir.glob(File.join(dir, "*.gob")).flat_map { |file|
              SyntaxTree.parse(File.read(file)).statements.body.flat_map { |node|
                case node
                in SyntaxTree::ModuleDeclaration[bodystmt: SyntaxTree::BodyStmt[statements: SyntaxTree::Statements[body: body]]]
                  body
                else
                  [node]
                end
              }.filter_map { |node|
                case node
                in SyntaxTree::Assign[target: SyntaxTree::VarField[value: SyntaxTree::Const[value: name]]]
                  name
                else
                  nil
                end
              }
            }.uniq
          }
        end
      end

      attr_reader :body, :children, :tree, :state

      protected

      attr_reader :before_callback, :after_callback, :iterate_callback

      def inherit_callbacks_from(context)
        @before_callback = context.before_callback
        @after_callback = context.after_callback
        @iterate_callback = context.iterate_callback
      end

      public

      def initialize(body, state: nil)
        @body = body
        @state = state || { declared: [], uppercase_constants: [], comments: [] }
        if (global = self.class.global) && (constants = global[:uppercase_constants])
          @state[:uppercase_constants] = (@state[:uppercase_constants] | constants)
        end
        @children = []
        @tree = []
      end

      # A nested scope sees what was declared above it, and nothing it declares
      # escapes back out. `inherit: false` opens a fresh declaration scope.
      def descend(body, inherit: true, declared: [])
        child_state =
          if inherit
            { **state, declared: state.fetch(:declared).dup.concat(declared), uppercase_constants: state.fetch(:uppercase_constants, []).dup, comments: [] }
          else
            { declared: declared.dup, uppercase_constants: [], comments: [] }
          end

        child_context = self.class.new(body, state: child_state)
        child_context.inherit_callbacks_from(self)

        @children << child_context

        child_context
      end

      # Answers with `names` that are not already in scope, without mutating.
      def undeclared(names)
        declared = state.fetch(:declared)
        names.reject { |name| declared.include?(name) }
      end

      # Records `names` and answers with the ones that were not already in scope.
      def declare(names)
        undeclared(names).tap { |fresh| state.fetch(:declared).concat(fresh) }
      end

      def match(&block)
        instance_exec(self, &block) if block

        before_callback&.call(self)

        Array(body).each do |node|
          iterate_callback && instance_exec(self, node, &iterate_callback).then do |result|
            case result
            when Hoist
              result.nodes.each do |hoisted_node|
                hoisted = iterate_callback && instance_exec(self, hoisted_node, &iterate_callback)

                if hoisted
                  @tree << hoisted
                end
              end
            when nil
              # dropped
            else
              @tree << result
            end
          end
        end

        children.each(&:match)

        after_callback&.call(self)

        self
      end

      def before(&block)
        @before_callback = block
      end

      def after(&block)
        @after_callback = block
      end

      def iterate(&block)
        @iterate_callback = block
      end
    end
  end
end
