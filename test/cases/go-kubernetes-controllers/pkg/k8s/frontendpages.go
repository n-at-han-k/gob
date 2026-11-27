package k8s

import (
	"context"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/thegostev/go-kubernetes-controllers/api/v1alpha1"
	"github.com/thegostev/go-kubernetes-controllers/internal/types"
	"github.com/thegostev/go-kubernetes-controllers/pkg/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/client-go/dynamic"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
)

type Client struct {
	clientset  *kubernetes.Clientset
	logger     zerolog.Logger
	restConfig *rest.Config
}

func (self *Client) ListFrontendPages(ctx context.Context, options *types.ListOptions) (*v1alpha1.FrontendPageList, error) {
	logger := self.logger.With().Str("operation", "list-frontendpages").Logger()
	// Validate options
	err := options.Validate()
	if err != nil {
		logger.Error().Err(err).Msg("invalid list options")
		return nil, errors.NewValidationError("list options", err.Error())
	}
	// Set defaults
	options.SetDefaults()
	logger.Debug().Str("namespace", options.Namespace).Dur("timeout", options.Timeout).Msg("listing frontend pages")
	// Create context with timeout
	ctx, cancel := context.WithTimeout(ctx, options.Timeout)
	defer cancel()
	// Check if context is already cancelled
	select {
	case <-ctx.Done():
		return nil, ctx.Err()
	default:
	}
	// Use dynamic client for CRD
	dynamicClient, err := dynamic.NewForConfig(self.restConfig)
	if err != nil {
		logger.Error().Err(err).Msg("failed to create dynamic client")
		return nil, errors.NewConnectionError("failed to create dynamic client", err)
	}
	// List frontend pages
	frontendPageGVR := v1alpha1.GroupVersion.WithResource("frontendpages")
	unstructuredList, err := dynamicClient.Resource(frontendPageGVR).Namespace(options.Namespace).List(ctx, metav1.ListOptions{})
	if err != nil {
		logger.Error().Err(err).Str("namespace", options.Namespace).Msg("failed to list frontend pages")
		return nil, errors.NewConnectionError("failed to list frontend pages", err)
	}
	// Convert to typed list
	frontendPageList := &v1alpha1.FrontendPageList{}
	err = runtime.DefaultUnstructuredConverter.FromUnstructured(unstructuredList.Object, frontendPageList)
	if err != nil {
		logger.Error().Err(err).Msg("failed to convert unstructured list")
		return nil, errors.NewConnectionError("failed to convert unstructured list", err)
	}
	logger.Info().Str("namespace", options.Namespace).Int("count", len(frontendPageList.Items)).Msg("frontend pages listed successfully")
	return frontendPageList, nil
}

func (self *Client) GetFrontendPage(ctx context.Context, namespace string, name string) (*v1alpha1.FrontendPage, error) {
	logger := self.logger.With().Str("operation", "get-frontendpage").Logger()
	// Basic validation
	if namespace == "" {
		return nil, errors.NewValidationError("namespace", "cannot be empty")
	}
	if name == "" {
		return nil, errors.NewValidationError("name", "cannot be empty")
	}
	logger.Debug().Str("namespace", namespace).Str("name", name).Msg("getting frontend page")
	// Check if context is already cancelled
	select {
	case <-ctx.Done():
		return nil, ctx.Err()
	default:
	}
	// Use dynamic client for CRD
	dynamicClient, err := dynamic.NewForConfig(self.restConfig)
	if err != nil {
		logger.Error().Err(err).Msg("failed to create dynamic client")
		return nil, errors.NewConnectionError("failed to create dynamic client", err)
	}
	// Get frontend page
	frontendPageGVR := v1alpha1.GroupVersion.WithResource("frontendpages")
	unstructuredObj, err := dynamicClient.Resource(frontendPageGVR).Namespace(namespace).Get(ctx, name, metav1.GetOptions{})
	if err != nil {
		logger.Error().Err(err).Str("namespace", namespace).Str("name", name).Msg("failed to get frontend page")
		return nil, errors.NewConnectionError("failed to get frontend page", err)
	}
	// Convert to typed object
	frontendPage := &v1alpha1.FrontendPage{}
	err = runtime.DefaultUnstructuredConverter.FromUnstructured(unstructuredObj.Object, frontendPage)
	if err != nil {
		logger.Error().Err(err).Msg("failed to convert unstructured object")
		return nil, errors.NewConnectionError("failed to convert unstructured object", err)
	}
	logger.Debug().Str("namespace", namespace).Str("name", name).Msg("frontend page retrieved successfully")
	return frontendPage, nil
}
