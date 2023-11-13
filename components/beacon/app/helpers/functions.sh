#!/usr/bin/env bash

_echoerr() {
  1>&2 echo "$@"
}

_err() {
  _echoerr "error: $*"
  exit 1
}
