require "fmt"
require "os"
require "sort"
module Main
  demos = {
    "crypto" => runCrypto,
    "aes" => runAES,
    "cipher" => runCipher,
    "des" => runDES,
    "dsa" => runDSA,
    "ecdh" => runECDH,
    "ecdsa" => runECDSA,
    "ed25519" => runED25519,
    "elliptic" => runElliptic,
    "fips140" => runFIPS140,
    "hkdf" => runHKDF,
    "hmac" => runHMAC,
    "hpke" => runHPKE,
    "md5" => runMD5,
    "mlkem" => runMLKEM,
    "pbkdf2" => runPBKDF2,
    "rand" => runRand,
    "rc4" => runRC4,
    "rsa" => runRSA,
    "sha1" => runSHA1,
    "sha256" => runSHA256,
    "sha3" => runSHA3,
    "sha512" => runSHA512,
    "subtle" => runSubtle,
    "tls" => runTLS,
    "x509" => runX509
  }
  def main
    if len(os.Args) < 2
      fmt.Println("usage: go run . <package>")
      fmt.Println("available demos:")
      names = make([], 0, len(demos))
      demos.each { |k| names = append(names, k) }
      sort.Strings(names)
      names.each { |_, n| fmt.Println("  ", n) }

      return
    end

    demo, ok = demos[os.Args[1]]

    unless ok
      fmt.Println("unknown demo:", os.Args[1])
      os.Exit(1)
    end

    demo()
  end
end
