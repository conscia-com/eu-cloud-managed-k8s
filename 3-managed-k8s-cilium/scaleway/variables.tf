
variable "region" {
  default = "fr-par"
}

variable "project" {
  # Scaleway project ID  
}

variable "name" {
  default     = "sandbox"
  description = "value used to name resources in this sandbox"
}

variable "pn_cidr" {
  default = "10.0.48.0/22" # must be a min /22 CIDR block
}

variable "trusted_ip" {
  # IP address or CIDR block that is allowed to access the cluster
}

variable "cluster" {
  type = object({
    name      = string
    type      = string
    version   = string
    cni       = string
    node_type = string
  })
  default = {
    name      = "sandbox"
    type      = "kapsule"
    version   = "1.32.3"
    cni       = "cilium"
    node_type = "DEV1-M"
  }
}
