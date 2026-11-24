# frozen_string_literal: true

module SyntaxTree
  module Go
    class MatchVisitor < BasicVisitor
      attr_reader :q

      def initialize(q)
        @q = q
      end

      def visit(node)
        case node
        when SyntaxTree::Go::Node
          visit_node(node)
        when Array
          visit_array(node)
        when Hash
          visit_hash(node)
        when String
          q.text(node.inspect)
        when Symbol
          q.text(node.inspect)
        when NilClass, TrueClass, FalseClass, Integer, Float
          q.text(node.inspect)
        else
          node.pretty_print(q)
        end
      end

      private

        def visit_node(node)
          pairs =
            node.semantic_fields.map do |key, value, role|
              value = value.to_sym if role == :token && !value.nil?
              [key, value]
            end

          return q.text(node.class.name) if pairs.empty?

          q.group do
            q.text(node.class.name)
            q.text("[")

            q.indent do
              q.breakable("")

              q.seplist(pairs) do |(key, value)|
                q.group do
                  q.text(key.to_s)
                  q.text(": ")
                  visit(value)
                end
              end
            end

            q.breakable("")
            q.text("]")
          end
        end

        def visit_array(values)
          return q.text("[]") if values.empty?

          q.group do
            q.text("[")

            q.indent do
              q.breakable("")
              q.seplist(values) { |value| visit(value) }
            end

            q.breakable("")
            q.text("]")
          end
        end

        def visit_hash(hash)
          return q.text("{}") if hash.empty?

          q.group do
            q.text("{")

            q.indent do
              q.breakable("")

              q.seplist(hash.to_a) do |(key, value)|
                q.group do
                  visit(key)
                  q.text(" => ")
                  visit(value)
                end
              end
            end

            q.breakable("")
            q.text("}")
          end
        end
    end
  end
end
