# frozen_string_literal: true

module RuboCop
  module Cop
    module Gob
      class ClassRules < Base
        MSG = "Disallowed class-level statement: `%<name>s`"

        ALLOWED_SENDS = %w[
          define_const
          const
          define_var
          var
          attr_accessor
          private
          public
          protected
          include
          extend
          prepend
        ].freeze

        def on_class(node)
          check_body(node.body)
        end

        private

        def check_body(body)
          return if body.nil?

          children = body.begin_type? ? body.children : [body]
          children.each { |child| check_node(child) }
        end

        def check_node(node)
          return if node.nil?

          case node.type
          when :def, :class, :module, :casgn
            true
          when :defs
            add_offense(node.loc.keyword || node.loc.name || node.loc.expression, message: "Disallowed `def self.*` in class; Go has no static methods")
          when :lvasgn, :ivasgn, :cvasgn, :gvasgn
            true
          when :send
            name = node.method_name.to_s
            return if ALLOWED_SENDS.include?(name)

            add_offense(node.loc.selector || node.loc.expression, message: format(MSG, name: name))
          when :block
            send_node = node.send_node
            if send_node && ALLOWED_SENDS.include?(send_node.method_name.to_s)
              true
            else
              name = send_node ? send_node.method_name.to_s : "block"
              add_offense(node.loc.expression, message: format(MSG, name: name))
            end
          else
            add_offense(node.loc.expression, message: format(MSG, name: node.type))
          end
        end
      end
    end
  end
end
