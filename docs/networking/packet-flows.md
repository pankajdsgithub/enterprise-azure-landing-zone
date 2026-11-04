# Network design and packet flows

Addresses: Hub `10.0.0.0/23`, Dev `10.10.0.0/22`, QA `10.20.0.0/22`, Prod `10.30.0.0/22`. Firewall private IP is shown as `FW` (first usable address in AzureFirewallSubnet, normally `10.0.0.4`).

## 1. Spoke-to-spoke (Dev web 10.10.0.4 → QA app 10.20.0.68)
1. Dev VM sends to 10.20.0.68. Dev VNet knows only its own range and the hub (peering). No system route for 10.20.0.0/22 → the **UDR 0.0.0.0/0 → FW** matches.
2. Packet crosses the Dev→Hub peering (`allow_forwarded_traffic = true` required) to the firewall.
3. Firewall policy evaluates network rules. Allowed (`dev|qa` HTTPS only) → forwards. Prod → anything: no allow rule → dropped.
4. Hub has system routes to every peered spoke, so the firewall sends the packet over the Hub→QA peering.
5. **Return path:** QA's UDR sends the reply to FW; the firewall tracks the flow (stateful) → symmetric.
Without a firewall (training mode) spoke-to-spoke is **not possible** (peering is non-transitive) - this is by design.

## 2. Spoke-to-internet
Spoke VM → UDR 0.0.0.0/0 → FW → application/network rules → SNAT to the firewall public IP → internet. With no firewall deployed, default Azure outbound access is **disabled** on our subnets (`default_outbound_access_enabled = false`), so VMs have no internet until a NAT/firewall path exists. (Plan for patching: firewall FQDN rules or a private mirror.)

## 3. On-premises ↔ Azure (ExpressRoute, optional)
On-prem → provider → ExpressRoute circuit → ER gateway in `GatewaySubnet` → peering (hub `allow_gateway_transit`, spoke `use_remote_gateways`) → spoke. Gateway learns on-prem prefixes by BGP and advertises 10.0.0.0/8 spoke ranges. Spoke route tables disable BGP propagation, so inbound-from-on-prem still hits the spoke via the hub, while replies follow the UDR to the firewall - inspect both directions by also adding a **GatewaySubnet route table** with spoke prefixes → FW.
**ExpressRoute is not deployed by this repo.** To add it: (1) order a circuit with the provider and obtain the service key; (2) the provider provisions private peering; (3) deploy `azurerm_virtual_network_gateway` (type `ExpressRoute`, SKU ErGw1AZ+) in GatewaySubnet; (4) `azurerm_virtual_network_gateway_connection` of type `ExpressRoute` to the circuit; (5) set `hub_has_gateway = true`. VPN as backup: Route-based VPN gateway with active-passive or S2S in coexistence; or VPN as a lab substitute. A fake loopback is *not* an ExpressRoute deployment and is deliberately not provided.

## 4. Private Endpoint communication (App VM → SQL)
App VM resolves `sql-app1-dev-x1y2z.database.windows.net` → (DNS, below) → `10.10.0.196` (PE NIC in snet-pe). Traffic stays in the spoke: VM → PE IP over the VNet system route (no UDR on snet-pe needed; if a UDR sends it to the firewall, you must also set `private_endpoint_network_policies` to `RouteTableEnabled`/`Enabled` and allow the flow). NSG on snet-pe allows 1433 from app/web subnets only.

## 5. DNS resolution for Private Endpoints
1. VM asks Azure DNS (168.63.129.16) or custom DNS (firewall proxy).
2. Public DNS answer is a CNAME: `x.database.windows.net → x.privatelink.database.windows.net`.
3. The VNet is linked to Private DNS zone `privatelink.database.windows.net`, which holds an A record `x → 10.10.0.196` (written by the PE's DNS zone group).
4. VM connects to the private IP.
From on-prem: conditional forwarder for `database.windows.net` (or the privatelink name) to an Azure DNS Private Resolver inbound endpoint in the hub.
Failure signature: answer is a **public IP** → the VNet is not linked to the zone, or the DNS server used cannot reach 168.63.129.16.
