# 3 things

* definition -> what exists before operations and logic?
* logic      -> how are the operations controlled?
* messages   -> what do we do with the computer?

These are `top-level`... there is nothing else.
Simply identify them... and process them.

Defining the language is defining what patterns are allowed to exist.

We denote and identify patterns starting with keywords.
Keywords may be in any position of the pattern. They are simply the identifier.

## Ruby

- [-] __ENCODING__
- [-] __LINE__
- [-] __FILE__
- [-] BEGIN
- [-] END
- [-] alias
- [-] and
- [D] begin
- [-] break
- [L] case
- [D] class
- [D] def
- [-] defined?
- [-] do
- [-] else
- [-] elsif
- [-] end
- [-] ensure
- [-] false
- [L] for
- [L] if
- [-] in
- [D] module
- [-] next
- [-] nil
- [-] not
- [-] or
- [-] redo
- [-] rescue
- [-] retry
- [-] return
- [-] self
- [-] super
- [-] then
- [-] true
- [-] undef
- [L] unless
- [-] until
- [-] when
- [L] while
- [-] yield

### Definitions

begin
class
def
module

### Logic

case
for
if
unless
while

### Statements

Statements are largely irrelevant initially because they are defined by syntax.

---
# Context & Matching

Each `level` is a `context` and is recursive.
Matches that aren't recursive aren't contexts.

In a sense the "recursion" isn't real. It's the fact that each `context` is of the same type.
In this sense you can imagine that each `context` is a `node` that defines the `tree`.
By this definition the `context` is where the tree is mutated.

We're able to mutate the tree here because we've found the very thing that joins the 2 trees together.
