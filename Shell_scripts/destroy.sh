#!/bin/bash
set -e

echo "============================="
echo "DevOps cluster teardown started"
echo "============================="

# Delete Ingress resources for all tools
TOOLS=(
  "cicd|jenkins|jenkins"
  "cicd|argo-argocd-server|argocd"
  "monitoring|grafana|grafana"
  "monitoring|prometheus-server|prometheus"
)

for tool in "${TOOLS[@]}"; do
  IFS='|' read -r namespace svc_name subdomain <<< "$tool"
  kubectl delete ingress ${svc_name}-ingress -n $namespace --ignore-not-found
  kubectl delete secret ${subdomain}-tls -n $namespace --ignore-not-found
done

# Delete cert-manager and ClusterIssuer
kubectl delete clusterissuer selfsigned-issuer --ignore-not-found
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml --ignore-not-found
kubectl delete namespace cert-manager --ignore-not-found

# Delete Helm releases
helm uninstall jenkins -n cicd || true
helm uninstall argo-cd -n cicd || true
helm uninstall prometheus -n monitoring || true
helm uninstall grafana -n monitoring || true

# Delete namespaces
NAMESPACES=("cicd" "monitoring" "service" "network" "application")
for ns in "${NAMESPACES[@]}"; do
  kubectl delete namespace $ns --ignore-not-found
done

# Delete Kind cluster
kind delete cluster --name devops-cluster || true

echo "============================="
echo "DevOps cluster teardown complete"
echo "============================="