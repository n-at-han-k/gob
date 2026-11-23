# frozen_string_literal: true

module SyntaxTree
  module Go
    class PrettyPrintVisitor < BasicVisitor
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
        when Symbol, String, Integer, Float, TrueClass, FalseClass, NilClass
          q.text(node.inspect)
        else
          node.pretty_print(q)
        end
      end

      private

      def visit_node(node)
        pairs =
          node.deconstruct_keys(nil).filter_map do |key, value|
            next if key == :location && value == SyntaxTree::Location.default
            next if key == :comments && (value.nil? || value.empty?)

            [key, value]
          end

        if pairs.empty?
          q.text(node.class.name)
          return
        end

        q.group(2, "#{node.class.name}(", ")") do
          q.breakable("")
          q.seplist(pairs) do |(key, value)|
            q.group do
              q.text("#{key}: ")
              visit(value)
            end
          end
        end
      end

      def visit_array(values)
        if values.empty?
          q.text("[]")
          return
        end

        q.group(2, "[", "]") do
          q.breakable("")
          q.seplist(values) { |value| visit(value) }
        end
      end

      def visit_hash(hash)
        if hash.empty?
          q.text("{}")
          return
        end

        q.group(2, "{", "}") do
          q.breakable("")
          q.seplist(hash.to_a) do |(key, value)|
            q.group do
              q.text(key.inspect)
              q.text(" => ")
              visit(value)
            end
          end
        end
      end
    end
  end
end
