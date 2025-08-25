variable "namespaces" {
  description = "Namespaces with metadata"
  type = map(object({
    description = string
    purpose     = string
    linkerd     = string
  }))

  default = {
    cicd = {                                           #this is the key and description,purpose and linkerd are values
      description = "Namespace for Jenkins and ArgoCD"
      purpose     = "CI/CDWorkloads"
      linkerd     = "disabled"
    }
    monitoring = {
      description = "Namespace for Prometheus and Grafana"
      purpose     = "Monitoring"
      linkerd     = "disabled"
    }
    logging = {
      description = "Namespace for Loki"
      purpose     = "CentralizedLogging"
      linkerd     = "disabled"
    }
    security = {
      description = "Namespace for Kyverno"
      purpose     = "SecretsManagement"
      linkerd     = "disabled"
    }
    ingress = {
      description = "Namespace for NGINX ingress controller"
      purpose     = "IngressManagement"
      linkerd     = "disabled"
    }
    linkerd = {
      description = "Namespace for Linkerd control plane"
      purpose     = "ServiceMesh"
      linkerd     = "system"
    }
    apps = {
      description = "Namespace for sample/demo apps"
      purpose     = "ApplicationWorkloads"
      linkerd     = "enabled"
    }
  }
}
