variable "prefix" {
    type = string
    description = "prefix for all resources"
    default = "paritala"
  
}

variable "rgloc" {
    type = string
    description = "resource group location"
    default = "East US"
  
}

variable "vnet" {
    type = string
    description = "resource group location"
    default = "vnet1"
}

variable "sql-admin-login" {
    type = string
    description = "value for sql login"
}
variable "sql-admin-password" {
    type = string
    description = "value for sql admin password"
    sensitive = true
}
variable "vm-username" {
    type = string
    description = "username for virtual machine"
}
variable "vm-password" {
    type = string
    description = "password for virtual machine"
    sensitive = true

}
