package errors

import "fmt"

// ConfigError represents configuration-related errors

type ConfigError struct {
	Message string
	Err     error
}

func (self *ConfigError) Error() string {
	if self.Err != nil {
		return fmt.Sprintf("configuration error: %s: %v", self.Message, self.Err)
	}
	return fmt.Sprintf("configuration error: %s", self.Message)
}

// ConnectionError represents cluster connection errors

type ConnectionError struct {
	Message string
	Err     error
}

func (self *ConnectionError) Error() string {
	if self.Err != nil {
		return fmt.Sprintf("connection error: %s: %v", self.Message, self.Err)
	}
	return fmt.Sprintf("connection error: %s", self.Message)
}

// ValidationError represents input validation errors

type ValidationError struct {
	Field   string
	Message string
}

func (self *ValidationError) Error() string {
	return fmt.Sprintf("validation error for field '%s': %s", self.Field, self.Message)
}

// WatchError represents watch stream failures

type WatchError struct {
	Message string
	Err     error
}

func (self *WatchError) Error() string {
	if self.Err != nil {
		return fmt.Sprintf("watch error: %s: %v", self.Message, self.Err)
	}
	return fmt.Sprintf("watch error: %s", self.Message)
}

// CacheError represents cache corruption or storage issues

type CacheError struct {
	Message string
	Err     error
}

func (self *CacheError) Error() string {
	if self.Err != nil {
		return fmt.Sprintf("cache error: %s: %v", self.Message, self.Err)
	}
	return fmt.Sprintf("cache error: %s", self.Message)
}

// ResyncError represents resync operation failures

type ResyncError struct {
	Message string
	Err     error
}

func (self *ResyncError) Error() string {
	if self.Err != nil {
		return fmt.Sprintf("resync error: %s: %v", self.Message, self.Err)
	}
	return fmt.Sprintf("resync error: %s", self.Message)
}

// Helper functions to create errors

func NewConfigError(message string, err error) *ConfigError {
	return &ConfigError{Message: message, Err: err}
}

func NewConnectionError(message string, err error) *ConnectionError {
	return &ConnectionError{Message: message, Err: err}
}

func NewValidationError(field string, message string) *ValidationError {
	return &ValidationError{Field: field, Message: message}
}

func NewWatchError(message string, err error) *WatchError {
	return &WatchError{Message: message, Err: err}
}

func NewCacheError(message string, err error) *CacheError {
	return &CacheError{Message: message, Err: err}
}

func NewResyncError(message string, err error) *ResyncError {
	return &ResyncError{Message: message, Err: err}
}
