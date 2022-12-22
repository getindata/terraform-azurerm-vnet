output "name" {
  description = "Name of the VNET"
  value       = one(azurerm_virtual_network.this[*].name)
}

output "id" {
  description = "ID of the VNET"
  value       = one(azurerm_virtual_network.this[*].id)
}

output "resource_group_name" {
  description = "Name of the VNET resource group"
  value       = one(azurerm_virtual_network.this[*].resource_group_name)
}

output "address_space" {
  description = "The address space of the VNET"
  value       = one(azurerm_virtual_network.this[*].address_space)
}

output "subnets" {
  description = "List of subnet IDs"
  value       = [for subnet in azurerm_subnet.this : subnet.id]
}

output "subnets_map" {
  description = "Map of subnet IDs"
  value       = { for subnet_name, subnet in azurerm_subnet.this : subnet_name => subnet.id }
}

output "nat_gateway" {
  description = "NAT Gateway created for the VNET"
  value       = module.nat_gateway
}
