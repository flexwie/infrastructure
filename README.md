# felixwie.com infrastructure
![GitHub deployments](https://img.shields.io/github/deployments/flexwie/infrastructure/production?label=deployment&logo=felixwie.com&style=for-the-badge)

This repository holds the code for the cluster behind [my homepage](https://felixwie.com).
The machines are hosted on ARM instances in the Orcale Cloud Infrastructure. Deployment, orchestration, discovery and everything related is managed with the HashiStack (Nomad, Consul, Packer, Terraform, Vault etc). Continue reading to learn more.

### Image
`see .\packer`  
The image runnning on the machines is custom build with Packer. It extends Ubuntu 20.04-aarch64 and preinstalls Nomad and Consul together with matching configuration.

### Infrastructure
`see .\terraform`
Terraform provisions the machines in a public subnet on the Oracle Cloud. Following in future updates are more machines, stricter port regulations for ingresses and a load balancer.