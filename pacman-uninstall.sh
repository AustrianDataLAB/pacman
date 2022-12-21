#!/bin/bash

#kubectl delete -n $pacman -f security/rbac.yaml
kubectl delete -n $pacman -f security/secret.yaml
kubectl delete -n $pacman -f deployments/mongo-deployment.yaml
kubectl delete -n $pacman -f deployments/pacman-deployment.yaml
kubectl delete -n $pacman -f services/mongo-service.yaml
kubectl delete -n $pacman -f services/pacman-service.yaml
kubectl delete -n $pacman -f ingress/ingress.yaml
#this secret better not delete cause of the rate limiting of lets encrypt
#kubectl delete secret -n $pacman $pacman-ingress-tls

if [[ $# -gt 0  && "$1" == "keeppvc" ]]
then
    echo "Keeping namespace and persistent volume claim"
else
    kubectl delete -n $pacman -f persistentvolumeclaim/mongo-pvc.yaml
fi

echo "cleaning up your files"
rm persistentvolumeclaim/mongo-pvc.yaml
rm security/secret.yaml
rm ingress/ingress.yaml
