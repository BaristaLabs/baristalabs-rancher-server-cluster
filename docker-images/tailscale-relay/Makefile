IMAGE_TAG="baristalabs/tailscale-relay:latest"

build:
	@docker buildx build . -t $(IMAGE_TAG) --platform linux/amd64,linux/arm64,linux/arm/v7

push: build
	@docker buildx build . -t $(IMAGE_TAG) --platform linux/amd64,linux/arm64,linux/arm/v7 --push
