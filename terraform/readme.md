# How to

To use these modules see:

- AWS: <https://wiki.getshifting.com/terraform#terraform_on_aws>
- Azure: <https://wiki.getshifting.com/terraform#terraform_in_azure_devops_from_a_local_environment>

## Azure

```powershell
# Go to directory with the module you want to deploy
terraform init
terraform validate
terraform plan -var-file="getshifting.tfvars" -out="postgresql.tfplan"
terraform apply "postgresql.tfplan"
terraform destroy -var-file="getshifting.tfvars" -auto-approve
```
