module Ast
  module DSL
    # lambda { ... } -- a call with a block, not a -> literal, so its empty
    # argument list is a bare Args rather than an ArgParen.
    def Lambda(vars = [], body: [])
      MethodAddBlock(CallNode(nil, nil, Ident("lambda"), Args([])), Block(vars, body: body))
    end
  end
end
