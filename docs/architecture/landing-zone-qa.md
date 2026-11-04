# Azure Landing Zone - Detailed Questions and Answers

This document is written in an interview and architect review style for Azure enterprise landing zone implementation. It focuses on the same patterns used in this repository: hub-spoke networking, management groups, governance, private DNS, route tables, Azure Firewall, and workload isolation.

---

## 1. What is an Azure landing zone?

### Q: What is an Azure landing zone?

A: An Azure landing zone is a standardized, secure, and scalable foundation for deploying workloads in Azure. It includes the foundational platform resources and guardrails required for enterprise workloads, such as:

- management group hierarchy
- subscription design
- networking model
- identity and access model
- policy and governance
- monitoring and logging
- connectivity services
- security controls

The purpose is to provide a consistent baseline for application teams while ensuring enterprise standards are enforced centrally.

### Q: Why do organizations need a landing zone?

A: Without a landing zone, each application team may build Azure resources in an ad hoc manner. That creates issues such as:

- inconsistent subnet design
- poor network isolation
- weak governance and policy enforcement
- no centralized logging
- repeated security mistakes
- unpredictable cost and operations patterns

A landing zone introduces standardization and reduces deployment risk.

---

## 2. What are the common Azure landing zone design principles?

### Q: What are the key design principles for a landing zone?

A: The most common principles are:

1. Separation of responsibilities
   - platform team owns common services
   - workload teams own application resources

2. Security by default
   - least privilege
   - private endpoints
   - privileged access control
   - denying public access where possible

3. Standardization
   - recurring architecture patterns for all environments

4. Governance at scale
   - policy inheritance through management groups
   - tags and naming conventions

5. Centralized operations
   - shared monitoring and logging
   - central firewall and DNS

6. Network isolation and segmentation
   - hub-spoke, NSG, route tables, private access

7. Scalability and repeatability
   - Terraform or IaC for repeatability

---

## 3. What is the platform layer and workload layer?

### Q: What is the platform layer in this repo?

A: The platform layer includes the shared control plane and common infrastructure used by all workloads. In this repository, that includes:

- management groups
- governance and Azure Policy
- connectivity hub VNet
- Azure Firewall
- private DNS zones
- Log Analytics and monitoring
- identity and pipeline RBAC

This layer is managed centrally and reused by all application environments.

### Q: What is the workload layer?

A: The workload layer is where application-specific resources are deployed, such as:

- spoke VNets
- virtual machines
- SQL database
- Key Vault
- storage accounts
- private endpoints
- monitoring resources tied to the application

The key idea is that the platform is stable and shared, while workloads are environment-specific and can scale independently.

### Q: Why is this separation important?

A: It gives better:

- responsibility separation
- governance enforcement
- cost accountability
- operational consistency
- reduced blast radius during changes

---

## 4. How is the management group and subscription design structured?

### Q: Why are management groups used?

A: Management groups are used to apply governance and policy to multiple subscriptions at once. They create a hierarchy like:

- Root management group
- Platform management group
- Landing Zone management group
- Connectivity / Management / Identity subscriptions
- Non-prod and prod workload subscriptions

This allows inheritance of policies, role assignments, and standardized governance without repeated configuration per subscription.

### Q: What is the purpose of separating subscriptions?

A: Subscription separation helps in:

- governance isolation
- cost reporting by business unit or environment
- operational boundaries
- business-critical workloads segregation
- workload and platform independence

### Q: What is usually placed in the platform subscription?

A: Shared resources such as:

- hub VNet
- Azure Firewall
- DNS zones
- Log Analytics
- Azure Policy assignments
- shared monitoring
- centralized security services

### Q: What is usually placed in workload subscriptions?

A: Application-specific workloads like:

- application VNets
- compute resources
- databases
- storage
- app-level services

---

## 5. What is the hub-spoke model and why is it used?

### Q: What is a hub-spoke network?

A: In a hub-spoke model, all shared connectivity services are placed in a central hub VNet, while each application or workload environment is in a separate spoke VNet. The hub acts as the central transit point.

### Q: Why is the hub-spoke pattern useful?

A: It offers:

- centralized security controls
- shared egress flow
- simpler firewall management
- easier routing design
- isolation between workloads

### Q: How does this repo use it?

A: The repo creates a hub VNet in the connectivity layer, while the application workloads create spoke VNets and peer them back to the hub. This ensures the firewall and shared services are placed in a centralized location.

### Q: Is VNet peering enough for communication?

