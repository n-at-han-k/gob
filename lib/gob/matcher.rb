# frozen_string_literal: true

module Gob
  class Matcher
    MISS = :__gob_miss__
    DROP = :__gob_drop__

    Rule = Struct.new(:name, :block)

    def initialize
      @rules = []
    end

    def rule(name, &block)
      @rules << Rule.new(name, block)
      self
    end

    def match(node, context)
      @rules.each do |rule|
        result = context.instance_exec(node, &rule.block)
        next if result == MISS

        return nil if result == DROP
        return result
      rescue NoMatchingPatternError
        next
      end
      MISS
    end

    attr_reader :rules
  end
end
