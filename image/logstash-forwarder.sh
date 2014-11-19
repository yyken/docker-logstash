#!/usr/bin/env bash

# Fail fast, including pipelines
set -e -o pipefail

# Set LOGSTASH_TRACE to enable debugging
[[ $LOGSTASH_TRACE ]] && set -x

# The default logstash-forwarder keys are insecure. Please do not
# use them in production. Set the LF_SSL_CERT_KEY_URL and LF_SSL_CERT_URL
# env vars to use your secure keys.

SSL_CERT_PATH='/opt/ssl'

create_ssl_directory() {
    echo 'Creating SSL certificate directory ...'

    if ! "$(mkdir -p $SSL_CERT_PATH)" ; then
        echo "Unable to create ${SSL_CERT_PATH}" >&2
    fi
}

LF_SSL_CERT_FILE="${SSL_CERT_PATH}/logstash-forwarder.crt"
LF_SSL_CERT_URL=${LF_SSL_CERT_URL:-'https://gist.githubusercontent.com/pblittle/8994726/raw/insecure-logstash-forwarder.crt'}

download_cert() {
    echo 'Downloading logstash forwarder ssl certificate ...'

    if ! "$(curl -s $LF_SSL_CERT_URL > $LF_SSL_CERT_FILE)" ; then
        echo "Unable to download ${LF_SSL_CERT_URL} to ${LF_SSL_CERT_FILE}" >&2
    fi
}

LF_SSL_CERT_KEY_FILE="${SSL_CERT_PATH}/logstash-forwarder.key"
LF_SSL_CERT_KEY_URL=${LF_SSL_CERT_KEY_URL:-'https://gist.githubusercontent.com/pblittle/8994708/raw/insecure-logstash-forwarder.key'}

download_key() {
    echo 'Downloading logstash forwarder ssl key ...'

    if ! "$(curl -s $LF_SSL_CERT_KEY_URL > $LF_SSL_CERT_KEY_FILE)" ; then
        echo "Unable to download ${LF_SSL_CERT_KEY_URL} to ${LF_SSL_CERT_KEY_FILE}" >&2
    fi
}

main() {
    # Download logstash-forwarder key and certificate
    #
    create_ssl_directory && download_cert && download_key
}

main "$@"