A: Not by itself. You also need proper route tables, allowed traffic rules, and DNS integration. For example, if the spoke needs internet egress or private service resolution, you need route tables and DNS to work correctly.

---

## 6. What is VNet peering? Explain step by step.

### Q: What is VNet peering?

A: VNet peering connects two Azure VNets so they can communicate privately over the Azure backbone. It is used to connect a hub and its spokes or two different workload VNets.

### Q: What are the different types of peering?

A: There are mainly two categories:

1. VNet peering within the same region
   - low latency
   - same region is simpler
   - often used for hub-spoke in one region

2. Global VNet peering
   - connects VNets in different Azure regions
   - used when workloads are spread across regions

### Q: What are the key peering settings?

A: Common settings include:

- allow_virtual_network_access
- allow_forwarded_traffic
- allow_gateway_transit
- use_remote_gateways
- remote virtual network ID

### Q: What does each setting mean?

A: 

- allow_virtual_network_access: allows the peered VNet to send traffic to the other VNet
- allow_forwarded_traffic: allows traffic that is forwarded by a firewall or router to pass through the peering
- allow_gateway_transit: allows the peered VNet to use the current VNet as a transit gateway
- use_remote_gateways: allows the current VNet to use the remote VNet’s gateway for connectivity

### Q: What are the implementation steps for VNet peering?

A: In this architecture, the steps are:

1. Create the hub VNet with required subnets
2. Create spoke VNet for the workload
3. Create the peering resource from hub to spoke
4. Create the reverse peering from spoke to hub
5. Set traffic forwarding and transit rules depending on use case
6. Validate routing tables and NSGs
7. Validate DNS resolution and firewall path

### Q: What should be checked after peering is created?

A: Check the following:

- source and destination subnets are allowed by NSGs
- route tables direct traffic as expected
- DNS resolves to private IPs
- firewall is in path for outbound access
- no blocked routing because of incorrect UDR or gateway rules

### Q: What is the common mistake in VNet peering design?

A: People often create one direction of peering only. Azure peering must be configured in both directions for a full working design. Also, if forwarding is needed for firewall inspection, the forwarding flag must be enabled correctly.

---

## 7. How do you implement VNet peering in the landing zone pattern?

### Q: How is peering done in this repo?

A: The repo creates a spoke VNet and then peers it to the hub VNet using reusable Terraform module logic. The peering module includes the main settings that enable traffic flow and routing support.

### Q: What pattern is used for hub-to-spoke connectivity?

A: A central hub contains shared components like firewall, DNS, gateways, and security services. Each spoke connects to the hub. Traffic from workloads goes to the hub for inspection and egress. This is how the repo enforces centralized control.

### Q: What should be done when a workload needs outbound internet access?

A: The workstation or workload should route 0.0.0.0/0 through the firewall in the hub. The firewall then controls and inspects outbound traffic. Without this route, the workload might go out directly and bypass the intended enterprise controls.

---

## 8. What is a User Defined Route (UDR)?

### Q: What is a User Defined Route (UDR)?

A: A UDR is a custom route table attached to a subnet. It allows you to control how traffic leaves a subnet. In enterprise Azure design, it is usually used to force traffic through the firewall or NVA instead of directly going out to the internet.

### Q: Why do we define UDRs?

A: To enforce traffic inspection and route policy. For example:

- default route 0.0.0.0/0 points to Azure Firewall
- traffic to on-premises networks is routed via VPN/ER or gateway
- internal subnets prefer hub services for routing

### Q: What is the typical default route configuration?

A: The general pattern is:

- 0.0.0.0/0 -> VirtualAppliance
- next hop is the Azure Firewall private IP

This means all internet-bound traffic from the spoke is sent through the firewall.

### Q: What are the steps to define a UDR?

A: In practice:

1. Create a route table resource
2. Define route entries, such as default route and any custom prefixes
3. Set the next hop type based on the design
4. Attach the route table to the subnet or subnets requiring custom routing
5. Validate route propagation
6. Validate connectivity after deployment

### Q: What is the main difference between Azure Firewall and default Azure routing?

A: Azure Firewall is a security service inserted into the path for inbound and outbound traffic. A UDR ensures traffic chooses the firewall as the next hop, rather than the system default route.

### Q: What are the common mistakes when creating UDRs?

A: 

- forgetting to attach the route table to the subnet
- using wrong next hop type
- pointing 0.0.0.0/0 to a non-existent appliance
- using route propagation in a way that conflicts with required path
- not testing application connectivity after deployment

---

## 9. How is Azure Firewall created and configured?

### Q: What is Azure Firewall used for?

