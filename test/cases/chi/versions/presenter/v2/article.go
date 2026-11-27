package v2

import (
	"fmt"
	"github.com/go-chi/chi/v5/_examples/versions/data"
	"net/http"
)

// Article presented in API version 2.
type Article struct {
	Article *data.Article
	SelfURL string       `json:"self_url" xml:"self_url"`
	URL     any          `json:"url,omitempty" xml:"url,omitempty"`
}

func (self *Article) Render(w http.ResponseWriter, r *http.Request) error {
	self.SelfURL = fmt.Sprintf("http://localhost:3333/v2?id=%v", self.ID)
	return nil
}

func NewArticleResponse(article *data.Article) *Article {
	return &Article{Article: article}
}
