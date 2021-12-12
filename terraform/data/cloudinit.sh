#!/bin/bash

# Disable firewall 
sudo /usr/sbin/netfilter-persistent stop
sudo /usr/sbin/netfilter-persistent flush

sudo systemctl stop netfilter-persistent.service
sudo systemctl disable netfilter-persistent.service

# END Disable firewall

sudo apt-get update
sudo apt-get install -y software-properties-common jq
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

local_ip=$(curl -s -H "Authorization: Bearer Oracle" -L http://169.254.169.254/opc/v2/vnics/ | jq -r '.[0].privateIp')
public_ip=$()
flannel_iface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)')

echo "Cluster init!"
sudo snap install microk8s --classic

sudo microk8s status --wait-ready

sudo microk8s enable dns:1.1.1.1 ingress rbac


until sudo microk8s kubectl get pods -A | grep 'Running'; do
  echo 'Waiting for microk8s startup'
  sleep 5
done

sudo usermod -a -G microk8s ubuntu
sudo chown -f -R ubuntu ~/.kube

sudo newgrp microk8s