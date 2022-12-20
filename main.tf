data "azurerm_resource_group" "this" {
  count = local.enabled && var.location == null ? 1 : 0

  name = var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  count = local.enabled ? 1 : 0

  name = local.name_from_descriptor

  location            = local.location
  resource_group_name = local.resource_group_name

  address_space = var.address_space
  bgp_community = var.bgp_community
  dns_servers   = var.dns_servers

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan != null ? [var.ddos_protection_plan] : []

    content {
      enable = ddos_protection_plan.value.enable
      id     = ddos_protection_plan.value.id
    }
  }

  tags = module.this.tags
}

resource "azurerm_subnet" "this" {
  for_each = local.enabled ? toset(var.subnet_names) : []

  address_prefixes                              = [local.subnet_names_prefixes[each.value]]
  name                                          = each.value
  resource_group_name                           = local.resource_group_name
  virtual_network_name                          = one(azurerm_virtual_network.this[*].name)
  private_endpoint_network_policies_enabled     = lookup(var.subnet_private_endpoint_network_policies_enabled, each.value, false)
  private_link_service_network_policies_enabled = lookup(var.subnet_private_link_service_network_policies_enabled, each.value, false)
  service_endpoints                             = lookup(var.subnet_service_endpoints, each.value, null)

  dynamic "delegation" {
    for_each = lookup(var.subnet_delegation, each.value, {})

    content {
      name = delegation.key

      service_delegation {
        name    = lookup(delegation.value, "service_name")
        actions = lookup(delegation.value, "service_actions", [])
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "vnet" {
  for_each = local.enabled ? var.nsg_ids : {}

  network_security_group_id = each.value
  subnet_id                 = azurerm_subnet.this[each.key].id
}

resource "azurerm_subnet_route_table_association" "vnet" {
  for_each = local.enabled ? var.route_tables_ids : {}

  route_table_id = each.value
  subnet_id      = azurerm_subnet.this[each.key].id
}

module "nat_gateway" {
  source  = "getindata/nat-gateway/azurerm"
  version = "1.0.2"
  context = module.this.context

  enabled = local.nat_gateway_enabled

  location            = local.location
  resource_group_name = local.resource_group_name

  descriptor_name         = var.nat_gateway.descriptor_name
  idle_timeout_in_minutes = var.nat_gateway.idle_timeout_in_minutes
  zones                   = var.nat_gateway.zones
  public_ip_prefix_ids    = var.nat_gateway.public_ip_prefix_ids
  public_ip_address_ids   = var.nat_gateway.public_ip_address_ids
  public_ip = merge(
    var.nat_gateway.public_ip,
    { diagnostic_settings = var.diagnostic_settings }
  )

  subnet_ids = [for subnet_name in var.nat_gateway.subnet_names : azurerm_subnet.this[subnet_name].id]
}

module "diagnostic_settings" {
  count = local.enabled && var.diagnostic_settings.enabled != null ? 1 : 0

  source  = "claranet/diagnostic-settings/azurerm"
  version = "6.2.0"

  resource_id           = one(azurerm_virtual_network.this[*].id)
  logs_destinations_ids = var.diagnostic_settings.logs_destinations_ids
}
