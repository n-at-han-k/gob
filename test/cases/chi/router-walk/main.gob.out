package main

import (
	"fmt"
	"github.com/go-chi/chi/v5"
	"net/http"
	"strings"
)

func main() {
	r := chi.NewRouter()
	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write(([]byte)("root."))
	})
	r.Route("/road", func(r chi.Router) {
		r.Get("/left", func(w http.ResponseWriter, r *http.Request) {
			w.Write(([]byte)("left road"))
		})
		r.Post("/right", func(w http.ResponseWriter, r *http.Request) {
			w.Write(([]byte)("right road"))
		})
	})
	r.Put("/ping", Ping)
	walkFunc := func(method string, route string, handler http.Handler) error {
		route = strings.ReplaceAll(route, "/*/", "/")
		fmt.Printf("%s %s\n", method, route)
		return nil
	}
	err := chi.Walk(r, walkFunc)
	if err != nil {
		fmt.Printf("Logging err: %s\n", err.Error())
	}
}

// Ping returns pong

func Ping(w http.ResponseWriter, r *http.Request) {
	w.Write(([]byte)("pong"))
}
