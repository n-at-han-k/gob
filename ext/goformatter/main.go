package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"encoding/json"
	"unsafe"

	"gob.ext/goformatter/format"
)

//export FormatSourceJSON
func FormatSourceJSON(src *C.char) *C.char {
	output, err := format.Source([]byte(C.GoString(src)))
	result := map[string]any{"output": string(output)}
	if err != nil {
		result["error"] = err.Error()
	}

	encoded, _ := json.Marshal(result)
	return C.CString(string(encoded))
}

//export FreeString
func FreeString(str *C.char) {
	if str != nil {
		C.free(unsafe.Pointer(str))
	}
}

func main() {}
