variable "zone" {
  default = "ch-dk-2"
}

variable "cluster" {
  type = object({
    name           = string
    version        = string
    cni            = string
    service_level  = string
    instance_type  = string
    instance_count = number
  })
  default = {
    name           = "sandbox-cluster"
    version        = "1.33.2"
    cni            = "cilium"
    service_level  = "starter"
    instance_type  = "standard.small"
    instance_count = 1
  }
}
