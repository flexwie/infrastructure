#!/bin/bash
# kubectl create -f traefik-serviceaccount.yml
# kubectl create -f traefik-clusterrole.yml
# kubectl create -f traefik-crb.yml
kubectl create -f traefik-deployment.yml
kubectl create -f traefik-np.yml
kubectl create -f traefik-ui-ingress.yml