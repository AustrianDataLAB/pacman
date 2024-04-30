CLUSTER_NAME=lecture7
OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH := $(shell uname -m | sed 's/x86_64/amd64/')
HELM := $(shell which helm)

##@ packing pacman
.PHONY: helm-create
helm-create: helm check-context ## 
	-$(HELM) create pacman-rancher

.PHONY: helm-package
helm-package: helm check-context ## 
	-$(HELM) lint pacman-rancher
	-$(HELM) package pacman-rancher

## Exercise : use the my-values.yaml in the ../charts/pacman-rancher directory and understand the settings where it says Exercise
.PHONY: helm-deploy
helm-deploy:  check-context ## 
	-$(HELM) upgrade --install pacman-rancher ../charts/pacman-rancher --namespace pacman --create-namespace
	- kubectl port-forward -n pacman svc/pacman-rancher 8080:8080

##@ Monitoring

.PHONY: monitoring
monitoring: helm check-context ## 
	-$(HELM) repo add prometheus-community https://prometheus-community.github.io/helm-charts
	-$(HELM) repo update
	-$(HELM) upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring  --create-namespace


.PHONY: clean
clean: helm check-context ## 
	-$(HELM) uninstall kube-prometheus-stack --namespace monitoring  


##@ Kind

.PHONY: cluster-up
cluster-up: kind ## Create the kind cluster
	$(KIND) create cluster --name $(CLUSTER_NAME) 


.PHONY: cluster-down
cluster-down: kind clean ## Create the kind cluster
	$(KIND) delete cluster --name $(CLUSTER_NAME) 


.PHONY: kind
KIND = $(shell pwd)/bin/kind
kind: ## Download kind if required
ifeq (,$(wildcard $(KIND)))
ifeq (,$(shell which kind 2> /dev/null))
	@{ \
		mkdir -p $(dir $(KIND)); \
		curl -sSLo $(KIND) https://kind.sigs.k8s.io/dl/$(KIND_VERSION)/kind-$(OS)-$(ARCH); \
		chmod + $(KIND); \
	}
else
KIND = $(shell which kind)
endif
endif

.PHONY: helm
HELM = $(shell pwd)/bin/helm
helm: ## Download helm if required
ifeq (,$(wildcard $(HELM)))
ifeq (,$(shell which helm 2> /dev/null))
	@{ \
		mkdir -p $(dir $(HELM)); \
		curl -sSLo $(HELM).tar.gz https://get.helm.sh/helm-v$(HELM_VERSION)-$(OS)-$(ARCH).tar.gz; \
		tar -xzf $(HELM).tar.gz --one-top-level=$(dir $(HELM)) --strip-components=1; \
		chmod + $(HELM); \
	}
else
HELM = $(shell which helm)
endif
endif


.PHONY: check-context
check-context:
    CURRENT_CONTEXT:=$(shell kubectl config current-context) \
    if [ "$${CURRENT_CONTEXT}" != "kind-$${CLUSTER_NAME}" ]; then \
        echo "Error: kubectl context is not set to kind-$${CLUSTER_NAME}"; \
        exit 1; \
    fi