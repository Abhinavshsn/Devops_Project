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
  config_path = local_file.kubeconfig.filename
  depends_on  = [local_file.kubeconfig]
}

provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
    depends_on  = [local_file.kubeconfig]
  }
}


