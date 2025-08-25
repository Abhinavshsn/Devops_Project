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
  config_path = ""            # leave blank
  config_raw  = kind_cluster.default.kubeconfig_raw
}

provider "helm" {
  kubernetes {
    config_path = ""          # leave blank
    config_raw  = kind_cluster.default.kubeconfig_raw
  }
}


