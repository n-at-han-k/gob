package main

import (
	"fmt"
	"go/constant"
	"go/token"
)

func runConstant() {
	big := constant.Shift(constant.MakeInt64(1), token.SHL, 100)
	fmt.Println("1 << 100 =", big)
	sum := constant.BinaryOp(constant.MakeFloat64(1.5), token.ADD, constant.MakeInt64(2))
	fmt.Println("1.5 + 2 =", sum, "(kind:", sum.Kind(), ")")
	fmt.Println("1<<100 > 1e30?", constant.Compare(big, token.GTR, constant.MakeFloat64(1.0e+30)))
}
