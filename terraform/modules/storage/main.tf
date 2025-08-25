#################################
# CI/CD TOOLS
#################################

# Jenkins
resource "kubernetes_persistent_volume" "jenkins_pv" {
  metadata {
    name = "jenkins-pv"
  }

  spec {
    capacity = { storage = "1Gi" }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path { path = "${var.base_path}/jenkins" }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "jenkins_pvc" {
  metadata {
    name      = "jenkins-pvc"
    namespace = "cicd"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "1Gi" }
    }
    volume_name = kubernetes_persistent_volume.jenkins_pv.metadata[0].name
  }
}

# ArgoCD
resource "kubernetes_persistent_volume" "argocd_pv" {
  metadata {
    name = "argocd-pv"
  }

  spec {
    capacity = { storage = "1Gi" }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path { path = "${var.base_path}/argocd" }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "argocd_pvc" {
  metadata {
    name      = "argocd-pvc"
    namespace = "cicd"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "1Gi" }
    }
    volume_name = kubernetes_persistent_volume.argocd_pv.metadata[0].name
  }
}

#################################
# MONITORING
#################################

# Prometheus
resource "kubernetes_persistent_volume" "prometheus_pv" {
  metadata {
    name = "prometheus-pv"
  }

  spec {
    capacity = { storage = "1Gi" }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path { path = "${var.base_path}/prometheus" }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "prometheus_pvc" {
  metadata {
    name      = "prometheus-pvc"
    namespace = "monitoring"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "1Gi" }
    }
    volume_name = kubernetes_persistent_volume.prometheus_pv.metadata[0].name
  }
}

# Grafana
resource "kubernetes_persistent_volume" "grafana_pv" {
  metadata {
    name = "grafana-pv"
  }

  spec {
    capacity = { storage = "1Gi" }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path { path = "${var.base_path}/grafana" }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "grafana_pvc" {
  metadata {
    name      = "grafana-pvc"
    namespace = "monitoring"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "1Gi" }
    }
    volume_name = kubernetes_persistent_volume.grafana_pv.metadata[0].name
  }
}

#################################
# LOGGING
#################################

# Loki
resource "kubernetes_persistent_volume" "loki_pv" {
  metadata {
    name = "loki-pv"
  }

  spec {
    capacity = { storage = "1Gi" }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path { path = "${var.base_path}/loki" }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "loki_pvc" {
  metadata {
    name      = "loki-pvc"
    namespace = "logging"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "1Gi" }
    }
    volume_name = kubernetes_persistent_volume.loki_pv.metadata[0].name
  }
}

# Promtail
resource "kubernetes_persistent_volume" "promtail_pv" {
  metadata {
    name = "promtail-pv"
  }

  spec {
    capacity = { storage = "1Gi" }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path { path = "${var.base_path}/promtail" }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "promtail_pvc" {
  metadata {
    name      = "promtail-pvc"
    namespace = "logging"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "1Gi" }
    }
    volume_name = kubernetes_persistent_volume.promtail_pv.metadata[0].name
  }
}

#################################
# SECURITY
#################################

# Kyverno
resource "kubernetes_persistent_volume" "kyverno_pv" {
  metadata {
    name = "kyverno-pv"
  }

  spec {
    capacity = { storage = "1Gi" }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path { path = "${var.base_path}/kyverno" }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "kyverno_pvc" {
  metadata {
    name      = "kyverno-pvc"
    namespace = "security"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "1Gi" }
    }
    volume_name = kubernetes_persistent_volume.kyverno_pv.metadata[0].name
  }
}

#################################
# INGRESS
#################################

# Nginx Ingress
resource "kubernetes_persistent_volume" "nginx_ingress_pv" {
  metadata {
    name = "nginx-ingress-pv"
  }

  spec {
    capacity = { storage = "1Gi" }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path { path = "${var.base_path}/nginx-ingress" }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "nginx_ingress_pvc" {
  metadata {
    name      = "nginx-ingress-pvc"
    namespace = "ingress"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "1Gi" }
    }
    volume_name = kubernetes_persistent_volume.nginx_ingress_pv.metadata[0].name
  }
}

#################################
# SERVICE MESH
#################################

# Linkerd
resource "kubernetes_persistent_volume" "linkerd_pv" {
  metadata {
    name = "linkerd-pv"
  }

  spec {
    capacity = { storage = "1Gi" }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
      host_path { path = "${var.base_path}/linkerd" }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "linkerd_pvc" {
  metadata {
    name      = "linkerd-pvc"
    namespace = "linkerd"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = { storage = "1Gi" }
    }
    volume_name = kubernetes_persistent_volume.linkerd_pv.metadata[0].name
  }
}
