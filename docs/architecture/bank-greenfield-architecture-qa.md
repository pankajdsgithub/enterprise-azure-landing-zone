# Azure Bank Greenfield Landing Zone: Detailed Q&A from Business Requirement to LLD

This document is written as a detailed interview-oriented architecture walk-through for a greenfield banking project. It starts from business requirements and moves step by step through technical conversion, HLD, LLD, and the exact Azure resource decisions that an architect would make.

The scenario assumes:

- bank is moving from an on-premises customer data estate to Azure
- customer data is highly sensitive and regulated
- there is a need for centralized security, strong identity controls, and private connectivity
- the solution must support multiple environments: dev, QA, prod
- workloads need secure access to on-premises data and controlled internet egress
- the architecture must use a landing zone pattern with platform and workload segmentation

---

## 1. Business requirement understanding

### Q1: The bank says they want to move their customer systems to Azure. What is the first thing you would do?

A: The first step is to translate the business problem into architecture requirements. For a bank, this is not just about "moving to the cloud". It is about meeting business continuity, compliance, security, scalability, and performance expectations.

I would ask:

- What business capabilities are being modernized? Internet banking, core banking, customer onboarding, loan processing, KYC, payment workflows?
- What is the data residency requirement?
- Are there regulatory controls such as PCI DSS, SOX, RBI/FINRA/GLBA, or local banking compliance?
- How much customer data is on-premises?
- Is there a legacy dependency to applications, databases, or network appliances?
- What is the expected availability and recovery objective?
- Do they need private connectivity to on-prem through ExpressRoute or VPN?
- What workloads are in scope for phase 1?

For a bank, the architect must first map the real business need: secure digital transformation while keeping compliance and customer trust intact.

### Q2: Why is business requirement mapping so important before choosing Azure services?

A: Because Azure is not a product choice alone; it is a business-enabling platform. If we skip the requirement analysis, we may create a technically correct but business-incompatible architecture.

For a bank, this means the architecture must support:

- zero public exposure of critical systems
- strict identity and access control
- private connectivity to on-prem data
- centralized audit logging
- regulated data handling
- resilient DR and backup
- network segmentation between systems and environments

This is why architecture starts with business and compliance statements, not with subnet sizes or VM types.

---

## 2. Determining the architecture style

### Q3: What architecture pattern would you choose for a bank greenfield project?

A: I would choose an enterprise Azure landing zone using a hub-spoke network model with platform and workload separation.

Why:

- it supports central security controls
- it keeps shared service patterns in a reusable platform layer
- it isolates workloads by business domain or environment
- it enables centralized policy enforcement and network monitoring
- it is scalable for future growth

The main goal is not just to deploy one application but to create a standard operating model for all future bank workloads.

### Q4: Why not just create one single VNet and put everything in it?

A: Because a single flat network is not suitable for a regulated banking environment. It creates security and operations risk.

In a bank, different workloads have different sensitivity and trust levels:

- public web front-end
- internal applications
- database tier
- integration services
- management and monitoring services
- identity and security services

These need clear boundaries. A landing zone with platform and workload separation provides:

- better security segmentation
- precise route control
- easier policy enforcement
- safer troubleshooting
- cleaner future expansion

---

## 3. Platform vs Workload management groups and subscription model

### Q5: What is the first technical design artifact after business requirement analysis?

A: The management group hierarchy and the subscription plan.

For a bank, I would create a tiered structure like:

- Root management group
- Platform management group
- Landing Zones management group
- Shared Services / Connectivity / Management / Identity platform subscriptions
- Production banking subscriptions
- Non-production subscriptions
- Sandbox / QA / dev subscriptions

### Q6: Why create platform management groups and workload management groups separately?

A: Because equality of control is not the same as equality of responsibility.

Platform management group responsibilities:

- connectivity
- monitoring and logs
- identity and RBAC
- policy enforcement
- shared security services
- central DNS and firewall

Workload management group responsibilities:

- application VNets
- databases
- app services
- business-specific workloads
- subscription-level isolation by environment

This ensures the platform team owns shared controls while workload teams only own their application stacks.

### Q7: What types of subscriptions would you recommend for a bank?

A: In an enterprise bank, I would normally separate by function and environment, for example:

1. Connectivity Subscription
   - shared hub VNet
   - Azure Firewall
   - DNS zones
   - private connectivity services

2. Management Subscription
   - Log Analytics
   - Azure Monitor
   - dashboards
   - alerting and action groups

3. Identity Subscription
   - shared identity services and automation identities

4. Production Workload Subscription
   - customer-facing banking applications
   - core banking systems
   - secure service layers

5. Non-prod subscriptions
   - dev, QA, UAT

6. Sandbox subscription
   - experiments and isolated learning

This pattern creates accountability and reduces blast radius.

---

## 4. Governance and policy design for a bank

### Q8: Why are Azure Policy and governance critical for a bank?

A: A bank cannot allow teams to build services with inconsistent naming, networking, or security. Azure Policy is the control plane that enforces enterprise defaults.

Examples of policy decisions:

- deny public IP creation in production workloads
- require tags like CostCenter, Environment, Application, Owner
- allow Azure regions only in approved regions
- enforce private DNS and private endpoint usage
- require managed identities for services
- restrict public network access for databases and storage

### Q9: What are the most important governance requirements in a bank environment?

A: 

- data location controls
- network restrictions
- encryption enforcement
- tagging for cost and ownership
- secure baseline for all workloads
- RBAC-based least privilege
- central policy inheritance from management groups

### Q10: How do management groups help with this?

A: Policies can be assigned at the root or platform group and inherited by all child scopes. This is ideal for a bank because it keeps platform compliance consistent across all workloads.

---

## 5. Network design for a bank: hub and spoke

### Q11: What network model would you choose for a bank landing zone?

A: Hub-spoke with a central connectivity hub and separate workload spokes.

Why:

- centralized firewall and connectivity
- central DNS and routing services
- private connectivity to on-premises data sources
- easier security inspection
- separation of bank domains

### Q12: What is in the hub VNet?

A: The hub is the central platform network. In a bank, it typically includes:

- AzureFirewallSubnet
- GatewaySubnet
- shared services subnet
- management subnet
- optional bastion or jump host subnet

The hub contains the shared services required by all workloads.

### Q13: What is in the workload spoke VNet?

A: A spoke VNet is dedicated to one application or bank domain. It typically contains:

- web tier subnet
- app tier subnet
- data tier subnet
- private endpoint subnet
- management or bastion access subnet

This isolates each workload and allows controlled connectivity.

---

## 6. Connectivity to on-premises customer data

### Q14: The bank says customer data is on-premises. What network connectivity model would you choose?

A: I would use private connectivity, ideally Azure ExpressRoute or a secure site-to-site VPN if ER is not available initially.

Why:

- on-prem data access must be private and controlled
- public access would violate security and compliance expectations
- banks handle sensitive customer information and need predictable performance

### Q15: Why is ExpressRoute preferred for a bank?

A: ExpressRoute gives:

- private connectivity without internet exposure
- predictable latency
- higher security posture
- support for hybrid enterprise patterns

The bank’s on-prem environment can be connected to Azure hub over ER and then routed to the relevant spoke workloads.

### Q16: How would you integrate this with the landing zone hub?

A: The connectivity hub VNet would have the GatewaySubnet and the route tables needed to carry traffic from on-prem to the spoke workloads. The hub is the transit point. The bank can route back to the on-prem estate via the hub gateway, while the hub firewall inspects the traffic before it reaches the spoke.

---

## 7. Detailed VNet peering design

### Q17: What is VNet peering and how is it used in this bank architecture?

A: VNet peering connects the hub and each workload spoke. It allows traffic to flow privately between virtual networks without public IP exposure.

In a bank architecture, the pattern is:

- spoke to hub peering
- hub to spoke peering
- all shared traffic passes through the hub

### Q18: What are the types of peering?

A: There are several relevant patterns:

1. VNet peering within the same region
2. Global VNet peering between regions
3. Hub-spoke peering for central connectivity
4. Gateway transit pattern for shared connectivity

For a bank, the main pattern is hub-spoke peering with secure route control.

### Q19: What peering settings are critical in a regulated architecture?

A: The most important settings are:

