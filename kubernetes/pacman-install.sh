#!/bin/sh
# Taken from this blog: https://vzilla.co.uk/vzilla-blog/building-the-home-lab-kubernetes-playground-part-9

echo "Installing your PacMan app on K8s"
envsubst < persistentvolumeclaim/mongo-pvc.txt.yaml > persistentvolumeclaim/mongo-pvc.yaml
envsubst < security/secret.txt.yaml > security/secret.yaml
envsubst < ingress/ingress.txt.yaml > ingress/ingress.yaml
#I took out the priviledged parts here, this is not required, we can discuss this
#kubectl apply -n $pacman -f security/rbac.yaml
kubectl apply -n $pacman -f security/secret.yaml
kubectl apply -n $pacman -f persistentvolumeclaim/mongo-pvc.yaml
kubectl apply -n $pacman -f deployments/mongo-deployment.yaml
while [ "$(kubectl get pods -l=name='mongo' -n $pacman -o jsonpath='{.items[*].status.containerStatuses[0].ready}')" != "true" ]; do
   sleep 5
   echo "Waiting for mongo pod to change to running status"
done
kubectl apply -n $pacman -f deployments/pacman-deployment.yaml
kubectl apply -n $pacman -f services/mongo-service.yaml
kubectl apply -n $pacman -f services/pacman-service.yaml
kubectl apply -n $pacman -f ingress/ingress.yaml
