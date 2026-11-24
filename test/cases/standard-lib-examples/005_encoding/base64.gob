require "encoding/base64"
require "fmt"
require "log"

module Main

    # ()
    def runBase64
      src = "hello base64+/=?".bytes
      std = base64.StdEncoding.EncodeToString(src)
      fmt.Println("std:", std)
      url = base64.URLEncoding.EncodeToString(src)
      fmt.Println("url:", url)
      fmt.Println("raw:", base64.RawURLEncoding.EncodeToString(src))
      back, err = base64.StdEncoding.DecodeString(std)

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("decoded: %s\n", back)
    end
end
