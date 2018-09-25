FROM python:3.7.0-alpine

RUN apk add --no-cache bash

ADD src /usr/local/devsecops-ci

WORKDIR /usr/local/devsecops-ci
