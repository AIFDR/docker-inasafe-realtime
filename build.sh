#!/bin/sh

REALTIME_DATA_DIR=/home/realtime/analysis_data
INASAFE_REALTIME_IMAGE=docker-realtime-inasafe

function download_analysis_data {
    echo "Downloading Analysis Data"

    analysis_data=( population.tif population.keywords indonesia.sqlite )
    for data in "${analysis_data[@]}"
    do
        if ! [ -f "${REALTIME_DATA_DIR}/${data}" ]
        then
            wget -c -O ${REALTIME_DATA_DIR}/${data} http://quake.linfiniti.com/${data}
        fi
        cp ${REALTIME_DATA_DIR}/${data} .
    done
}

function build_realtime_image {
    echo "Building InaSAFE Realtime Dockerfile"
    docker build -t AIFDR/${INASAFE_REALTIME_IMAGE} .
}

download_analysis_data
build_realtime_image

# Clean this dir again
rm indonesia.sqlite population.tif population.keywords
