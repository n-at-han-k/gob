require "crypto/pbkdf2"
require "crypto/rand"
require "crypto/sha256"
require "fmt"
require "log"

module Main

    # ()
    def runPBKDF2
      salt = make([], 16)
      rand.Read(salt)
      key, err = pbkdf2.Key(sha256.New, "hunter2", salt, 100_000, 32)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("salt: %x\nkey:  %x\n", salt, key)
    end
end
