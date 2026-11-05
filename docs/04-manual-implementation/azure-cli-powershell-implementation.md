# Azure CLI and PowerShell Implementation Guide

## Objective
Use command-line automation to validate and verify the platform configuration and to support manual troubleshooting.

## Core Commands
```bash
az login
az account show --output table
az group list --output table
az policy assignment list --output table
az network vnet list --output table
az monitor log-analytics workspace list --output table
```

## PowerShell Examples
```powershell
Connect-AzAccount
Get-AzSubscription | Select-Object Name, Id, TenantId
Get-AzPolicyAssignment | Select-Object DisplayName, Scope
Get-AzVirtualNetwork | Select-Object Name, ResourceGroupName
```

## Use This For
- verifying configuration drift
- validating secure state and network conditions
- confirming resources created by Terraform are consistent with the documented design

## Exit Criteria
The CLI-based review should match the architecture intent and the expected Azure Portal view.
