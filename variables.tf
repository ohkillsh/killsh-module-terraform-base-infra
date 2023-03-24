
variable "product" {
  type        = string
  description = "the name is used on resources of product or subscription"
}

variable "location" {
  type        = string
  description = "Location of resources"
}

variable "environment" {
  type        = string
  description = "environment variables on files .tfvars"
}

variable "sp_client_id" {
  type        = string
  description = "Client Id of service Principal for auth on environment"
}

variable "sp_object_id" {
  type        = string
  description = "Object Id of service Principal for giving permission on Key Vault"
}

variable "sp_client_secret" {
  type      = string
  sensitive = true
}

variable "user_tags" {
  default = null
  type    = map(string)
}
