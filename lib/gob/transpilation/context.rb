#!/usr/bin/env ruby
#
# context.rb
# Copyright (C) 2026 nathan <nathan@elitedesk>
#
# Distributed under terms of the MIT license.
#

module Gob
  module Transpilation
    Hoist = Struct.new(:nodes)

    class Context
      attr_reader :body, :children, :tree, :state

      protected

      attr_reader :before_callback, :after_callback, :iterate_callback

      def inherit_callbacks_from(context)
        @before_callback = context.before_callback
        @after_callback = context.after_callback
        @iterate_callback = context.iterate_callback
      end

      public

      def initialize(body, state: nil)
        @body = body
        @state = state
        @children = []
        @tree = []
      end

      def descend(body)
        child_context = self.class.new(body, state: state)
        child_context.inherit_callbacks_from(self)

        @children << child_context

        child_context
      end

      def match(&block)
        instance_exec(self, &block) if block

        before_callback&.call(self)

        Array(body).each do |node|
          result = iterate_callback&.call(self, node)

          case result
          when Hoist
            result.nodes.each do |hoisted_node|
              hoisted = iterate_callback&.call(self, hoisted_node)
              @tree << hoisted if hoisted
            end
          when nil
            # dropped
          else
            @tree << result
          end
        end

        children.each(&:match)

        after_callback&.call(self)

        self
      end

      alias match_each_child match

      def before(&block)
        @before_callback = block
      end

      def after(&block)
        @after_callback = block
      end

      def iterate(&block)
        @iterate_callback = block
      end
    end
  end
end
