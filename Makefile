SHELL := /usr/bin/env bash


.PHONY:
docker-deskop:
	docker volume create mongodb
	docker-compose -f localdev/docker-compose.yml up

.PHONY:
clean:
	docker volume rm mongodb
