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
        hash = { "type" => node.class.name.split("::").last }
        node.deconstruct_keys(nil).each do |key, value|
          next if key == :location
          next if key == :comments && (value.nil? || value.empty?)

          hash[key.to_s] = visit(value)
        end
        hash
      end
    end
  end
end
