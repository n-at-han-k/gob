module Ast
  module DSL
    # type: :int, default: 2 -- trailing keyword arguments to a call.
    def Kwargs(pairs)
      BareAssocHash(pairs.map { |key, value| Assoc(Label("#{key}:"), node(value)) })
    end
  end
end
