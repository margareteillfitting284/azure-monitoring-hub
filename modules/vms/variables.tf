variable "name" {}
variable "location" {}
variable "rg" {}
variable "vm_size" {}
variable "tag" {
    type = map(string)
    default = {}
}
variable "os_name" {}
variable "computer_name" {}
variable "admin_username" {}
variable "admin_password" {
    type = string
    sensitive = true
}

variable "nic_name" {}
variable "subnet_id" {}