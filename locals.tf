locals {
  vnets = {
    "workload_vnet" = {
      address_space                = "10.0.0.0/16"
      peered_to                    = "security_hub_vnet"
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true

    }

    "security_hub_vnet" = {
      address_space                = "10.1.0.0/16"
      peered_to                    = "workload_vnet"
      allow_virtual_network_access = true
      allow_forwarded_traffic      = true
    }
  }

  subnets = {
    "workload_logic_subnet" = {
      vnet             = "workload_vnet"
      address_prefixes = "10.0.1.0/24"
    }
    "AzureBastionSubnet" = {
      vnet             = "security_hub_vnet"
      address_prefixes = "10.1.1.0/24"
    }
  }

  nsg_rules = {
    "nsg-app" = [
      {
        name                       = "allow-lb-health-probe"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-bastion-ssh"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-intra-subnet-ssh"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.1.0/24"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-intra-subnet-outbound"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.1.0/24"
        destination_address_prefix = "10.0.1.0/24"
      },
      {
        name                       = "allow-azure-monitor-outbound"
        priority                   = 110
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "AzureMonitor"
      },
      {
        name                       = "deny-all-inbound"
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-http-outbound"
        priority                   = 120
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "Internet"
      },
      {
        name                       = "allow-https-outbound"
        priority                   = 130
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "Internet"
      },
      {
        name                       = "deny-all-outbound"
        priority                   = 4096
        direction                  = "Outbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  virtual_machines = {
    "vm1" = {
      vm_size = "Standard_D2s_v3"
      tag = {
        Environment = "production"
        Role        = "webserver"
      }
    }

    "vm2" = {
      vm_size = "Standard_D2s_v3"
      tag = {
        Environment = "production"
        Role        = "webserver"
      }
    }
  }

  monitor_roles = toset([
    "Monitoring Reader",
    "Reader"
  ])

  public_ips = {
    bastion-pip = {
      name              = "bastion-pip"
      allocation_method = "Static"
      sku               = "Standard"
    }

    nat_pip = {
      name              = "monitor-nat-pip"
      allocation_method = "Static"
      sku               = "Standard"
    }
  }

  law_name            = "monitoring-law"
  action_group_name   = "monitoring-actiongroup"
  email_receiver_name = "admin-email-receiver"
  metric_alert_name   = "monitoring-metric-alert"

}