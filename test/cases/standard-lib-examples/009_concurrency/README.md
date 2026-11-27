# 009_concurrency

Channels, buffering, `select` and closing.

```sh
go run . channels
go run . buffering
go run . select
go run . closing
```

## Spellings

Ruby cannot parse `<-`, so channel operations use method-call syntax on `<<`.

| gob                      | go                      |
| ------------------------ | ----------------------- |
| `Chan[string]`           | `chan string`           |
| `make(Chan[int], 3)`     | `make(chan int, 3)`     |
| `ch.<< v` / `ch.<<(v)`   | `ch <- v`               |
| `ch << v`                | `ch <- v`               |
| `ch ← v`                 | `ch <- v`               |
| `ch.<<`                  | `<-ch`                  |
| `←ch`                    | `<-ch`                  |
| `n, ok = ch.<<`          | `n, ok := <-ch`         |
| `time.After(d).<<`       | `<-time.After(d)`       |
| `close(ch)`              | `close(ch)`             |
| `ch.each do \|v\|`       | `for v := range ch`     |

`Chan[T]` follows `Array[T]` and `Hash[K, V]`.

A `case` with a subject is a `switch`; a `case` with **no** subject is a `select`,
its `when` clauses are comm clauses and its `else` is `default`.

```ruby
case
when msg = fast.<<
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
