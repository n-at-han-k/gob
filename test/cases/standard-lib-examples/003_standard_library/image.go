package main

import (
	"bytes"
	"fmt"
	"image"
	"image/color"
	"image/color/palette"
	"image/draw"
	"image/gif"
	"image/jpeg"
	"image/png"
	"log"
	"os"
)

func runImage() {
	const size = 100
	img := makeGradient(size)
	tint := image.NewUniform(color.RGBA{200, 0, 0, 128})
	quadrant := image.Rect(size/2, size/2, size, size)
	draw.Draw(img, quadrant, tint, image.Point{}, draw.Over)
	writeFile("gradient.png", func(w *os.File) error {
		return png.Encode(w, img)
	})
	writeFile("gradient.jpg", func(w *os.File) error {
		return jpeg.Encode(w, img, &jpeg.Options{Quality: 90})
	})
	writeGIF("gradient.gif", img)
	decoded, format, err := image.Decode(bytes.NewReader(pngBytes(img)))
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("decoded format=%s bounds=%v\n", format, decoded.Bounds())
	fmt.Printf("Plan9 palette:   %d colours\n", len(palette.Plan9))
	fmt.Printf("WebSafe palette: %d colours\n", len(palette.WebSafe))
}

func makeGradient(size int) *image.RGBA {
	img := image.NewRGBA(image.Rect(0, 0, size, size))
	for y := range size {
		for x := range size {
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
	err = enc(f)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("wrote", name)
}

func writeGIF(name string, src image.Image) {
	paletted := image.NewPaletted(src.Bounds(), palette.Plan9)
	draw.FloydSteinberg.Draw(paletted, src.Bounds(), src, image.Point{})
	writeFile(name, func(w *os.File) error {
		return gif.Encode(w, paletted, nil)
	})
}

func pngBytes(img image.Image) []byte {
	var buf bytes.Buffer
	png.Encode(&buf, img)
	return buf.Bytes()
}
