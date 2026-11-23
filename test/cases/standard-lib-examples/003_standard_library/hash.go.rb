# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/hash — Package hash provides interfaces for hash functions.
require "hash"
# https://pkg.go.dev/hash/adler32 — Package adler32 implements the Adler-32 checksum.
require "hash/adler32"
# https://pkg.go.dev/hash/crc32 — Package crc32 implements the 32-bit cyclic redundancy check, or CRC-32, checksum.
require "hash/crc32"
# https://pkg.go.dev/hash/crc64 — Package crc64 implements the 64-bit cyclic redundancy check, or CRC-64, checksum.
require "hash/crc64"
# https://pkg.go.dev/hash/fnv — Package fnv implements FNV-1 and FNV-1a, non-cryptographic hash functions.
require "hash/fnv"
# https://pkg.go.dev/hash/maphash — Package maphash provides hash functions on byte sequences and comparable values.
require "hash/maphash"
module Main
  private

    # hash defines the common Hash / Hash32 / Hash64 interfaces that the
    # other hash/* packages implement. None of these are cryptographic —
    # use crypto/sha256 or similar when collision resistance matters.
    def self.runHash
      data = "hello".bytes

      # Iterate a set of hashes uniformly via the shared hash.Hash interface.
      hashes = [
        ["adler32", adler32.New()],
        ["crc32", crc32.NewIEEE()],
        ["crc64", crc64.New(crc64.MakeTable(crc64.ISO))],
        ["fnv-64a", fnv.New64a()]
      ]

      hashes.each do |_, entry|
        entry.h.Write(data)
        fmt.Printf("%-8s size=%d  sum=%x\n", entry.name, entry.h.Size(), entry.h.Sum(nil))
      end

      # One-shot helpers avoid the New/Write/Sum dance.
      fmt.Printf("adler32 (Checksum): %x\n", adler32.Checksum(data))
      fmt.Printf("crc32   (IEEE):     %x\n", crc32.ChecksumIEEE(data))
      # maphash is designed for use as a Go map key hasher: seeded per-process
      # to prevent collision-based DoS attacks. Same seed → same result.
      seed = maphash.MakeSeed()
      fmt.Printf("maphash string(%q): %x\n", data, maphash.String(seed, string(data)))

      fmt.Printf(
        "maphash comparable: %x\n",
        maphash.Comparable(seed, Struct.new(
          :a,
          :b,
          keyword_init: true
        ).new(1, 2))
      )
    end
end
