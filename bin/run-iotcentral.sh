#!/bin/bash

PROVISIONING_SOURCE="dps"
PROVISIONING_REGISTRATION_ID=""
PROVISIONING_IDSCOPE=""
PROVISIONING_SYMMETRIC_KEY=""

docker_network=$(docker network list | awk '/azure-iot-edge/ { print $2 }' | grep '^azure-iot-edge$')

if [ ! -z "$docker_network" ]; then
  echo 'azure-iot-edge docker network found.'
else
  echo 'azure-iot-edge docker network not found, creating...'
  docker network create --attachable azure-iot-edge
fi

docker run \
    -i \
    -t \
    --rm \
    -v //var//run//docker.sock://var//run//docker.sock \
    -p 15580:15580 \
    -p 15581:15581 \
    --network bridge \
    --name iotedgec \
    -e PROVISIONING_SOURCE="$PROVISIONING_SOURCE" \
    -e PROVISIONING_REGISTRATION_ID="$PROVISIONING_REGISTRATION_ID" \
    -e PROVISIONING_IDSCOPE="$PROVISIONING_IDSCOPE" \
    -e PROVISIONING_SYMMETRIC_KEY="$PROVISIONING_SYMMETRIC_KEY" \
    iotedge-runtime

