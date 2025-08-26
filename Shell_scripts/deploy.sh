#!/bin/bash
set -e

LOG_FILE="$HOME/devops_setup_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "============================="
echo "DevOps cluster setup started"
echo "Log file: $LOG_FILE"
echo "============================="

# VARIABLES
CLUSTER_NAME="devops-cluster"
KIND_CONFIG_FILE="kind-config.yaml"
VOLUME_DIR="/home/abhinav/devops-volumes"

# NAMESPACES
NAMESPACES=("cicd" "monitoring" "service" "network" "application")

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

# CREATE KIND CONFIG FILE WITH RESOURCE LIMITS
cat <<EOF > $KIND_CONFIG_FILE
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker

EOF


echo "[INFO] Creating Kind cluster..."
kind create cluster --name $CLUSTER_NAME --config $KIND_CONFIG_FILE || echo "[INFO] Cluster may already exist"
kubectl label node devops-cluster-worker monitoring=true
kubectl label node devops-cluster-worker2 cicd=true
kubectl label node devops-cluster-worker3 application=true


# CREATE NAMESPACES
for ns in "${NAMESPACES[@]}"; do
    kubectl create namespace $ns || echo "[INFO] Namespace $ns already exists"
done

# HELM REPO SETUP
helm repo add jenkins https://charts.jenkins.io
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo add linkerd https://helm.linkerd.io/stable
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

echo "[INFO] Installing tools..."

# CICD
helm upgrade --install jenkins jenkins/jenkins --namespace cicd \
    --set persistence.existingClaim="" \
    --set persistence.mountPath="$VOLUME_DIR/jenkins" \
    --set nodeSelector."cicd"="true" \
    --set resources.requests.cpu="250m" \
    --set resources.requests.memory="512Mi" \
    --set resources.limits.cpu="500m" \
    --set resources.limits.memory="1Gi"

helm upgrade --install argo argo/argo-cd --namespace cicd \
    --set server.extraVolumeMounts[0].mountPath="$VOLUME_DIR/argocd" \
    --set server.extraVolumeMounts[0].name="argocd-data" \
    --set server.extraVolumes[0].name="argocd-data" \
    --set server.extraVolumes[0].hostPath.path="$VOLUME_DIR/argocd" \
    --set nodeSelector."cicd"="true" \
    --set server.resources.requests.cpu="100m" \
    --set server.resources.requests.memory="256Mi" \
    --set server.resources.limits.cpu="250m" \
    --set server.resources.limits.memory="512Mi"

# MONITORING
helm upgrade --install prometheus prometheus-community/prometheus --namespace monitoring \
  --set server.persistentVolume.existingClaim="" \
  --set server.persistentVolume.mountPath="$VOLUME_DIR/prometheus" \
  --set nodeSelector."monitoring"="true" \
  --set server.resources.requests.cpu="250m" \
  --set server.resources.requests.memory="512Mi" \
  --set server.resources.limits.cpu="500m" \
  --set server.resources.limits.memory="1Gi"

helm uninstall grafana -n monitoring
helm upgrade --install grafana grafana/grafana --namespace monitoring \
  --set persistence.existingClaim="" \
  --set persistence.mountPath="$VOLUME_DIR/grafana" \
  --set resources.requests.cpu="100m" \
  --set resources.requests.memory="256Mi" \
  --set resources.limits.cpu="250m" \
  --set resources.limits.memory="512Mi"

helm upgrade --install loki grafana/loki-stack --namespace monitoring \
  --set persistence.enabled=true \
  --set persistence.mountPath="$VOLUME_DIR/loki" \
  --set promtail.enabled=true \
  --set promtail.extraVolumes[0].name="promtail-data" \
  --set promtail.extraVolumes[0].hostPath.path="$VOLUME_DIR/promtail" \
  --set promtail.extraVolumeMounts[0].name="promtail-data" \
  --set promtail.extraVolumeMounts[0].mountPath="$VOLUME_DIR/promtail" \
  --set nodeSelector."monitoring"="true" \
  --set loki.resources.requests.cpu="200m" \
  --set loki.resources.requests.memory="512Mi" \
  --set loki.resources.limits.cpu="400m" \
  --set loki.resources.limits.memory="1Gi" \
  --set promtail.resources.requests.cpu="50m" \
  --set promtail.resources.requests.memory="128Mi" \
  --set promtail.resources.limits.cpu="100m" \
  --set promtail.resources.limits.memory="256Mi"

# SECURITY
helm upgrade --install kyverno kyverno/kyverno --namespace security \
    --set persistence.mountPath="$VOLUME_DIR/kyverno" \
    --set resources.requests.cpu="50m" \
    --set resources.requests.memory="128Mi" \
    --set resources.limits.cpu="100m" \
    --set resources.limits.memory="256Mi"

# NETWORK
helm upgrade --install nginx-ingress ingress-nginx/ingress-nginx --namespace network \
    --set controller.extraVolumeMounts[0].mountPath="$VOLUME_DIR/nginx" \
    --set controller.extraVolumeMounts[0].name="nginx-data" \
    --set controller.extraVolumes[0].name="nginx-data" \
    --set controller.extraVolumes[0].hostPath.path="$VOLUME_DIR/nginx" \
    --set controller.resources.requests.cpu="50m" \
    --set controller.resources.requests.memory="128Mi" \
    --set controller.resources.limits.cpu="100m" \
    --set controller.resources.limits.memory="256Mi"


# -------------------------
# SERVICE MESH: Linkerd CLI
# -------------------------
echo "[INFO] Installing Linkerd via CLI..."

# Install Linkerd CLI if not already installed
if ! command -v linkerd &> /dev/null; then
    echo "[INFO] Installing Linkerd CLI..."
    curl -sL https://run.linkerd.io/install | sh
    export PATH=$PATH:$HOME/.linkerd2/bin
else
    echo "[INFO] Linkerd CLI already installed"
fi

# Validate cluster pre-install
linkerd check --pre || true

# Install Linkerd control plane
linkerd install | kubectl apply -f -

# Wait for control plane to be ready
echo "[INFO] Waiting for Linkerd control plane to be ready..."
kubectl -n linkerd wait --for=condition=available deployment --all --timeout=300s

# Enable Linkerd injection only in application namespace
kubectl label namespace application linkerd.io/inject=enabled --overwrite

echo "[INFO] Linkerd installation and namespace injection completed"

echo "[INFO] All tools deployed successfully!"
echo "[INFO] KIND cluster is ready. Use 'kubectl get all -A' to see resources."
