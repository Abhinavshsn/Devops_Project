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
      purpose     = "CI/CD workloads"
      linkerd     = "disabled"
    }
    monitoring = {
      description = "Namespace for Prometheus and Grafana"
      purpose     = "Monitoring"
      linkerd     = "disabled"
    }
    logging = {
      description = "Namespace for Loki"
      purpose     = "Centralized Logging"
      linkerd     = "disabled"
    }
    security = {
      description = "Namespace for Kyverno"
      purpose     = "Secrets Management"
      linkerd     = "disabled"
    }
    ingress = {
      description = "Namespace for NGINX ingress controller"
      purpose     = "Ingress management"
      linkerd     = "disabled"
    }
    linkerd = {
      description = "Namespace for Linkerd control plane"
      purpose     = "Service Mesh"
      linkerd     = "system"
    }
    apps = {
      description = "Namespace for sample/demo apps"
      purpose     = "Application workloads"
      linkerd     = "enabled"
    }
  }
}
