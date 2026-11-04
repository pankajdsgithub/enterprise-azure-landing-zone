output "backend_config_snippet" {
  description = "Copy into environments/<env>/backend.hcl (key is set per root module)."
  value       = <<-EOT
    resource_group_name  = "${module.rg.name}"
    storage_account_name = "${module.state_storage.name}"
    use_azuread_auth     = true
  EOT
}
