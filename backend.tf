terraform {
  backend "azurerm" {
    resource_group_name  = "githubactionsPOC"
    storage_account_name = "githubactionspoc"
    container_name       = "githubactionspoc"
    key                  = "terraform.tfstate"
  }
}
