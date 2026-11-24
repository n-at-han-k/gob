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
bin/test-transpilation
```

## Writing transpilation rules

Rules shold only extract `captures` and compose `constructors`.
The idea of the `Syntax::Go::DSL` helpers is that they are the abstraction above the basic nodes.
Logic shold be in helpers not in rules.

Use this command to see what must be converted and what it must be converted into.

```
bin/examine-source-and-target-trees
```
