my-k8s-platform/
├── main.tf               # Root entrypoint - calls modules
├── providers.tf          # Declares Terraform providers (kind, kubernetes, helm)
├── variables.tf          # Root-level variables (cluster name, node count, etc.)
├── outputs.tf            # Root outputs (like kubeconfig)
├── terraform.tfvars      # Default values (cluster name, namespace list, etc.)
│
├── modules/
│   ├── cluster/          # Kind cluster module
│   │   ├── main.tf       # Define the kind_cluster resource
│   │   ├── variables.tf  # Module variables (cluster name, node config, etc.)
│   │   ├── outputs.tf    # Export kubeconfig
│   │
│   ├── namespaces/       # Namespace module
│   │   ├── main.tf       # kubernetes_namespace resources
│   │   ├── variables.tf  # Namespace list variable
│   │   ├── outputs.tf    # Export created namespaces
│   │
│   └── helm/             # (later) Helm releases for NGINX, ArgoCD, etc.
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│
└── README.md             # Documentation for your setup

# Root Layer

main.tf
Orchestrates everything by calling modules (cluster, namespaces, later helm).

providers.tf
Defines the kind, kubernetes, and helm providers.
Important: kubernetes and helm depend on the kubeconfig output from the cluster module.

variables.tf
Input variables (like cluster name, namespace list). Keeps code DRY.

outputs.tf
Outputs things like kubeconfig_path or kubeconfig_content. Useful when running kubectl or passing into CI/CD.

terraform.tfvars

# modules/cluster/

main.tf
Defines the kind_cluster resource with:

1 control plane + N workers

Port mappings (80/443)

Optional node labels

variables.tf
Cluster-specific variables (cluster_name, worker_count, extra_port_mappings).

outputs.tf
Exports the kubeconfig (either as file path or raw content).

# modules/namespaces/

main.tf
Creates Kubernetes namespaces using the kubernetes_namespace resource.
Applies labels/annotations (istio-injection=enabled for apps).

variables.tf
Accepts a list of namespace names from root.

outputs.tf
Exports the list of namespaces created (useful for Helm module later).

# modules/helm/

main.tf
Installs charts (NGINX, Prometheus, Grafana, Loki, ArgoCD, etc.) using helm_release.

variables.tf
Defines variables for each chart (version, repo, values file path).

outputs.tf
Exports installed Helm releases (can be used for debugging or dependencies).