package main

import (
	"bytes"               // https://pkg.go.dev/bytes — Package bytes implements functions for the manipulation of byte slices.
	"fmt"                 // https://pkg.go.dev/fmt — Package fmt implements formatted I/O with functions analogous to C's printf and scanf.
	"image"               // https://pkg.go.dev/image — Package image implements a basic 2-D image library.
	"image/color"         // https://pkg.go.dev/image/color — Package color implements a basic color library.
	"image/color/palette" // https://pkg.go.dev/image/color/palette — Package palette provides standard color palettes.
	"image/draw"          // https://pkg.go.dev/image/draw — Package draw provides image composition functions.
	"image/gif"           // https://pkg.go.dev/image/gif — Package gif implements a GIF image decoder and encoder.
	"image/jpeg"          // https://pkg.go.dev/image/jpeg — Package jpeg implements a JPEG image decoder and encoder.
	"image/png"           // https://pkg.go.dev/image/png — Package png implements a PNG image decoder and encoder.
	"log"                 // https://pkg.go.dev/log — Package log implements a simple logging package.
	"os"                  // https://pkg.go.dev/os — Package os provides a platform-independent interface to operating system functionality.
)

func runImage() {
	const size = 100
	img := makeGradient(size)

	// image/draw composites the top-left quadrant of the gradient onto
	// itself in the bottom-right, tinted red.
	tint := image.NewUniform(color.RGBA{200, 0, 0, 128})
	quadrant := image.Rect(size/2, size/2, size, size)
	draw.Draw(img, quadrant, tint, image.Point{}, draw.Over)

	// Encode the same image in three formats.
	writeFile("gradient.png", func(w *os.File) error { return png.Encode(w, img) })
	writeFile("gradient.jpg", func(w *os.File) error { return jpeg.Encode(w, img, &jpeg.Options{Quality: 90}) })
	writeGIF("gradient.gif", img)

	// Decode one back to demonstrate the read side + the generic
	// image.Decode dispatch (uses the registered format decoders).
	decoded, format, err := image.Decode(bytes.NewReader(pngBytes(img)))
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("decoded format=%s bounds=%v\n", format, decoded.Bounds())

	// image/color/palette provides standard palettes (WebSafe, Plan9).
	fmt.Printf("Plan9 palette:   %d colours\n", len(palette.Plan9))
	fmt.Printf("WebSafe palette: %d colours\n", len(palette.WebSafe))
}

func makeGradient(size int) *image.RGBA {
	img := image.NewRGBA(image.Rect(0, 0, size, size))
	for y := 0; y < size; y++ {
		for x := 0; x < size; x++ {
			img.Set(x, y, color.RGBA{
				R: uint8(x * 255 / size),
				G: uint8(y * 255 / size),
				B: 128,
				A: 255,
			})
		}
	}
	return img
}

func writeFile(name string, enc func(*os.File) error) {
	f, err := os.Create(name)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	if err := enc(f); err != nil {
		log.Fatal(err)
	}
	fmt.Println("wrote", name)
}

func writeGIF(name string, src image.Image) {
	// GIFs use a palette; quantise the RGBA image down to the Plan 9 palette.
	paletted := image.NewPaletted(src.Bounds(), palette.Plan9)
	draw.FloydSteinberg.Draw(paletted, src.Bounds(), src, image.Point{})
	writeFile(name, func(w *os.File) error { return gif.Encode(w, paletted, nil) })
}

func pngBytes(img image.Image) []byte {
	var buf bytes.Buffer
	png.Encode(&buf, img)
	return buf.Bytes()
}
