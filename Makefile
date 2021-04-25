REGISTRY_OWNER:=fazenda
MULTIARCH:=false
ARCHS:=linux/amd64
PROJECT_TAG:=latest

ifeq (true, $(MULTIARCH))
	ARCHS:=linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64/v8,linux/ppc64le,linux/s390x
endif

all: install setup

install:
	@curl -fSL https://get.docker.com | sh
	@sudo usermod -aG docker $(USER)
	@sudo systemctl enable docker
	@sudo systemctl start docker

mkcert:
	@git clone https://github.com/FiloSottile/mkcert $(HOME)/mkcert
  # @go build -ldflags "-X main.Version=$(shell git describe --tags)"
  # PATH:=$(PATH):$(HOME)/mkcert
	@mkcert -install
	@mkdir $(HOME)/.certs
	@mkdir $(HOME)/.traefik
	@mkcert \
		-cert-file $(HOME)/.certs/local-cert.pem \
		-key-file $(HOME)/.certs/local-key.pem \
		"docker.localhost" "*.docker.localhost" "domain.local" "*.domain.local"

compose:
	@pip3 install docker-compose==1.27.4

setup: mkcert compose
	@docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	@docker buildx rm builder
	@docker buildx create --name builder --driver docker-container --use
	@docker buildx inspect --bootstrap

build:
	@docker buildx build --platform $(ARCHS) --target dev --push --tag ${REGISTRY_OWNER}/vuehouse:${PROJECT_TAG} .
