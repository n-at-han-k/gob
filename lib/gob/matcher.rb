# frozen_string_literal: true

module Gob
  class Matcher
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
        return result unless result.nil?
      rescue NoMatchingPatternError
        next
      end
      nil
    end

    attr_reader :rules
  end
end
