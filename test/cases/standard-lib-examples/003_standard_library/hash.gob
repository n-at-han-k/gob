require "fmt"
require "hash"
require "hash/adler32"
require "hash/crc32"
require "hash/crc64"
require "hash/fnv"
require "hash/maphash"

module Main

    # ()
    def runHash
      data = "hello".bytes

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

      fmt.Printf("adler32 (Checksum): %x\n", adler32.Checksum(data))
      fmt.Printf("crc32   (IEEE):     %x\n", crc32.ChecksumIEEE(data))
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
