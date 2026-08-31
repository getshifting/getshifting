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

## Inspiration for your own modules

If you want to embark on the journey of creating your own modules, I can highly recommend [this blog and video](https://www.hashicorp.com/en/blog/how-to-write-and-rightsize-terraform-modules). It will give you food for thoughts, will make you think and question your choices and help you design Terraform modules with clear scope, simple code structure, early security validation, and practical tests.
