terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
  }
}

provider "kind" {}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

#Terraform doesn’t allow using a resource (kind_cluster.default.kubeconfig_path) directly inside provider configuration, because providers are initialized before resources exist.

#Fix: use the kubeconfig output from the kind_cluster resource instead. The kind_cluster resource gives you the raw kubeconfig as a string.SO don't use a path for kubeconfig(kubeconfig_path = pathexpand("/tmp/config")) to get the details here.