# 009_concurrency

Channels, buffering, `select` and closing.

```sh
go run . channels
go run . buffering
go run . select
go run . closing
```

## Spellings

Ruby cannot parse `<-`. Receiving is a syntax error outright, and `ch <- v`
parses as the comparison `ch < -v`, so both operators need a spelling of
their own.

| gob                      | go                      |
| ------------------------ | ----------------------- |
| `Chan[string]`           | `chan string`           |
| `make(Chan[int], 3)`     | `make(chan int, 3)`     |
| `ch << v`                | `ch <- v`               |
| `~ch`                    | `<-ch`                  |
| `n, ok = ~ch`            | `n, ok := <-ch`         |
| `~time.After(d)`         | `<-time.After(d)`       |
| `close(ch)`              | `close(ch)`             |
| `ch.each do \|v\|`       | `for v := range ch`     |

`Chan[T]` follows `Array[T]` and `Hash[K, V]`.

`~` is Ruby's unary operator and binds looser than `.`, so it wraps a whole
call expression rather than gluing to its first segment.

A `case` with a subject is a `switch`; a `case` with **no** subject is a `select`,
its `when` clauses are comm clauses and its `else` is `default`.

```ruby
case
when msg = fast.recv
  fmt.Println("got:", msg)
else
  fmt.Println("nothing ready")
end
```

```go
select {
case msg := <-fast:
	fmt.Println("got:", msg)
default:
	fmt.Println("nothing ready")
}
```
