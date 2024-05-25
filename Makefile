.PHONY: build-fetch build-all

# Default dockerhub account
DOCKER_ACCOUNT ?= matthieujln

#===================================#
#       BUILD DOCKER IMAGES			
#===================================#
build-sca:
	cd docker/sca && ./build.sh $(DOCKER_ACCOUNT)


build-all: 
	$(MAKE) build-sca
#===================================#
#        PUSH DOCKER IMAGES
#===================================#
push-sca:
	cd docker/sca && ./push.sh $(DOCKER_ACCOUNT)

push-all: 
	$(MAKE) push-sca

#===================================#
#       DOCKER COMPOSE			
#===================================#

run-sca:
	DOCKERHUB_USERNAME=$(DOCKER_ACCOUNT) docker compose up sca

run-all:
	DOCKERHUB_USERNAME=$(DOCKER_ACCOUNT) docker compose up

shutdown:
	docker compose down

teardown:
	docker compose down -v
