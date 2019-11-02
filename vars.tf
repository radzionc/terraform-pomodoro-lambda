variable "name" {}

variable "memory_size" {
  default = "128"
}

// CI/CD
variable "ci_containers_storage_name" {
  default = "tf-ci"
}
variable "ci_container_name" {}
variable "repo_owner" {}
variable "repo_name" {}
variable "branch" {}

// if you have a domain
variable "main_domain" {}
variable "zone_id" {}
variable "certificate_arn" {}

variable "sentry_key" {}
