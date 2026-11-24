# frozen_string_literal: true

module SyntaxTree
  module Go
    class Node < SyntaxTree::Node
      def pretty_print(q)
        PrettyPrintVisitor.new(q).visit(self)
      end

      def to_json(*opts)
        JSONVisitor.new.visit(self).to_json(*opts)
      end

      def construct_keys
        PrettierPrint.format(+"") { |q| MatchVisitor.new(q).visit(self) }
      end

      def semantic_fields
        self.class::SEMANTIC_FIELDS.map do |name, role|
          [name, public_send(name), role]
        end
      end

      def ===(other)
        return false unless other.is_a?(self.class)

        semantic_fields.all? do |name, value, role|
          semantic_value_equal?(value, other.public_send(name), role: role)
        end
      end

      private

        def semantic_value_equal?(left, right, role: nil)
          if role == :token
            left.to_s == right.to_s
          elsif left.is_a?(Array)
            right.is_a?(Array) && left.length == right.length &&
              left.zip(right).all? do |left_value, right_value|
                semantic_value_equal?(left_value, right_value)
              end
          elsif left.is_a?(SyntaxTree::Go::Node)
            left === right
          else
            left == right
          end
        end
    end
  end
end
