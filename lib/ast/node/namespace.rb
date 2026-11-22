module Ast
  module DSL
    # module <name> ... end
    def Namespace(name, body: []) = ModuleDeclaration(ConstRef(const_token(name)), Body(body))
  end
end
