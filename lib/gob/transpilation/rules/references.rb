# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module References
        module_function

        def register(matcher)
          matcher.rule(:variable) do |node|
            node => SyntaxTree::VarRef[value: SyntaxTree::Ident[value: name]]

            Ident(name)
          end

          matcher.rule(:constant) do |node|
            node => SyntaxTree::VarRef[value: SyntaxTree::Const[value: name]]

            Ident(Gob::Transpilation::Rules.const_go_name(name))
          end

          matcher.rule(:instance_variable) do |node|
            node => SyntaxTree::VarRef[value: SyntaxTree::IVar[value: name]]

            UnaryExpr(:&, Ident(name.delete_prefix("@")))
          end

          matcher.rule(:class_variable) do |node|
            node => SyntaxTree::VarRef[value: SyntaxTree::CVar[value: name]]

            Ident(name.delete_prefix("@@"))
          end

          matcher.rule(:global_variable) do |node|
            node => SyntaxTree::VarRef[value: SyntaxTree::GVar[value: name]]

            Ident(name.delete_prefix("$"))
          end

          matcher.rule(:bare_identifier) do |node|
            node => SyntaxTree::VCall[value: SyntaxTree::Ident[value: name]]

            Ident(name)
          end

          matcher.rule(:const_path_ref) do |node|
            node => SyntaxTree::ConstPathRef[
              constant: SyntaxTree::Const[value: name]
            ]

            case node.parent
            in SyntaxTree::VarRef[value: SyntaxTree::Const[value: package_name]]
              SelectorExpr(Ident(package_name), name)
            in SyntaxTree::ConstPathRef
              SelectorExpr(visit(node.parent), name)
            else
              Matcher::MISS
            end
          end
        end
      end
    end
  end
end
