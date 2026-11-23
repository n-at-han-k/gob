require "bytes"
require "fmt"
require "image"
require "image/color"
require "image/color/palette"
require "image/draw"
require "image/gif"
require "image/jpeg"
require "image/png"
require "log"
require "os"
module Main
  private

    def self.runImage
      size = 100
      img = makeGradient(size)
      tint = image.NewUniform(RGBA.new(200, 0, 0, 128))
      quadrant = image.Rect(size / 2, size / 2, size, size)
      draw.Draw(img, quadrant, tint, Point.new(), draw.Over)
      writeFile("gradient.png", lambda { |w| return png.Encode(w, img) })
      writeFile("gradient.jpg", lambda { |w| return jpeg.Encode(w, img, Options.new(Quality: 90)) })
      writeGIF("gradient.gif", img)
      decoded, format, err = image.Decode(bytes.NewReader(pngBytes(img)))

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("decoded format=%s bounds=%v\n", format, decoded.Bounds())
      fmt.Printf("Plan9 palette:   %d colours\n", len(palette.Plan9))
      fmt.Printf("WebSafe palette: %d colours\n", len(palette.WebSafe))
    end

    def self.makeGradient(size)
      img = image.NewRGBA(image.Rect(0, 0, size, size))

      (0...size).each do |y|
        (0...size).each do |x|
          img.Set(
            x,
            y,
            RGBA.new(
              R: uint8(x * 255 / size),
              G: uint8(y * 255 / size),
              B: 128,
              A: 255
            )
          )
        end
      end

      return img
    end

    def self.writeFile(name, enc)
      f, err = os.Create(name)

      if err != nil
        log.Fatal(err)
      end

      defer { f.Close() }
      err = enc(f)

      if err != nil
        log.Fatal(err)
      end

      fmt.Println("wrote", name)
    end

    def self.writeGIF(name, src)
      paletted = image.NewPaletted(src.Bounds(), palette.Plan9)
      draw.FloydSteinberg.Draw(paletted, src.Bounds(), src, Point.new())
      writeFile(name, lambda { |w| return gif.Encode(w, paletted, nil) })
    end

    def self.pngBytes(img)
      buf = nil
      png.Encode(buf, img)

      return buf.Bytes()
    end
end
