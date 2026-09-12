# Networking Module

The networking module creates the single virtual network used by the development environment and separates the infrastructure into dedicated subnets.

## Resources

- Virtual Network with configurable address space.
- Application Gateway subnet.
- Web subnet.
- App subnet.
- Delegated PostgreSQL subnet.
- Azure Bastion subnet named `AzureBastionSubnet`.
- Private endpoints subnet.
- Separate Network Security Groups for web, app, gateway, PostgreSQL, and Bastion.
- NAT Gateway and static public IP.
- Bastion public IP and host.

```text
VNet
|
|-- Application Gateway subnet
|-- Web subnet        -> web VM
|-- App subnet        -> app VM and internal load balancer
|-- PostgreSQL subnet -> delegated PostgreSQL server
|-- Bastion subnet    -> Azure Bastion
`-- Private endpoints subnet
```

The module creates one VNet. It does not create hub and spoke VNets, Azure Firewall, route tables, or peering.

The NAT Gateway is associated with the app subnet. The Application Gateway receives public HTTP traffic and routes it to the web VM. The web VM reaches the app tier through the internal load balancer.

Security rules are supplied through variables so each environment can define its own allowed ports and address ranges. Review these rules before applying an environment.
