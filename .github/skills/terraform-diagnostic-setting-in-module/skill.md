---
name: terraform-diagnostic-setting-in-module
description: 'Add azurerm_monitor_diagnostic_setting directly into an existing Terraform module, selecting cost-conscious log categories, always enabling metrics when supported, and documenting category decisions plus KQL examples in the module README.'
argument-hint: 'Provide the target module path and resource id expression(s) to attach diagnostics to'
user-invocable: true
---

# Add Diagnostic Settings To Existing Terraform Module

## Purpose

Use this skill to add `azurerm_monitor_diagnostic_setting` directly into an existing Terraform module.

Do not call or wrap another diagnostics module. The diagnostic resource must be declared in the target module itself.

Use actual category discovery from Azure before selecting logs. Do not rely on guessed or static category defaults.

## Required Outcomes

1. Add `azurerm_monitor_diagnostic_setting` in the existing module.
2. Discover all currently supported categories from Azure using Azure CLI or Az PowerShell for at least one real target resource instance.
3. Fetch categories in Terraform using `azurerm_monitor_diagnostic_categories`.
4. Enable only selected log categories by default (cost + troubleshooting + best practices), based on the discovered category names.
5. Always enable metrics if the target supports metrics.
6. Add an option to disable diagnostics (for environments with no logging requirement).
7. Update the module `readme.md` with:

- A category decision table (exact category name, added yes/no, reason)
- Metrics included in the same table
- Practical KQL query examples

## Files To Update In The Target Module

- `main.tf` (or equivalent resource file)
- `variables.tf`
- `readme.md`

## Implementation Steps

### 0. Discover Actual Categories First (Required)

Before coding selection logic, query a real resource instance of the same type.

Start by asking the user:

- Which subscription contains the target resource
- Whether they are currently logged in to Azure
- Optionally, the resource name to search for (if they do not have a resource id yet)

Then validate and set context before category discovery.

Azure CLI login and subscription checks:

```bash
az account show
az login
az account set --subscription <subscription-id-or-name>
```

Az PowerShell login and subscription checks:

```powershell
Get-AzContext
Connect-AzAccount
Set-AzContext -Subscription <subscription-id-or-name>
```

If only a resource name is provided, resolve the resource id first.

Azure CLI example:

```bash
az resource list --name <resource-name> --subscription <subscription-id-or-name> --query "[0].id" -o tsv
```

Use one of these commands:

Azure CLI:

```bash
az monitor diagnostic-settings categories list --resource <resource-id> --output json
```

Az PowerShell:

```powershell
Get-AzDiagnosticSettingCategory -ResourceId <resource-id>
```

Store the returned category names (logs and metrics). These exact names must drive both:

- Terraform default selection behavior
- README decision table

If live discovery cannot be executed (missing access/session/subscription), stop and ask for either:

- The command output from the user, or
- A resource id + permission to run the query.

Do not proceed with assumption-only category lists.

### 1. Add Inputs In `variables.tf`

Add:

- `enable_diagnostic_setting` (`bool`, default `true`)
- `law_id` (`string`, nullable via default `null`) with validation:
  - Required only when `enable_diagnostic_setting = true`
- Optional tuning lists:
  - `log_categories_include_exact` (`list(string)`, default `[]`)
  - `log_categories_exclude_exact` (`list(string)`, default `[]`)
  - `log_category_include_keywords` (`list(string)`, default `[]`)
  - `log_category_exclude_keywords` (`list(string)`, default `[]`)
- Optional override:
  - `enable_all_log_categories` (`bool`, default `false`)

### 2. Fetch Available Categories In `main.tf`

Use `azurerm_monitor_diagnostic_categories` with the target resource ID expression.

If diagnostics are disabled, set `count = 0` to avoid data/resource creation.

### 3. Add Curated Category Selection Logic

Create locals to normalize case and compute selected categories based on:

- Explicit include list OR include keyword match
- Exclusion exact/category keyword filters

Important:

- The default decision must be derived from the category names discovered in step 0.
- Do not assume categories exist for all resource types.
- If exact category names are known for the target module, prefer exact-name defaults over keyword heuristics.

### 4. Add `azurerm_monitor_diagnostic_setting`

Requirements:

- Resource creation must be controlled by `enable_diagnostic_setting`.
- Name can be derived from workspace id:

```terraform
name = split("/", var.law_id)[length(split("/", var.law_id)) - 1]
```

- `enabled_log` block:
  - Use all categories only if `enable_all_log_categories = true`
  - Otherwise use curated selected categories
