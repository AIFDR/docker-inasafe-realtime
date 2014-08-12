#!/bin/sh

INASAFE_REALTIME_IMAGE=docker-realtime-inasafe

function build_realtime_image {
    echo "Building InaSAFE Realtime Dockerfile"
    docker.io build -t AIFDR/${INASAFE_REALTIME_IMAGE} .
}

build_realtime_image
