module SyntaxTree::Go
  class Visitor < SyntaxTree::BasicVisitor
    def visit(node)
      case node
      when Array
        node.map { |child| visit(child) }
      when nil
        nil
      else
        node.accept(self)
      end
    end

    alias visit_comment visit_child_nodes
    alias visit_comment_group visit_child_nodes
    alias visit_field visit_child_nodes
    alias visit_field_list visit_child_nodes
    alias visit_bad_expr visit_child_nodes
    alias visit_ident visit_child_nodes
    alias visit_ellipsis visit_child_nodes
    alias visit_basic_lit visit_child_nodes
    alias visit_func_lit visit_child_nodes
    alias visit_composite_lit visit_child_nodes
    alias visit_paren_expr visit_child_nodes
    alias visit_selector_expr visit_child_nodes
    alias visit_index_expr visit_child_nodes
    alias visit_index_list_expr visit_child_nodes
    alias visit_slice_expr visit_child_nodes
    alias visit_type_assert_expr visit_child_nodes
    alias visit_call_expr visit_child_nodes
    alias visit_star_expr visit_child_nodes
    alias visit_unary_expr visit_child_nodes
    alias visit_binary_expr visit_child_nodes
    alias visit_key_value_expr visit_child_nodes
    alias visit_array_type visit_child_nodes
    alias visit_struct_type visit_child_nodes
    alias visit_func_type visit_child_nodes
    alias visit_interface_type visit_child_nodes
    alias visit_map_type visit_child_nodes
    alias visit_chan_type visit_child_nodes
    alias visit_bad_stmt visit_child_nodes
    alias visit_decl_stmt visit_child_nodes
    alias visit_empty_stmt visit_child_nodes
    alias visit_labeled_stmt visit_child_nodes
    alias visit_expr_stmt visit_child_nodes
    alias visit_send_stmt visit_child_nodes
    alias visit_inc_dec_stmt visit_child_nodes
    alias visit_assign_stmt visit_child_nodes
    alias visit_go_stmt visit_child_nodes
    alias visit_defer_stmt visit_child_nodes
    alias visit_return_stmt visit_child_nodes
    alias visit_branch_stmt visit_child_nodes
    alias visit_block_stmt visit_child_nodes
    alias visit_if_stmt visit_child_nodes
    alias visit_case_clause visit_child_nodes
    alias visit_switch_stmt visit_child_nodes
    alias visit_type_switch_stmt visit_child_nodes
    alias visit_comm_clause visit_child_nodes
    alias visit_select_stmt visit_child_nodes
    alias visit_for_stmt visit_child_nodes
    alias visit_range_stmt visit_child_nodes
    alias visit_import_spec visit_child_nodes
    alias visit_value_spec visit_child_nodes
    alias visit_type_spec visit_child_nodes
    alias visit_bad_decl visit_child_nodes
    alias visit_gen_decl visit_child_nodes
    alias visit_func_decl visit_child_nodes
    alias visit_file visit_child_nodes
    alias visit_package visit_child_nodes
  end
end