- `enabled_metric` block:
  - Always enable every available metric category

Metrics rule is strict: if `data.azurerm_monitor_diagnostic_categories` returns metric categories, all of them must be enabled.

### 5. Update `readme.md`

Add a section like "Diagnostic Categories Selection" with a table.

Build the table from the exact categories discovered in step 0 and from Terraform data source behavior.

Use this template:

```markdown
| Category    | Type   | Added By Default | Why                                                   |
| ----------- | ------ | ---------------- | ----------------------------------------------------- |
| AuditEvent  | Log    | Yes              | Compliance and investigation value with moderate cost |
| Transaction | Log    | No               | High-volume category, enable only when needed         |
| AllMetrics  | Metric | Yes              | Metrics are always enabled when available             |
```

Important:

- The table must explicitly include metrics.
- Use exact category names returned by discovery commands.
- Include a short rationale per category that balances troubleshooting value and ingestion cost.

### 6. Add KQL Query Examples In `readme.md`

Include practical examples for both logs and metrics. At minimum:

1. Recent errors by resource
2. Security/audit events timeline
3. Top noisy categories (volume/cost proxy)
4. Failed operations in the last 24h
5. Metrics trend (for example CPU/requests)
6. Correlating spikes in logs with metric anomalies

Use generic table names where needed:

- `AzureDiagnostics`
- `AzureMetrics`

When possible, include category filters using exact discovered category values.

## Terraform Pattern Example

```terraform
locals {
  include_exact_lower    = [for c in var.log_categories_include_exact : lower(c)]
  exclude_exact_lower    = [for c in var.log_categories_exclude_exact : lower(c)]
  include_keywords_lower = [for k in var.log_category_include_keywords : lower(k)]
  exclude_keywords_lower = [for k in var.log_category_exclude_keywords : lower(k)]

  selected_log_categories = [
    for category_set in data.azurerm_monitor_diagnostic_categories.categories : [
      for category in category_set.log_category_types : category
      if (
        (
          contains(local.include_exact_lower, lower(category)) ||
          length([for keyword in local.include_keywords_lower : keyword if strcontains(lower(category), keyword)]) > 0
        ) &&
        !contains(local.exclude_exact_lower, lower(category)) &&
        length([for keyword in local.exclude_keywords_lower : keyword if strcontains(lower(category), keyword)]) == 0
      )
    ]
  ]
}

data "azurerm_monitor_diagnostic_categories" "categories" {
  count       = var.enable_diagnostic_setting ? length(var.targets_resource_id) : 0
  resource_id = var.targets_resource_id[count.index]
}

resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  count                      = var.enable_diagnostic_setting ? length(var.targets_resource_id) : 0
  name                       = split("/", var.law_id)[length(split("/", var.law_id)) - 1]
  target_resource_id         = var.targets_resource_id[count.index]
  log_analytics_workspace_id = var.law_id

  dynamic "enabled_log" {
    for_each = var.enable_all_log_categories ? data.azurerm_monitor_diagnostic_categories.categories[count.index].log_category_types : local.selected_log_categories[count.index]
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.categories[count.index].metrics
    content {
      category = enabled_metric.value
    }
  }
}
```

## Validation Checklist

Before finalizing:

- `terraform validate` passes in the target module scope
- Live discovery command output captured and category names verified
- Diagnostics can be turned off cleanly (`enable_diagnostic_setting = false`)
- Metrics are always enabled when available
- README category table includes logs and metrics with exact discovered names
- README has usable KQL examples
- No reference to consuming a separate diagnostics wrapper module

## Cleanup

After validation and testing, clean up temporary Terraform artifacts:

```bash
# Remove Terraform working directory and state files
rm -rf .terraform
rm -f .terraform.lock.hcl
rm -f terraform.tfstate
rm -f terraform.tfstate.backup
```

Or using PowerShell:

```powershell
# Remove Terraform working directory and state files
Remove-Item -Path '.terraform' -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path '.terraform.lock.hcl' -Force -ErrorAction SilentlyContinue
Remove-Item -Path 'terraform.tfstate' -Force -ErrorAction SilentlyContinue
Remove-Item -Path 'terraform.tfstate.backup' -Force -ErrorAction SilentlyContinue
```

Ensure these artifacts are added to `.gitignore` if not already present:

```
.terraform/
.terraform.lock.hcl
terraform.tfstate
terraform.tfstate.backup
*.tfstate*
```
