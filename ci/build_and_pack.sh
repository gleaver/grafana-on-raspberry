#!/bin/bash

set -x

ASSETS=${ASSETS:-/tmp/assets}
GRAFANA_VERSION=${GRAFANA_VERSION:-5.0.3}
FPM_DOCKER_TAG=${FPM_DOCKER_TAG:-1.9.3}

usage() {
  base="$(basename "$0")"
  cat <<EOUSAGE
usage: $base <arch>
Build and package grafana (armv6, armv7 or arm64 on linux, osx64 and win64) reusing offical assets
Available arch:
  $base armv6
  $base armv7
  $base arm64
  $base osx64
  $base win64 
EOUSAGE
}

if [[ -z `docker images fg2it/fgbw -q` ]]; then
  ci/createImage.py ${GRAFANA_VERSION}
fi
if [[ -z `docker volume ls -q | grep assets-fgbw` ]]; then
  docker volume create assets-fgbw
fi

for TARGET in "$@"
do
  case "$TARGET" in
    armv6)
      ;;
    armv7)
      ;;
    arm64)
      ;;
    osx64)
      ;;
    win64)
      ;;      
    *)
      echo >&2 'error: unknown arch:' "$TARGET"
      usage >&2
      exit 1
      ;;
  esac
  docker run --rm -v assets-fgbw:/tmp/assets/ fg2it/fgbw:all /build.sh ${TARGET}
  FPM_DOCKER_TAG=${FPM_DOCKER_TAG} ci/package.sh ${TARGET}
done