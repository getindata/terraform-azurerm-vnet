variable "resource_group_name" {
  description = "Azure resource group name where resources will be deployed"
  type        = string
}

variable "location" {
  description = "Location where resources will be deployed. If not provided it will be read from resource group location"
  type        = string
  default     = null
}

variable "descriptor_name" {
  description = "Name of the descriptor used to form a resource name"
  type        = string
  default     = "azure-vnet"
}

variable "diagnostic_settings" {
  description = "Enables diagnostics settings for a resource and streams the logs and metrics to any provided sinks"
  type = object({
    enabled               = optional(bool, false)
    logs_destinations_ids = optional(list(string), [])
  })
  default  = {}
  nullable = false
}

variable "address_space" {
  description = "The address space that is used by the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "bgp_community" {
  description = "The BGP community attribute in format `<as-number>:<community-value>`"
  type        = string
  default     = null
}

variable "ddos_protection_plan" {
  description = "The set of DDoS protection plan configuration"
  type = object({
    enable = optional(bool, true)
    id     = string
  })
  default = null
}

variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  type        = list(string)
  default     = []
}

variable "nsg_ids" {
  description = "A map of subnet name to Network Security Group IDs"
  type        = map(string)
  default     = {}
}

variable "route_tables_ids" {
  description = "A map of subnet name to Route table ids"
  type        = map(string)
  default     = {}
}

variable "subnet_delegation" {
  description = "A map of subnet name to delegation block on the subnet"
  type        = map(map(any))
  default     = {}
}

variable "subnet_private_endpoint_network_policies_enabled" {
  description = "A map of subnet name to enable/disable private link endpoint network policies on the subnet"
  type        = map(bool)
  default     = {}
}

variable "subnet_private_link_service_network_policies_enabled" {
  description = "A map of subnet name to enable/disable private link service network policies on the subnet"
  type        = map(bool)
  default     = {}
}

variable "subnet_names" {
  description = "A list of public subnets inside the VNET"
  type        = list(string)
  default     = ["PrivateSubnet", "PublicSubnet"]
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "subnet_service_endpoints" {
  description = "A map of subnet name to service endpoints to add to the subnet"
  type        = map(any)
  default     = {}
}

variable "nat_gateway" {
  description = "Should the Azure NAT Gateway be deployed"
  type = object({
    enabled                 = optional(bool, false)
    subnet_names            = optional(list(string), [])
    descriptor_name         = optional(string, "azure-nat-gateway")
    idle_timeout_in_minutes = optional(number, 4)
    zones                   = optional(list(string), [])
    public_ip_prefix_ids    = optional(list(string), [])
    public_ip_address_ids   = optional(list(string), [])
    public_ip = optional(object({
      count             = optional(number, 0)
      allocation_method = optional(string, "Static")
      zones             = optional(list(string))
      ip_version        = optional(string)
      sku               = optional(string, "Standard")
      sku_tier          = optional(string)
    }), {})
  })
  default  = {}
  nullable = false
}
