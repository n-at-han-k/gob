# frozen_string_literal: true

module SyntaxTree
  module Go
    class JSONVisitor < BasicVisitor
      def visit(node)
        case node
        when SyntaxTree::Go::Node
          visit_node(node)
        when Array
          node.map { |child| visit(child) }
        when Hash
          node.transform_keys(&:to_s).transform_values { |v| visit(v) }
        when Symbol
          node.to_s
        when String, Integer, Float, TrueClass, FalseClass, NilClass
          node
        else
          node.to_s
        end
      end

      private

        def visit_node(node)
          { "type" => node.class.name.split("::").last }.tap do |hash|
            node.semantic_fields.each do |key, value, _role|
              hash[key.to_s] = visit(value)
            end
          end
        end
    end
  end
end
