# Azure networking questions (batch 1: 10 of the 30 target)
**Q1. Is peering transitive?** No. Use NVA + UDR, vWAN, or gateway transit for specific cases.
**Q2. Route precedence?** Longest prefix match first; for equal prefixes UDR > BGP > system.
**Q3. Why `allow_forwarded_traffic`?** Lets traffic that did not originate in the peered VNet (forwarded by the firewall) in.
**Q4. NSG vs Azure Firewall?** NSG = L3/L4 distributed ACL; Firewall = stateful central L3-L7, FQDN, threat intel, logging.
**Q5. Azure Firewall SKUs?** Basic (SMB, throughput-limited, needs mgmt subnet), Standard, Premium (TLS inspection, IDPS, URL filtering).
**Q6. Service endpoint vs private endpoint?** SE: public endpoint with VNet identity, service-wide; PE: private IP for one resource, works from on-prem, DNS needed.
**Q7. ExpressRoute vs VPN?** ER: private circuit via provider, SLA, predictable latency; VPN: encrypted over internet, cheaper, backup for ER.
**Q8. Why reserved subnet names?** Azure services detect their subnet by name (GatewaySubnet, AzureFirewallSubnet, AzureBastionSubnet).
**Q9. 168.63.129.16?** Azure virtual public IP for DNS, health probes, DHCP; must not be blocked.
**Q10. How to inspect traffic between spokes?** UDR 0.0.0.0/0 (or spoke prefixes) → firewall in the hub; forwarded traffic enabled.
