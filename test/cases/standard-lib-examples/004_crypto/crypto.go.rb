# https://pkg.go.dev/crypto — Package crypto collects common cryptographic constants.
require "crypto"
# register MD5 so crypto.MD5.Available() returns true -- imported as _
require "crypto/md5"
# register SHA-1 -- imported as _
require "crypto/sha1"
# imported as _
require "crypto/sha256"
# imported as _
require "crypto/sha512"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
module Main
  private

    # The root crypto package only defines shared types (Hash, PublicKey,
    # Signer, ...). Sub-packages must be blank-imported before their Hash
    # value becomes Available.
    def self.runCrypto
      hashes = [crypto.MD5, crypto.SHA1, crypto.SHA256, crypto.SHA512]

      hashes.each do |_, h|
        fmt.Printf("%-8s size=%d bytes available=%v\n", h, h.Size(), h.Available())
      end
    end
end
