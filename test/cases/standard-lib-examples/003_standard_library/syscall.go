package main

import (
	"fmt"     // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"syscall" // https://pkg.go.dev/syscall — Package syscall contains an interface to the low-level operating system primitives.
)

// syscall exposes raw OS primitives. It's frozen — new code should use
// golang.org/x/sys — but reading process metadata is still fine.
func runSyscall() {
	fmt.Println("pid:  ", syscall.Getpid())
	fmt.Println("ppid: ", syscall.Getppid())
	fmt.Println("uid:  ", syscall.Getuid())
	fmt.Println("gid:  ", syscall.Getgid())
	// Umask returns the old value; call it twice to read without changing.
	old := syscall.Umask(0)
	syscall.Umask(old)
	fmt.Printf("umask: %03o\n", old)
}
