package k8s

import (
	"context"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/thegostev/go-kubernetes-controllers/internal/types"
	"github.com/thegostev/go-kubernetes-controllers/pkg/errors"
	appsv1 "k8s.io/api/apps/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
)

type Client struct {
	clientset  *kubernetes.Clientset
	logger     zerolog.Logger
	restConfig *rest.Config
}

func (self *Client) ListDeployments(ctx context.Context, options *types.ListOptions) (*appsv1.DeploymentList, error) {
	logger := self.logger.With().Str("operation", "list-deployments").Logger()
	// Validate options
	err := options.Validate()
	if err != nil {
		logger.Error().Err(err).Msg("invalid list options")
		return nil, errors.NewValidationError("list options", err.Error())
	}
	// Set defaults
	options.SetDefaults()
	logger.Debug().Str("namespace", options.Namespace).Dur("timeout", options.Timeout).Msg("listing deployments")
	// Create context with timeout
	ctx, cancel := context.WithTimeout(ctx, options.Timeout)
	defer cancel()
	// Check if context is already cancelled
	select {
	case <-ctx.Done():
		return nil, ctx.Err()
	default:
	}
	// List deployments
	deployments, err := self.clientset.AppsV1().Deployments(options.Namespace).List(ctx, metav1.ListOptions{})
	if err != nil {
		logger.Error().Err(err).Str("namespace", options.Namespace).Msg("failed to list deployments")
		return nil, errors.NewConnectionError("failed to list deployments", err)
	}
	logger.Info().Str("namespace", options.Namespace).Int("count", len(deployments.Items)).Msg("deployments listed successfully")
	return deployments, nil
}

func (self *Client) GetDeployment(ctx context.Context, namespace string, name string) (*appsv1.Deployment, error) {
	logger := self.logger.With().Str("operation", "get-deployment").Logger()
	// Basic validation
	if namespace == "" {
		return nil, errors.NewValidationError("namespace", "cannot be empty")
	}
	if name == "" {
		return nil, errors.NewValidationError("name", "cannot be empty")
	}
	logger.Debug().Str("namespace", namespace).Str("name", name).Msg("getting deployment")
	// Check if context is cancelled
	select {
	case <-ctx.Done():
		return nil, ctx.Err()
	default:
	}
	// Get deployment
	deployment, err := self.clientset.AppsV1().Deployments(namespace).Get(ctx, name, metav1.GetOptions{})
	if err != nil {
		logger.Error().Err(err).Str("namespace", namespace).Str("name", name).Msg("failed to get deployment")
		return nil, errors.NewConnectionError("failed to get deployment", err)
	}
	logger.Debug().Str("namespace", namespace).Str("name", name).Msg("deployment retrieved successfully")
	return deployment, nil
}
