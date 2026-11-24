require "bytes"
require "crypto/mlkem"
require "fmt"
require "log"

module Main

    # ()
    def runMLKEM
      dk, err = mlkem.GenerateKey768()

      if err != nil
        log.Fatal(err)
      end

      ek = dk.EncapsulationKey()
      shared1, ct = ek.Encapsulate()
      shared2, err = dk.Decapsulate(ct)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("shared secret (%d B): %x\n", len(shared1), shared1)
      fmt.Println("both sides agree:", bytes.Equal(shared1, shared2))
    end
end
