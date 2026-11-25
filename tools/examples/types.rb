#!/usr/bin/env ruby
#
# types.rb
# Copyright (C) 2026 nathan <nathan@elitedesk>
#
# Distributed under terms of the MIT license.
#


# []string
Array[string]

# [][]string
Array[Array[string]]

# []byte
Array[byte]

# [5]int
Array[int, 5]

# [9]string (from your example)
Array[string, 9]

# [][8]string (from your example)
Array[Array[string, 8]]

# *[2][3]int (Pointer to a 2x3 fixed array)
Pointer[Array[Array[int, 3], 2]]


# []byte("Hello") (Type conversion)
Array[byte].new("Hello")

# []elliptic.Curve{elliptic.P224(), elliptic.P225()}
Array[elliptic.Curve].new(
  elliptic.P224(),
  elliptic.P225(),
)

# []string{"h2", "h1"}
Array[string].new(
  "h2",
  "h1",
)

# [5]int{2, 3, 5, 7, 11}
Array[int, 5].new(
  2, 3, 5, 7, 11
)

# map[string]int
Hash[string, int]

# map[string]string (from your example)
Hash[string, string]

# map[string]func(){}
Hash[string, Proc].new()

# map[string]func(int) bool{}
Hash[string, Proc[int, [bool]]].new()

# map[netip.Addr]int{}
Hash[netip.Addr, int].new()

# map[string]string{"item": "one"} (Symbol key shorthand)
Hash[string, string].new(
  item: "one",
)

# map[string]string{"item": "one"} (String key)
Hash[string, string].new(
  "item" => "one", # Note: In Ruby, "item": "one" also works as valid syntax!
)

# []map[string]bool{}
Array[Hash[string, bool]].new()

# map[string]map[string]int
Hash[string, Hash[string, int]]

