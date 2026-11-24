# frozen_string_literal: true

module RuboCop
  module Cop
    module Gob
      class ModuleRules < Base
        MSG = "Disallowed module-level statement: `%<name>s`"

        ALLOWED_SENDS = %w[
          require
          define_const
          const
          define_var
          var
          attr_accessor
          private
          public
          protected
          module_function
          include
          extend
          prepend
        ].freeze

        def on_module(node)
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
          when :def, :defs, :class, :module, :casgn
            true
          when :lvasgn, :ivasgn, :cvasgn, :gvasgn
            # variable assignments at module scope
            true
          when :send
            name = node.method_name.to_s
            return if ALLOWED_SENDS.include?(name)

            add_offense(node.loc.selector || node.loc.expression, message: format(MSG, name: name))
          when :block
            # allow block-form calls? e.g. describe blocks not expected; be strict
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
