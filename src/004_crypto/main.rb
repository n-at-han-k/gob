# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
# https://pkg.go.dev/sort — Package sort provides primitives for sorting slices and user-defined collections.
require "sort"
module Main
  # Each *.go file in this directory demonstrates one crypto/* subpackage.
  # Run one demo at a time, e.g.:
  #
  # go run . aes
  #
  # or list what's available with `go run .`.
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
