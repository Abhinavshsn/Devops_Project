#!/bin/bash
set -e

# VARIABLES
NAMESPACE_INGRESS="network"
INGRESS_CLASS="nginx"
CERT_MANAGER_NAMESPACE="cert-manager"
DOMAIN="localdevops.test"   # replace with your domain for HTTPS

# TOOLS with namespace, service name, and path
TOOLS=(
  "cicd|jenkins|/jenkins"
  "cicd|argo-cd-server|/argocd"
  "monitoring|prometheus-server|/prometheus"
  "monitoring|grafana|/grafana"
  "monitoring|loki|/loki"
  "monitoring|prometheus-node-exporter|/node-exporter"
  "security|kyverno|/kyverno"
  "service|linkerd-web|/linkerd"
  "inspection|kubeshark|/kubeshark"
  "application|my-java-app|/my-java-app"
)

echo "[INFO] Installing cert-manager..."
kubectl create namespace $CERT_MANAGER_NAMESPACE || true
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml

# Wait for cert-manager pods to be ready
kubectl wait --for=condition=available --timeout=180s deployment -n $CERT_MANAGER_NAMESPACE --all

echo "[INFO] Creating ClusterIssuer for self-signed certs..."
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
EOF

echo "[INFO] Creating Ingress resources for all tools..."

for tool in "${TOOLS[@]}"; do
  IFS='|' read -r namespace svc_name path <<< "$tool"

  cat <<EOF | kubectl apply -n $namespace -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${svc_name}-ingress
  annotations:
    kubernetes.io/ingress.class: "$INGRESS_CLASS"
    cert-manager.io/cluster-issuer: "selfsigned-issuer"
spec:
  rules:
  - host: $DOMAIN
    http:
      paths:
      - path: $path
        pathType: Prefix
        backend:
          service:
            name: $svc_name
            port:
              number: 80
  tls:
  - hosts:
    - $DOMAIN
    secretName: ${svc_name}-tls
EOF

done

echo "[INFO] All Ingress resources created successfully!"
echo "[INFO] Add to /etc/hosts: 127.0.0.1 $DOMAIN"
echo "[INFO] Access your tools via https://$DOMAIN/<tool-path>"
