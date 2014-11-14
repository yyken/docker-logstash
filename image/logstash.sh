#!/usr/bin/env bash

# Fail fast, including pipelines
set -e -o pipefail

# Set LOGSTASH_TRACE to enable debugging
[[ $LOGSTASH_TRACE ]] && set -x

# If you don't provide a value for the LOGSTASH_CONFIG_URL env
# var, your install will default to our very basic logstash.conf file.
#
LOGSTASH_DEFAULT_CONFIG_URL='https://gist.github.com/pblittle/8778567/raw/logstash.conf'
LOGSTASH_CONFIG_URL=${LOGSTASH_CONFIG_URL:-${LOGSTASH_DEFAULT_CONFIG_URL}}

LOGSTASH_CONFIG_PATH='/etc/logstash/conf.d/'

config_exists() {
    local exists='true'

    if [[ ! -f $LOGSTASH_CONFIG_PATH ]]; then
        exists='false'
    fi

    echo $exists
}

create_config_directory() {
    local config_path="$LOGSTASH_CONFIG_PATH"

    # && chown -R logstash:logstash ${config_path}

    if ! "mkdir -p ${config_path}" ; then
        echo "Unable to create ${config_path}" >&2
    fi
}

download_error_message() {
    echo "Unable to download ${1} to ${2}"
}

download_config() {
    local config_url="$LOGSTASH_CONFIG_URL"
    local config_path="$LOGSTASH_CONFIG_PATH"

    # Only create the config if one doesn't already exist
    #
    # if [[ $config_exists = 'false' ]]; then
    # else
    #   echo "The ${config_path} directory already exists" >&2
    # fi

    case "$config_url" in
        *.tar|*.tar.gz|*.tgz)
            download_tar "$config_url" "$config_path"
            ;;
        *.war|*.zip)
            download_zip "$config_url" "$config_path"
            ;;
        *.git)
            download_git "$config_url" "$config_path"
            ;;
        *)
            download_other "$config_url" "$config_path"
            ;;
    esac
fi
}

download_tar() {
    if ! "curl -SL ${1} | tar -xzC ${2} --strip-components=1" ; then
        echo download_error_message $1 $2 >&2
    fi
}

download_zip() {
    : # no-op
}

download_git() {
    : # no-op
}

download_other() {
    if ! "curl -k -o ${2} ${1}" ; then
        echo download_error_message $1 $2 >&2
    fi
}

# This will replace ES_EMBEDDED, ES_HOST, and ES_PORT in your logstash.conf
# file if they exist with the IP and port dynamically generated
# by docker. Take a look at the readme for more details.
#
# Note: Don't use this on a file mounting using a docker
# volume, as the inode switch will cause `device or resource busy`
# Instead download your file as normal
#
sanitize_config() {
    sed -e "s/ES_EMBEDDED/${es_embedded}/g" \
        -e "s/ES_HOST/${es_host}/g" \
        -e "s/ES_PORT/${es_port}/g" \
        -i $LOGSTASH_CONFIG_PATH
}

# Fire up logstash!
#
start_agent() {
    exec logstash \
         agent \
         --config $LOGSTASH_CONFIG_PATH \
         -- \
         web
}

main() {

    create_config_directory

    download_config

    sanitize_config

    start_agent
}

main "$@"
