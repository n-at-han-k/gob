# frozen_string_literal: true

require "syntax_tree"
require_relative "matcher"
require_relative "go/dsl"

module Gob
  class Transpiler
    include Go::DSL

    attr_reader :matcher, :source

    def initialize(matcher: nil)
      @matcher = matcher || Gob.default_matcher
    end

    def transpile(source)
      @source = source
      program = SyntaxTree.parse(source)
      visit(program)
    end

    def visit(node)
      return nil if node.nil?
      return node.map { |n| visit(n) }.compact.flatten if node.is_a?(Array)

      result = matcher.match(node, self)
      return result unless result.nil?

      raise UnsupportedNode, "No rule matched #{node.class}: #{node.inspect[0, 200]}"
    end

    def visit_all(nodes)
      Array(nodes).flat_map { |n| Array(visit(n)) }.compact
    end

    def visit_params(node)
      params = node
      params = params.contents if params.is_a?(SyntaxTree::Paren)
      return [] unless params.is_a?(SyntaxTree::Params)

      requireds = params.requireds || []
      requireds.map do |p|
        name = p.is_a?(SyntaxTree::Ident) ? p.value : p.to_s
        SyntaxTree::Go::Field.new(names: [ident(name)], type: nil)
      end
    end

    def visit_args(node)
      return [] if node.nil?

      args_node = node
      args_node = args_node.arguments if args_node.is_a?(SyntaxTree::ArgParen)
      parts = args_node.is_a?(SyntaxTree::Args) ? args_node.parts : Array(args_node)
      visit_all(parts)
    end

    def string_value(node)
      case node
      when SyntaxTree::StringLiteral
        node.parts.map { |p| p.is_a?(SyntaxTree::TStringContent) ? p.value : "" }.join
      else
        nil
      end
    end

    def const_name(node)
      case node
      when SyntaxTree::ConstRef then node.constant.value
      when SyntaxTree::ConstPathRef
        left = const_name(node.parent)
        right = node.constant.value
        left ? "#{left}::#{right}" : right
      when SyntaxTree::Const then node.value
      when SyntaxTree::VarRef then node.value.value
      else
        nil
      end
    end

    class UnsupportedNode < StandardError; end
  end
end
