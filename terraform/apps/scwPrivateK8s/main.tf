terraform {
  required_version = ">= 0.14.9"

  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.75.0"
    }
  }
  #backend "s3" {}
}

provider "scaleway" {
  region          = "nl-ams"
  zone            = "nl-ams-1"
  project_id      = "30b3c71d-a123-a123-a123-abcd12345678"
  organization_id = "30b3c71d-a123-a123-a123-abcd12345678"
  access_key      = "SCW1234567890123456789"
  secret_key      = "070e530a-dab7-4876-a9f7-6e11d14a7704"
}
