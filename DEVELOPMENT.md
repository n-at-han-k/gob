NOTE: there is old implementation in this still
the official implementation is ./lib/gob/transpilation/runner.rb

# Hacking on Gob (for profit or banter...)

There are several main parts...

1. code parsing
2. input validation
3. transpilation rules
4. code emitting
5. output formatting

## Building the go parser

We try to generate the entire thing from the go ast itself... the scripts to do this are in `./tools`.
This is important to ensure that we cover the entire go specification.


## Testing the compiler

We have a `./test/cases` directory which contains "golden" examples of `.gob` and `.go` files.
We generate `.gob.out` files and diff those against the `.go` files.


```sh
bin/transpilation-check
```

## Writing transpilation rules

Rules shold only extract `captures` and compose `constructors`.
The idea of the `Syntax::Go::DSL` helpers is that they are the abstraction above the basic nodes.
Logic shold be in helpers not in rules.

Use this command to see what must be converted and what it must be converted into.

```
bin/examine-source-and-target-trees
```

Utilize `./tools/print-examples.rb` and `./bin/examine-source-and-target-trees`



---
Ruby pattern matching (case/in, =>, and rightward assignment) lets you unpack, validate, and branch on nested data structures cleanly. See Advanced Pattern Matching Techniques in Ruby 3.x for deeper examples. [1] (https://docs.ruby-lang.org/en/3.4/syntax/pattern_matching_rdoc.html), [2] (https://www.youtube.com/watch?v=O_fqvOPJs7s&t=20), [3] (https://delias.info/posts/ruby-pattern-matching-techniques/)

Pin Operator (^)

• Match against an existing local variable instead of reassigning it.
• Pin outer variables or expressions (like ^(expected_id)) inside array or hash patterns.
• Useful for checking equality between two fields in the same payload, such as { user_id:, actor_id: ^user_id }.

Find Patterns (*)

• Match sub-sequences anywhere inside an array using leading and trailing splats: [*prefix, target, *suffix].
• Capture surrounding elements cleanly without manual index slicing.
• Combine with type or hash patterns, such as [*_, { status: "failed", reason: }, *].

As Patterns (=>)

• Bind a matched sub-structure to a variable while continuing to inspect its internals.
• Works inside arrays and hashes: { payload: { id: } => full_payload }.
• Avoids repeating verbose nested structures when you need both the whole object and specific fields.

Guard Clauses (if / unless)

• Attach arbitrary boolean conditions after a pattern: in [x, y] if x < y.
• Runs only after the structural and value pattern succeeds.
• Keeps complex predicates out of deep pattern expressions.

Custom Objects (deconstruct & deconstruct_keys)

• Define deconstruct on a class to support array patterns (in [a, b]).
• Define deconstruct_keys(keys) to support hash patterns (in { id:, status: }).
• Data and Struct classes support destructuring out of the box, while custom classes can return only requested keys to avoid unnecessary work.

One-Liners & Gotchas

• expr in pattern returns true or false without raising NoMatchingPatternError.
• expr => pattern destructures and binds variables, raising NoMatchingPatternError on mismatch.
• Hash patterns match subsets of keys by default; add **nil to forbid extra keys.
• Do not mix when and in inside the same case statement. [1] (https://gorails.com/episodes/ruby-pattern-matching), [2] (https://www.youtube.com/watch?v=O_fqvOPJs7s&t=20)

Ruby does not allow variable bindings inside alternative (|) patterns because it cannot guarantee which branch matched or that every branch binds the same variables with the same types. Because of this restriction, handling optional nested structures requires specific workarounds.

Why | Fails With Bindings

• Writing in { user: { name: } | nil } raises a SyntaxError (illegal variable in alternative pattern).
• Alternative patterns (|) only work when matching literals, types, or pinned variables without capturing new local variables—such as in { status: "active" | "pending" }.

Workaround 1: Split Into Multiple in Clauses

The cleanest and most idiomatic approach is to separate the present and missing/nil cases into distinct in branches.
ruby
case payload
in { user: { name:, role: } }
  "#{name} (#{role})"
in { user: nil } | {}
  "Anonymous"
end
Use code with caution.
• Note that {} matches any hash because Ruby hash patterns check subsets by default, so put the more specific { user: { ... } } branch first.

Workaround 2: Use **rest to Capture Optional Keys

If a nested key might be omitted entirely rather than explicitly nil, capture the remaining keys in a hash and inspect them separately.
ruby
case payload
in { id:, **rest }
  user_name = rest.dig(:user, :name) || "Anonymous"
end
Use code with caution.
• This avoids deep branching when you have several independent optional fields in the same payload.

Workaround 3: Guard Clauses With dig

When a nested path is optional and you don't need to unpack multiple inner keys, use a guard clause instead of structural destructuring.
ruby
case payload
in { id: } if payload.dig(:meta, :retries).to_i > 3
  # handle retry limit
end
Use code with caution.

Workaround 4: Alternative Patterns Without Bindings

If you only need to validate the shape or value of a nested field without binding a variable, | works fine inside nested hashes and arrays.
ruby
case event
in { type: "payment", meta: { provider: "stripe" | "adyen" } | nil }
  # valid payment event with known provider or no meta
end
Use code with caution.
If you share the shape of the payload you are matching against (for example, JSON API responses or event objects), I can show you the cleanest pattern structure for it.

