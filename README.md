# Kubernetes Cluster Infrastructure

This repository holds configurations for Kubernetes clusters on Azure, OCI and the Hetzner Cloud. I currently actively use AKS on Azure but will keep the other two for reference.

## AKS

The AKS cluster is set up with a storage account and SQL server accessible over a private network. It also has OIDC and [workload identities](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview) enabled.

## OCI

The cluster on the Oracle Cloud is running a custom packer image on ARM instances. I tried to create a self-managed cluster fully within their free tier limits but abandoned the idea because the availability of ARM instances was too flaky.

## Hetzner

The Hetzner cluster is a very simple cluster that runs a single node with K3s.
