# Enterprise Azure Landing Zone Architecture Guide

## 1. Purpose and outcome

This document captures the architecture of the repository as an enterprise Azure landing zone. It is written from an architect’s point of view and explains the journey from business and technical requirements through the high-level design (HLD), low-level design (LLD), and the actual implementation represented by the Terraform modules and platform roots in this repository.

The end state is a repeatable, governed, secure, and scalable Azure foundation that supports multiple workloads, separate environments, centralized logging, private connectivity, and a modern Infrastructure as Code delivery model.

---

## 2. Business context

The repository describes a common enterprise transformation pattern:

- move workloads from an on-premises data center to Azure
- keep dev, QA, and production isolated
- centralize governance, cost visibility, and auditability
- provide secure private connectivity and centralized egress
- implement repeatable IaC pipelines
- support a migration pattern for a portfolio of applications rather than a single workload

The project is intentionally structured as a training and interview-prep landing zone but follows the practical shape of a real enterprise implementation.

---

## 3. Requirements synthesis

### 3.1 Business requirements

| ID | Requirement | Architectural intent |
|---|---|---|
| BR-01 | Migrate 50 applications from on-premises to Azure | Build a scalable landing zone pattern for multiple app teams |
| BR-02 | Separate Dev, QA and Production | Environment isolation with separate subscriptions, networking, and state |
| BR-03 | Central governance and compliance | Management groups, Azure Policy, tags, role-based access control |
| BR-04 | Private connectivity to on-premises | Hub-and-spoke architecture with optional gateway paths |
| BR-05 | Central traffic inspection | Firewall and route control in the connectivity platform |
| BR-06 | Auditability and centralized logging | Central Log Analytics, Azure Monitor, and activity logs |
| BR-07 | Backup, business continuity and DR | Backup vault, private endpoints, and future ASR strategy |
| BR-08 | Repeatable, auditable deployment | Terraform + Azure DevOps CI/CD + remote state |

### 3.2 Technical requirements

| ID | Requirement | Implementation approach |
|---|---|---|
| TR-01 | Hub-spoke topology | Dedicated connectivity subscription with VNet peering |
| TR-02 | No public IPs on workloads | Private-only network design and private endpoints |
| TR-03 | PaaS accessed via private endpoints | Storage, Key Vault, SQL with private DNS |
| TR-04 | Entra ID + Azure RBAC | Platform identity and workload identities with federated credentials |
| TR-05 | No secrets in code or pipelines | Managed identities and OIDC-based CI/CD |
| TR-06 | Policy-enforced guardrails | Azure Policy at management group scope |
| TR-07 | Centralized observability | Log Analytics workspace and Azure Monitor rules |
| TR-08 | Locked and isolated state | Storage-backed remote Terraform state with RBAC |

### 3.3 Non-functional requirements

- Security: least privilege, private-only access, encrypted at rest/in transit
- Reliability: isolated environments, zone-aware services, optional backup and DR design
- Scalability: standard landing zone patterns reusable by multiple app teams
- Cost control: expensive services are disabled by default
- Maintainability: IaC modules, environment separation, and phase-based implementation

---

## 4. Architecture principles

The design follows a few governing principles:

1. Separate platform from workload.
   - Platform subscriptions own connectivity, identity, governance, and monitoring.
   - Workloads live in app landing zones, not mixed into platform services.

2. Default to private access.
   - Public access is explicitly denied or avoided by default.
   - The system uses private DNS, private endpoints, and hub routing to keep traffic inside Azure.

3. Centralize common controls.
   - Firewall, DNS, monitoring, and policy are centralized in shared subscriptions.

4. Keep environments isolated.
   - Dev, QA, and prod are separate address spaces and state contexts.

5. Prefer guardrails over manual intervention.
   - Azure policies and role assignments enforce standards instead of relying on human discipline alone.

6. Keep cost and risk adjustable.
   - Expensive services such as firewall, Bastion, Defender plans, and ER/VPN gateways are optional and disabled by default.

---

## 5. High-Level Design (HLD)

### 5.1 HLD overview

The solution is a multi-subscription Azure landing zone built around a hub-spoke network model.

- The connectivity subscription hosts the shared hub network
- The management subscription hosts central observability and security operations
- The identity subscription hosts pipeline and RBAC-related identity assets
- Landing zones host workloads for dev, QA, and production

### 5.2 Management group structure

The governance root creates a hierarchy similar to:

- Tenant Root
  - Contoso root management group
    - Platform
      - Connectivity
      - Management
      - Identity
    - Landing Zones
      - Non-Production
      - Production
    - Sandbox
    - Decommissioned

This structure enables organization-wide governance and policy inheritance while keeping platform and workload responsibilities distinct.

### 5.3 Network HLD

The hub network is the shared transit and shared platform layer. Each workload spoke is connected through VNet peering to the hub. Traffic from spokes is forced through the firewall or controlled egress path. The private DNS zone structure provides resolution for private endpoints for SQL, Key Vault, and Storage.

