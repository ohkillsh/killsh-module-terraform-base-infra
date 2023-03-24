# Doc CI/CD

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

```bash
terraform init \
  -upgrade \
  --input=false \
  -backend-config="resource_group_name=NAME OF RESOURCE GROUP CREATED ON MAIN.TF" \
  -backend-config="storage_account_name=NAME OF STORAGE ACCOUNT CREATED ON STORAGEACCOUNT.TF" \
  -backend-config="container_name=terraform" \
  -backend-config="key=development.tfstate"
```