- allow_virtual_network_access
- allow_forwarded_traffic
- allow_gateway_transit if the hub is carrying the gateway
- packet forwarding only where required

### Q20: Why is allow_forwarded_traffic important?

A: Because traffic might need to traverse the hub firewall or an appliance before reaching a spoke or on-prem system. If forwarding is not enabled, the security path will not work correctly.

### Q21: How do you manually implement VNet peering step by step?

A: Step-by-step:

1. Create hub VNet with required subnets
2. Create spoke VNet for the application domain
3. Define the peering resource in the hub to spoke direction
4. Define the reverse peering resource in the spoke to hub direction
5. Set allow_virtual_network_access = true
6. Set allow_forwarded_traffic = true if the hub is acting as transit
7. Attach route tables to the spoke subnets
8. Validate route propagation and connectivity
9. Confirm NSG rules allow the required flows
10. Test application connectivity and DNS resolution

### Q22: What is the common mistake when implementing peering?

A: Creating only one side of the peering. In Azure, if the peering is not configured in both directions, the environment will appear partially connected but will fail in real traffic paths.

---

## 8. Route tables and UDRs

### Q23: What is a User Defined Route and why is it critical in a bank landing zone?

A: A UDR is a custom route table attached to a subnet. It overrides default Azure routing and forces traffic along a designed path.

In a bank, the key design is:

- traffic from application subnets goes to Azure Firewall for inspection
- traffic to on-prem or remote resources uses the hub or gateway path
- internet egress is not direct unless explicitly approved

### Q24: What specific route is usually defined?

A: A default route is usually used:

- 0.0.0.0/0 -> Azure Firewall private IP

This ensures all internet-bound traffic passes through the firewall for inspection and policy enforcement.

### Q25: What are the manual steps to create a UDR?

A: 

1. Create a route table resource
2. Add route entries with destination prefixes and next hop type
3. Set next hop as VirtualAppliance for the firewall
4. Attach the route table to the appropriate subnet
5. Validate route propagation and route selection
6. Test egress and private connectivity

### Q26: Why is the UDR considered a security control, not just a routing feature?

A: Because it determines whether traffic is forced through a monitored and controlled network path. Without UDR, workloads can bypass centralized inspection and violate the bank’s security design.

### Q27: What are common UDR issues?

A: 

- applying route table to the wrong subnet
- not enabling the firewall route properly
- missing route table association for the app subnet
- conflicting system routes
- failed connectivity because the firewall is not reachable

---

## 9. Azure Firewall configuration and reasons

### Q28: Where is Azure Firewall placed in the bank design?

A: It is placed in the hub VNet, usually in the AzureFirewallSubnet. That gives centralized control over traffic from all workload spokes.

### Q29: Why is firewall placement in the hub important?

A: Because the hub becomes the single network control point. This centralizes both routing and traffic inspection. It also simplifies logs, alerting, and rule maintenance.

### Q30: What rules would a bank typically define?

A: 

- allow required outbound DNS traffic
- allow application-specific egress destinations
- block direct internet egress from sensitive apps
- allow access to managed services required by the workload
- deny unknown or non-compliant destinations

### Q31: What is the difference between network rules and application rules?

A: 

- network rules work at IP, port, and protocol level
- application rules work at FQDN or URL level

For a bank, both are useful. Network rules handle core flows; application rules help with outbound web access restrictions and governance.

### Q32: How is Azure Firewall connected to the final application design?

A: The application subnets use UDRs to direct all outbound traffic to the firewall. The firewall applies policy and allows only approved destinations. This gives the bank full egress control without exposing workloads directly to the internet.

---

## 10. Private DNS, DNS links, and private endpoints

### Q33: Why is DNS critical in a private banking environment?

A: Because bank workloads often use private endpoints to access Azure PaaS services, and those services use private IPs. Without private DNS, the service names will not resolve to the correct private IP addresses.

### Q34: What are private DNS zones?

A: Private DNS zones are internal DNS domains that resolve only within Azure-private connectivity. They are used for services like:

- SQL private endpoints
- storage private endpoints
- Key Vault private endpoints
- application-specific internal domains

### Q35: How do you configure private DNS for a private endpoint?

A: The steps are:

