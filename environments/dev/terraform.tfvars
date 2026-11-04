# DEV - lowest cost training profile. No secrets and no subscription IDs in this file.
environment         = "dev"
spoke_address_space = "10.10.0.0/22"
unique_suffix       = "x1y2z" # change: must make Key Vault / Storage / SQL names globally unique

# Values from `terraform output` of platform/connectivity and platform/management:
# hub_vnet_id, hub_vnet_name, hub_resource_group_name, firewall_private_ip,
# private_dns_zone_ids, private_dns_resource_group_name, log_analytics_workspace_id
# -> put them in environments/dev/platform.auto.tfvars (gitignored) or pass as TF_VAR_*.

enable_compute       = true
vm_size              = "Standard_B2s"
enable_load_balancer = false
enable_database      = true
sql_sku_name         = "Basic"
enable_backup        = true
