**The purpose of this library** is STRICTLY `ruby-to-go`... 

**The only reason** any `ast-grep` stuff exists is because we needed to generate `ruby` examples so that there was something to turn into `go`. NEVER consider `go-to-ruby` conversion, we do not care.

**The reason we don't care** about `go-to-ruby` is because the `ruby` can be written in multiple ways to generate precisely the same `go` code.

for example:

```ruby
require "fmt"

def main
  fmt.PrintLn("Hello, gob-head!")
end
```

and

```ruby
require "fmt"

module Main
  def main
    fmt.PrintLn("Hello, gob-head!")
  end
end
```

should both generate

```go
package main

import "fmt"

func main() {
  fmt.PrintLn("Hello, gob-head!")
}
```

with `main` being a special rule.

## Pattern Matching

The ast nodes are for `pattern-matching` the `ruby` source to easily pull out chunks that can be converted to `go`.

```ruby
case SyntaxTree.parse("1 + 1")
program => SyntaxTree::Program[statements: SyntaxTree::Statements[body: [SyntaxTree::Binary => binary]]]
binary
# => (binary (int "1") :+ (int "1"))
```

This is the most powerful tool you will ever use in your life, it enables us to
1. understand parsing logic at a glance.
2. generate code from structured data.

This is just the most beautiful thing, and **vastly** more readable than a spaghetti class.

```ruby
SyntaxTree::Program[
  statements: SyntaxTree::Statements[
    body: [
      SyntaxTree::Binary[
        left: SyntaxTree::Int[value: "1"],
        operator: :+,
        right: SyntaxTree::Int[value: "1"]
      ]
    ]
  ]
]
```

The `syntax_tree` gem even provides the tools to output this.

```
program = SyntaxTree.parse("1 + 1")
puts program.construct_keys
# SyntaxTree::Program[
#   statements: SyntaxTree::Statements[
#     body: [
#       SyntaxTree::Binary[
#         left: SyntaxTree::Int[value: "1"],
#         operator: :+,
#         right: SyntaxTree::Int[value: "1"]
#       ]
#     ]
#   ]
# ]
```

You can run experiments by writing a `ruby` file and running the `syntax_tree` gem cli.

```bash
stree match path/to/file.rb
```

outputs:

```ruby
SyntaxTree::Program[
  statements: SyntaxTree::Statements[
    body: [
      SyntaxTree::Binary[
        left: SyntaxTree::Int[value: "1"],
        operator: :+,
        right: SyntaxTree::Int[value: "1"]
      ]
    ]
  ]
]
```

Or if you want to see the `json` structured data for this.

```bash
stree json path/to/file.rb
```

outputs: 

```json
{
  "type": "program",
  "location": [1, 0, 1, 6],
  "statements": {
    "type": "statements",
    "location": [1, 0, 1, 6],
    "body": [
      {
        "type": "binary",
        "location": [1, 0, 1, 5],
        "left": {
          "type": "int",
          "location": [1, 0, 1, 1],
          "value": "1",
          "comments": []
        },
        "operator": "+",
        "right": {
          "type": "int",
          "location": [1, 4, 1, 5],
          "value": "1",
          "comments": []
        },
        "comments": []
      }
    ],
    "comments": []
  },
  "comments": []
}
```
