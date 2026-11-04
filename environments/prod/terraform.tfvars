# PROD profile - shows the production design. Costs materially more; deploy only deliberately.
environment         = "prod"
spoke_address_space = "10.30.0.0/22"
unique_suffix       = "x1y2z"

enable_compute             = true
vm_size                    = "Standard_D2s_v5"
vm_zones                   = { web = "1", app = "2" } # zone-spread tiers
enable_load_balancer       = true
enable_database            = true
sql_sku_name               = "GP_Gen5_2"
sql_zone_redundant         = true
storage_replication_type   = "GZRS"
key_vault_purge_protection = true
enable_backup              = true
backup_storage_mode        = "GeoRedundant"
enable_delete_lock         = true
