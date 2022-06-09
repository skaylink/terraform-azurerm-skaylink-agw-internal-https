# Skaylink Terraform module; Azure application gateway

Deploys an application gateway with standard rule set for https traffic internally.
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_gateway.agw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway) | resource |
| [azurerm_key_vault_access_policy.allow_user_identiy_cert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_public_ip.agw_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_user_assigned_identity.identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_secret.certificate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_resource_group.networking_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agw_name"></a> [agw\_name](#input\_agw\_name) | The name of the application gateway | `string` | n/a | yes |
| <a name="input_agw_private_ip"></a> [agw\_private\_ip](#input\_agw\_private\_ip) | The internal, private ip address of the application gateway | `string` | n/a | yes |
| <a name="input_backend_fqdns"></a> [backend\_fqdns](#input\_backend\_fqdns) | Backend addresses to be added to Pool | `list(string)` | `[]` | no |
| <a name="input_backend_type"></a> [backend\_type](#input\_backend\_type) | Define backend http or https type | `string` | `"http"` | no |
| <a name="input_cert_key_vault_name"></a> [cert\_key\_vault\_name](#input\_cert\_key\_vault\_name) | The key vault name that holds the certificate for the https listener. Ensure that the pipeline has contributor rights on that key vault, as an access policy for the AGW will be created within this module. | `string` | n/a | yes |
| <a name="input_cert_name"></a> [cert\_name](#input\_cert\_name) | The name of the SSL certificate inside the certificate key vault | `string` | n/a | yes |
| <a name="input_disabled_rules"></a> [disabled\_rules](#input\_disabled\_rules) | ###################### WAF Rule Exceptions # ###################### | <pre>list(object({<br>    rule_group_name = string<br>    rules           = list(number)<br>  }))</pre> | `[]` | no |
| <a name="input_is_private_agw"></a> [is\_private\_agw](#input\_is\_private\_agw) | Defines wether the AGW is publicly reachable | `bool` | `true` | no |
| <a name="input_mgmg_resource_group"></a> [mgmg\_resource\_group](#input\_mgmg\_resource\_group) | resource group with KV used for certificates | `string` | `"iq3-basemanagement"` | no |
| <a name="input_override_backend_host_name"></a> [override\_backend\_host\_name](#input\_override\_backend\_host\_name) | n/a | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group to create the application gateway in | `string` | n/a | yes |
| <a name="input_ssl_policy_name"></a> [ssl\_policy\_name](#input\_ssl\_policy\_name) | Name of the predefined SSL TLS policiy | `string` | `"AppGwSslPolicy20170401"` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | The name of the virtual network inside networking resourcegroup | `string` | n/a | yes |
| <a name="input_vnet_resource_group_name"></a> [vnet\_resource\_group\_name](#input\_vnet\_resource\_group\_name) | The resource group in which the network components are located in (vnet and subnet) | `string` | n/a | yes |
| <a name="input_vnet_subnet_name"></a> [vnet\_subnet\_name](#input\_vnet\_subnet\_name) | The subnet name where the application gateway should be located in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_pool"></a> [backend\_pool](#output\_backend\_pool) | n/a |
<!-- END_TF_DOCS -->