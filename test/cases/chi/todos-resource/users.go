package main

import (
	"github.com/go-chi/chi/v5"
	"net/http"
)

type usersResource struct{}

// Routes creates a REST router for the todos resource
func (self usersResource) Routes() chi.Router {
	r := chi.NewRouter()
	// r.Use() // some middleware..

	r.Get("/", self.List)    // GET /users - read a list of users
	r.Post("/", self.Create) // POST /users - create a new user and persist it
	r.Put("/", self.Delete)

	r.Route("/{id}", func(r chi.Router) {
		// r.Use(self.TodoCtx) // lets have a users map, and lets actually load/manipulate
		r.Get("/", self.Get)       // GET /users/{id} - read a single user by :id
		r.Put("/", self.Update)    // PUT /users/{id} - update a single user by :id
		r.Delete("/", self.Delete) // DELETE /users/{id} - delete a single user by :id
	})

	return r
}

func (self usersResource) List(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("users list of stuff.."))
}

func (self usersResource) Create(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("users create"))
}

func (self usersResource) Get(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("user get"))
}

func (self usersResource) Update(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("user update"))
}

func (self usersResource) Delete(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("user delete"))
}
