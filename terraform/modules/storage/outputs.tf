output "pvc_names" {
  value = {
    jenkins   = kubernetes_persistent_volume_claim.jenkins_pvc.metadata[0].name
    argocd    = kubernetes_persistent_volume_claim.argocd_pvc.metadata[0].name
    prometheus= kubernetes_persistent_volume_claim.prometheus_pvc.metadata[0].name
    grafana   = kubernetes_persistent_volume_claim.grafana_pvc.metadata[0].name
    loki      = kubernetes_persistent_volume_claim.loki_pvc.metadata[0].name
    promtail  = kubernetes_persistent_volume_claim.promtail_pvc.metadata[0].name
    kyverno   = kubernetes_persistent_volume_claim.kyverno_pvc.metadata[0].name
    nginx     = kubernetes_persistent_volume_claim.nginx_ingress_pvc.metadata[0].name
    linkerd   = kubernetes_persistent_volume_claim.linkerd_pvc.metadata[0].name
  }
}
