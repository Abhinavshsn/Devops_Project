resource "kind_cluster" "default" {
  name            = "devops-project"
  node_image      = "kindest/node:v1.27.1"
  kubeconfig_path = pathexpand("/tmp/config")
  wait_for_ready  = true

  kind_config {                                #Similar to how you write yaml to create cluster with nodes but in hcl language
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    # Control plane node with ingress ports(http on 80 and https on 443)
    node {
      role = "control-plane"

      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }

      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
      

    }

    # Worker nodes (no port mappings needed)
    node {
      role = "worker"
    }
    node {
      role = "worker"
    }
    node {
      role = "worker"
    }
  }
}
