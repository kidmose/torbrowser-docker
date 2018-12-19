SHELL := /bin/bash

# The directory of this file
DIR := $(shell echo $(shell cd "$(shell  dirname "${BASH_SOURCE[0]}" )" && pwd ))

# The local users UID/GID
LUID := $(shell id -u)
LGID := $(shell id -g)

VERSION ?= latest
IMAGE_NAME ?= kidmose/torbrowser
CONTAINER_NAME ?= torbrowser
USER ?= torbrowser

# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# Build the container
build: ## Build the container
	sudo docker build --rm -t $(IMAGE_NAME) .

build-nc: ## Build the container without caching
	sudo docker build --rm --no-cache -t $(IMAGE_NAME) .

run: ## Run container
	XSOCK=/tmp/.X11-unix && \
	XAUTH=$(shell mktemp /tmp/torbrowser_tmp.XXX.xauth) && \
	xauth nlist $$DISPLAY | sed -e 's/^..../ffff/' | xauth -f $$XAUTH nmerge - && \
	chmod 644 $$XAUTH && \
	mkdir -p $(DIR)/Downloads && \
	sudo docker run \
		-it \
		--name $(CONTAINER_NAME) \
		-e DISPLAY=$$DISPLAY \
		-e XAUTHORITY=$$XAUTH \
		-e LOCAL_USER_ID=$(LUID) \
		-e LOCAL_GROUP_ID=$(LGID) \
		-v $$XSOCK:$$XSOCK:ro \
		-v $$XAUTH:$$XAUTH \
		-v $(DIR)/Downloads:/home/$(USER)/Downloads \
		$(IMAGE_NAME):$(VERSION)  && \
	rm $$XAUTH

get: ## Get the latest image
	sudo docker pull $(IMAGE_NAME):$(VERSION)

stop: ## Stop a running container
	sudo docker stop $(CONTAINER_NAME)

remove: ## Remove a (running) container
	sudo docker rm -f $(CONTAINER_NAME)

remove-image-force: ## Remove the latest image (forced)
	sudo docker rmi -f $(IMAGE_NAME):$(VERSION)

