#!/bin/bash
set -e

# VARIABLES
NAMESPACE_INGRESS="network"
INGRESS_CLASS="nginx"
CERT_MANAGER_NAMESPACE="cert-manager"
DOMAIN_SUFFIX="devops.com"   # Main domain suffix for all tools

# TOOL mapping: namespace|service|subdomain
TOOLS=(
  "cicd|jenkins|jenkins"
  "cicd|argo-argocd-server|argocd"
  "monitoring|grafana|grafana"
  "monitoring|prometheus-server|prometheus"
)

echo "[INFO] Installing cert-manager..."
kubectl create namespace $CERT_MANAGER_NAMESPACE || true
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
kubectl wait --for=condition=available --timeout=180s deployment -n $CERT_MANAGER_NAMESPACE --all
echo "[INFO] Waiting for cert-manager webhook TLS to be ready..."
sleep 20

echo "[INFO] Creating ClusterIssuer for self-signed certs..."
for i in {1..5}; do
  cat <<EOF | kubectl apply -f - && break 
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
EOF
  echo "[WARN] ClusterIssuer creation failed, retrying in 10s... (attempt $i/5)"
  sleep 10
done

echo "[INFO] Creating Ingress resources for selected tools..."

for tool in "${TOOLS[@]}"; do
  IFS='|' read -r namespace svc_name subdomain <<< "$tool"
  host="$subdomain.$DOMAIN_SUFFIX"

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
  - host: $host
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: $svc_name
            port:
              number: $(kubectl get svc $svc_name -n $namespace -o jsonpath='{.spec.ports[0].port}')
  tls:
  - hosts:
    - $host
    secretName: ${subdomain}-tls
EOF

done

echo "[INFO] All Ingress resources created successfully!"
echo "[INFO] Update /etc/hosts with:"
for tool in "${TOOLS[@]}"; do
  IFS='|' read -r _ _ subdomain <<< "$tool"
  echo "127.0.0.1 $subdomain.$DOMAIN_SUFFIX"
done
echo "[INFO] Access your tools via https://<subdomain>.$DOMAIN_SUFFIX"
