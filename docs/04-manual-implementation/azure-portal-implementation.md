# Azure Portal Implementation Guide

## Objective
Use the Azure Portal to validate the Terraform design and confirm the live Azure environment reflects the expected landing zone model.

## Manual Steps
1. open Azure Portal and confirm the correct tenant and subscription
2. review resource groups and management groups
3. inspect the hub and spoke networking resources
4. validate Policy assignments and governance inheritance
5. review monitoring, Key Vault, and private endpoint resources

## Validation Points
- resource naming matches the expected corporate standard
- policy assignments are inherited where they should be
- networking resources follow the intended topology
- key platform services are visible and healthy

## Sign-off
Capture screenshots or exported configuration records for each major platform component before moving to higher-risk changes.
