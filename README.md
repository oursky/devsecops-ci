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

## Tests coverage
- potential secret committed to git
- python [safety](https://github.com/pyupio/safety)
- python [bandit](https://github.com/PyCQA/bandit)


## How to add to your project
To hide dependency packages from polluting workspace, we recommend to use the prebuilt docker image or just `docker build` it on CI.
```
docker build -t devsecops-ci https://github.com/oursky/devsecops-ci.git
```
To delete the image:
```
docker rmi devsecops-ci
```
To perform tests, run:
```
docker run -it --rm -v "`pwd`:/target:ro" devsecops-ci ./check.sh --target-dir=/target --commit-range=rev1..rev2
```
Where `--target-dir` points to the mounted directory in `-v flag`, `--commit-range` is optional to limit checking commit revisions, e.g. `--commit-range=${TRAVIS_COMMIT_RANGE}`


This run check against current `pwd`, this directory should be the top level directory of your project.

You can also build and run it locally on your development computer.


<!-- Markdown link & img dfn's -->
[travis-url]: https://travis-ci.org/oursky/devsecops-ci
[travis-image]: https://travis-ci.org/oursky/devsecops-ci.svg?branch=master
