# Terraform vs Bicep (interview preparation)

**Your honest positioning:** "My hands-on IaC experience is Terraform (this landing zone project). I understand Bicep conceptually and how it maps; I have not delivered a production project in Bicep, so I would ramp up quickly using the concepts I already hold."  *(Do not claim professional Bicep project experience.)*

| Topic | Terraform | Bicep |
|---|---|---|
| Type | Declarative, HCL, multi-provider | Declarative DSL that compiles to ARM JSON, Azure only |
| State | **You manage state** (remote backend, locking, isolation) | **No state file**; ARM is the source of truth; `what-if` previews |
| Resource coverage | AzureRM lags new features; `azapi` fills gaps | Day-0 support for new Azure resource types/API versions |
| Modules | Registry/local/git modules, inputs/outputs, `for_each`/`count` on modules | Modules (local, registry `br:`, template specs); loops/conditions on modules |
| Dependencies | Implicit via references + `depends_on`; dependency graph | Implicit via symbolic names + `dependsOn` |
| Variables | `variable`, `locals`, tfvars, validation blocks | `param` (with decorators `@allowed`, `@minLength`), `var`, `.bicepparam` |
| Outputs | `output` | `output` |
| Scopes | Provider/subscription per root; MG resources via azurerm resources | First-class `targetScope` = resourceGroup, subscription, managementGroup, tenant (and `scope:` on modules) |
| Deployment | `plan` / `apply` / `destroy` | `what-if` / `az deployment <scope> create`; **incremental** default, complete mode deletes; no destroy command (delete the RG) |
| Drift | Detected at plan (state vs real) | Not tracked; redeploy to converge |
| CI/CD | Pipeline with plan artifact + approval | `AzureResourceManagerTemplateDeployment` / `az` tasks + what-if gate |
| Multi-cloud | Yes (AWS, GCP, Kubernetes, Entra via azuread, SaaS) | No |
| Secrets | Values land in state | `@secure()` params; Key Vault references in parameter files |
| Testing | `validate`, `plan`, Checkov, `terraform test` | `bicep build/lint`, PSRule for Azure, what-if |
| Landing zones | CAF Terraform modules / ALZ Terraform | ALZ-Bicep, AVM Bicep modules |

## When to choose which
Choose **Bicep** when the customer is Azure-only, wants no state to manage, needs same-day support for new Azure features, and has ARM skills. Choose **Terraform** when there are multiple clouds/SaaS providers, a platform team already runs Terraform, drift detection and plan/apply governance are required, or Entra/Kubernetes/Datadog are in the same pipeline. Hybrid is common: Bicep for subscription vending, Terraform for workloads (or the reverse).

## Concept mapping you can say out loud
`module` ≈ `module`; `variable` ≈ `param`; `locals` ≈ `var`; `for_each` ≈ `[for x in ...]` / `for` on resources; `count` conditional ≈ `if (cond)`; `terraform plan` ≈ `what-if`; `data` source ≈ `existing` keyword; remote state ≈ *not needed*; `depends_on` ≈ `dependsOn`; workspaces ≈ parameter files per environment.

## Example: same resource
```hcl
resource "azurerm_resource_group" "rg" { name = "rg-demo" location = "centralindia" }
```
```bicep
targetScope = 'subscription'
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = { name: 'rg-demo', location: 'centralindia' }
```

## Conversation script (customer uses Bicep)
"Both are declarative and describe the same ARM resources. The design decisions in a landing zone - hub-spoke, policy, RBAC, private DNS - are tool-independent, and I can defend those. In Terraform I've handled state, locking and drift; with Bicep that burden goes away, and I'd use what-if and deployment stacks instead. I'd start by translating one of my modules to Bicep to learn the syntax and review it against the ALZ-Bicep / AVM patterns."
