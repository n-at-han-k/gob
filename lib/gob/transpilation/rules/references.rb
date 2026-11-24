# frozen_string_literal: true

module Gob
  module Transpilation
    module Rules
      module References
        module_function

        def register(matcher)
          matcher.rule(:self_reference) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::VarRef)

            node => SyntaxTree::VarRef[value: SyntaxTree::Kw[value: "self"]]

            Ident("self")
          end

          matcher.rule(:variable) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::VarRef)

            node => SyntaxTree::VarRef[value: SyntaxTree::Ident[value: name]]

            Ident(name)
          end

          matcher.rule(:constant) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::VarRef)

            node => SyntaxTree::VarRef[value: SyntaxTree::Const[value: name]]

            Ident(Gob::Transpilation::Rules.const_go_name(name))
          end

          matcher.rule(:self_reference) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::VarRef)

            node => SyntaxTree::VarRef[value: SyntaxTree::Kw[value: "self"]]

            Ident(current_class ? current_class[0].downcase : "self")
          end

          matcher.rule(:instance_variable) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::VarRef)

            node => SyntaxTree::VarRef[value: SyntaxTree::IVar[value: name]]

            name =
              if name == "@self" && current_class
                current_class[0].downcase
              else
                name.delete_prefix("@")
              end

            UnaryExpr(:&, Ident(name))
          end

          matcher.rule(:class_variable) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::VarRef)

            node => SyntaxTree::VarRef[value: SyntaxTree::CVar[value: name]]

            Ident(name.delete_prefix("@@"))
          end

          matcher.rule(:global_variable) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::VarRef)

            node => SyntaxTree::VarRef[value: SyntaxTree::GVar[value: name]]

            Ident(name.delete_prefix("$"))
          end

          matcher.rule(:bare_identifier) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::VCall)

            node => SyntaxTree::VCall[value: SyntaxTree::Ident[value: name]]

            Ident(name)
          end

          matcher.rule(:const_path_ref) do |node|
            next Matcher::MISS unless node.is_a?(SyntaxTree::ConstPathRef)

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
