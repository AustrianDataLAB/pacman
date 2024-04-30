#!/bin/bash
kustomize build base > base.yaml
# Build and apply manifests for devkind environment
kustomize build devkind > devkind.yaml
#kubectl apply -f devkind.yaml --kubeconfig=/path/to/devkind/kubeconfig

# Build and apply manifests for devaks environment
kustomize build devaks > devaks.yaml
#kubectl apply -f devaks.yaml --kubeconfig=/path/to/devaks/kubeconfig