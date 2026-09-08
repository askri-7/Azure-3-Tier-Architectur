# Azure Application Gateway

Azure Application Gateway acts as a smart, Layer 7 traffic router that sits between the public internet and your private backend infrastructure. It inspects web traffic to safely direct requests to your internal application servers without exposing them directly to the internet.

## The Traffic Journey

- **The Front Entry**: Public internet traffic arrives at a dedicated static IP address assigned to the gateway.
- **The Listener**: An active monitor on the gateway checks incoming requests on a specific port (like port 80 for standard web traffic) to ensure they are valid.
- **Routing Rules**: The gateway's decision engine evaluates accepted requests and determines which internal pool of servers should handle them based on predefined rules.
- **Backend Settings**: The gateway configures internal communication rules, specifying how fast it expects answers from your servers and which ports to use internally.
- **Backend Pool**: The target group of private virtual machines or App Services that receive the request and process your application code.

## How it Works with Core Networking

Your core networking infrastructure builds the private boundaries, while the gateway serves as the controlled entry checkpoint:

- **Subnet Isolation**: Core networking reserves a dedicated subnet exclusively for the gateway. Backend servers sit in separate, private subnets with no direct public access.
- **Controlled Access**: External users can only communicate with the gateway's public IP. The gateway then passes requests into the private network on their behalf.
- **Cost-Effective Security**: Using standard Layer 7 ingress load balancing prevents external traffic from hitting backend databases or application code directly, providing strong network separation without paying for dedicated firewall appliances.
