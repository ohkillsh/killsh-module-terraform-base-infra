variable "environment" {
  type        = string
  description = "environment variables on files .tfvars"
}

variable "client_id" {
  type        = string
  description = "Client Id of service Principal for auth on environment"
}

variable "product" {
  type        = string
  description = "the name is used on resources of product or subscription"
}


#variable "tags" {
#  type = map(strig)
#}
