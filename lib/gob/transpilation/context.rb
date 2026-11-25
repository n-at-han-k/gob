#!/usr/bin/env ruby
#
# context.rb
# Copyright (C) 2026 nathan <nathan@elitedesk>
#
# Distributed under terms of the MIT license.
#

module Gob
  module Transpilation
    class Context
      attr_reader :node

      def initialize(node)
        @node = node
      end

      def children
        []
      end

      def descend(node)
        # shuld create a enw context object with the
        # same callbacks and run it wiht .match
      end

      def match_each_child(&block)
        yield.then do
          @before_callback.call

          children.each do |node|
            @iterate_callback.call(node)
          end

          @after_callback.call
        end
      end

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
