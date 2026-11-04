output "pipeline_identity_client_id" {
  description = "Use as the client ID of the Azure DevOps service connection (workload identity federation, manual)."
  value       = module.pipeline_identity.client_id
}

output "pipeline_identity_principal_id" {
  value = module.pipeline_identity.principal_id
}
