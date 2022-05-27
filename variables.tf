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

variable "resource_group_name" {
  type        = string
  description = "The resource group to create the application gateway in"
}

variable "mgmg_resource_group" {
  type = string
  description = "resource group with KV used for certificates"
  default = "iq3-basemanagement"
}

variable "vnet_resource_group_name" {
  type        = string
  description = "The resource group in which the network components are located in (vnet and subnet)"
}

variable "agw_name" {
  type        = string
  description = "The name of the application gateway"
}

variable "is_private_agw" {
  type        = bool
  default     = true
  description = "Defines wether the AGW is publicly reachable"
}

variable "agw_private_ip" {
  type        = string
  description = "The internal, private ip address of the application gateway"
}

variable "vnet_name" {
  type        = string
  description = "The name of the virtual network inside networking resourcegroup"
}

variable "vnet_subnet_name" {
  type        = string
  description = "The subnet name where the application gateway should be located in"
}

variable "cert_key_vault_name" {
  type        = string
  description = "The key vault name that holds the certificate for the https listener. Ensure that the pipeline has contributor rights on that key vault, as an access policy for the AGW will be created within this module."
}

variable "cert_name" {
  type        = string
  description = "The name of the SSL certificate inside the certificate key vault"
}

variable "backend_fqdns" {
  type        = list(string)
  default     = []
  description = "Backend addresses to be added to Pool"
}

variable "backend_type" {
  type        = string
  default     = "http"
  description = "Define backend http or https type"

  validation {
    condition     = contains(["http", "https"], var.backend_type)
    error_message = "The backend type must be either http or https."
  }
}

variable "override_backend_host_name" {
  type    = string
  default = null
}

variable "ssl_policy_name" {
  type        = string
  default     = "AppGwSslPolicy20170401"
  description = "Name of the predefined SSL TLS policiy"
}

#######################
# WAF Rule Exceptions #
#######################
variable "disabled_rules" {
  type = list(object({
    rule_group_name = string
    rules           = list(number)
  }))
  default = []
}