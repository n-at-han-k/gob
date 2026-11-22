require "fmt"
module Main
  private

    # HPKE (Hybrid Public Key Encryption, RFC 9180) combines a KEM, a KDF,
    # and an AEAD to encrypt to a recipient's public key.
    #
    # The full API (crypto/hpke) is fairly ceremonial — sender.Seal,
    # receiver.Open, encapsulation keys, exporters — and is used mainly
    # inside protocols like ECH and MLS. A minimal sketch:
    #
    # suite := hpke.Suite{
    #     KEM:  hpke.DHKEM_X25519_HKDF_SHA256,
    #     KDF:  hpke.KDF_HKDF_SHA256,
    #     AEAD: hpke.AEAD_ChaCha20Poly1305,
    # }
    # pub, priv, _ := suite.KEM.GenerateKeyPair(rand.Reader)
    #
    # enc, sender, _ := suite.NewSender(pub, []byte("app info"))
    # ct := sender.Seal(nil, []byte("associated"), []byte("secret"))
    #
    # receiver, _ := suite.NewReceiver(priv, []byte("app info"), enc)
    # pt, _ := receiver.Open(nil, []byte("associated"), ct)
    #
    # See https://pkg.go.dev/crypto/hpke for the concrete types.
    def self.runHPKE
      fmt.Println("crypto/hpke is used by TLS ECH, MLS, and similar protocols")
      fmt.Println("see comments above for a Sender/Receiver skeleton")
    end
end
