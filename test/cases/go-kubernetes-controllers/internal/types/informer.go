package types

import (
	"github.com/thegostev/go-kubernetes-controllers/pkg/errors"
	"time"
)

// InformerConfig represents informer configuration

type InformerConfig struct {
	Namespace       string
	ResyncPeriod    time.Duration `json:"resyncPeriod"`
	MaxCacheSize    int           `json:"maxCacheSize"`
	MaxConnections  int           `json:"maxConnections"`
	EventBufferSize int           `json:"eventBufferSize"`
	Workers         int           `json:"workers"`
}

func (self *InformerConfig) Validate() error {
	if self.ResyncPeriod < time.Second || self.ResyncPeriod > 30*time.Minute {
		return errors.NewValidationError("resyncPeriod", "must be between 1s and 30m")
	}
	if self.MaxCacheSize <= 0 {
		return errors.NewValidationError("maxCacheSize", "must be positive")
	}
	if self.MaxConnections <= 0 {
		return errors.NewValidationError("maxConnections", "must be positive")
	}
	if self.EventBufferSize <= 0 {
		return errors.NewValidationError("eventBufferSize", "must be positive")
	}
	if self.Workers <= 0 {
		return errors.NewValidationError("workers", "must be positive")
	}
	return nil
}

func (self *InformerConfig) SetDefaults() {
	if self.ResyncPeriod == 0 {
		self.ResyncPeriod = 10 * time.Minute
	}
	if self.MaxCacheSize == 0 {
		self.MaxCacheSize = 1000
	}
	if self.MaxConnections == 0 {
		self.MaxConnections = 10
	}
	if self.EventBufferSize == 0 {
		self.EventBufferSize = 100
	}
	if self.Workers == 0 {
		self.Workers = 2
	}
}

// InformerHealth represents informer health status

type InformerHealth struct {
	IsHealthy bool
	LastSync  time.Time `json:"lastSync"`
	Error     error     `json:"error,omitempty"`
	CacheSize int       `json:"cacheSize"`
	Workers   int       `json:"workers"`
}

// Event represents a deployment event

type Event struct {
	Type      string
	Namespace string    `json:"namespace"`
	Name      string    `json:"name"`
	Timestamp time.Time `json:"timestamp"`
	Object    any       `json:"object,omitempty"`
}
