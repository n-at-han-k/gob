# frozen_string_literal: true

module Gob
  module Go
    class Printer
      def self.print(node)
        new.print(node)
      end

      def print(node)
        out = +""
        emit(node, out)
        out << "\n" unless out.end_with?("\n")
        out
      end

      private

      def emit(node, out, indent: 0)
        case node
        when SyntaxTree::Go::File then emit_file(node, out)
        when SyntaxTree::Go::GenDecl then emit_gen_decl(node, out, indent: indent)
        when SyntaxTree::Go::ImportSpec then emit_import_spec(node, out)
        when SyntaxTree::Go::FuncDecl then emit_func_decl(node, out, indent: indent)
        when SyntaxTree::Go::FuncType then emit_func_type(node, out)
        when SyntaxTree::Go::FieldList then emit_field_list(node, out)
        when SyntaxTree::Go::Field then emit_field(node, out)
        when SyntaxTree::Go::TypeSpec then emit_type_spec(node, out, indent: indent)
        when SyntaxTree::Go::StructType then emit_struct_type(node, out, indent: indent)
        when SyntaxTree::Go::BlockStmt then emit_block_stmt(node, out, indent: indent)
        when SyntaxTree::Go::ExprStmt then emit(node.x, out, indent: indent)
        when SyntaxTree::Go::ReturnStmt then emit_return_stmt(node, out, indent: indent)
        when SyntaxTree::Go::AssignStmt then emit_assign_stmt(node, out, indent: indent)
        when SyntaxTree::Go::DeclStmt then emit(node.decl, out, indent: indent)
        when SyntaxTree::Go::CallExpr then emit_call_expr(node, out)
        when SyntaxTree::Go::SelectorExpr then emit_selector_expr(node, out)
        when SyntaxTree::Go::Ident then out << node.name.to_s
        when SyntaxTree::Go::BasicLit then out << node.value.to_s
        when SyntaxTree::Go::BinaryExpr then emit_binary_expr(node, out)
        when SyntaxTree::Go::UnaryExpr then emit_unary_expr(node, out)
        when SyntaxTree::Go::ParenExpr then emit_paren_expr(node, out)
        when SyntaxTree::Go::CompositeLit then emit_composite_lit(node, out)
        when SyntaxTree::Go::KeyValueExpr then emit_key_value_expr(node, out)
        when SyntaxTree::Go::IndexExpr then emit_index_expr(node, out)
        when SyntaxTree::Go::StarExpr then out << "*"; emit(node.x, out)
        when SyntaxTree::Go::ArrayType then emit_array_type(node, out)
        when SyntaxTree::Go::MapType then emit_map_type(node, out)
        when SyntaxTree::Go::FuncLit then emit_func_lit(node, out, indent: indent)
        when SyntaxTree::Go::TypeAssertExpr then emit_type_assert(node, out)
        when SyntaxTree::Go::IfStmt then emit_if_stmt(node, out, indent: indent)
        when SyntaxTree::Go::ForStmt then emit_for_stmt(node, out, indent: indent)
        when SyntaxTree::Go::RangeStmt then emit_range_stmt(node, out, indent: indent)
        when SyntaxTree::Go::SwitchStmt then emit_switch_stmt(node, out, indent: indent)
        when SyntaxTree::Go::CaseClause then emit_case_clause(node, out, indent: indent)
        when SyntaxTree::Go::BranchStmt then emit_branch_stmt(node, out, indent: indent)
        when SyntaxTree::Go::IncDecStmt then emit(node.x, out); out << node.tok.to_s
        when SyntaxTree::Go::DeferStmt then out << "defer "; emit(node.call, out)
        when SyntaxTree::Go::GoStmt then out << "go "; emit(node.call, out)
        when SyntaxTree::Go::SendStmt then emit(node.chan, out); out << " <- "; emit(node.value, out)
        when SyntaxTree::Go::LabeledStmt then out << node.label.name.to_s << ":\n"; emit(node.stmt, out, indent: indent)
        when SyntaxTree::Go::EmptyStmt then nil
        when SyntaxTree::Go::CommentGroup then emit_comment_group(node, out, indent: indent)
        when SyntaxTree::Go::Comment then emit_comment(node, out, indent: indent)
        when nil then out << "nil"
        else
          out << "/* unsupported: #{node.class} */"
        end
      end

      def tabs(indent)
        "\t" * indent
      end

      def emit_file(node, out)
        out << "package "
        emit(node.name, out)
        out << "\n"

        node.decls.each do |decl|
          out << "\n"
          emit(decl, out, indent: 0)
          out << "\n" unless out.end_with?("\n")
        end
      end

      def emit_gen_decl(node, out, indent: 0)
        out << tabs(indent) << node.tok.to_s
        if node.specs.length == 1 && node.lparen.nil?
          out << " "
          emit(node.specs.first, out)
        else
          out << " (\n"
          node.specs.each do |spec|
            out << tabs(indent + 1)
            emit(spec, out)
            out << "\n"
          end
          out << tabs(indent) << ")"
        end
      end

      def emit_import_spec(node, out)
        if node.name
          emit(node.name, out)
          out << " "
        end
        emit(node.path, out)
      end

      def emit_type_spec(node, out, indent: 0)
        emit(node.name, out)
        out << " "
        emit(node.type, out, indent: indent)
      end

      def emit_struct_type(node, out, indent: 0)
        out << "struct {"
        fields = node.fields&.list || []
        if fields.empty?
          out << "}"
          return
        end
        out << "\n"
        fields.each do |f|
          out << tabs(indent + 1)
          emit_field(f, out)
          out << "\n"
        end
        out << tabs(indent) << "}"
      end

      def emit_func_decl(node, out, indent: 0)
        out << tabs(indent) << "func "
        if node.recv
          emit(node.recv, out)
          out << " "
        end
        emit(node.name, out)
        emit(node.type.params, out) if node.type&.params
        if node.type&.results
          out << " "
          emit(node.type.results, out)
        end
        if node.body
          out << " "
          emit(node.body, out, indent: indent)
        end
      end

      def emit_func_type(node, out)
        out << "func"
        emit(node.params, out) if node.params
        if node.results
          out << " "
          emit(node.results, out)
        end
      end

      def emit_field_list(node, out)
        out << "("
        node.list.each_with_index do |field, i|
          out << ", " if i > 0
          emit_field(field, out)
        end
        out << ")"
      end

      def emit_field(node, out)
        if node.names && !node.names.empty?
          node.names.each_with_index do |name, i|
            out << ", " if i > 0
            emit(name, out)
          end
          out << " " if node.type
        end
        emit(node.type, out) if node.type
        if node.tag
          out << " "
          emit(node.tag, out)
        end
      end

      def emit_block_stmt(node, out, indent: 0)
        out << "{\n"
        node.list.each do |stmt|
          out << tabs(indent + 1)
          emit(stmt, out, indent: indent + 1)
          out << "\n" unless out.end_with?("\n")
        end
        out << tabs(indent) << "}"
      end

      def emit_return_stmt(node, out, indent: 0)
        out << "return"
        unless node.results.empty?
          out << " "
          node.results.each_with_index do |r, i|
            out << ", " if i > 0
            emit(r, out)
          end
        end
      end

      def emit_assign_stmt(node, out, indent: 0)
        node.lhs.each_with_index { |n, i| out << ", " if i > 0; emit(n, out) }
        out << " #{node.tok} "
        node.rhs.each_with_index { |n, i| out << ", " if i > 0; emit(n, out) }
      end

      def emit_call_expr(node, out)
        emit(node.fun, out)
        out << "("
        node.args.each_with_index do |arg, i|
          out << ", " if i > 0
          emit(arg, out)
        end
        if node.ellipsis
          out << "..."
        end
        out << ")"
      end

      def emit_selector_expr(node, out)
        emit(node.x, out)
        out << "."
        emit(node.sel, out)
      end

      def emit_binary_expr(node, out)
        emit(node.x, out)
        out << " " << node.op.to_s << " "
        emit(node.y, out)
      end

      def emit_unary_expr(node, out)
        out << node.op.to_s
        emit(node.x, out)
      end

      def emit_paren_expr(node, out)
        out << "("
        emit(node.x, out)
        out << ")"
      end

      def emit_composite_lit(node, out)
        emit(node.type, out) if node.type
        out << "{"
        node.elts.each_with_index do |elt, i|
          out << ", " if i > 0
          emit(elt, out)
        end
        out << "}"
      end

      def emit_key_value_expr(node, out)
        emit(node.key, out)
        out << ": "
        emit(node.value, out)
      end

      def emit_index_expr(node, out)
        emit(node.x, out)
        out << "["
        emit(node.index, out)
        out << "]"
      end

      def emit_array_type(node, out)
        out << "["
        emit(node.len, out) if node.len
        out << "]"
        emit(node.elt, out)
      end

      def emit_map_type(node, out)
        out << "map["
        emit(node.key, out)
        out << "]"
        emit(node.value, out)
      end

      def emit_func_lit(node, out, indent: 0)
        emit(node.type, out)
        out << " "
        emit(node.body, out, indent: indent)
      end

      def emit_type_assert(node, out)
        emit(node.x, out)
        out << ".("
        if node.type
          emit(node.type, out)
        else
          out << "type"
        end
        out << ")"
      end

      def emit_if_stmt(node, out, indent: 0)
        out << "if "
        if node.init
          emit(node.init, out)
          out << "; "
        end
        emit(node.cond, out)
        out << " "
        emit(node.body, out, indent: indent)
        if node.else_
          out << " else "
          if node.else_.is_a?(SyntaxTree::Go::IfStmt)
            emit(node.else_, out, indent: indent)
          else
            emit(node.else_, out, indent: indent)
          end
        end
      end

      def emit_for_stmt(node, out, indent: 0)
        out << "for "
        if node.init || node.post
          emit(node.init, out) if node.init
          out << "; "
          emit(node.cond, out) if node.cond
          out << "; "
          emit(node.post, out) if node.post
          out << " "
        elsif node.cond
          emit(node.cond, out)
          out << " "
        end
        emit(node.body, out, indent: indent)
      end

      def emit_range_stmt(node, out, indent: 0)
        out << "for "
        if node.key
          emit(node.key, out)
          if node.value
            out << ", "
            emit(node.value, out)
          end
          out << " #{node.tok} "
        end
        out << "range "
        emit(node.x, out)
        out << " "
        emit(node.body, out, indent: indent)
      end

      def emit_switch_stmt(node, out, indent: 0)
        out << "switch "
        if node.init
          emit(node.init, out)
          out << "; "
        end
        if node.tag
          emit(node.tag, out)
          out << " "
        end
        emit(node.body, out, indent: indent)
      end

      def emit_case_clause(node, out, indent: 0)
        if node.list.empty?
          out << tabs(indent) << "default:\n"
        else
          out << tabs(indent) << "case "
          node.list.each_with_index { |n, i| out << ", " if i > 0; emit(n, out) }
          out << ":\n"
        end
        node.body.each do |stmt|
          out << tabs(indent + 1)
          emit(stmt, out, indent: indent + 1)
          out << "\n" unless out.end_with?("\n")
        end
      end

      def emit_branch_stmt(node, out, indent: 0)
        out << node.tok.to_s
        if node.label
          out << " "
          emit(node.label, out)
        end
      end

      def emit_comment(node, out, indent: 0)
        out << tabs(indent) << node.text.to_s
      end

      def emit_comment_group(node, out, indent: 0)
        node.list.each do |c|
          emit(c, out, indent: indent)
          out << "\n" unless out.end_with?("\n")
        end
      end
    end
  end
end
