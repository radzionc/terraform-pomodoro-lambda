variable "name" {}

// CI/CD
variable "ci_containers_storage_name" {
  default = "tf-ci"
}
variable "ci_container_name" {}
variable "repo_owner" {}
variable "repo_name" {}
variable "branch" {}

variable "memory_size" {
  default = "128"
}

variable "main_domain" {}


variable "sentry_key" {}
