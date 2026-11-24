require "debug/buildinfo"
require "debug/dwarf"
require "debug/elf"
require "debug/gosym"
require "debug/macho"
require "debug/pe"
require "debug/plan9obj"
require "fmt"
require "log"
require "os"

module Main

    # ()
    def runDebug
      self_, err = os.Executable()

      if err != nil
        log.Fatal(err)
      end

      debugBuildinfo(self_)
      debugFormats(self_)
      debugElfSections(self_)
      debugDwarf(self_)
      debugGosym(self_)
    end

    # (string)
    def debugBuildinfo(path)
      bi, err = buildinfo.ReadFile(path)

      if err != nil
        fmt.Println("buildinfo err:", err)

        return
      end

      fmt.Println("=== buildinfo ===")
      fmt.Println("go version:", bi.GoVersion)
      fmt.Println("main path: ", bi.Main.Path)
    end

    # (string)
    def debugFormats(path)
      fmt.Println("\n=== format detection ===")
      f, err = elf.Open(path)

      if err == nil
        fmt.Printf("elf:      %s %s, %d sections\n", f.Class, f.Machine, len(f.Sections))
        f.Close()
      else
        fmt.Println("elf:      not an ELF file")
      end

      f, err = macho.Open(path)

      if err == nil
        fmt.Printf("macho:    cpu=%s, %d sections\n", f.Cpu, len(f.Sections))
        f.Close()
      else
        fmt.Println("macho:    not a Mach-O file")
      end

      f, err = pe.Open(path)

      if err == nil
        fmt.Printf("pe:       machine=0x%x, %d sections\n", f.Machine, len(f.Sections))
        f.Close()
      else
        fmt.Println("pe:       not a PE file")
      end

      f, err = plan9obj.Open(path)

      if err == nil
        fmt.Printf("plan9obj: magic=%d, %d sections\n", f.Magic, len(f.Sections))
        f.Close()
      else
        fmt.Println("plan9obj: not a Plan 9 a.out file")
      end
    end

    # (string)
    def debugElfSections(path)
      f, err = elf.Open(path)

      if err != nil
        return
      end

      defer { f.Close() }
      fmt.Println("\n=== elf sections (first 5) ===")

      f.Sections.each do |i, s|
        if i >= 5
          break
        end

        fmt.Printf("  %-24s addr=0x%08x size=%d\n", s.Name, s.Addr, s.Size)
      end
    end

    # (string)
    def debugDwarf(path)
      f, err = elf.Open(path)

      if err != nil
        return
      end

      defer { f.Close() }
      d, err = f.DWARF()

      if err != nil
        fmt.Println("\n=== dwarf ===\n  not available:", err)

        return
      end

      fmt.Println("\n=== dwarf (first 3 compilation units) ===")
      r = d.Reader()
      shown = 0

      while shown < 3
        e, err = r.Next()

        if err != nil || e == nil
          break
        end

        if e.Tag == dwarf.TagCompileUnit
          name, _ = e.Val(dwarf.AttrName)
          fmt.Println("  CU:", name)
          shown += 1
        end

        r.SkipChildren()
      end
    end

    # (string)
    def debugGosym(path)
      f, err = elf.Open(path)

      if err != nil
        return
      end

      defer { f.Close() }
      text = f.Section(".text")
      pclntab = f.Section(".gopclntab")

      if text == nil || pclntab == nil
        fmt.Println("\n=== gosym ===\n  .text or .gopclntab missing")

        return
      end

      data, err = pclntab.Data()

      if err != nil
        return
      end

      tab, err = gosym.NewTable(nil, gosym.NewLineTable(data, text.Addr))

      if err != nil
        fmt.Println("\n=== gosym ===\n  err:", err)

        return
      end

      fmt.Println("\n=== gosym (main.main location) ===")
      fn = tab.LookupFunc("main.main")

      if fn != nil
        file, line, _ = tab.PCToLine(fn.Entry)
        fmt.Printf("  main.main at %s:%d\n", file, line)
      end
    end
end
