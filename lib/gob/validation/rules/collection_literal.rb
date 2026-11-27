# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      # Gives collection literals an explicit Go element type.
      class CollectionLiteral < Cop
        ARRAY_MSG = "Write `Array[%<type>s].new(...)`, not an untyped array literal"
        HASH_MSG = "Write `Hash[%<key>s, %<value>s].new(...)`, not an untyped hash literal"
        ARRAY_UNKNOWN_MSG = "Write an explicitly typed `Array[Type].new(...)`"
        HASH_UNKNOWN_MSG = "Write an explicitly typed `Hash[Key, Value].new(...)`"

        NUMERIC = %w[
          int int8 int16 int32 int64
          uint uint8 uint16 uint32 uint64 uintptr
          float32 float64 string bool byte rune
        ].freeze

        private

          # [1, 2, 3]
          # Array[int].new(1, 2, 3)
          # { "one" => 1 }
          # Hash[string, int].new("one" => 1)
          # ---
          def rule(node)
            return if typed? || nested? || type_argument?

            case node
            in SyntaxTree::ArrayLiteral[contents: SyntaxTree::Args[parts: parts]]
              literal(node, "Array", common_type(parts.map { |part| type_of(part) }), ARRAY_MSG, ARRAY_UNKNOWN_MSG)

            in SyntaxTree::HashLiteral[assocs: assocs]
              key = common_type(assocs.map { |assoc| type_of(assoc.key) })
              value = common_type(assocs.map { |assoc| type_of(assoc.value) })

              literal(node, "Hash", key && value && [key, value], HASH_MSG, HASH_UNKNOWN_MSG)

            else
              nil
            end
          end

          # The nodes this one sits inside.
          # ---
          def enclosing
            @ancestors[0...-1]
          end

          # A literal inside a constructor is already typed, whether the type
          # is written on the collection itself, as in `Array[int].new(...)`,
          # or carried by the field it is given to, as in
          # `metav1.ObjectMeta.new(Labels: {"app" => "test"})`.
          # ---
          def typed?
            enclosing.any? do |ancestor|
              case ancestor
              in SyntaxTree::CallNode[
                operator: SyntaxTree::Period[value: "."],
                message: SyntaxTree::Ident[value: "new"],
                arguments: SyntaxTree::Node => arguments
              ]
                enclosing.include?(arguments)

              else
                false
              end
            end
          end

          # A literal in a type position is not a collection literal. It is
          # the result list of a func type, as in `Proc[int, [bool, error]]`,
          # where the brackets index a Gob type form rather than build a value.
          # ---
          def type_argument?
            enclosing.any? do |ancestor|
              ancestor in SyntaxTree::ARef[
                collection: SyntaxTree::VarRef[value: SyntaxTree::Const]
              ]
            end
          end

          # An inner literal is reported through the outer one, which carries
          # the element type for both.
          # ---
          def nested?
            enclosing.any? { |ancestor| ancestor in SyntaxTree::ArrayLiteral | SyntaxTree::HashLiteral }
          end

          def literal(node, constructor, type, message, unknown_message)
            case type
            in nil
              add_offense(range(node.location), message: unknown_message)

            in type
              replacement = "#{constructor}[#{Array(type).join(", ")}].new(#{contents(node)})"

              add_offense(range(node.location), message: format(message, type: Array(type).join(", "), key: type[0], value: type[1])) do |corrector|
                corrector.replace(range(node.location), replacement)
              end
            end
          end

          # What the literal holds, without the brackets around it.
          # ---
          def contents(node)
            case node
            in SyntaxTree::ArrayLiteral[contents: SyntaxTree::Args[parts: parts]]
              parts.map { |part| source(part.location) }.join(", ")

            in SyntaxTree::HashLiteral[assocs: assocs]
              assocs.map { |assoc| source(assoc.location) }.join(", ")
            end
          end

          # One type for the whole literal, or none when the elements disagree.
          # ---
          def common_type(types)
            case types
            in [] | [*, nil, *]
              nil

            in [type, *rest]
              rest.all?(type) ? type : nil
            end
          end

          def type_of(node)
            case node
            in SyntaxTree::Int
              "int"

            in SyntaxTree::FloatLiteral
              "float64"

            in SyntaxTree::StringLiteral | SyntaxTree::XStringLiteral
              "string"

            in SyntaxTree::VarRef[value: SyntaxTree::Kw[value: "true" | "false"]]
              "bool"

            in SyntaxTree::VarRef[value: SyntaxTree::Kw[value: "nil"]]
              nil

            in SyntaxTree::Unary[operator: "-", statement: SyntaxTree::Int]
              "int"

            in SyntaxTree::Unary[operator: "-", statement: SyntaxTree::FloatLiteral]
              "float64"

            in SyntaxTree::ArrayLiteral[contents: SyntaxTree::Args[parts: parts]]
              common_type(parts.map { |part| type_of(part) }).then { |element| element && "Array[#{element}]" }

            in SyntaxTree::HashLiteral[assocs: assocs]
              key = common_type(assocs.map { |assoc| type_of(assoc.key) })
              value = common_type(assocs.map { |assoc| type_of(assoc.value) })

              key && value && "Hash[#{key}, #{value}]"

            # person.new(...) is a value of the type that made it.
            # ---
            in SyntaxTree::CallNode[
              receiver: receiver,
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Ident[value: "new"]
            ]
              source(receiver.location)

            # int(x) is a conversion, so the value is that Go type.
            # ---
            in SyntaxTree::CallNode[
              receiver: nil,
              operator: nil,
              message: { value: String => name },
              arguments: SyntaxTree::ArgParen[arguments: SyntaxTree::Args[parts: [_]]]
            ] if NUMERIC.include?(name)
              name

            else
              nil
            end
          end
      end
    end
  end
end
