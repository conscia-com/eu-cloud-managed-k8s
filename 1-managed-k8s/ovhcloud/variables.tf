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
  default = "EU-WEST-PAR" # Gravelines, France "GRA9", London "UK1", France "EU-WEST-PAR"
}

variable "ovh_az" {
  default = "eu-west-par-a"
}

variable "cluster" {
  type = object({
    name      = string
    version   = string
    node_type = string
  })
  default = {
    name      = "sandbox-cluster"
    version   = "1.33"
    node_type = "b3-8"
  }
}

variable "network" {
  type = object({
    name          = string
    network       = string
    start         = string
    end           = string
    gateway_model = string
  })
  default = {
    name          = "sandbox-network"
    network       = "10.2.0.0/16"
    start         = "10.2.0.2"
    end           = "10.2.255.254"
    gateway_model = "s"
  }
}


variable "registry_plan" {
  default = "SMALL"
}

variable "registry_email" {}
variable "registry_user" {}
