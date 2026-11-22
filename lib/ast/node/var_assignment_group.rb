module Ast
  module DSL
    # One subject, one statement per inner list of links.
    def VarAssignmentGroup(name, calls: [])
      calls.map { Var(name, calls: _1) }
    end
  end
end
