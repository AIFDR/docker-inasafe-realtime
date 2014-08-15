#!/bin/bash

REALTIME_DIR=/home/realtime
INASAFE_SOURCE_DIR=${REALTIME_DIR}/src/inasafe
SHAKE_DIR=/home/realtime/shakemaps
REALTIME_DATA_DIR=${REALTIME_DIR}/analysis_data
INASAFE_REALTIME_IMAGE=docker-realtime-inasafe
SFTP_IMAGE=docker-realtime-sftp


function get_credentials {
   docker cp ${SFTP_IMAGE}:/credentials .
   cat credentials
   rm credentials
}

function get_inasafe {

    echo ""
    echo "Pulling the latest InaSAFE Realtime from Github."
    echo "================================================"

    if [ ! -d ${INASAFE_SOURCE_DIR} ]
    then
        git clone --branch realtime http://github.com/AIFDR/inasafe.git --depth 1 --verbose ${INASAFE_SOURCE_DIR}
    else
        cd ${INASAFE_SOURCE_DIR}
        git pull origin realtime
        cd -
    fi
}

# Get inasafe source
get_inasafe

# Kill the previous container
docker kill ${INASAFE_REALTIME_IMAGE}
docker rm ${INASAFE_REALTIME_IMAGE}

SFTP_LOCAL_IP=$(docker inspect ${SFTP_IMAGE} | grep IPAddress | cut -d '"' -f 4)
SFTP_LOCAL_PORT=$(docker inspect ${SFTP_IMAGE} | grep /tcp -m 1 | cut -d ':' -f 1 | cut -d '"' -f 2 | cut -d '/' -f 1)
SFTP_USER_NAME=$(get_credentials | cut -d ':' -f 2 | cut -d ' ' -f 2)
SFTP_USER_PASSWORD=$(get_credentials | cut -d ':' -f 3 | cut -d ' ' -f 2)
SFTP_BASE_PATH=$(docker inspect ${SFTP_IMAGE} | grep ${SHAKE_DIR} -m 1 | cut -d ':' -f 1 | cut -d '"' -f 2)

INSAFE_REALTIME_TEMPLATE=${REALTIME_DATA_DIR}/realtime-template.qpt
INSAFE_REALTIME_PROJECT=${REALTIME_DATA_DIR}/realtime.qgs
INASAFE_POPULATION_PATH=${REALTIME_DATA_DIR}/exposure/population.tif
GEONAMES_SQLITE_PATH=${REALTIME_DATA_DIR}/indonesia.sqlite

docker run --name="${INASAFE_REALTIME_IMAGE}" \
-e EQ_SFTP_BASE_URL=${SFTP_LOCAL_IP} \
-e EQ_SFTP_PORT=${SFTP_LOCAL_PORT} \
-e EQ_SFTP_USER_NAME=${SFTP_USER_NAME} \
-e EQ_SFTP_USER_PASSWORD=${SFTP_USER_PASSWORD} \
-e EQ_SFTP_BASE_PATH=${SFTP_BASE_PATH} \
-e INSAFE_REALTIME_TEMPLATE=${INSAFE_REALTIME_TEMPLATE} \
-e INSAFE_REALTIME_PROJECT=${INSAFE_REALTIME_PROJECT} \
-e INASAFE_POPULATION_PATH=${INASAFE_POPULATION_PATH} \
-e GEONAMES_SQLITE_PATH=${GEONAMES_SQLITE_PATH} \
-v ${INASAFE_SOURCE_DIR}:${INASAFE_SOURCE_DIR} \
-v ${REALTIME_DATA_DIR}:${REALTIME_DATA_DIR} \
-v ${REALTIME_DIR}/shakemaps-cache:${REALTIME_DIR}/shakemaps-cache \
-v ${REALTIME_DIR}/shakemaps-extracted:${REALTIME_DIR}/shakemaps-extracted \
-i -t aifdr/${INASAFE_REALTIME_IMAGE}
