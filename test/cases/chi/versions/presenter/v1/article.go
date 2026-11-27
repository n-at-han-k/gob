package v1

import (
	"github.com/go-chi/chi/v5/_examples/versions/data"
	"net/http"
)

// Article presented in API version 1.
type Article struct {
	Article *data.Article
	Data    map[string]bool `json:"data" xml:"data"`
}

func (self *Article) Render(w http.ResponseWriter, r *http.Request) error {
	return nil
}

func NewArticleResponse(article *data.Article) *Article {
	return &Article{Article: article}
}
