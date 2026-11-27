# frozen_string_literal: true

require "syntax_tree"

module Gob
  # SyntaxTree homes a comment on the nearest node beside it and stops at the
  # first one it finds, however coarse. At the edge of an argument list that
  # node is the list itself, so a tag written above the first field or beside
  # the last is left holding onto the list and belongs to no field at all.
  #
  # A list is not a field. Step into it and keep stepping until the comment
  # reaches the field it was written for.
  #
  # Struct.new(
  #   Title: string, # `json:"title"`
  # )
  # ---
  class RubyParser < SyntaxTree::Parser
    def self.parse(source) = new(source).parse

    private

      def nearest_nodes(node, comment)
        preceding, enclosing, following = super

        [ innermost(preceding, :last), enclosing, innermost(following, :first) ]
      end

      # The field at one end of a list, however many lists deep it sits.
      # ---
      def innermost(node, side)
        case node
        in SyntaxTree::Args | SyntaxTree::BareAssocHash
          innermost(node.child_nodes.compact.public_send(side), side)
        else
          node
        end
      end
  end
end
