ROOT_DIR?=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PREDICTORS_DIR=$(ROOT_DIR)/predictors

GCP_REGION?=us-central1
GCP_PROJECT?=<PLEASE WRITE YOUR GCP PROJECT NAME HERE>
GCP_SERVICE_ACCOUNT?=numerai-compute@$(GCP_PROJECT).iam.gserviceaccount.com

CLOUD_RUN_CPU?=2
CLOUD_RUN_MEMORY?=2Gi

REPOSITORY?=$(GCP_REGION)-docker.pkg.dev/$(GCP_PROJECT)/numerai-compute
TAG?=$(shell TZ=UTC date '+%Y%m%d')

run-%: build-%
	docker run --rm -it \
		-e PORT=8080 \
		-p 8080:8080 \
	    $(REPOSITORY)/${@:run-%=%}:local

build-%:
	docker build \
	    --tag $(REPOSITORY)/${@:build-%=%}:$(TAG) \
		--platform linux/amd64 \
		-f $(PREDICTORS_DIR)/${@:build-%=%}/Dockerfile \
		--build-arg PREDICTOR=${@:build-%=%} \
		$(ROOT_DIR)
	docker tag $(REPOSITORY)/${@:build-%=%}:$(TAG) $(REPOSITORY)/${@:build-%=%}:local

push-%:
	docker push $(REPOSITORY)/${@:build-%=%}:$(TAG)

deploy-%:
	gcloud beta run deploy numerai-compute-$(subst _,-,${@:build-%=%}) \
		--execution-environment=gen2 \
		--image=$(REPOSITORY)/${@:deploy-%=%}:$(TAG) \
		--allow-unauthenticated \
		--service-account=$(GCP_SERVICE_ACCOUNT) \
		--concurrency=1 \
		--timeout=1200 \
		--cpu=$(CLOUD_RUN_CPU) \
		--memory=$(CLOUD_RUN_MEMORY) \
		--max-instances=4 \
		--set-secrets=NUMERAI_PUBLIC_ID=numerai-public-id:1,NUMERAI_SECRET_KEY=numerai-secret:1 \
		--region=$(GCP_REGION) \
		--project=$(GCP_PROJECT)

release-%: build-% push-% deploy-%
