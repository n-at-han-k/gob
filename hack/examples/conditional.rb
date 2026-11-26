#!/usr/bin/env ruby
#
# conditional.rb
# Copyright (C) 2026 nathan <nathan@elitedesk>
#
# Distributed under terms of the MIT license.
#

err = getSomeValue()
if err
  false
end

_, err = getSomeValue()
if err
  false
end

err = getSomeValue()
unless err
  true
end

_, err = getSomeValue()
unless err
  true
end

if err = getSomeValue()
  true
end

if (x, err = getSomeValue())
  true
end

if err == nil
end

if x == true
end

unless x == true
end
