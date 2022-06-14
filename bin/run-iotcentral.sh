#!/bin/bash

PROVISIONING_SOURCE="dps"
PROVISIONING_REGISTRATION_ID="236oirtaht0"
PROVISIONING_IDSCOPE="0ne001C7684"
PROVISIONING_SYMMETRIC_KEY="Q8towau87oZ9uJ1OMblqQo2kCcyzuaDcZaUlBhEOBXw="
IOT_DEVICE_CONNSTR="HostName=oceanbox-iotedge.azure-devices.net;DeviceId=testiotedge-mac-docker;SharedAccessKey=q164SPd4vCMCG+ajnt/u6qyTqCcyOvPhn0XBaUTgi5k="

docker_network=$(docker network list | awk '/azure-iot-edge/ { print $2 }' | grep '^azure-iot-edge$')

if [ ! -z "$docker_network" ]; then
  echo 'azure-iot-edge docker network found.'
else
  echo 'azure-iot-edge docker network not found, creating...'
  docker network create --attachable azure-iot-edge
fi

if [ -z ${IOT_DEVICE_CONNSTR} ]; then
    echo "Cannot run IoT Edge container: IOT_DEVICE_CONNSTR is not set"
    echo "Eg:"
    echo "export IOT_DEVICE_CONNSTR='HostName=iothub0730.azure-devices.net;DeviceId=myEdgeDevice;SharedAccessKey=zfD73oX3agHTlT0rOvjPnYTkxRPw/k3U0exEGBDWQ5A='"
    exit
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
    -e IOT_DEVICE_CONNSTR="$IOT_DEVICE_CONNSTR" \
    -e PROVISIONING_SOURCE="$PROVISIONING_SOURCE" \
    -e PROVISIONING_REGISTRATION_ID="$PROVISIONING_REGISTRATION_ID" \
    -e PROVISIONING_IDSCOPE="$PROVISIONING_IDSCOPE" \
    -e PROVISIONING_SYMMETRIC_KEY="$PROVISIONING_SYMMETRIC_KEY" \
    iotedge-runtime

