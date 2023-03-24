# Introduction

Repositório base para utilização de terraform em uma estrutura DevOps.

**Autenticação:**
```
# sh
export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="12345678-0000-0000-0000-000000000000"
export ARM_TENANT_ID="10000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="20000000-0000-0000-0000-000000000000"

# PowerShell
> $env:ARM_CLIENT_ID = "00000000-0000-0000-0000-000000000000"
> $env:ARM_CLIENT_SECRET = "12345678-0000-0000-0000-000000000000"
> $env:ARM_TENANT_ID = "10000000-0000-0000-0000-000000000000"
> $env:ARM_SUBSCRIPTION_ID = "20000000-0000-0000-0000-000000000000"
```

## Manual para executar a pipeline  
  
* Define these variables on Pipeline used by Terraform on pipeline

```yaml
  - name: TF-KV
    value: $(TF-KeyVault-Name)
  - name: TF-Backend-ResourceGroup
  - name: TF-Backend-StgName
  - name: TF-Backend-StgKey
  - name: TF-Subscription
    value: $(TF-Subscription-ID)
  - name: TF-Environment-Name
    value: $(TF-Environment-Name)
  - name: TF-Path
    value: "Terraform/Environment/4.Production"
```

## Create base on Azure

```bash
$ az account set -s "NAME OF SUBSCRIPTION"
```

### Infrastructure State
terraform plan -out=plan.tfplan -var-file=development.tfvars
terraform plan -out=plan.tfplan -var-file=production.tfvars

``` Infrastructure
terraform init \
-upgrade \
--input=false \
-backend-config="resource_group_name=NAME OF RESOURCE GROUP CREATED ON MAIN.TF" \
-backend-config="storage_account_name=NAME OF STORAGE ACCOUNT CREATED ON STORAGEACCOUNT.TF" \
-backend-config="container_name=terraform" \
-backend-config="key=development.tfstate"
```

az storage blob upload \
--account-name <NAME OF STORAGE ACCOUNT CREATED ON STORAGEACCOUNT.TF> \
--container-name terraform \
--name myFile.txt \
--file myFile.txt \
--auth-mode login

## Reference

* https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs