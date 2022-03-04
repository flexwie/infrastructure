#!/bin/bash

kubectl patch deployment ingress-nginx-controller --patch-file ./k8s/system/deployment.patch.yml -n kube-system
# kubectl apply -f ./k8s/system/nginx.metrics.yml
