module SyntaxTree::Go
  class Format < Visitor
    attr_reader(:q)
    def initialize(q)
      @q = q
    end
    def visit_comment(node)
      @q.text(node.class(name))
    end
    def visit_comment_group(node)
      @q.text(node.class(name))
    end
    def visit_field(node)
      @q.text(node.class(name))
    end
    def visit_field_list(node)
      @q.text(node.class(name))
    end
    def visit_bad_expr(node)
      @q.text(node.class(name))
    end
    def visit_ident(node)
      @q.text(node.class(name))
    end
    def visit_ellipsis(node)
      @q.text(node.class(name))
    end
    def visit_basic_lit(node)
      @q.text(node.class(name))
    end
    def visit_func_lit(node)
      @q.text(node.class(name))
    end
    def visit_composite_lit(node)
      @q.text(node.class(name))
    end
    def visit_paren_expr(node)
      @q.text(node.class(name))
    end
    def visit_selector_expr(node)
      @q.text(node.class(name))
    end
    def visit_index_expr(node)
      @q.text(node.class(name))
    end
    def visit_index_list_expr(node)
      @q.text(node.class(name))
    end
    def visit_slice_expr(node)
      @q.text(node.class(name))
    end
    def visit_type_assert_expr(node)
      @q.text(node.class(name))
    end
    def visit_call_expr(node)
      @q.text(node.class(name))
    end
    def visit_star_expr(node)
      @q.text(node.class(name))
    end
    def visit_unary_expr(node)
      @q.text(node.class(name))
    end
    def visit_binary_expr(node)
      @q.text(node.class(name))
    end
    def visit_key_value_expr(node)
      @q.text(node.class(name))
    end
    def visit_array_type(node)
      @q.text(node.class(name))
    end
    def visit_struct_type(node)
      @q.text(node.class(name))
    end
    def visit_func_type(node)
      @q.text(node.class(name))
    end
    def visit_interface_type(node)
      @q.text(node.class(name))
    end
    def visit_map_type(node)
      @q.text(node.class(name))
    end
    def visit_chan_type(node)
      @q.text(node.class(name))
    end
    def visit_bad_stmt(node)
      @q.text(node.class(name))
    end
    def visit_decl_stmt(node)
      @q.text(node.class(name))
    end
    def visit_empty_stmt(node)
      @q.text(node.class(name))
    end
    def visit_labeled_stmt(node)
      @q.text(node.class(name))
    end
    def visit_expr_stmt(node)
      @q.text(node.class(name))
    end
    def visit_send_stmt(node)
      @q.text(node.class(name))
    end
    def visit_inc_dec_stmt(node)
      @q.text(node.class(name))
    end
    def visit_assign_stmt(node)
      @q.text(node.class(name))
    end
    def visit_go_stmt(node)
      @q.text(node.class(name))
    end
    def visit_defer_stmt(node)
      @q.text(node.class(name))
    end
    def visit_return_stmt(node)
      @q.text(node.class(name))
    end
    def visit_branch_stmt(node)
      @q.text(node.class(name))
    end
    def visit_block_stmt(node)
      @q.text(node.class(name))
    end
    def visit_if_stmt(node)
      @q.text(node.class(name))
    end
    def visit_case_clause(node)
      @q.text(node.class(name))
    end
    def visit_switch_stmt(node)
      @q.text(node.class(name))
    end
    def visit_type_switch_stmt(node)
      @q.text(node.class(name))
    end
    def visit_comm_clause(node)
      @q.text(node.class(name))
    end
    def visit_select_stmt(node)
      @q.text(node.class(name))
    end
    def visit_for_stmt(node)
      @q.text(node.class(name))
    end
    def visit_range_stmt(node)
      @q.text(node.class(name))
    end
    def visit_import_spec(node)
      @q.text(node.class(name))
    end
    def visit_value_spec(node)
      @q.text(node.class(name))
    end
    def visit_type_spec(node)
      @q.text(node.class(name))
    end
    def visit_bad_decl(node)
      @q.text(node.class(name))
    end
    def visit_gen_decl(node)
      @q.text(node.class(name))
    end
    def visit_func_decl(node)
      @q.text(node.class(name))
    end
    def visit_file(node)
      @q.text(node.class(name))
    end
    def visit_package(node)
      @q.text(node.class(name))
    end
  end
end
