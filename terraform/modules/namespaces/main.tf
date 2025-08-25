resource "kubernetes_namespace_v1" "this" {
  for_each = var.namespaces                  #I need 7 namespaces with name and labels which are defined as variable objects(var intialised in namespaces/variables.tf but defined in root/variables.tf)

  metadata {
    name = each.key
    labels = {
      purpose = each.value.purpose
      linkerd = each.value.linkerd
    }
    annotations = {
      description = each.value.description
    }
  }
}
