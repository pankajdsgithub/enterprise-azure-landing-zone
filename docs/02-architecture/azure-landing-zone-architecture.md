# Azure Landing Zone Architecture

## Overview
This repository implements an Azure landing zone pattern designed around shared platform services and isolated workload environments.

## Architecture Layers
### 1. Platform Layer
The platform layer contains shared controls for:
- management groups
- network connectivity
- centralized logging
- RBAC and identity
- policy and audit controls

### 2. Workload Layer
The workload layer includes:
- dev, QA, prod landing zones
- app resource groups
- compute, data, and application resources
- secure private connectivity paths

## Design Intent
- separate controls from workloads
- centralize traffic inspection and egress control
- keep workloads isolated by environment
- enforce security and cost governance through policy

## Manual Review Checklist
- confirm subscription separation is aligned with the design
- review the address ranges before creating VNets
- confirm whether platform services are in a shared subscription or within the same deployment model
- review cost and optional services before enabling them

## Outcome
This model creates a repeatable and auditable base for secure Azure deployments and future enterprise growth.
