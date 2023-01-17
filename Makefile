SHELL := /usr/bin/bash

MONGODB_DATA_VOLUME := ./localdev/mongodb

.PHONY:
data_volume:
	mkdir -p $(MONGODB_DATA_VOLUME)
	chown -R 1001:1001 $(MONGODB_DATA_VOLUME)

.PHONY:
clean:
	rm -rf $(MONGODB_DATA_VOLUME)
