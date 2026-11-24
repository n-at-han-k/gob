#!/usr/bin/env ruby
# frozen_string_literal: true

paths = []

if ARGV.empty?
  paths << "test/cases/standard-lib-examples"
else
  paths.concat(ARGV)
end

ENV["GOB_CASE_PATHS"] = paths.join("\n")
ARGV.clear

require_relative "../test/transpile_check_test"
