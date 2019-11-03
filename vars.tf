variable "name" {}

variable "memory_size" {
  default = "128"
}

variable env_vars {
  default = {}
}

variable with_api_gateway {
  default = true
}

// CI/CD
variable "ci_containers_storage_name" {
  default = "tf-ci"
}
variable "ci_container_name" {
  default = ""
}
variable "repo_owner" {
  default = ""
}
variable "repo_name" {
  default = ""
}
variable "branch" {
  default = ""
}

// if you have a domain
variable "main_domain" {
  default = ""
}
variable "zone_id" {
  default = ""
}
variable "certificate_arn" {
  default = ""
}
