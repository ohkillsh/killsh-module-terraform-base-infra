# Introduction

Repositório base para utilização de Terraform em CI/CD na cloud Azure.

## Antes de executar

* revisão das variavies dos ambinetes

## Autenticação

```bash
az account set -s "NAME OF SUBSCRIPTION"
```

```bash
# Create a service principal with required parameter
spName="sp-devops-killsh"
SUBSCRIPTION_ID=20000000-0000-0000-0000-000000000000

# Using Cloud shell at https://shell.azure.com it's working good
az ad sp create-for-rbac --name $spName --role contributor --scopes /subscriptions/$SUBSCRIPTION_ID

# Guarde em um lugar seguro as informações do output
```

## Criando a estrutura base

```bash
# Login utilizando AZ CLI
az login 
az account set -s ""

# Terraform Init
terraform init -upgrade --input=false 


# Environment: Development
terraform plan -out="plan.tfplan" -var-file="variables/development.tfvars" -var sp_client_secret="00000000-1111-2222-3333-00000000"

# Environment: Productiton
terraform plan -out="plan.tfplan" -var-file="variables/production.tfvars"


# Upload Terraform state to blob container
az storage blob upload --auth-mode login \
--account-name <NAME OF STORAGE ACCOUNT CREATED ON STORAGEACCOUNT.TF> \
--container-name terraform \
--name dev.tfstate \
--file terraform.tfstate \
```

## Criando estrutura base utilizando como modulo

Utilize o padrão git "ref=" para definir, tag, commit ou branch"

```hcl
module "terraform_infra" {
  source = "git@github.com:ohkillsh/killsh-module-terraform-base-infra.git?ref=main"

  sp_client_id = "Defina - application_id / client_id"
  sp_object_id = "Defina - object_id"
  product      = "killsh"
  environment  = "global"
  location     = "eastus"

  user_tags = var.tags

}

```

## Reference

* [Terraform Provider AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
* [Azure Service Principal Doc](https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)


# TODO: fazer funcionar o terraform-docs