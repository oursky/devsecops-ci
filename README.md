# DevSecOps - CI
> Security checkers callable from CI

[![master](https://img.shields.io/badge/travis-master-blue.svg)][travis-url][![TravisCI][travis-image]][travis-url]

## What is DevSecOps?
In short, _Security as Code, Compliance as Code, Infrastructure as Code_. The goal of this repository is provide a easy to invoke checker toolset to enhance security quality, analogy to lint tool for code quality.

## Operation Pipeline
`devsecops-ci` works like an ordinately link checker, it open up a single command line interface to perform all necessary checks. Simply invoke it in the CI pipeline.
```
┌───────────────┐
│ coding        │
└───────┬───────┘
┌───────┴───────┐
│ git push      │
└───────┬───────┘
┌───────┴──────┐         ┌───────────────┐
│ CI           ├────┬────┤ lint          │
└───────┬──────┘    │    └───────────────┘
        │           │    ┌───────────────┐
        │           ├────┤ tests         │
        │           │    └───────────────┘
        │           │    ┌───────────────┐
        │           └────┤ devsecops-ci  │
        │                └───────────────┘
┌───────┴──────┐
│ CD(optional) │
└──────────────┘
```

## How to add to your project
To hide dependency package from polluting workspace, we recommend to use the prebuilt docker image or just `docker build` it on CI.
```
git clone https://github.com/oursky/devsecops-ci.git
cd devsecops
docker build -t devsecops-ci .
```
To perform tests, run:
```
#!/bin/bash
TARGET=`pwd`
docker run -it --rm devsecops-ci ./run.sh -d /target -v "$TARGET:/target:ro"
if [ $? -ne 0 ]; then
  echo failed.
  exit 1
fi
exit 0
```
or simply
```
docker run -it --rm devsecops-ci ./run.sh -d /target -v "`pwd`:/target:ro"
```

This run check against current `pwd`

You can also build and run it locally on your development computer.

## Tests coverage
TBC.

<!-- Markdown link & img dfn's -->
[travis-url]: https://travis-ci.org/oursky/devsecops-ci
[travis-image]: https://travis-ci.org/oursky/devsecops-ci.svg?branch=master
