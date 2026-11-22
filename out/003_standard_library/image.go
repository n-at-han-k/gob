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
	size := 100
	img := makeGradient(size)
	tint := image.NewUniform(RGBA.new(200, 0, 0, 128))
	quadrant := image.Rect(size/2, size/2, size, size)
	draw.Draw(img, quadrant, tint, Point.new(), draw.Over)
	writeFile("gradient.png", func(w any) {
		return png.Encode(w, img)
	})
	writeFile("gradient.jpg", func(w any) {
		return jpeg.Encode(w, img, Options.new(map[any]any{Quality: 90}))
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

func makeGradient(size any) {
	img := image.NewRGBA(image.Rect(0, 0, size, size))
	for y := range size {
		for x := range size {
			img.Set(x, y, RGBA.new(map[any]any{R: uint8(x * 255 / size), G: uint8(y * 255 / size), B: 128, A: 255}))
		}
	}
	return img
}

func writeFile(name any, enc any) {
	f, err := os.Create(name)
	if err != nil {
		log.Fatal(err)
	}
	defer func() {
		f.Close()
	}()
	err = enc(f)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("wrote", name)
}

func writeGIF(name any, src any) {
	paletted := image.NewPaletted(src.Bounds(), palette.Plan9)
	draw.FloydSteinberg.Draw(paletted, src.Bounds(), src, Point.new())
	writeFile(name, func(w any) {
		return gif.Encode(w, paletted, nil)
	})
}

func pngBytes(img any) {
	buf := nil
	png.Encode(buf, img)
	return buf.Bytes()
}
