variable "ovh_endpoint" {
  description = "OVH endpoint"
  type        = string
  default     = "ovh-eu"
  sensitive   = true
}

variable "service_name" {
  # id of the OVH Cloud project
}

variable "ovh_region" {
  # default = "GRA9" # Gravelines, France
  default = "UK1" # London, France
}

variable "cluster" {
  type = object({
    name      = string
    version   = string
    node_type = string
  })
  default = {
    name      = "sandbox-cluster"
    version   = "1.32"
    node_type = "b2-7"
  }
}


variable "registry" {
  type = object({
    region = string
    plan   = string
  })
  default = {
    region = "GRA"
    plan   = "SMALL"
  }
}

variable "registry_email" {}
variable "registry_user" {}
