package main

import (
	"fmt"
	"reflect"
)

type ReflectUser struct {
	Name any
	Age  any
}

func runReflect() {
	u := ReflectUser.new(map[any]any{Name: "Nathan", Age: 30})
	v := reflect.ValueOf(u)
	t := reflect.TypeOf(u)
	fmt.Println("kind:", v.Kind(), "type:", t.Name())
	for i := range t.NumField() {
		f := t.Field(i)
		fmt.Printf("  %s (%s) = %v  json=%q\n", f.Name, f.Type, v.Field(i).Interface(), f.Tag.Get("json"))
	}
	up := ReflectUser.new()
	reflect.ValueOf(up).Elem().FieldByName("Name").SetString("Reflected")
	fmt.Printf("mutated: %+v\n", up)
}
