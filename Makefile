NAME = pblittle/docker-logstash
VERSION = 0.9.0

# Set the LOGSTASH_CONFIG_URL env var to your logstash.conf file.
# We will use our basic config if the value is empty.
#
# Override default: `make LOGSTASH_CONFIG_URL=<your_config_url> ... run`
#
LOGSTASH_CONFIG_URL := https://gist.githubusercontent.com/pblittle/8778567/raw/logstash.conf

# This default host and port are for using the embedded elasticsearch
# in LogStash.
#
# Override default: `make ES_HOST=127.0.0.2 ES_PORT=9300 ... run`
#
ES_HOST := 127.0.0.1
ES_PORT := 9200

# This env var will create a link to the Elasticsearch container
#
# Override default: `make ES_CONTAINER=elasticsearch ... run`
#
ES_CONTAINER :=

# This is the default exposed Kibana port
#
# Override default: `make KIBANA_PORT=443 ... run`
#
KIBANA_PORT := 9292

# The default logstash-forwarder keys are insecure. Please do not use in production.
#
# Override default: `make LF_SSL_CERT_KEY_URL=<your_key_url> LF_SSL_CERT_URL=<your_cert_url> ... run`
#
LF_SSL_CERT_KEY_URL := https://gist.githubusercontent.com/pblittle/8994708/raw/insecure-logstash-forwarder.key
LF_SSL_CERT_URL := https://gist.githubusercontent.com/pblittle/8994726/raw/insecure-logstash-forwarder.crt

docker_link_flag =
ifdef ES_CONTAINER
	docker_link_flag = --link $(ES_CONTAINER):es
endif

.PHONY: build
build:
	docker build --rm -t $(NAME):$(VERSION) image

.PHONY: run
run:
	docker run -d \
		--name logstash \
		-e ES_HOST=$(ES_HOST) \
		-e ES_PORT=$(ES_PORT) \
		-e LF_SSL_CERT_URL=$(LF_SSL_CERT_URL) \
		-e LF_SSL_CERT_KEY_URL=$(LF_SSL_CERT_KEY_URL) \
		-e LOGSTASH_CONFIG_URL=$(LOGSTASH_CONFIG_URL) \
		-p $(ES_PORT):$(ES_PORT) \
		-p $(KIBANA_PORT):$(KIBANA_PORT) \
		$(docker_link_flag) \
		$(NAME):$(VERSION)

.PHONY: shell
shell:
	docker exec -it $(NAME):$(VERSION) /bin/bash

.PHONY: test
test:
	/bin/bash tests/logstash.sh

.PHONY: tag
tag:
	docker tag $(NAME):$(VERSION) $(NAME):latest

.PHONY: release
release:
	docker push $(NAME)
