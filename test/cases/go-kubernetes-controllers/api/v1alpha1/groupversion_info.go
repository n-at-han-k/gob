package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
)

// GroupVersion is group version used to register these objects

const (
	groupversion = schema.GroupVersion{Group: "frontend.thegostev.com", Version: "v1alpha1"}
	// SchemeBuilder is used to add go types to the GroupVersionKind scheme
	schemebuilder = &runtime.SchemeBuilder{addKnownTypes}
	// AddToScheme adds the types in this group-version to the given scheme.
	addtoscheme = schemebuilder.AddToScheme
)

// Adds the list of known types to the given scheme.

func addKnownTypes(scheme *runtime.Scheme) error {
	scheme.AddKnownTypes(groupversion, &FrontendPage{}, &FrontendPageList{})
	metav1.AddToGroupVersion(scheme, groupversion)
	return nil
}
