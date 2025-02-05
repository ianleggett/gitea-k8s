#!/bin/bash
sudo snap install microk8s --classic
sudo usermod -a -G microk8s ubuntu

microk8s enable dns 
microk8s enable dashboard
microk8s enable storage
microk8s enable ingress
microk8s install helm

alias kube="microk8s kubectl"
alias helm="microk8s helm"

helm repo add jetstack https://charts.jetstack.io --force-update
helm install cert-manager jetstack/cert-manager   --namespace cert-manager   --create-namespace   --version v1.17.0   --set crds.enabled=true

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install quickstart ingress-nginx/ingress-nginx

kubectl create -f issuer-staging.yaml
kubectl create -f issuer-prod.yaml
kubectl describe issuer letsencrypt-staging
kubectl describe issuer letsencrypt-prod

kubectl describe certificate

helm repo add gitea-charts https://dl.gitea.com/charts/
helm install gitea gitea-charts/gitea