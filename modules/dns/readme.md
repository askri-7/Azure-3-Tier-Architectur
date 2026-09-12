# Private DNS Module

The DNS module creates private DNS zones and links each zone to the application VNet.

## Current Zones

The development environment supplies zones for:

- PostgreSQL Flexible Server.
- Key Vault private link.
- ACR private link.

The module creates one zone and one VNet link for every entry in the `zones` map.

## Inputs

- `zones`: map of logical names to private DNS zone names.
- `vnet_id`: VNet to link.
- `vnet_name`: used for link naming.
- `resource_group_name`: resource group for the zones and links.
- `tags`: resource tags.

The private DNS zones support private endpoint name resolution. They do not by themselves make a service private. Service network access settings and private endpoints must also be configured by the calling resources.
