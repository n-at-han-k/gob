package informer

import (
	"context"
	"github.com/rs/zerolog"
	"github.com/thegostev/go-kubernetes-controllers/internal/types"
)

// EventWorker processes events asynchronously

type EventWorker struct {
	queue  chan types.Event
	logger zerolog.Logger
}

func (self *EventWorker) Start(ctx context.Context) {
	self.logger.Debug().Msg("starting event worker")
	for {
		select {
		case event, ok := <-self.queue:
			if !ok {
				self.logger.Debug().Msg("event queue closed, stopping worker")
				return
			}
			self.processEvent(event)
		case <-ctx.Done():
			self.logger.Debug().Msg("context cancelled, stopping worker")
			return
		}
	}
}

func (self *EventWorker) processEvent(event types.Event) {
	self.logger.Info().Str("type", event.Type).Str("namespace", event.Namespace).Str("name", event.Name).Time("timestamp", event.Timestamp).Msg("processing deployment event")
	// In a real implementation, you would do more processing here
	// For now, we just log the event
}

// NewEventWorker creates a new event worker

func NewEventWorker(queue chan types.Event, logger zerolog.Logger) *EventWorker {
	return &EventWorker{queue: queue, logger: logger}
}
