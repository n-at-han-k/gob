package main

import (
	"github.com/go-chi/chi/v5"
	"net/http"
)

type todosResource struct{}

// Routes creates a REST router for the todos resource
func (self todosResource) Routes() chi.Router {
	r := chi.NewRouter()
	// r.Use() // some middleware..

	r.Get("/", self.List)    // GET /todos - read a list of todos
	r.Post("/", self.Create) // POST /todos - create a new todo and persist it
	r.Put("/", self.Delete)

	r.Route("/{id}", func(r chi.Router) {
		// r.Use(self.TodoCtx) // lets have a todos map, and lets actually load/manipulate
		r.Get("/", self.Get)       // GET /todos/{id} - read a single todo by :id
		r.Put("/", self.Update)    // PUT /todos/{id} - update a single todo by :id
		r.Delete("/", self.Delete) // DELETE /todos/{id} - delete a single todo by :id
		r.Get("/sync", self.Sync)
	})

	return r
}

func (self todosResource) List(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("todos list of stuff.."))
}

func (self todosResource) Create(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("todos create"))
}

func (self todosResource) Get(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("todo get"))
}

func (self todosResource) Update(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("todo update"))
}

func (self todosResource) Delete(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("todo delete"))
}

func (self todosResource) Sync(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("todo sync"))
}
