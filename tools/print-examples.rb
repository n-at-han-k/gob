#!/usr/bin/env ruby
#
# print-examples.rb
# Copyright (C) 2026 nathan <nathan@elitedesk>
#
# Distributed under terms of the MIT license.
#
require "syntax_tree"

Dir.glob("**/examples/*.rb").each do |filename|
  File.read(filename).then do |content|
    puts SyntaxTree.parse(content).construct_keys
  end
end