A: Azure Firewall is a centralized network security service that controls allowed traffic based on policies. It can enforce:

- network rules
- application rules
- outbound filtering
- threat detection features
- hub-based egress control

### Q: What are the typical firewall components?

A: 

- Azure Firewall Policy
- Azure Firewall instance
- Rule collections
- Rule collection groups

### Q: What are Azure Firewall rules?

A: There are two major categories:

1. Network rules
   - allow/deny by IP, port, protocol
   - used for basic outbound traffic control

2. Application rules
   - allow/deny based on FQDN or URL
   - used for outbound HTTP/HTTPS destinations

### Q: Why is firewall placement important?

A: The firewall should sit in the hub VNet so all spoke traffic can be inspected in one place. This reduces duplication and centralizes security rules.

### Q: What are the steps to configure Azure Firewall in a landing zone?

A: 

1. Create the firewall subnet in the hub VNet
2. Deploy the firewall and firewall policy
3. Create rules for required destinations
4. Attach a UDR to spoke subnets so 0.0.0.0/0 routes to the firewall
5. Validate that traffic flows through the firewall
6. Monitor logs and alerts in Log Analytics

### Q: What is the main concern with Azure Firewall cost?

A: It is a strong security service, but it can be costly. For testing or training, it may be disabled or used selectively. In a real enterprise environment, it is usually one of the first major platform investments.

---

## 10. What is private DNS and why is it necessary?

### Q: What is private DNS?

A: Azure Private DNS provides name resolution for private endpoints and private services without exposing those services publicly. It allows workloads inside a VNet or connected VNets to resolve to private IP addresses.

### Q: Why do we need private DNS for private endpoints?

A: When a service is private, it is assigned a private IP address. Without private DNS, clients cannot resolve the service name to the correct private IP, causing connectivity failures.

### Q: What are the common Azure private DNS zones?

A: Common examples:

- privatelink.blob.core.windows.net
- privatelink.vaultcore.azure.net
- privatelink.database.windows.net
- custom internal zones for internal apps

### Q: What are the implementation steps for DNS?

A: 

1. Create the required private DNS zone
2. Link the zone to the relevant VNet or hub-spoke structure
3. Register the private endpoint resource in the DNS zone
4. Ensure workloads use the same DNS suffix or custom domain mapping
5. Validate resolution from the spoke VNet
6. Confirm private endpoints resolve to the intended IP address

### Q: What is a VNet link?

A: A VNet link attaches a private DNS zone to a VNet so that resources in that VNet can query the zone. In a hub-spoke design, the zone is usually linked centrally and then shared with spoke VNets through network integration.

### Q: What is a common DNS pitfall?

A: The most common issue is failing to create or link the correct zone for the private endpoint. The resource works at the IP level, but the name does not resolve, making the application fail even though the endpoint is provisioned.

---

## 11. How are private endpoints implemented?

### Q: What is a private endpoint?

A: A private endpoint is a network interface attached to a private IP in a subnet. It provides private access to Azure PaaS services without a public IP.

### Q: Why are private endpoints preferred in landing zones?

A: They improve security by:

- removing public exposure
- limiting traffic to private network paths
- preserving centralized enforcement patterns
- reducing external attack surface

### Q: What is the standard private endpoint pattern?

A: 

1. Create the target service
2. Create a dedicated private endpoint subnet
3. Create the private endpoint resource for the PaaS service
4. Link the private endpoint to the service’s target subresource
5. Create the proper DNS registration
6. Validate traffic from the app subnet to the private IP

### Q: Which services commonly use private endpoints?

A: 

- Key Vault
- Azure SQL
- Storage accounts
- App Service integration points
- other PaaS services with private access support

---

## 12. What is the role of NSGs in the design?

### Q: What is a Network Security Group (NSG)?

A: An NSG filters inbound and outbound traffic to Azure resources based on rules. It is a subnet or NIC-level security control.

### Q: Why do we use NSGs in the landing zone?

A: They provide local restrictions and segmentation between tiers, for example:

- web tier allows only 80/443 from the internet or load balancer
- app tier allows only the application port from web tier
- database tier allows only SQL from app subnet
- private endpoint subnet allows only specific service traffic

### Q: What is the principle behind NSG rule design?

A: Default deny and allow only required ports. This is essential for secure landing zone design.

---

## 13. Why is DNS + peering + firewall + UDR all connected?

### Q: Why do these components depend on each other?

A: They form a full network path:

- VNet peering connects the subnets logically
- UDR decides which next hop traffic uses
- Azure Firewall inspects traffic
- Private DNS resolves service names to private IPs
- NSGs control allowed traffic

