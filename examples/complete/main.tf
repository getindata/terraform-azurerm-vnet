module "resource_group" {
  source  = "github.com/getindata/terraform-azurerm-resource-group?ref=v1.2.1"
  context = module.this.context

  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = module.this.id
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  tags                = module.this.tags
  sku                 = "PerGB2018"
}

resource "azurerm_route_table" "this" {
  name                = module.this.id
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
}

resource "azurerm_network_security_group" "private" {
  name                = module.this.id
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
}

module "vnet" {
  source  = "../../"
  context = module.this.context

  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  address_space = ["10.0.0.0/16"]
  dns_servers   = ["8.8.8.8"]

  subnet_names    = ["PrivateSubnet", "PublicSubnet"]
  subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24"]
  subnet_service_endpoints = {
    PrivateSubnet = ["Microsoft.Storage"]
  }

  route_tables_ids = {
    PrivateSubnet = azurerm_route_table.this.id
  }
  nsg_ids = {
    PublicSubnet = azurerm_network_security_group.private.id
  }

  nat_gateway = {
    enabled      = true
    subnet_names = ["PrivateSubnet", "PublicSubnet"]
    public_ip = {
      count = 2
    }
  }

  diagnostic_settings = {
    enabled = true
    logs_destinations_ids = [
      azurerm_log_analytics_workspace.this.id
    ]
  }
}
