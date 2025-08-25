variable "namespaces" {
  type = map(object({
    description = string
    purpose     = string
    linkerd     = string
  }))
}
