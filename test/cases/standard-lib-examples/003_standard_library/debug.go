package main

import (
	"debug/buildinfo" 
	"debug/dwarf"     
	"debug/elf"       
	"debug/gosym"     
	"debug/macho"     
	"debug/pe"        
	"debug/plan9obj"  
	"fmt"             
	"log"             
	"os"              
)

func runDebug() {
	self, err := os.Executable()
	if err != nil {
		log.Fatal(err)
	}
	debugBuildinfo(self)
	debugFormats(self)
	debugElfSections(self)
	debugDwarf(self)
	debugGosym(self)
}

func debugBuildinfo(path string) {
	bi, err := buildinfo.ReadFile(path)
	if err != nil {
		fmt.Println("buildinfo err:", err)
		return
	}
	fmt.Println("=== buildinfo ===")
	fmt.Println("go version:", bi.GoVersion)
	fmt.Println("main path: ", bi.Main.Path)
}

func debugFormats(path string) {

	fmt.Println("\n=== format detection ===")
	if f, err := elf.Open(path); err == nil {
		fmt.Printf("elf:      %s %s, %d sections\n", f.Class, f.Machine, len(f.Sections))
		f.Close()
	} else {
		fmt.Println("elf:      not an ELF file")
	}
	if f, err := macho.Open(path); err == nil {
		fmt.Printf("macho:    cpu=%s, %d sections\n", f.Cpu, len(f.Sections))
		f.Close()
	} else {
		fmt.Println("macho:    not a Mach-O file")
	}
	if f, err := pe.Open(path); err == nil {
		fmt.Printf("pe:       machine=0x%x, %d sections\n", f.Machine, len(f.Sections))
		f.Close()
	} else {
		fmt.Println("pe:       not a PE file")
	}
	if f, err := plan9obj.Open(path); err == nil {
		fmt.Printf("plan9obj: magic=%d, %d sections\n", f.Magic, len(f.Sections))
		f.Close()
	} else {
		fmt.Println("plan9obj: not a Plan 9 a.out file")
	}
}

func debugElfSections(path string) {
	f, err := elf.Open(path)
	if err != nil {
		return
	}
	defer f.Close()
	fmt.Println("\n=== elf sections (first 5) ===")
	for i, s := range f.Sections {
		if i >= 5 {
			break
		}
		fmt.Printf("  %-24s addr=0x%08x size=%d\n", s.Name, s.Addr, s.Size)
	}
}

func debugDwarf(path string) {
	f, err := elf.Open(path)
	if err != nil {
		return
	}
	defer f.Close()
	d, err := f.DWARF()
	if err != nil {
		fmt.Println("\n=== dwarf ===\n  not available:", err)
		return
	}
	fmt.Println("\n=== dwarf (first 3 compilation units) ===")
	r := d.Reader()
	shown := 0
	for shown < 3 {
		e, err := r.Next()
		if err != nil || e == nil {
			break
		}
		if e.Tag == dwarf.TagCompileUnit {
			name, _ := e.Val(dwarf.AttrName).(string)
			fmt.Println("  CU:", name)
			shown++
		}
		r.SkipChildren()
	}
}

func debugGosym(path string) {
	f, err := elf.Open(path)
	if err != nil {
		return
	}
	defer f.Close()

	text := f.Section(".text")
	pclntab := f.Section(".gopclntab")
	if text == nil || pclntab == nil {
		fmt.Println("\n=== gosym ===\n  .text or .gopclntab missing")
		return
	}
	data, err := pclntab.Data()
	if err != nil {
		return
	}
	tab, err := gosym.NewTable(nil, gosym.NewLineTable(data, text.Addr))
	if err != nil {
		fmt.Println("\n=== gosym ===\n  err:", err)
		return
	}
	fmt.Println("\n=== gosym (main.main location) ===")
	if fn := tab.LookupFunc("main.main"); fn != nil {
		file, line, _ := tab.PCToLine(fn.Entry)
		fmt.Printf("  main.main at %s:%d\n", file, line)
	}
}
