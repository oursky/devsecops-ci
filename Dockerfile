FROM python:3.7.0-alpine

RUN apk add --no-cache bash make git sed grep
RUN pip install --upgrade pip

ADD src /usr/local/devsecops-ci
RUN ln -s /usr/local/devsecops-ci/check.sh /usr/local/bin/check

WORKDIR /usr/local/devsecops-ci

RUN make build