1. Create the required private DNS zone
2. Link it to the relevant VNet or the hub-spoke model
3. Create the private endpoint for the service
4. Ensure the private endpoint registers the correct A record
5. Validate that the application resolves the service name to the private IP
6. Confirm the request reaches the service over the private path

### Q36: Why is DNS automation important?

A: If DNS is not configured correctly, the application may not find the private service, even though the resource was created successfully. This is one of the most common failures in private architecture design.

---

## 11. Private endpoints and service isolation

### Q37: Why are private endpoints important for a bank?

A: Private endpoints reduce public exposure and support a secure by default pattern. A bank should avoid public endpoints for SQL, Key Vault, storage, and internal integration services whenever possible.

### Q38: What is the typical pattern for a private endpoint subnet?

A: A dedicated subnet such as a private endpoint subnet with a small CIDR range, for example:

- 10.0.4.0/24 or similar

The private endpoint NIC is created in this subnet and attached to the target service resource.

### Q39: What should be protected with private endpoints?

A: In a bank architecture, likely candidates are:

- Azure SQL
- Storage accounts
- Key Vault
- application-specific PaaS services
- secret and config stores

### Q40: What is the main security reason for private endpoints?

A: They help enforce network segmentation and private-only access patterns. This is fundamental to a bank’s security requirements.

---

## 12. Subnet design for workloads

### Q41: What is the logic behind subnet design in a bank landing zone?

A: Subnets are designed by function and trust level. The bank architecture should not place everything in one subnet because it would become a large security boundary.

Typical pattern:

- web subnet
- app subnet
- data subnet
- private endpoint subnet
- management subnet
- firewall subnet
- optional bastion subnet

### Q42: Why separate web and app subnets?

A: To reduce lateral movement risk. If the web layer is compromised, access to the app and database layers should be limited by NSGs and route design.

### Q43: How does the bank control communication between tiers?

A: Through route tables, NSGs, firewall policies, and private endpoints. Each layer only allows the necessary traffic patterns.

---

## 13. NSGs and least privilege defaults

### Q44: What is the role of NSGs in a banking landing zone?

A: NSGs are the local filtering layer. They define what traffic is allowed in and out of each subnet or NIC.

### Q45: What would be the design principle?

A: Default deny, allow only what is required.

For example:

- web subnet only allows 80 or 443 from approved sources
- app subnet allows application TCP port from web subnet
- database subnet allows SQL from app subnet only
- management subnet only allows approved admin flows

### Q46: Why is NSG design important in a bank?

A: Because the architecture must reduce lateral movement and enforce compartmentalization, especially in a production banking environment.

---

## 14. Identity and RBAC for a bank

### Q47: Why is identity such a critical design area in a bank?

A: A bank is identity heavy. Access must be controlled tightly and auditable. No production workload should rely on shared credentials or long-lived secrets.

### Q48: What identity model would you use?

A: Microsoft Entra ID with managed identities, group-based access, and least privilege RBAC.

### Q49: Why are managed identities preferred?

A: They remove the need for credentials embedded in code or configuration. This is important for:

- app-to-service access
- Key Vault access
- Azure SQL access
- automation and deployment identity

### Q50: How do you handle deployment identity?

A: Use a managed identity or OIDC-based federation for CI/CD. This reduces secret sprawl and improves governance.

### Q51: What is the final requirement for RBAC in a bank?

A: Use least privilege at the smallest scope possible. For example:

- application identity has access only to specific secrets or resources
- platform team has elevated but controlled rights
- operations and support teams have read-only or approved delegated access

---

## 15. Monitoring and logging for security and ops

### Q52: Why is centralized monitoring required for a bank?

A: Because enterprise operations and audit requirements demand visibility. This includes network, application, health, and security telemetry.

### Q53: What would you centralize?

A: 

- Log Analytics workspace
- Azure Monitor alerts
- action groups
- activity logs
- security event collection
- app diagnostics
- firewall logs
- DNS and routing observability

### Q54: Why is central logging critical for compliance?

A: Because a bank must prove who did what, when, and what system was affected. Centralized logs are essential for audits and incident response.

---

## 16. Workload design: a bank application in Azure

### Q55: Let’s say the bank has customer onboarding, account management, and loan processing. How would you break the workload design?

