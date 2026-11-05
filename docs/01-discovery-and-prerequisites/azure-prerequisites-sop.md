# Azure Prerequisites SOP

## Goal
Prepare the Azure tenant and subscription for the landing zone implementation before creating any governance or network resources.

## Pre-flight Checklist
- confirm you are using an Azure tenant with permission to create subscriptions or management groups
- confirm you have at least Owner or equivalent rights on the target subscription
- confirm the target region is approved for the landing zone
- confirm the organization naming standards and tag taxonomy
- confirm whether the project will use a single subscription or multiple subscriptions

## Required Azure CLI Checks
```bash
az login
az account show -o table
az account list -o table
az provider list --query "[?registrationState!='Registered'].[namespace,registrationState]" -o table
```

## Required Providers
Register core service providers before applying Terraform:
```bash
for p in Microsoft.Network Microsoft.Compute Microsoft.Storage \
  Microsoft.KeyVault Microsoft.Sql Microsoft.OperationalInsights \
  Microsoft.Insights Microsoft.Authorization Microsoft.ManagedIdentity \
  Microsoft.PolicyInsights Microsoft.Security; do
  az provider register --namespace $p
 done
```

## Validate Provider State
```bash
az provider show --namespace Microsoft.Network --query registrationState -o tsv
az provider show --namespace Microsoft.KeyVault --query registrationState -o tsv
```

## Operational Notes
- if provider registration is blocked, fix authorization and retry
- if region choice is unavailable, confirm quota or alternative region is approved
- keep production subscription access separate from development or sandbox use

## Exit Criteria
The tenant and subscription are confirmed, provider registration has completed, and the environment is ready for Terraform bootstrap.
