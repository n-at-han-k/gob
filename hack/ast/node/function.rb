module Ast
  module DSL
    # One definition, carrying Go's two axes: whose method it is and who may
    # call it.
    #
    #   owner:      :instance -> `def name`, :class -> `def self.name`
    #   visibility: :private  -> a `private` of its own, directly above
    #
    # The visibility goes INLINE, on the definition -- `private def self.name`.
    # Every definition carries its own, public ones included, because at this
    # point the emitter is looking at one Go function and knows nothing about
    # where it will land in the body.
    #
    # That is deliberately not the final shape. It is what Transpile/VisibilitySections
    # consumes: having both markers present on every definition is what lets
    # the cop reorder the body, strip the markers and leave a single `private`
    # section. Emitting the section here instead would mean deciding order
    # here, one function at a time, which is exactly what cannot be done.
    def Function(name, params: [], body: [], visibility: :public, owner: :instance)
      definition =
        if owner == :class
          DefNode(VarRef(Kw("self")), Period("."), Ident(name.to_s), ParamSlot(params), Body(body))
        else
          Def(name, params: params, body: body)
        end

      [Visibility(visibility, definition)]
    end

    # `private def name` -- the modifier applied to the definition itself.
    def Visibility(name, definition) = Command(Ident(name.to_s), Args([definition]), nil)

    # An empty parameter list is a bare Params; a populated one is parenthesised.
    def ParamSlot(names) = names.empty? ? ParamList([]) : Paren(LParen("("), ParamList(names))
  end
end
