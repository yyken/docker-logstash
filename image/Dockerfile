FROM debian:jessie
MAINTAINER P. Barrett Little <barrett@barrettlittle.com> (@pblittle)

ENV LOGSTASH_VERSION 1.4.2
ENV LOGSTASH_SOURCE_URL https://download.elasticsearch.org/logstash/logstash/logstash-$LOGSTASH_VERSION.tar.gz

ENV JAVA_VERSION 7u65

RUN groupadd -r logstash \
    && useradd -r -g logstash logstash

RUN apt-get update \
    && apt-get install -y \
       ca-certificates \
       curl \
       git \
       openjdk-7-jre-headless="$JAVA_VERSION"* \
       --no-install-recommends \
    && rm -rf /var/cache/apt/* \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/logstash \
    && chown -R logstash:logstash /usr/src/logstash

RUN curl -SL "$LOGSTASH_SOURCE_URL" \
    | tar -xzC /usr/src/logstash --strip-components=1

ENV PATH /usr/src/logstash/bin:$PATH

RUN mkdir -p /usr/src/app \
    && chown -R logstash:logstash /usr/src/app

WORKDIR /usr/src/app

# Build files
COPY . /usr/src/app

# Kibana
EXPOSE 9292

# Start logstash
ENTRYPOINT ["bin/boot"]
