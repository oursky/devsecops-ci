## Build and run with Docker

```sh
docker build -t ignorefile .
docker run --rm -v "$PWD":/target:ro ignorefile --help
docker run --rm -v "$PWD":/target:ro ignorefile .dockerignore
```

## Build locally

```sh
# Install opam, the compiler version manager and package manager of OCaml.
# Follow the instruction to setup opam.
brew install opam
# Create a switch, which is a standalone environment in opam terms.
# It downloads and compiles the compiler from source so it takes time.
opam switch create . ocaml-base-compiler.4.07.1
# Install dependencies
opam install . --deps-only --with-test
# Run test
make test
```
