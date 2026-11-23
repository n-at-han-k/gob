package main

import (
	"fmt"     // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"reflect" // https://pkg.go.dev/reflect — Package reflect implements run-time reflection, allowing a program to manipulate objects with arbitrary types.
)

type reflectUser struct {
	Name string `json:"name"`
	Age  int    `json:"age"`
}

func runReflect() {
	u := reflectUser{Name: "Nathan", Age: 30}
	v := reflect.ValueOf(u)
	t := reflect.TypeOf(u)

	fmt.Println("kind:", v.Kind(), "type:", t.Name())

	// Iterate fields, reading tags and values.
	for i := 0; i < t.NumField(); i++ {
		f := t.Field(i)
		fmt.Printf("  %s (%s) = %v  json=%q\n",
			f.Name, f.Type, v.Field(i).Interface(), f.Tag.Get("json"))
	}

	// Setting a field requires a pointer and Elem().
	up := &reflectUser{}
	reflect.ValueOf(up).Elem().FieldByName("Name").SetString("Reflected")
	fmt.Printf("mutated: %+v\n", up)
}
