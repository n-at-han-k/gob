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

        private

          # [1, 2, 3]
          # Array[int].new(1, 2, 3)
          # { "one" => 1 }
          # Hash[string, int].new("one" => 1)
          # ---
          def rule(node)
            return if @ancestors&.[](0...-1)&.any? do |ancestor|
              ancestor.is_a?(SyntaxTree::ArrayLiteral) || ancestor.is_a?(SyntaxTree::HashLiteral)
            end

            case node
            in SyntaxTree::ArrayLiteral[contents: SyntaxTree::Args[parts: parts]]
              literal(node, "Array", common_type(parts.map { |part| type_of(part) }), ARRAY_MSG, ARRAY_UNKNOWN_MSG)

            in SyntaxTree::HashLiteral[assocs: assocs]
              keys = assocs.map { |assoc| type_of(assoc.key) }
              values = assocs.map { |assoc| type_of(assoc.value) }
              key_type = common_type(keys)
              value_type = common_type(values)
              literal(node, "Hash", key_type && value_type && [key_type, value_type], HASH_MSG, HASH_UNKNOWN_MSG)

            else
              nil
            end
          end

          def literal(node, constructor, type, message, unknown_message)
            if type
              replacement = "#{constructor}[#{Array(type).join(", ")}].new(#{contents(node)})"
              add_offense(range(node.location), message: format(message, type: Array(type).join(", "), key: type[0], value: type[1])) do |corrector|
                corrector.replace(range(node.location), replacement)
              end
            else
              add_offense(range(node.location), message: unknown_message)
            end
          end

          def contents(node)
            source(node.location)[1...-1].strip
          end

          def common_type(types)
            return nil if types.empty? || types.any?(&:nil?)

            types.uniq.length == 1 ? types.first : nil
          end

          def type_of(node)
            case node
            in SyntaxTree::Int
              "int"
            in SyntaxTree::FloatLiteral
              "float64"
            in SyntaxTree::StringLiteral
              "string"
            in SyntaxTree::XStringLiteral
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
              element = common_type(parts.map { |part| type_of(part) })
              element && "Array[#{element}]"
            in SyntaxTree::HashLiteral[assocs: assocs]
              key = common_type(assocs.map { |assoc| type_of(assoc.key) })
              value = common_type(assocs.map { |assoc| type_of(assoc.value) })
              key && value && "Hash[#{key}, #{value}]"
            in SyntaxTree::CallNode[
              receiver: receiver,
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Ident[value: "new"]
            ]
              source(receiver.location)
            in SyntaxTree::CallNode[
              receiver: nil,
              operator: nil,
              message: { value: name },
              arguments: SyntaxTree::ArgParen[arguments: SyntaxTree::Args[parts: [_]]]
            ] if %w[int int8 int16 int32 int64 uint uint8 uint16 uint32 uint64 uintptr float32 float64 string bool byte rune].include?(name)
              name
            else
              nil
            end
          end
      end
    end
  end
end
