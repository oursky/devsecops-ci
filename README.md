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
- [npm audit](https://docs.npmjs.com/cli/audit)


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
docker run -it --rm -v "`pwd`:/target:ro" devsecops-ci check
 OR
docker run -it --rm -v "`pwd`:/target:ro" devsecops-ci check --commit-range=rev1..rev2
 OR
docker run -it --rm -v "`pwd`:/target:ro" devsecops-ci check --target-dir=/target --commit-range=rev1..rev2
```
Where `--target-dir` is optional argument points to the mounted directory, defaults to `/target`.
`--commit-range` is optional argument to check only selected commit revisions, e.g. `--commit-range=revA..revB` or `--commit-range=${TRAVIS_COMMIT_RANGE}`.

This run check against current `pwd`, this directory should be the top level directory of your project.
You can also build and run it locally on your development computer.


## Integrate with TravisCI
Add a job to `.travis.yml`
```
matrix:
  include:
    # your project build jobs
    - language: node_js
    ...

    # devsecops-ci
    - language: minimal
      dist: xenial
      services:
        - docker
      before_install:
        - docker build -t devsecops-ci https://github.com/oursky/devsecops-ci.git
      script:
        - docker run -it --rm -v "`pwd`:/target:ro" devsecops-ci check --verbose=no --commit-range=${TRAVIS_COMMIT_RANGE}
```


## Suppress false alarm
You may suppress false alarm by adding entry to `.devsecops-ci` file.

##### Secret Scanner
```
[git-secret]
exclude: .travis.yml|dir/*.example
allow_secrets:
    secret1
    secret2
```
`exclude` takes a [regex](https://docs.python.org/3/library/re.html) and suppress checking on matched files.  
`allow_secrets` take a list of whitelisted string to ignore, which is partiicularly useful for non-secret like sentry DSN.  

##### bandit
```
[bandit]
exclude: alembic,tests
skips: B123,B456
```
`exclude` takes a comma-separated list of directory or filename and suppress checking on matched files.  
`skips` suppress checking on particular test cases.  
Check https://github.com/PyCQA/bandit for detail.  


<!-- Markdown link & img dfn's -->
[travis-url]: https://travis-ci.org/oursky/devsecops-ci
[travis-image]: https://travis-ci.org/oursky/devsecops-ci.svg?branch=master
