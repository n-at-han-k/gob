package main

import (
	"fmt"     
	"syscall" 
)

func runSyscall() {
	fmt.Println("pid:  ", syscall.Getpid())
	fmt.Println("ppid: ", syscall.Getppid())
	fmt.Println("uid:  ", syscall.Getuid())
	fmt.Println("gid:  ", syscall.Getgid())

	old := syscall.Umask(0)
	syscall.Umask(old)
	fmt.Printf("umask: %03o\n", old)
}
