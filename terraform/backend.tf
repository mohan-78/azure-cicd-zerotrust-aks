terraform {
  backend "azurerm" {

    # Resource Group where storage exists
    resource_group_name = "rg-cicd-poc-dev"

    # Storage Account name
    # Must match variable in main.tf
    storage_account_name = "stterraformpocdev"

    # Container inside storage account
    container_name = "tfstate"

    # Name of the state file
    # One state file per environment
    key = "dev.terraform.tfstate"
  }
}