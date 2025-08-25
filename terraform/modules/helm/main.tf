#################################
# CI/CD TOOLS
#################################
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = "cicd"

  create_namespace = false
  wait             = true
  timeout          = 600
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "cicd"

  create_namespace = false
  wait             = true
  timeout          = 600
}

#################################
# MONITORING
#################################
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

  create_namespace = false
  wait             = true
  timeout          = 600
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"

  create_namespace = false
  wait             = true
  timeout          = 600
}

#################################
# LOGGING
#################################
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = "logging"

  create_namespace = false
  wait             = true
  timeout          = 600
}

resource "helm_release" "promtail" {
  name       = "promtail"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  namespace  = "logging"

  create_namespace = false
  wait             = true
  timeout          = 600
}

#################################
# SECURITY
#################################
resource "helm_release" "kyverno" {
  name       = "kyverno"
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  namespace  = "security"

  create_namespace = false
  wait             = true
  timeout          = 600
}

#################################
# INGRESS
#################################
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress"

  create_namespace = false
  wait             = true
  timeout          = 600
}

#################################
# SERVICE MESH
#################################
resource "helm_release" "linkerd" {
  name       = "linkerd"
  repository = "https://helm.linkerd.io/stable"
  chart      = "linkerd2"
  namespace  = "linkerd"

  create_namespace = false
  wait             = true
  timeout          = 600
}

#################################
# CERT MANAGER
#################################
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "security"

  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      installCRDs = true
    })
  ]
}


#################################
# Let's encrypt ClusterIssuer
#################################
resource "kubernetes_manifest" "selfsigned_clusterissuer" {
  manifest = yamldecode(<<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-cluster-issuer
spec:
  selfSigned: {}
YAML
  )
  depends_on = [helm_release.cert_manager]
}

#################################
# TOOLS INGRESS WITH TLS
#################################
resource "kubernetes_manifest" "tools_ingress" {
  manifest   = yamldecode(file("${path.module}/tools-ingress.yaml"))
  depends_on = [
    helm_release.nginx_ingress,
    helm_release.cert_manager,
    kubernetes_manifest.selfsigned_clusterissuer
  ]
}

resource "kubernetes_manifest" "tools_ingress" {
  manifest = yamldecode(file("${path.module}/tools-ingress.yaml"))
  depends_on = [helm_release.nginx_ingress]
}
