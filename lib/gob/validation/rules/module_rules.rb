# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      class ModuleRules < Cop
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

            if body.begin_type?
              children = body.children
            else
              children = [body]
            end

            children.each { |child| check_node(child) }
          end

          def check_node(node)
            return if node.nil?

            case node.type
            when :def, :defs, :class, :module, :casgn
              true
            when :lvasgn, :ivasgn, :cvasgn, :gvasgn
              true
            when :send
              name = node.method_name.to_s
              return if ALLOWED_SENDS.include?(name)
              add_offense(node.loc.selector || node.loc.expression, message: format(MSG, name: name))
            when :block
              send_node = node.send_node

              if (
                send_node &&
                ALLOWED_SENDS.include?(send_node.method_name.to_s)
              )
                true
              else
                if send_node
                  name = send_node.method_name.to_s
                else
                  name = "block"
                end

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
