FROM ocaml/opam2:alpine as builder

# opam is a program designed for running as non-root.
# The user of the image should be opam.
# opam relies on `eval $(opam env)` to
# make $PATH correctly. Normally that command
# is run as part of the login shell.
# But RUN is not login shell so
# we need to RUN every command with `opam config exec`
USER opam:nogroup

RUN mkdir -p /home/opam/src
WORKDIR /home/opam/src

COPY --chown=opam:nogroup ignorefile.opam .
RUN opam install . --deps-only

COPY --chown=opam:nogroup . .
RUN opam config exec make build

FROM alpine:3.9
COPY --from=builder /home/opam/src/_build/default/cmd/ignorefile.exe /
WORKDIR /target
ENTRYPOINT ["/ignorefile.exe"]
