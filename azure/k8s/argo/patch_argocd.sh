#!/bin/bash
mkdir -p temp

envsubst < ./k8s/argo/configmap.patch.yml | tee temp/cm.yml
envsubst < ./k8s/argo/rbac.patch.yml | tee temp/rbac.yml

kubectl patch cm argocd-cm --patch-file temp/cm.yml -n argo
kubectl patch cm argocd-rbac-cm --patch-file temp/rbac.yml -n argo

rm -rf temp