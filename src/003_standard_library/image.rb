# https://pkg.go.dev/bytes — Package bytes implements functions for the manipulation of byte slices.
require "bytes"
# https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
require "fmt"
# https://pkg.go.dev/image — Package image implements a basic 2-D image library.
require "image"
# https://pkg.go.dev/image/color — Package color implements a basic color library.
require "image/color"
# https://pkg.go.dev/image/color/palette — Package palette provides standard color palettes.
require "image/color/palette"
# https://pkg.go.dev/image/draw — Package draw provides image composition functions.
require "image/draw"
# https://pkg.go.dev/image/gif — Package gif implements a GIF image decoder and encoder.
require "image/gif"
# https://pkg.go.dev/image/jpeg — Package jpeg implements a JPEG image decoder and encoder.
require "image/jpeg"
# https://pkg.go.dev/image/png — Package png implements a PNG image decoder and encoder.
require "image/png"
# https://pkg.go.dev/log — Package log implements a simple logging package.
require "log"
# https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
require "os"
module Main
  private

    def self.runImage
      size = 100
      img = makeGradient(size)
      # image/draw composites the top-left quadrant of the gradient onto
      # itself in the bottom-right, tinted red.
      tint = image.NewUniform(RGBA.new(200, 0, 0, 128))
      quadrant = image.Rect(size / 2, size / 2, size, size)
      draw.Draw(img, quadrant, tint, Point.new(), draw.Over)
      # Encode the same image in three formats.
      writeFile("gradient.png", lambda { |w| return png.Encode(w, img) })
      writeFile("gradient.jpg", lambda { |w| return jpeg.Encode(w, img, Options.new(Quality: 90)) })
      writeGIF("gradient.gif", img)
      # Decode one back to demonstrate the read side + the generic
      # image.Decode dispatch (uses the registered format decoders).
      decoded, format, err = image.Decode(bytes.NewReader(pngBytes(img)))

      if err != nil
        log.Fatal(err)
      end

      fmt.Printf("decoded format=%s bounds=%v\n", format, decoded.Bounds())
      # image/color/palette provides standard palettes (WebSafe, Plan9).
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
      # GIFs use a palette; quantise the RGBA image down to the Plan 9 palette.
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
