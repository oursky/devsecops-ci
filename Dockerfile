FROM python:3.7.0-alpine
MAINTAINER Overflow "overflow@oursky.com"

RUN apk add --no-cache bash

ADD src /usr/local/devsecops-ci

WORKDIR /usr/local/devsecops-ci
