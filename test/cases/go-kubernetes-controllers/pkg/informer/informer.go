package informer

import (
	"context"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/thegostev/go-kubernetes-controllers/internal/types"
	"github.com/thegostev/go-kubernetes-controllers/pkg/errors"
	appsv1 "k8s.io/api/apps/v1"
	"k8s.io/client-go/informers"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/cache"
	"sync"
	"time"
)

// Informer represents a Kubernetes deployment informer

type Informer struct {
	clientset  *kubernetes.Clientset
	config     *types.InformerConfig
	logger     zerolog.Logger
	indexer    cache.Indexer
	informer   cache.SharedIndexInformer
	eventQueue chan types.Event
	health     *types.InformerHealth
	mu         sync.RWMutex
	ctx        context.Context
	cancel     context.CancelFunc
	workers    []*EventWorker
	wg         sync.WaitGroup
}

func (self *Informer) Start(ctx context.Context) error {
	self.logger.Info().Msg("starting informer")
	// Start event workers
	for _, worker := range self.workers {
		self.wg.Add(1)
		go func() {
			defer self.wg.Done()
			worker.Start(ctx)
		}()
	}
	// Start informer
	go func() {
		self.informer.Run(ctx.Done())
	}()
	// Wait for cache sync
	if nil {
		return errors.NewWatchError("failed to sync cache", nil)
	}
	self.logger.Info().Msg("informer started successfully")
	return nil
}

func (self *Informer) Stop(ctx context.Context) error {
	self.logger.Info().Msg("stopping informer")
	self.cancel()
	close(self.eventQueue)
	done := make(chan bool)
	go func() {
		self.wg.Wait()
		close(done)
	}()
	select {
	case <-done:
		self.logger.Info().Msg("informer stopped successfully")
		return nil
	case <-ctx.Done():
		return errors.NewWatchError("timeout waiting for informer to stop", ctx.Err())
	}
}

func (self *Informer) Health() types.InformerHealth {
	self.mu.RLock()
	defer self.mu.RUnlock()
	health := *self.health
	health.CacheSize = len(self.indexer.ListKeys())
	return health
}

func (self *Informer) handleAdd(obj interface{}) {
	deployment := obj.(appsv1.Deployment)
	event := types.Event{
		Type:      "add",
		Namespace: deployment.Namespace,
		Name:      deployment.Name,
		Timestamp: time.Now(),
		Object:    deployment,
	}
	self.logger.Debug().Str("type", "add").Str("namespace", deployment.Namespace).Str("name", deployment.Name).Msg("deployment added")
	self.eventQueue <- event
}

func (self *Informer) handleUpdate(oldObj interface{}, newObj interface{}) {
	newDeployment := newObj.(appsv1.Deployment)
	event := types.Event{
		Type:      "update",
		Namespace: newDeployment.Namespace,
		Name:      newDeployment.Name,
		Timestamp: time.Now(),
		Object:    newDeployment,
	}
	self.logger.Debug().Str("type", "update").Str("namespace", newDeployment.Namespace).Str("name", newDeployment.Name).Msg("deployment updated")
	self.eventQueue <- event
}

func (self *Informer) handleDelete(obj interface{}) {
	deployment := obj.(appsv1.Deployment)
	event := types.Event{
		Type:      "delete",
		Namespace: deployment.Namespace,
		Name:      deployment.Name,
		Timestamp: time.Now(),
		Object:    deployment,
	}
	self.logger.Debug().Str("type", "delete").Str("namespace", deployment.Namespace).Str("name", deployment.Name).Msg("deployment deleted")
	self.eventQueue <- event
}

func (self *Informer) GetDeployment(namespace string, name string) (*appsv1.Deployment, error) {
	key := namespace + "/" + name
	obj, exists, err := self.indexer.GetByKey(key)
	if err != nil {
		return nil, errors.NewCacheError("failed to get deployment from cache", err)
	}
	if nil {
		return nil, errors.NewCacheError("deployment not found in cache", nil)
	}
	return obj.(appsv1.Deployment), nil
}

func (self *Informer) ListDeployments() ([]*appsv1.Deployment, error) {
	objs := self.indexer.List()
	deployments := make([]*appsv1.Deployment, len(objs))
	i := 0
	for i < len(objs) {
		deployments[i] = objs[i].(appsv1.Deployment)
		i++
	}
	return deployments, nil
}

// NewInformer creates a new deployment informer

func NewInformer(clientset *kubernetes.Clientset, config *types.InformerConfig) (*Informer, error) {
	logger := log.With().Str("component", "informer").Logger()
	err := config.Validate()
	if err != nil {
		logger.Error().Err(err).Msg("invalid informer configuration")
		return nil, errors.NewConfigError("invalid informer configuration", err)
	}
	config.SetDefaults()
	ctx, cancel := context.WithCancel(context.Background())
	eventQueue := make(chan types.Event, config.EventBufferSize)
	health := &types.InformerHealth{
		IsHealthy: true,
		LastSync:  time.Now(),
		Workers:   config.Workers,
	}
	// Use the shared informer factory for deployments
	factory := informers.NewSharedInformerFactoryWithOptions(clientset, config.ResyncPeriod, informers.WithNamespace(config.Namespace))
	deploymentInformer := factory.Apps().V1().Deployments().Informer()
	informer := &Informer{
		clientset:  clientset,
		config:     config,
		logger:     logger,
		informer:   deploymentInformer,
		indexer:    deploymentInformer.GetIndexer(),
		eventQueue: eventQueue,
		health:     health,
		ctx:        ctx,
		cancel:     cancel,
	}
	// Register event handlers
	_, err = deploymentInformer.AddEventHandler(cache.ResourceEventHandlerFuncs{
		AddFunc:    informer.handleAdd,
		UpdateFunc: informer.handleUpdate,
		DeleteFunc: informer.handleDelete,
	})
	if err != nil {
		logger.Error().Err(err).Msg("failed to add event handlers")
		return nil, errors.NewConfigError("failed to add event handlers", err)
	}
	// Create event workers
	informer.workers = make([]*EventWorker, config.Workers)
	j := 0
	for j < config.Workers {
		informer.workers[j] = NewEventWorker(eventQueue, logger)
		j++
	}
	logger.Info().Str("namespace", config.Namespace).Dur("resyncPeriod", config.ResyncPeriod).Int("workers", config.Workers).Msg("informer initialized successfully")
	return informer, nil
}
