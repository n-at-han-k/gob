package main

import (
	"fmt"     
	"reflect" 
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

	for i := 0; i < t.NumField(); i++ {
		f := t.Field(i)
		fmt.Printf("  %s (%s) = %v  json=%q\n",
			f.Name, f.Type, v.Field(i).Interface(), f.Tag.Get("json"))
	}

	up := &reflectUser{}
	reflect.ValueOf(up).Elem().FieldByName("Name").SetString("Reflected")
	fmt.Printf("mutated: %+v\n", up)
}
