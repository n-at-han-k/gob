require "encoding/asn1"
require "fmt"
require "log"

module Main
  class Person
    attr_accessor :Name
    attr_accessor :Age
  end


    # ()
    def runASN1
      p = Person.new(Name: "Nathan", Age: 30)
      der, err = asn1.Marshal(p)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("DER (%d bytes): %x\n", len(der), der)
      back = nil
      _, err = asn1.Unmarshal(der, back)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("parsed: %+v\n", back)
    end
end
