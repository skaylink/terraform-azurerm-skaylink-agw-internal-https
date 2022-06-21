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

locals {
  backend_address_pool_name = "${data.azurerm_virtual_network.vnet.name}-beap"
}

resource "azurerm_public_ip" "agw_public_ip" {
  name                = "${var.agw_name}-ip"
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_user_assigned_identity" "identity" {
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location

  name = "${var.agw_name}-MI"
}

resource "azurerm_key_vault_access_policy" "allow_user_identiy_cert" {
  key_vault_id = data.azurerm_key_vault.key_vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_user_assigned_identity.identity.principal_id
  secret_permissions = [
    "Get"
  ]
  certificate_permissions = [
    "Get"
  ]
}

resource "azurerm_application_gateway" "agw" {
  name                = var.agw_name
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = data.azurerm_subnet.subnet.id
  }

  frontend_ip_configuration {
    name                 = "public_ip"
    public_ip_address_id = azurerm_public_ip.agw_public_ip.id
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.is_private_agw ? ["feip"] : []
    content {
      name                          = frontend_ip_configuration.value
      private_ip_address_allocation = "Static"
      private_ip_address            = var.agw_private_ip
      subnet_id                     = data.azurerm_subnet.subnet.id
    }
  }

  backend_address_pool {
    name  = local.backend_address_pool_name
    fqdns = length(var.backend_fqdns) == 0 ? null : var.backend_fqdns
  }

  frontend_port {
    name = "port-443"
    port = 443
  }

  frontend_port {
    name = "port-80"
    port = 80
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_type == "http" ? [var.backend_type] : []
    content {
      pick_host_name_from_backend_address = var.override_backend_host_name == null
      name                                = "setting-443-to-${var.backend_type}"
      cookie_based_affinity               = "Disabled"
      port                                = 80
      protocol                            = "Http"
      request_timeout                     = 20
      probe_name                          = "customprobe"
      host_name                           = var.override_backend_host_name
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_type == "https" ? [var.backend_type] : []
    content {
      pick_host_name_from_backend_address = var.override_backend_host_name == null
      name                                = "setting-443-to-${var.backend_type}"
      cookie_based_affinity               = "Disabled"
      port                                = 443
      protocol                            = "https"
      request_timeout                     = 20
      probe_name                          = "customprobe"
      host_name                           = var.override_backend_host_name
    }
  }

  http_listener {
    name                           = "listener-443"
    frontend_ip_configuration_name = var.is_private_agw ? "feip" : "public_ip"
    frontend_port_name             = "port-443"
    protocol                       = "Https"
    ssl_certificate_name           = var.cert_name
  }

  http_listener {
    name                           = "listener-80"
    frontend_ip_configuration_name = var.is_private_agw ? "feip" : "public_ip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }

  redirect_configuration {
    name                 = "redirect-80-to-443"
    redirect_type        = "Permanent"
    target_listener_name = "listener-443"
    include_path         = true
    include_query_string = true
  }

  request_routing_rule {
    name                       = "rr-443"
    rule_type                  = "Basic"
    http_listener_name         = "listener-443"
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = "setting-443-to-${var.backend_type}"
    priority                   = 10
  }

  request_routing_rule {
    name                        = "rr-80"
    rule_type                   = "Basic"
    http_listener_name          = "listener-80"
    redirect_configuration_name = "redirect-80-to-443"
    priority                    = 11
  }

  probe {
    pick_host_name_from_backend_http_settings = true
    name                                      = "customprobe"
    protocol                                  = var.backend_type
    path                                      = "/"
    timeout                                   = 30
    interval                                  = 30
    minimum_servers                           = 0
    unhealthy_threshold                       = 3

    match {
      body = ""
      status_code = [
        "200-499",
      ]
    }
  }

  waf_configuration {
    enabled                  = true
    file_upload_limit_mb     = 100
    firewall_mode            = "Detection"
    max_request_body_size_kb = 128
    request_body_check       = true
    rule_set_type            = "OWASP"
    rule_set_version         = "3.0"

    dynamic "disabled_rule_group" {
      for_each = var.disabled_rules
      content {
        rule_group_name = disabled_rule_group.value.rule_group_name
        rules           = disabled_rule_group.value.rules
      }
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }

  ssl_certificate {
    name                = var.cert_name
    key_vault_secret_id = data.azurerm_key_vault_secret.certificate.id
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = var.ssl_policy_name
  }
}
