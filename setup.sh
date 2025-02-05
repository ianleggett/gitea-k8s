#!/bin/bash
sudo snap install microk8s --classic
sudo usermod -a -G microk8s ubuntu

microk8s enable dns
microk8s enable dashboard
microk8s enable storage
microk8s enable ingress
microk8s enable helm
microk8s enable helm3

echo "Setting helm repo"

microk8s helm repo add jetstack https://charts.jetstack.io --force-update

microk8s helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.17.0 --set crds.enabled=true

microk8s helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
microk8s helm repo update

microk8s helm install quickstart ingress-nginx/ingress-nginx

echo "applying files"
microk8s kubectl create -f domain-secret-tls.yaml
microk8s kubectl create -f issuer-staging.yaml
microk8s kubectl create -f issuer-prod.yaml

microk8s kubectl describe issuer letsencrypt-staging
microk8s kubectl describe issuer letsencrypt-prod

microk8s kubectl describe certificate

echo "Setting up GITEA..."
microk8s helm repo add gitea-charts https://dl.gitea.com/charts/
microk8s helm install gitea gitea-charts/gitea

echo "Complete, now apply ingress1.yaml"
