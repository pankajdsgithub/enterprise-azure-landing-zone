# Cost optimization guide

> Prices change and differ by region/agreement. Figures are **order-of-magnitude, approximate, USD/month if left running 24x7** and must be re-checked in the Azure Pricing Calculator before deployment. They are not quotes.

## Deployment profiles
| Profile | What runs | Rough cost driver |
|---|---|---|
| **Training-minimal (default)** | RGs, VNets, NSGs, Private DNS zones, LAW (1 GB/day cap), Key Vault, Storage LRS, Private Endpoints (3), SQL Basic. `enable_compute=false` to also drop VMs | Private Endpoints (~$7 each), SQL Basic (~$5), DNS zones (~$0.5 each) |
| **Training-full** | + 2 × B2s VMs, backup vault, App Insights | VMs (~$30-35 each), backup instances |
| **Network lab (hours only)** | + Azure Firewall **Basic**, Bastion **Basic** | Firewall Basic ~ $290 (billed hourly ≈ $0.40/h), Bastion Basic ~ $140 |
| **Production profile** | zonal D-series VMs, ZRS/GZRS, SQL GP zone-redundant, ILB, Firewall Standard/Premium, Defender plans, ASR, ExpressRoute | hundreds to thousands |

## Expensive components - NEVER deployed by default
| Component | Flag / status | Notes |
|---|---|---|
| Azure Firewall | `enable_firewall=false` | Standard ≈ $900+/mo; destroy after the lab |
| Azure Bastion | `enable_bastion=false` | Alternative: `az vm run-command`, or Developer SKU where available |
| VPN Gateway / ExpressRoute gateway | documented only | gateway hourly + circuit + provider fees |
| NAT Gateway | not implemented | alternative to firewall for egress-only |
| Azure Site Recovery | documented only | per protected instance + storage |
| Defender for Cloud plans | `defender_plans=[]` | per-resource billing |
| Load Balancer Standard | `enable_load_balancer=false` | small base + data processed |
| Zone-redundant SQL / GRS | prod tfvars | multiplies cost |

## Guard-rails
LAW `daily_quota_gb=1`; retention 30 days; budgets: create one per subscription (`az consumption budget create` or Portal > Cost Management > Budgets, alerts at 50/80/100 %). Tag-based cost allocation (`costcenter`). Auto-shutdown VMs (DevTest Labs schedule or automation) when idle; deallocate VMs: `az vm deallocate`. Use Azure Reservations/Savings Plans only for steady prod.

## Destroy instructions
```bash
bash scripts/destroy-all.sh                     # application per environment (remove locks first: enable_delete_lock=false)
cd platform/connectivity && terraform destroy    # after ALL spokes are gone
cd ../management && terraform destroy
cd ../governance && terraform destroy            # policies/MGs (subscriptions must be moved out first)
cd ../bootstrap-state && terraform apply -var enable_delete_lock=false && terraform destroy   # LAST
```
Soft-deleted Key Vaults keep their name: `az keyvault purge -n <name>` (not possible when purge protection is on - that is why it is off in dev). Verify nothing is left: `az resource list --tag managedby=terraform -o table`.

## Estimating
Terraform plan → Infracost (`infracost breakdown --path application`) or Pricing Calculator; add Infracost to the PR pipeline in production.
