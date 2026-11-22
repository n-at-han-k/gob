module Ast
  module DSL
    # A call with no receiver of its own. In a subject's calls: it attaches to
    # that subject; in a body it resolves bare. Its own calls: chain onto it,
    # which is how add_action(x).then do |action| is built.
    def Call(name, args: nil, parens: true, block: nil, calls: [])
      link { |receiver| Chain(send_node(receiver, name, args: args, parens: parens, block: block), calls) }
    end

    def TapBlock(var, body: []) = Call(:tap, block: Block([var], body: body))

    def ThenBlock(var = "action", body: []) = Call(:then, block: Block([var], body: body))
  end
end
