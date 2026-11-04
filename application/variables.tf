# ---------------- identity of the deployment ----------------
variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment must be dev, qa or prod."
  }
}

variable "app_name" {
  type    = string
  default = "app1"
}

variable "location" {
  type    = string
  default = "centralindia"
}

variable "location_short" {
  type    = string
  default = "cin"
}

variable "unique_suffix" {
  description = "3-5 lowercase chars making globally unique names (Key Vault, Storage, SQL)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,5}$", var.unique_suffix))
    error_message = "unique_suffix must be 3-5 lowercase letters/digits."
  }
}

variable "tags" {
  type = map(string)
  default = {
    owner      = "app-team"
    costcenter = "it-apps"
    workload   = "three-tier-sample"
    managedby  = "terraform"
  }
}

# ---------------- network ----------------
variable "spoke_address_space" {
  description = "Spoke CIDR (/22). Dev 10.10.0.0/22, QA 10.20.0.0/22, Prod 10.30.0.0/22."
  type        = string
}

variable "connectivity_subscription_id" {
  type    = string
  default = null
}

variable "hub_vnet_id" {
  type = string
}

variable "hub_vnet_name" {
  type = string
}

variable "hub_resource_group_name" {
  type = string
}

variable "firewall_private_ip" {
  description = "Hub firewall private IP. null = no firewall deployed: no UDR is created and the spoke uses default Azure internet egress."
  type        = string
  default     = null
}

variable "hub_has_gateway" {
  description = "true once a VPN/ExpressRoute gateway exists in the hub (enables gateway transit and use_remote_gateways)."
  type        = bool
  default     = false
}

variable "private_dns_zone_ids" {
  description = "Zone name => ID from platform/connectivity output."
  type        = map(string)
  default     = {}
}

variable "private_dns_resource_group_name" {
  type    = string
  default = null
}

variable "link_private_dns_to_spoke" {
  description = "Link the central zones to this spoke VNet. Set false if spokes use the firewall DNS proxy and only the hub is linked."
  type        = bool
  default     = true
}

variable "spoke_dns_servers" {
  description = "Custom DNS servers for the spoke (firewall DNS proxy IP when using Standard+ firewall)."
  type        = list(string)
  default     = []
}

# ---------------- shared platform ----------------
variable "log_analytics_workspace_id" {
  type = string
}

variable "alert_email_receivers" {
  type    = map(string)
  default = {}
}

# ---------------- compute ----------------
variable "enable_compute" {
  description = "COST: two VMs. Set false to deploy only network/security/data."
  type        = bool
  default     = true
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "vm_zones" {
  description = "Tier => availability zone, e.g. { web = \"1\", app = \"2\" } for production."
  type        = map(string)
  default     = {}
}

variable "admin_ssh_public_key" {
  description = "Public key text. Pass with TF_VAR_admin_ssh_public_key or a gitignored tfvars file."
  type        = string
  default     = null

  validation {
    condition     = var.admin_ssh_public_key != null || !var.enable_compute
    error_message = "Set admin_ssh_public_key (public key text) when enable_compute = true."
  }
}

variable "enable_load_balancer" {
  description = "COST: Standard internal Load Balancer in front of the web tier."
  type        = bool
  default     = false
}

# ---------------- data / security ----------------
variable "enable_database" {
  type    = bool
  default = true
}

variable "sql_sku_name" {
  type    = string
  default = "Basic"
}

variable "sql_zone_redundant" {
  type    = bool
  default = false
}

variable "sql_entra_admin_login" {
  type    = string
  default = null

  validation {
    condition     = !var.enable_database || (var.sql_entra_admin_login != null && var.sql_entra_admin_object_id != null)
    error_message = "enable_database = true requires sql_entra_admin_login and sql_entra_admin_object_id (Entra-only auth, no SQL password)."
  }
}

variable "sql_entra_admin_object_id" {
  type    = string
  default = null
}

variable "storage_replication_type" {
  type    = string
  default = "LRS"
}

variable "key_vault_purge_protection" {
  type    = bool
  default = false
}

variable "enable_backup" {
  description = "Recovery Services vault + daily VM backup (needs enable_compute)."
  type        = bool
  default     = true
}

variable "backup_storage_mode" {
  type    = string
  default = "LocallyRedundant"
}

variable "enable_delete_lock" {
  type    = bool
  default = false
}

variable "bastion_subnet_cidr" {
  description = "Hub AzureBastionSubnet CIDR allowed to reach SSH on the tiers."
  type        = string
  default     = "10.0.0.128/26"
}