Without all four, application traffic may fail or bypass security controls.

### Q: What is a common enterprise pattern?

A: A spoke VNet routes all internet traffic to the hub firewall, the hub firewall allows only approved destinations, and private services are accessed using private DNS with private endpoints.

---

## 14. What is the difference between public access and private-only access?

### Q: Why remove public access from services?

A: Public access increases attack surface and weakens operational control. In a secure landing zone, key services are private by default and accessible only through internal network paths.

### Q: What is the effect on application design?

A: Applications likely must be designed for:

- VNet connectivity
- private DNS resolution
- internal routing
- proper firewalls and NSGs
- centralized security review

This is why landing zones are built with strong network design from the beginning.

---

## 15. How do you secure access to Azure services and pipelines?

### Q: Why are managed identities important?

A: Managed identities remove the need to store credentials in code or configuration. Applications can access Azure services using identity-based access.

### Q: Why is OIDC used in CI/CD?

A: OIDC allows GitHub or Azure DevOps to authenticate to Azure without storing long-lived secrets. This improves security and aligns with modern cloud practices.

### Q: What is the best practice for role assignment?

A: Use least privilege and grant only specific roles at the required scope. For example:

- a workload may need Contributor to its RG
- a platform identity may need Key Vault access
- a pipeline identity may need only specific deployment permissions

---

## 16. What is the role of monitoring and logging in a landing zone?

### Q: Why is centralized monitoring necessary?

A: It provides shared operational visibility across the platform and workloads. Without it, every team would build isolated logging, causing governance problems and poor visibility.

### Q: What is typically centralized?

A: 

- Log Analytics workspace
- action groups
- alerts
- diagnostic settings
- Azure Activity Logs
- platform and workload health telemetry

### Q: What is the value of centralized monitoring?

A: It helps with:

- quick troubleshooting
- compliance evidence
- performance trends
- incident analysis
- security monitoring

---

## 17. How does Terraform help with landing zone implementation?

### Q: Why is Terraform used in this repo?

A: Terraform enables repeatable and standardized deployment. It helps create the platform and workload resources consistently across environments.

### Q: What is the benefit of modular design?

A: It separates the landing zone into reusable modules such as:

- VNet
- peering
- route tables
- firewall
- private DNS
- private endpoint
- policy
- monitoring

This reduces duplication and improves maintainability.

---

## 18. What are common implementation risks and how do you avoid them?

### Q: What are the key risks in an Azure landing zone implementation?

A: 

- wrong subnet CIDRs or overlaps
- missing private DNS zone registrations
- incomplete VNet peering
- bad route tables
- firewall not in the path
- wrong NSG ports or sources
- missing logging and policy assignments
- poor identity and RBAC design
- insecure public endpoints left enabled

### Q: How do you avoid them?

A: By validating each layer in order:

1. subnet planning
2. VNet peering
3. route decision
4. firewall inspection
5. DNS resolution
6. private endpoint health
7. NSG enforcement
8. governance and policy
9. monitoring and alerting

---

## 19. What should an architect validate before sign-off?

### Q: What should be validated before production deployment?

A: 

- management group hierarchy is correct
- subscriptions align with workload boundaries
- hub-spoke networking works
- firewall and UDR are correct
- private DNS resolves properly
- private endpoints are reachable privately
- NSGs allow minimal required traffic
- identity and RBAC are least privilege
- monitoring and logging are centralized
- application dependencies are tested end-to-end

### Q: Why is validation so important?

A: Architecture planning is not just about resource creation. The real challenge is ensuring traffic, identity, governance, and diagnostics work together correctly.

---

## 20. Final summary

### Q: What is the overall design pattern followed by this repo?

A: The repo follows a modern enterprise Azure landing zone pattern built around:

- management groups for governance
- platform services in a shared connectivity and management layer
- workload isolation in spoke VNets
- hub-spoke routing and central egress
- Azure Firewall for secure egress control
- private endpoints with private DNS
- NSGs and route tables for minimal allowed traffic
- central monitoring and identity controls
- reusable Terraform modules for repeatability

This is the standard architecture that provides security, scalability, governance, and operational consistency for enterprise Azure adoption.

---

## 21. Quick interview answer

### Q: If asked in one sentence, how would you explain this landing zone design?

A: It is a hub-spoke Azure landing zone where shared platform services such as connectivity, policy, DNS, firewall, and monitoring live in a centralized hub, while application workloads sit in isolated spokes with private networking, policy enforcement, and controlled egress through a centralized firewall.
