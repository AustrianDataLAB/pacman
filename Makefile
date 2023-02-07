SHELL := /usr/bin/env bash

MONGODB_DATA_VOLUME := ./localdev/mongodb

.PHONY:
data_volume:
	mkdir -p $(MONGODB_DATA_VOLUME)
	chown -R 1001:1001 $(MONGODB_DATA_VOLUME)

# use make docker-desktop for MAC, not yet tested on Linux
.PHONY:
docker-deskop:
	docker volume create mongodb
	docker-compose -f localdev/docker-compose.yml up

.PHONY:
clean:
	rm -rf $(MONGODB_DATA_VOLUME)
