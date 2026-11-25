#!/usr/bin/env ruby
#
# test.rb
# Copyright (C) 2026 nathan <nathan@elitedesk>
#
# Distributed under terms of the MIT license.
#
@arr = []

state = State.new

Tree.parse("...").then do |tree|
  state = State.new

  Context.new(tree.root).match_each_child do |ctx|
    ctx.before do
    end

    ctx.iterate do |node|
      # we match a module and...
    end

    ctx.after do
    end
  end
end

high_level_tree = Context.new(node).match_each_child do |ctx, old, new|
  case tree
  in {}
  in Module => node
    Package()
    ctx.descend(node.code_block)
  in Function => node
    @arr << Fuction(node)
    ctx.descend(node.code_block)
  else
    raise
  end
end

high_level_tree => {modules:, functions: }


case tree
in {}
in {}
in {} => node
  Fuction(node)
else
  raise
end

def Function(node)
  §
end
