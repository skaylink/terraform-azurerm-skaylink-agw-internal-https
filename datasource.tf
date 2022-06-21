# A Terraform module to create a subset of cloud components
# Copyright (C) 2022 Skaylink GmbH

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# For questions and contributions please contact info@iq3cloud.com

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {
}

data "azurerm_resource_group" "networking_resource_group" {
  name = var.vnet_resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.networking_resource_group.name
}

data "azurerm_subnet" "subnet" {
  name                 = var.vnet_subnet_name
  resource_group_name  = data.azurerm_resource_group.networking_resource_group.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

data "azurerm_key_vault" "key_vault" {
  name                = var.cert_key_vault_name
  resource_group_name = var.mgmt_resource_group
}

data "azurerm_key_vault_secret" "certificate" {
  name         = var.cert_name
  key_vault_id = data.azurerm_key_vault.key_vault.id
}
