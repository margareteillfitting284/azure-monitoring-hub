variable "rg_name" {
  type    = string
  default = "monitor-rg"
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "email_receiver_email" {
  type = string
}

variable "cpu_threshold" {
  type    = number
  default = 80
}

variable "monitoring-public-ip" {
  type    = string
  default = "monitor-public-ip"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "bastion_name" {
  type    = string
  default = "monitor-bastion"

}

variable "nat_name" {
  type    = string
  default = "monitor-nat-gateway"
}

variable "account_name" {
  type    = string
  default = "monitor-automation-account"
}

variable "runbook_name" {
  default = "monitor-remediation-runbook"
}

variable "ilb_name" {
  default = "ilb_monitor_hub"
}

variable "backend_pool_name" {
  default = "vms_backend_pool"
}

variable "vms_health_probe" {
  default = "vms_health_probe"
}

variable "vms_lb_rule" {
  default = "vms_lb_rule"
}