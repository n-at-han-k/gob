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
    end
  end
end
