variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID"
}

variable "client_id" {
  type        = string
  description = "The Azure client ID"
}

variable "client_secret" {
  type        = string
  description = "The Azure client secret"
}

variable "tenant_id" {
  type        = string
  description = "The Azure tenant ID"
}



variable "environment_name" {
  type = string
}

variable "rg_name" {
  type = string
  description = "resource group name"
}

variable "adm_user" {
  type = string
  description = "user name"
  sensitive = true
}



variable "adm_pass" {
    type = string
    description = "mahad user login pass"
    sensitive = true
}

variable "keydata" {
  type = string
  sensitive = true
  description = "public key file location"
}