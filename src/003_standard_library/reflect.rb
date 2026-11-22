# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/reflect — Package reflect implements run-time reflection, allowing a program to manipulate objects with arbitrary types.
require "reflect"
module Main
  class ReflectUser
    attr_accessor :Name # json:"name"
    attr_accessor :Age # json:"age"
  end

  private

    def self.runReflect
      u = ReflectUser.new(Name: "Nathan", Age: 30)
      v = reflect.ValueOf(u)
      t = reflect.TypeOf(u)
      fmt.Println("kind:", v.Kind(), "type:", t.Name())

      # Iterate fields, reading tags and values.
      (0...t.NumField()).each do |i|
        f = t.Field(i)
        fmt.Printf("  %s (%s) = %v  json=%q\n", f.Name, f.Type, v.Field(i).Interface(), f.Tag.Get("json"))
      end

      # Setting a field requires a pointer and Elem().
      up = ReflectUser.new()
      reflect.ValueOf(up).Elem().FieldByName("Name").SetString("Reflected")
      fmt.Printf("mutated: %+v\n", up)
    end
end
