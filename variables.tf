variable "list_of_subnet_cidr" {
  description = "list of subnet cidr"
  type = list(object({
    name             = string
    ip_address_range = string
  }))

  default = [
  {
    name             = "subnet-iot"
    ip_address_range = "10.0.0.0/24"
  },
  {
    name             = "subnet-bastion"
    ip_address_range = "10.0.1.0/24"
  },
  {
    name             = "subnet-dbw-public"
    ip_address_range = "10.0.2.0/24"
  },
  {
    name             = "subnet-dbw-private"
    ip_address_range = "10.0.3.0/24"
  }
  ]
}

variable "location" {
  description = "Supported Azure location where the resource deployed"
}

variable "environment" {
  description = "Name of the environment to be deployed, like dev, test, prod, etc."
}

variable "environment_version" {
  description = "Version of the environment to be deployed"
}

variable "sp_dbw_object_id" {

}

variable "key_vault_sku" {
  description = "Key vault SKU"
}

variable "subscription_id" {
}