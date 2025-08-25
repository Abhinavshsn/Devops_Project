# ---------------------
# Cluster
# ---------------------
module "cluster" {
  source = "./modules/cluster"
}

# ---------------------
# Namespaces
# ---------------------
module "namespaces" {
  source     = "./modules/namespaces"
  namespaces = var.namespaces
}


# ---------------------
# Tools
# ---------------------
module "helm" {
  source = "./modules/helm"
}

# ---------------------
# Storage
# ---------------------
module "storage" {
  source = "./modules/storage"
}
