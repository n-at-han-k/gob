package types

import (
	"github.com/thegostev/go-kubernetes-controllers/pkg/errors"
	"time"
)

// ListOptions represents options for listing resources

type ListOptions struct {
	Namespace string        `json:"namespace"`
	Timeout   time.Duration `json:"timeout"`
}

func (self *ListOptions) Validate() error {
	// Validate namespace
	if self.Namespace == "" {
		return errors.NewValidationError("namespace", "cannot be empty")
	}
	// Validate timeout
	if self.Timeout < time.Second || self.Timeout > 5*time.Minute {
		return errors.NewValidationError("timeout", "must be between 1s and 5m")
	}
	return nil
}

func (self *ListOptions) SetDefaults() {
	if self.Namespace == "" {
		self.Namespace = "default"
	}
	if self.Timeout == 0 {
		self.Timeout = 30 * time.Second
	}
}

// ClientConfig represents Kubernetes client configuration

type ClientConfig struct {
	KubeconfigPath string        `json:"kubeconfigPath"`
	Timeout        time.Duration `json:"timeout"`
}

func (self *ClientConfig) Validate() error {
	// Validate timeout
	if self.Timeout < time.Second || self.Timeout > 5*time.Minute {
		return errors.NewValidationError("timeout", "must be between 1s and 5m")
	}
	return nil
}

func (self *ClientConfig) SetDefaults() {
	if self.Timeout == 0 {
		self.Timeout = 30 * time.Second
	}
}