A: I would separate the application into trust and responsibility tiers:

- Internet / public-facing layer
- application tier
- integration layer
- data tier
- private service layer

The public-facing layer is kept minimal and tightly controlled, while sensitive business logic and data stay in the internal tiers.

### Q56: What services would be included in the workload layer?

A: 

- app VMs or App Service / AKS depending on architecture choice
- SQL database or managed relational service
- Key Vault for secrets
- Storage for documents and logs
- private endpoints for data access
- monitoring and backup services

### Q57: Why is this important for a bank?

A: It shows separation of exposure, data criticality, and operational responsibilities. It also matches the enterprise standards expected by regulators and auditors.

---

## 17. Disaster recovery and resilience

### Q58: How would you design DR for a bank environment?

A: In a regulated environment, DR is a business requirement, not a technical afterthought.

I would define:

- Recovery Point Objective (RPO)
- Recovery Time Objective (RTO)
- backup strategy for databases and shared services
- region redundancy for critical workloads
- failover plan for connectivity and security services

### Q59: Why is region design important?

A: A bank may require primary and secondary regions for resilience. The landing zone should be designed so that platform services and workloads can fail over in a controlled, testable way.

---

## 18. Security architecture from requirement to LLD

### Q60: How do you convert the bank’s business requirement into security architecture?

A: Business requirement: protect customer data and ensure private access.

Technical Translation:

- private networking only
- private endpoints for data services
- firewall in the hub
- UDRs enforcing traffic via firewall
- NSGs controlling lateral movement
- identity with MFA and RBAC
- logging and audit visibility
- no public access for critical data stores

This is the core of the architecture conversion process.

---

## 19. HLD design summary for interviewer

### Q61: If you had to present the HLD, what would you say?

A: The bank will use a multi-subscription Azure landing zone with management groups and centralized platform controls. A hub VNet provides shared connectivity, DNS, and firewall services. Each workload is deployed in a separate spoke VNet and connected to the hub by VNet peering. A UDR forces egress through Azure Firewall. Private endpoints and private DNS ensure customer and application data stay private. Identity and RBAC are managed in Entra ID and aligned with least privilege. Monitoring is centralized through Log Analytics and Azure Monitor. This gives the bank a secure, scalable, governable, and auditable environment.

---

## 20. LLD design summary for interviewer

### Q62: If you had to present the LLD, what would you say?

A: The LLD includes explicit subnet definitions, route tables, NSG rules, private DNS zone links, private endpoint deployment, firewall rule collections, hub and spoke VNet peerings, subscription boundaries, VM or app host configuration, database connectivity, identity assignments, and monitoring configuration. Every component is defined with resource names, CIDR ranges, routing decisions, policy assignments, and security controls. This is the build-ready architecture used for manual implementation or Terraform deployment.

---

## 21. Final interview style answer

### Q63: How would you explain the full architecture in one strong answer?

A: In a greenfield bank project, I would start from business requirements and translate them into a secure Azure landing zone. I would first define a management group hierarchy and subscription model to separate platform, governance, connectivity, and workload responsibilities. I would then design a hub-spoke network where the hub contains the shared connectivity, DNS, firewall, and gateway services, while each workload sits in its own spoke VNet. I would use VNet peering, UDRs, and Azure Firewall to ensure all egress and hybrid connectivity is routed through secure and monitored paths. I would use private endpoints and private DNS for customer and critical service access so that no sensitive data is exposed publicly. I would enforce identity and RBAC using Microsoft Entra ID and managed identities, apply Azure Policy at the management-group level, and centralize monitoring and logs in Log Analytics. The result is a secure, scalable, and auditable Azure platform that can support a bank’s digital transformation while meeting strict compliance and security expectations.

---

## 22. Why this design is correct for a bank

This design is correct because it addresses the bank’s business realities:

- customer data is sensitive and regulated
- on-prem connectivity must be secure and private
- security must be centralized and auditable
- workloads must be isolated by function and environment
- network and identity controls must be enforced consistently
- monitoring and governance must be repeatable at scale
- the platform must be ready for future application growth without a redesign

This is the value of a fully thought-through Azure landing zone: it converts business risk into a technical, deployable, and governable architecture.
