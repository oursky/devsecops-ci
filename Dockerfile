FROM python:3.7.0-alpine

RUN apk add --no-cache bash make
RUN pip install --upgrade pip

ADD src /usr/local/devsecops-ci

WORKDIR /usr/local/devsecops-ci

RUN make build
