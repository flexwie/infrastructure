# Azure Infrastructure

This repository contains IaC to provision a Kubernetes cluster on AKS with an optional scaling node pool and bootstrap it with essential resources like nginx-ingress, certs, ArgoCD, monitoring, etc.

## Authentification

Authentification uses the Az CLI so make sure that you have it [installed](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), are logged in (`az login`) and have selected the correct subscription (az account set --subscription \<ID>).

## Components

Running `terraform apply` will create the cluster, a node pool that scales up to 2 additional nodes if needed (from 0) and Azure AD resources to authenticate in ArgoCD (app registration and admin user group). It will also deploy the needed Kubernetes manifests for ArgoCD (located in `k8s/argo`) in the argo namespace along with an application that has configuration for the nginx ingress and cert-manager (located in `k8s/system`).
Additional apps for the ingresses and monitoring will need to be added to ArgoCD by hand (automation to come).