The platform network includes:

- hub VNet for shared services
- GatewaySubnet reserved for future VPN/ExpressRoute gateway integration
- AzureFirewallSubnet for optional firewall
- AzureBastionSubnet for optional jump-box access
- management and shared subnets

Each spoke includes:

- web subnet
- app subnet
- private endpoint subnet

### 5.4 Security HLD

Security in this design is layered.

- Azure Policy enforces location restrictions, tags, and secure configuration defaults
- NSGs restrict traffic between subnets and controlled ingress
- Private endpoints keep PaaS resources off the public internet
- Managed identities avoid embedded secrets and long-lived credentials
- Azure RBAC provides granular access control across management groups, subscriptions, and resources

### 5.5 Observability HLD

Central Log Analytics acts as the control plane for operational telemetry. The design sends resource diagnostics, activity logs, and VM agent data to a central workspace in the management subscription.

This enables:

- centralized troubleshooting
- alerting for CPU, health, and security events
- monitoring of platform and workload resources from one place
- operational reporting and dashboards

### 5.6 Identity and access model

The architecture uses Microsoft Entra ID and Azure RBAC. Identity responsibilities are separated as follows:

- Human administrators use Entra ID groups and PIM eligibility
- Platform control plane uses a pipeline managed identity with OIDC federation
- Applications use user-assigned or system-assigned identities
- Secrets are not stored in code or YAML pipelines

### 5.7 Backup and DR HLD

The design includes backup for VMs and data services and leaves the DR strategy defined for future production hardening. The architecture formally recognizes that Azure Site Recovery and a production ExpressRoute/VPN design are required for full enterprise resilience but are optional in the current training implementation.

### 5.8 IaC and delivery HLD

The repository implements a phased Terraform delivery model:

- bootstrap-state: creates the remote state storage
- governance: management groups and policies
- connectivity: hub network, firewall, DNS, peering
- management: Log Analytics and monitoring
- identity: pipeline identity and RBAC
- application: environment-specific spoke, SQL, Key Vault, private endpoints, VM workload

CI/CD pipelines support validation, plan, and apply workflows, with OIDC federation instead of client secrets.

---

## 6. Low-Level Design (LLD)

### 6.1 Address planning

The project defines a deterministic IP model. Example design:

| Range | Use |
|---|---|
| 10.0.0.0/23 | Hub network |
| 10.10.0.0/22 | Dev spoke |
| 10.20.0.0/22 | QA spoke |
| 10.30.0.0/22 | Prod spoke |
| Reserved | Future expansion and on-prem overlap control |

Subnet split examples:

| VNet | Subnet | Purpose |
|---|---|---|
| Hub | AzureFirewallSubnet | Azure Firewall |
| Hub | AzureBastionSubnet | Jump host access |
| Hub | GatewaySubnet | Optional gateway |
| Hub | snet-shared | Shared services |
| Hub | snet-mgmt | Management access |
| Spoke | snet-web | Web tier |
| Spoke | snet-app | App tier |
| Spoke | snet-pe | Private endpoints |

### 6.2 Routing and firewall design

The design intentionally routes default egress through the firewall. This is implemented by creating a UDR on the spoke subnets that sends 0.0.0.0/0 to the firewall virtual appliance address. Spokes peer only to the hub, so traffic is centralized and controlled.

This has architectural value because it creates a single inspection point instead of allowing each spoke to exit directly to the internet.

### 6.3 NSG design

The repository creates separate NSG rules for web, app, and private-endpoint subnets to enforce least privilege. Examples:

- allow HTTPS to web subnet from approved sources
- allow app-to-app traffic from web to app tier only
- allow SSH from bastion subnet only
- deny all other inbound traffic

This avoids broad open access and supports a simple security model for a lab and a realistic enterprise baseline.

### 6.4 DNS and private endpoint design

Private DNS zones are centralized in the connectivity subscription and linked to the hub and spokes. Key services like Storage, Key Vault, and SQL register and resolve through private links. The model makes the backend services accessible only within the network boundary and reduces public exposure.

### 6.5 Compute and application tier design

The application root creates a two-tier VM model:

- web tier VM(s)
- app tier VM(s)

These are deployed into the spoke VNet and can be attached to a standard internal load balancer when enabled. The design keeps load balancing optional to control cost and complexity, while still supporting a production-ready pattern.

### 6.6 Data platform design

The workload root provisions:

- Storage account with private-only access and public network disabled
- Key Vault with RBAC-based access control and private endpoint
- Azure SQL logical server and database with Entra admin configuration
- Private endpoints for each service

The solution does not expose data services publicly and instead restricts them to the private network.

### 6.7 Monitoring and alerting design

The monitoring layer includes:

- central Log Analytics workspace
- action group for alert notifications
- VM Data Collection Rule to pull metrics and logs
- application insights for app telemetry
- CPU metric alerts on VM resources

This provides the essential first layer of operational governance for a production landing zone.

### 6.8 Terraform implementation details

