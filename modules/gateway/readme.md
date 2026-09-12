# Application Gateway Module

The gateway module creates the public entry point for the web tier.

## Resources

- Static public IP.
- Azure Application Gateway.
- Gateway IP configuration connected to the Application Gateway subnet.
- HTTP frontend listener on port 80.
- Empty backend address pool populated by the web tier NIC association.
- HTTP backend settings on port 80.
- Basic request routing rule.

```text
Public client
    |
    v
Application Gateway public IP
    |
    v
Web VM backend pool
```

The gateway currently provides HTTP routing. HTTPS certificates, TLS termination, WAF policy, autoscaling, and multiple backend pools are not implemented by this module yet.

The web tier consumes the exported backend pool ID and associates its NIC with the gateway pool. The gateway does not route directly to the app VM or PostgreSQL.
