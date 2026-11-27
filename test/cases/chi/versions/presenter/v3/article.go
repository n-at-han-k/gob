package v3

import (
	"fmt"
	"github.com/go-chi/chi/v5/_examples/versions/data"
	"math/rand"
	"net/http"
)

// Article presented in API version 2.
type Article struct {
	Article                *data.Article `json:",inline" xml:",inline"`
	URL                    string        `json:"url" xml:"url"`
	ViewsCount             int64         `json:"views_count" xml:"views_count"`
	APIVersion             string        `json:"api_version" xml:"api_version"`
	CustomDataForAuthUsers any           `json:"custom_data,omitempty" xml:"custom_data,omitempty"`
}

func (self *Article) Render(w http.ResponseWriter, r *http.Request) error {
	self.ViewsCount = rand.Int63n(100000)
	self.URL = fmt.Sprintf("http://localhost:3333/v3/?id=%v", self.ID)

	// Only show to auth'd user.
	_, ok := r.Context().Value("auth").(bool)
	if ok {
		self.CustomDataForAuthUsers = self.Article.CustomDataForAuthUsers
	}

	return nil
}

func NewArticleResponse(article *data.Article) *Article {
	return &Article{Article: article}
}