The repository uses one Terraform root per platform layer and a separate application root with environment variables.

Key state separation:

- bootstrap-state: remote state bootstrap
- governance: management group and policy state
- connectivity: hub network state
- management: monitoring state
- identity: identity and RBAC state
- application dev/qa/prod: workload state separated by environment

This is a healthier model than a single monolithic Terraform state because platform and workload changes can be managed independently and with different approval gates.

---

## 7. Component-by-component implementation map

### 7.1 Bootstrap state

Path: `platform/bootstrap-state`

Goal: create the Azure storage backend used for Terraform remote state.

Purpose:
- central state control
- locking and versioning
- consistent environment boundaries

### 7.2 Governance

Path: `platform/governance`

Includes:
- management group hierarchy
- built-in policies
- custom policy definitions
- policy initiatives and assignments
- tag governance

This section is key because it establishes the guardrails for everything deployed afterward.

### 7.3 Connectivity

Path: `platform/connectivity`

Includes:
- hub VNet and subnets
- NSGs for shared and management subnets
- optional Azure Firewall
- optional Bastion
- private DNS zones and VNet links

This is the network foundation for all spoke workloads.

### 7.4 Management

Path: `platform/management`

Includes:
- Log Analytics workspace
- action group
- activity log configuration
- Defender plans and contact settings

This establishes centralized operational visibility and security monitoring.

### 7.5 Identity

Path: `platform/identity`

Includes:
- user-assigned managed identity for the Terraform pipeline
- workload identity federation configuration
- Azure RBAC assignments to Entra groups and service identities

This is the control layer for secure automation without secrets.

### 7.6 Application workload root

Path: `application`

Includes:
- spoke VNet creation
- route table + NSG rules
- VNet peering to hub
- private DNS links
- managed identity
- Key Vault, Storage, SQL, and private endpoints
- VM compute layer
- monitoring and backup modules

This is the main landing-zone workload environment root and reflects a complete application pod.

---

## 8. Step-by-step implementation sequence

This is the recommended execution order from an architect’s and platform operations perspective:

1. Confirm business and regulatory requirements.
2. Define the management group hierarchy and subscription model.
3. Prepare the Azure tenant and identity boundaries.
4. Bootstrap Terraform state.
5. Deploy governance and policy baseline.
6. Deploy connectivity and hub network.
7. Deploy management and central analytics.
8. Deploy identity and pipeline credentials.
9. Deploy the application spoke network and DNS integration.
10. Deploy storage, Key Vault, SQL, and private endpoints.
11. Deploy compute VMs and any load balancer.
12. Validate routing, DNS resolution, and security boundaries.
13. Turn on monitoring, alerting, and backup policies.
14. Validate compliance and operational readiness.
15. Progress to production rollout with standardized change control.

---

## 9. Key architect decisions and trade-offs

### 9.1 Hub-spoke instead of flat network

This is the strongest enterprise pattern for centralized egress, inspection, and connectivity. It is better suited for a governed landing zone than a flat VNet model.

### 9.2 Private-only workload access

Private endpoints and no public access are considered critical enterprise defaults. They support secure architecture and align with cloud best practices.

### 9.3 Centralized monitoring and diagnostics

The design avoids isolated resource monitoring by pushing all logs into a shared Log Analytics workspace. This is crucial for governance and operations.

### 9.4 Policy-first governance

Azure Policy is a strategic control plane in this repo. It creates the baseline before workloads are deployed and reduces drift over time.

### 9.5 Cost-aware defaults

The repo intentionally disables expensive services by default. The architecture can be expanded to production-grade patterns later without redoing the entire landing zone.

---

## 10. Risks and gaps to acknowledge as an architect

- The repository has not been deployed to Azure in the authoring environment, so real-world schema validation is still pending.
- ExpressRoute, VPN gateway, and Azure Site Recovery are documented but not fully implemented as production infrastructure modules.
- Production-grade firewall, integration, and DR designs require deeper review before live rollout.
- Policy names and built-in definitions may need validation against the target tenant.

This is a healthy architect’s note: the design is strong and realistic, but it should be validated in the target Azure tenant before adoption as a production baseline.

---

## 11. Sign-off view for a customer or architecture review

A customer or architecture board should confirm the following before production adoption:

- requirements and scope are agreed
- management group and subscription model match the enterprise operating model
- IP plan and address ranges are approved
- hub-spoke segmentation is accepted
- firewall rule baseline is reviewed
- RBAC and PIM model are approved
- cost profile fits the target operating model
- DR and backup objectives are approved
- pipeline and state strategy are accepted

---

## 12. Summary

This project is a practical enterprise landing zone blueprint for Azure. It combines governance, secure networking, identity, private access, central monitoring, and reusable Terraform patterns into a strong foundational architecture.

From an architect’s perspective, the major success factor is not the individual resource definitions but the decision model behind them: platform services are centralized, workloads are isolated by environment, security defaults are enforced by policy, private networking is the norm, and deployment is repeatable through infrastructure as code.
