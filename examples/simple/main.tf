module "resource_group" {
  source = "github.com/getindata/terraform-azurerm-resource-group?ref=v1.2.1"

  name     = var.resource_group_name
  location = var.location
}

module "vnet" {
  source = "../../"

  name                = "example"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name

  address_space = ["10.0.0.0/16"]
  dns_servers   = ["8.8.8.8"]

  subnet_names    = ["PrivateSubnet", "PublicSubnet"]
  subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24"]
}
