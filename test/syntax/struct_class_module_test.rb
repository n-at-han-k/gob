# frozen_string_literal: true

require_relative "support/syntax_test"

class StructClassModuleTest < SyntaxTest
  def test_struct_new_with_tags
    go = transpile(<<~GOB)
      module Main
        var Person = Struct.new(Name: string, Age: int)
      end
    GOB
    assert_includes(go, "type Person struct {")
    assert_includes(go, "Name string")
  end

  def test_class_field_tags
    go = transpile(<<~GOB)
      module Main
        class Person
          # `json:"name"`
          attr_accessor :Name, string
        end
      end
    GOB
    assert_includes(go, '`json:"name"`')
  end

  def test_struct_new_field_tags
    go = transpile(<<~GOB)
      module Main
        var Person = Struct.new(
          # `json:"name"`
          Name: string
        )
      end
    GOB
    assert_includes(go, '`json:"name"`')
  end

  def test_module_as_interface
    go = transpile(<<~GOB)
      module Main
        module Greeter
          def Greet # (string) -> string
          end
        end
      end
    GOB
    assert_includes(go, "type Greeter interface {")
    assert_includes(go, "Greet(string) string")
  end

  def test_module_as_interface_multiple_methods
    go = transpile(<<~GOB)
      module Main
        module Vfs
          def Exists(filePath) # (string) -> bool
          end

          def Stat(filePath) # (string) -> (FileStat, error)
          end
        end
      end
    GOB
    assert_includes(go, "type Vfs interface {")
    assert_includes(go, "Exists(filePath string) bool")
    assert_includes(go, "Stat(filePath string) (FileStat, error)")
  end

  def test_class_include_module
    go = transpile(<<~GOB)
      module Main
        module Greeter
          def Greet # (string) -> string
          end
        end

        class Hello
          include Greeter

          def Greet(name) # (string) -> string
            return name
          end
        end
      end
    GOB
    assert_includes(go, "type Greeter interface {")
    assert_includes(go, "func (self *Hello) Greet(name string) string {")
    refute_includes(go, "var _ Greeter = (*Hello)(nil)")
  end

  def test_class_include_multiple_modules
    go = transpile(<<~GOB)
      module Main
        module Greeter
          def Greet # (string) -> string
          end
        end

        module Named
          def Name # () -> string
          end
        end

        class Hello
          include Greeter
          include Named

          def Greet(name) # (string) -> string
            return name
          end

          def Name # () -> string
            return "hello"
          end
        end
      end
    GOB
    assert_includes(go, "type Greeter interface {")
    assert_includes(go, "type Named interface {")
    assert_includes(go, "func (self *Hello) Greet(name string) string {")
    assert_includes(go, "func (self *Hello) Name() string {")
  end
end
