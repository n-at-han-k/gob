require "syntax_tree"

module Ast
  # Chunk helpers, named like SyntaxTree::DSL's. A subject (Var, Const, Self)
  # takes calls:, a list of links applied left to right. A link (Call, Set,
  # TapBlock, ThenBlock) carries no receiver, so used on its own it renders as
  # a bare statement.
  module DSL
    include SyntaxTree::DSL

    Link = Data.define(:builder) do
      def apply(receiver) = builder.call(receiver)

      # Kernel#format would otherwise shadow this; rendering a bare link means
      # rendering it with no receiver.
      def format(q) = apply(nil).format(q)
    end

    def Str(value) = StringLiteral([TStringContent(value.to_s)], '"')

    def Keyword(value) = VarRef(Kw(value.to_s))

    def Sym(value) = SymbolLiteral(Ident(value.to_s))

    def List(values) = ArrayLiteral(LBracket("["), Args(values))

    def Self(calls: []) = Chain(Keyword(:self), calls)

    def Var(name, calls: [])
      subject = name.is_a?(::String) || name.is_a?(::Symbol) ? VCall(Ident(name.to_s)) : name
      Chain(subject, calls)
    end

    def Const(name, calls: []) = Chain(ConstPath(name), calls)

    def Ivar(name, calls: []) = Chain(VarRef(IVar(name.to_s)), calls)

    # Our own, so either side may be a link.
    def Binary(left, operator, right)
      SyntaxTree::Binary.new(left: node(left), operator: operator, right: node(right),
                             location: SyntaxTree::Location.default)
    end

    def ConstPath(name)
      name.to_s.split("::").then do |parts|
        parts.drop(1).inject(VarRef(const_token(parts.first))) do |parent, part|
          ConstPathRef(parent, const_token(part))
        end
      end
    end

    def Chain(subject, calls) = calls.inject(subject) { |node, link| link.apply(node) }

    def Block(vars = [], body: [])
      BlockNode(Kw("do"), vars.empty? ? nil : BlockVar(ParamList(vars), []), Body(body))
    end

    def Body(statements) = BodyStmt(StatementList(statements), nil, nil, nil, nil)

    def StatementList(statements)
      resolved = statements.flatten.map { node(_1) }
      Statements(resolved.empty? ? [VoidStmt()] : resolved)
    end

    def ParamList(names) = Params(names.map { Ident(_1.to_s) }, [], nil, [], [], nil, nil)

    # endless: an endless def, whose body is a bare Statements rather than a BodyStmt.
    def Def(name, params: [], body: [], endless: false)
      DefNode(nil, nil, Ident(name.to_s),
              params.empty? ? ParamList([]) : Paren(LParen("("), ParamList(params)),
              endless ? StatementList(body) : Body(body))
    end

    private

      def link(&builder) = Link.new(builder)

      # A link in a value position has no receiver of its own.
      def node(value) = value.is_a?(Link) ? value.apply(nil) : value

      # Const() is this module's subject helper, so the bare token is built directly.
      def const_token(value) = SyntaxTree::Const.new(value: value.to_s, location: SyntaxTree::Location.default)

      def send_node(receiver, name, args: nil, parens: true, block: nil)
        call =
          if args.nil?
            receiver ? CallNode(receiver, Period("."), Ident(name.to_s), nil) : VCall(Ident(name.to_s))
          elsif parens
            CallNode(receiver, receiver && Period("."), Ident(name.to_s), ArgParen(Args(args.map { node(_1) })))
          elsif receiver
            CommandCall(receiver, Period("."), Ident(name.to_s), Args(args.map { node(_1) }), nil)
          else
            Command(Ident(name.to_s), Args(args.map { node(_1) }), nil)
          end

        block ? MethodAddBlock(call, block) : call
      end
  end
end

require "ast/node/function"
require "ast/node/local"
require "ast/node/block_pass"
require "ast/node/if"
require "ast/node/call"
require "ast/node/kwargs"
require "ast/node/namespace"
require "ast/node/lambda"
require "ast/node/constant"
require "ast/node/alias_accessor"
require "ast/node/set"
require "ast/node/var_assignment_group"
