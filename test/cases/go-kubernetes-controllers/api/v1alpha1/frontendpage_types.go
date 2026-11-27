package v1alpha1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
)

// FrontendPageSpec defines the desired state of FrontendPage

type FrontendPageSpec struct {
	Title      string
	Template   string      `json:"template"`
	Components []Component `json:"components"`
	Theme      string      `json:"theme,omitempty"`
}

func (self *FrontendPageSpec) DeepCopy() *FrontendPageSpec {
	if self == nil {
		return nil
	}
	out := FrontendPageSpec{}
	self.DeepCopyInto(&out)
	return &out
}

func (self *FrontendPageSpec) DeepCopyInto(out *FrontendPageSpec) {
	*out = *self
	if self.Components != nil {
		inComponents := self.Components
		outComponents := make([]Component, len(inComponents))
		i := 0
		for i < len(inComponents) {
			inComponents[i].DeepCopyInto(&outComponents[i])
			i++
		}
		out.Components = outComponents
	}
}

// Component defines a UI component on the page

type Component struct {
	Name   string
	Type   string         `json:"type"`
	Config map[string]any `json:"config,omitempty"`
}

func (self *Component) DeepCopy() *Component {
	if self == nil {
		return nil
	}
	out := Component{}
	self.DeepCopyInto(&out)
	return &out
}

func (self *Component) DeepCopyInto(out *Component) {
	*out = *self
	if self.Config != nil {
		inConfig := self.Config
		outConfig := make(map[string]any, len(inConfig))
		for key, val := range inConfig {
			outConfig[key] = val
		}
		out.Config = outConfig
	}
}

// FrontendPageStatus defines the observed state of FrontendPage

type FrontendPageStatus struct {
	Phase          string
	Message        string       `json:"message,omitempty"`
	URL            string       `json:"url,omitempty"`
	ComponentCount int          `json:"componentCount,omitempty"`
	LastUpdated    *metav1.Time `json:"lastUpdated,omitempty"`
}

func (self *FrontendPageStatus) DeepCopy() *FrontendPageStatus {
	if self == nil {
		return nil
	}
	out := FrontendPageStatus{}
	self.DeepCopyInto(&out)
	return &out
}

func (self *FrontendPageStatus) DeepCopyInto(out *FrontendPageStatus) {
	*out = *self
	if self.LastUpdated != nil {
		inLastUpdated := self.LastUpdated
		out.LastUpdated = inLastUpdated.DeepCopy()
	}
}

// FrontendPage is the Schema for the frontendpages API

type FrontendPage struct {
	TypeMeta   metav1.TypeMeta
	ObjectMeta metav1.ObjectMeta  `json:"metadata,omitempty"`
	Spec       FrontendPageSpec   `json:"spec,omitempty"`
	Status     FrontendPageStatus `json:"status,omitempty"`
}

func (self *FrontendPage) DeepCopy() *FrontendPage {
	if self == nil {
		return nil
	}
	out := FrontendPage{}
	self.DeepCopyInto(&out)
	return &out
}

func (self *FrontendPage) DeepCopyInto(out *FrontendPage) {
	*out = *self
	out.TypeMeta = self.TypeMeta
	self.ObjectMeta.DeepCopyInto(&out.ObjectMeta)
	self.Spec.DeepCopyInto(&out.Spec)
	self.Status.DeepCopyInto(&out.Status)
}

func (self *FrontendPage) DeepCopyObject() runtime.Object {
	c := self.DeepCopy()
	if c != nil {
		return c
	}
	return nil
}

// FrontendPageList contains a list of FrontendPage

type FrontendPageList struct {
	TypeMeta metav1.TypeMeta
	ListMeta metav1.ListMeta `json:"metadata,omitempty"`
	Items    []FrontendPage  `json:"items"`
}

func (self *FrontendPageList) DeepCopy() *FrontendPageList {
	if self == nil {
		return nil
	}
	out := FrontendPageList{}
	self.DeepCopyInto(&out)
	return &out
}

func (self *FrontendPageList) DeepCopyInto(out *FrontendPageList) {
	*out = *self
	out.TypeMeta = self.TypeMeta
	self.ListMeta.DeepCopyInto(&out.ListMeta)
	if self.Items != nil {
		inItems := self.Items
		outItems := make([]FrontendPage, len(inItems))
		i := 0
		for i < len(inItems) {
			inItems[i].DeepCopyInto(&outItems[i])
			i++
		}
		out.Items = outItems
	}
}

func (self *FrontendPageList) DeepCopyObject() runtime.Object {
	c := self.DeepCopy()
	if c != nil {
		return c
	}
	return nil
}
