require "errors"
require "fmt"
require "os"
module Main
  class NotFoundError
    attr_accessor :key

    def Error
      return fmt.Sprintf("key %q not found", this.key)
    end
  end

  private

    def self.lookup(k)
      return NotFoundError.new(key: k)
    end

    def self.runErrors
      sentinel = errors.New("sentinel failure")
      fmt.Println(sentinel)
      wrapped = fmt.Errorf("during startup: %w", sentinel)
      fmt.Println(wrapped)
      fmt.Println("Is sentinel:", errors.Is(wrapped, sentinel))
      err = lookup("missing")
      nf = nil

      if errors.As(err, nf)
        fmt.Println("typed error, key:", nf.key)
      end

      _, err = os.Open("/definitely/not/there")
      fmt.Println("file missing:", errors.Is(err, os.ErrNotExist))
    end
end
