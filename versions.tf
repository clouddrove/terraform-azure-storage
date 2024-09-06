terraform {
  required_version = ">= 1.7.8"
}

terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">=3.89.0"
      configuration_aliases = [azurerm.main_sub, azurerm.dns_sub]
    }
  }
}
