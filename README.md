# Description

Demonstration how `terraform plan` fails
when one makes too many changes to the ARM template at the same time.

# Steps to reproduce the bug

This repo contains 2 commits tagged as [@step1](https://github.com/gukoff/bug_in_azurerm_resource_group_template_deployment/commit/step1)
and [@step2](https://github.com/gukoff/bug_in_azurerm_resource_group_template_deployment/commit/step2).

### 1. `az login`

### 2. Provision basic infra

Including and ARM template without managed identity and without outputs. 

```shell
git checkout step1

terraform init 
terraform apply --auto-approve
```

### 3. Enrich ARM template.

Add managed identity and outputs to the ARM template. Reference these outputs
in another resource.

Do `terraform plan`, and it will fail:

```shell
git checkout step2

terraform plan

...
    │ Error: Unsupported attribute
    │
    │   on main.tf line 52, in resource "azurerm_role_assignment" "file_st_role_assignment":
    │   52:   principal_id         = jsondecode(azurerm_resource_group_template_deployment.arm_deployment.output_content).principalId.value
    │     ├────────────────
    │     │ azurerm_resource_group_template_deployment.arm_deployment.output_content is "{}"
    │
    │ This object does not have an attribute named "principalId".
```
