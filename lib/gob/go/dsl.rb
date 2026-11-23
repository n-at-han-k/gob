# frozen_string_literal: true

require "json"
require "syntax_tree/go"

module Gob
  module Go
    module DSL
      RUBY_KEYWORDS = %w[
        __FILE__ __LINE__ alias and begin BEGIN break case class def defined?
        do else elsif end END ensure false for if in module next nil not or
        redo rescue retry return self super then true undef unless until when
        while yield
      ].to_set

      SCHEMA_PATH = ::File.expand_path("../../syntax_tree/go/schema.json", __dir__)

      module_function

      def schema
        @schema ||= JSON.parse(::File.read(SCHEMA_PATH))
      end

      def snake(name)
        name.gsub(/([a-z0-9])([A-Z])/, "\\1_\\2").downcase
      end

      def fname(name)
        n = snake(name)
        RUBY_KEYWORDS.include?(n) ? "#{n}_" : n
      end

      def build_node(type, kwargs)
        klass = SyntaxTree::Go.const_get(type)
        node_def = schema.find { |n| n["name"] == type }
        args = {}
        node_def["fields"].each do |f|
          key = fname(f["name"]).to_sym
          args[key] = kwargs[key] if kwargs.key?(key)
        end
        klass.new(**args)
      end

      # Generic node builder: node("FuncDecl", name: ..., type: ..., body: ...)
      def node(type, **kwargs)
        build_node(type, kwargs)
      end

      # --- Convenience constructors ---

      def ident(name, name_pos: nil)
        SyntaxTree::Go::Ident.new(name_pos: name_pos, name: name.to_s, obj: nil)
      end

      def basic_lit(kind:, value:, value_pos: nil, value_end: nil)
        SyntaxTree::Go::BasicLit.new(value_pos: value_pos, value_end: value_end, kind: kind.to_s, value: value.to_s)
      end

      def str_lit(value)
        # value is raw string content (as in source), not interpreted
        basic_lit(kind: "STRING", value: "\"#{value}\"")
      end

      def int_lit(value)
        basic_lit(kind: "INT", value: value.to_s)
      end

      def float_lit(value)
        basic_lit(kind: "FLOAT", value: value.to_s)
      end

      def field_list(list: [], opening: nil, closing: nil)
        SyntaxTree::Go::FieldList.new(opening: opening, list: list, closing: closing)
      end

      def block_stmt(list: [], lbrace: nil, rbrace: nil)
        SyntaxTree::Go::BlockStmt.new(lbrace: lbrace, list: Array(list), rbrace: rbrace)
      end

      def expr_stmt(x:)
        SyntaxTree::Go::ExprStmt.new(x: x)
      end

      def return_stmt(results: [], return_: nil)
        SyntaxTree::Go::ReturnStmt.new(return_: return_, results: Array(results))
      end

      def call_expr(fun:, args: [], lparen: nil, ellipsis: nil, rparen: nil)
        SyntaxTree::Go::CallExpr.new(fun: fun, lparen: lparen, args: Array(args), ellipsis: ellipsis, rparen: rparen)
      end

      def selector_expr(x:, sel:)
        sel_node = sel.is_a?(String) || sel.is_a?(Symbol) ? ident(sel) : sel
        SyntaxTree::Go::SelectorExpr.new(x: x, sel: sel_node)
      end

      def func_type(params: nil, results: nil, func: nil, type_params: nil)
        params_node =
          case params
          when Array then field_list(list: params)
          when nil then field_list
          else params
          end
        SyntaxTree::Go::FuncType.new(func: func, type_params: type_params, params: params_node, results: results)
      end

      def func_decl(name:, body: nil, params: nil, results: nil, recv: nil, doc: nil, type_params: nil)
        name_node = name.is_a?(String) || name.is_a?(Symbol) ? ident(name) : name
        body_node = body.is_a?(Array) ? block_stmt(list: body) : body
        SyntaxTree::Go::FuncDecl.new(
          doc: doc, recv: recv, name: name_node,
          type: func_type(params: params, results: results, type_params: type_params),
          body: body_node
        )
      end

      def gen_decl(tok:, specs: [], doc: nil, lparen: nil, rparen: nil, tok_pos: nil)
        SyntaxTree::Go::GenDecl.new(doc: doc, tok_pos: tok_pos, tok: tok.to_s, lparen: lparen, specs: Array(specs), rparen: rparen)
      end

      def import_spec(path:, name: nil, doc: nil, comment: nil, end_pos: nil)
        path_node = path.is_a?(String) ? str_lit(path) : path
        name_node = name.is_a?(String) || name.is_a?(Symbol) ? ident(name) : name
        SyntaxTree::Go::ImportSpec.new(doc: doc, name: name_node, path: path_node, comment: comment, end_pos: end_pos)
      end

      def file_node(name:, decls: [], doc: nil, package: nil, imports: [], comments: [])
        name_node = name.is_a?(String) || name.is_a?(Symbol) ? ident(name) : name
        SyntaxTree::Go::File.new(
          doc: doc, package: package, name: name_node, decls: Array(decls),
          file_start: nil, file_end: nil, scope: nil, imports: Array(imports),
          unresolved: [], comments: Array(comments), go_version: nil
        )
      end
    end
  end
end
