#!/bin/bash
set -e

# VARIABLES
CLUSTER_NAME="devops-cluster"
KIND_CONFIG_FILE="kind-config.yaml"
VOLUME_DIR="/home/abhinav/devops-volumes"

# NAMESPACES
NAMESPACES=("cicd" "monitoring" "security" "service" "network" "inspection" "application")

# TOOLS per namespace
declare -A TOOLS
TOOLS=( 
    ["cicd"]="jenkins argo"
    ["monitoring"]="prometheus grafana loki node-exporter"
    ["security"]="kyverno"
    ["service"]="linkerd"
    ["network"]="nginx-ingress"
    ["inspection"]="kubeshark"
    ["application"]="my-java-app"
)

# CREATE KIND CONFIG FILE
cat <<EOF > $KIND_CONFIG_FILE
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
  - role: worker
EOF

echo "[INFO] Creating Kind cluster..."
kind create cluster --name $CLUSTER_NAME --config $KIND_CONFIG_FILE

# CREATE NAMESPACES
for ns in "${NAMESPACES[@]}"; do
    kubectl create namespace $ns || echo "[INFO] Namespace $ns already exists"
done

# INSTALL HELM CHARTS
echo "[INFO] Installing tools..."

# CICD
kubectl create namespace cicd || true
helm repo add jenkins https://charts.jenkins.io
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install jenkins jenkins/jenkins --namespace cicd \
    --set persistence.existingClaim="" \
    --set persistence.mountPath="$VOLUME_DIR/jenkins"
helm install argo argo/argo-cd --namespace cicd \
    --set server.extraVolumeMounts[0].mountPath="$VOLUME_DIR/argocd" \
    --set server.extraVolumeMounts[0].name="argocd-data"

# MONITORING
kubectl create namespace monitoring || true
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus --namespace monitoring \
    --set server.persistentVolume.existingClaim="" \
    --set server.persistentVolume.mountPath="$VOLUME_DIR/prometheus"
helm install grafana grafana/grafana --namespace monitoring \
    --set persistence.existingClaim="" \
    --set persistence.mountPath="$VOLUME_DIR/grafana"
# Loki stack
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki-stack --namespace monitoring \
    --set persistence.enabled=true \
    --set persistence.mountPath="$VOLUME_DIR/loki" \
    --set promtail.enabled=true \
    --set promtail.extraVolumeMounts[0].mountPath="$VOLUME_DIR/promtail"

# SECURITY
helm repo add kyverno https://kyverno.github.io/kyverno/
helm install kyverno kyverno/kyverno --namespace security \
    --set persistence.mountPath="$VOLUME_DIR/kyverno"

# SERVICE MESH
helm repo add linkerd https://helm.linkerd.io/stable
helm install linkerd linkerd/linkerd2 --namespace service

# <<< ADD THIS LINE IMMEDIATELY AFTER THE LINKERD INSTALL >>>
kubectl label namespace application linkerd.io/inject=enabled

# NETWORK
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace network \
    --set controller.extraVolumeMounts[0].mountPath="$VOLUME_DIR/nginx"

# INSPECTION
kubectl create namespace inspection || true
kubectl apply -f https://kubeshark.github.io/kubeshark/kubeshark.yaml -n inspection


echo "[INFO] All tools deployed successfully!"
echo "[INFO] KIND cluster is ready. Use 'kubectl get all -A' to see resources."
