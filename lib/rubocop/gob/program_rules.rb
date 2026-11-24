# frozen_string_literal: true

module RuboCop
  module Cop
    module Gob
      class ProgramRules < Base
        MSG = "Disallowed top-level statement: `%<name>s`"

        ALLOWED_SENDS = %w[
          require
          private
          public
          protected
          define_const
          define_var
        ].freeze

        def on_new_investigation
          return unless processed_source.ast

          body = processed_source.ast
          # root is usually :begin or a single node
          children = body.begin_type? ? body.children : [body]
          children.each { |child| check_node(child) }
        end

        private

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
