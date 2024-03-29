#!/bin/bash

echo '=> detecting IP'
export IP=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
export IOT_DEVICE_HOSTNAME="host.docker.internal"

ping -q -c1 $IOT_DEVICE_HOSTNAME > /dev/null 2>&1
if [ $? -ne 0 ]; then
  IOT_DEVICE_HOSTNAME=$(ip route | awk '/default/ { print $3 }' | awk '!seen[$0]++')
fi

if [ -n "$PROVISIONING_SOURCE" ]; then
  if [ $PROVISIONING_SOURCE == "manual" ]; then
read -d '' provisioning_info << EOF
provisioning:
  source: "manual"
  device_connection_string: "$IOT_DEVICE_CONNSTR"
EOF
  else
read -d '' provisioning_info << EOF
provisioning:
  source: "dps"
  global_endpoint: "https://global.azure-devices-provisioning.net"
  scope_id: "$PROVISIONING_IDSCOPE"
  attestation:
    method: "symmetric_key"
    registration_id: "$PROVISIONING_REGISTRATION_ID"
    symmetric_key: "$PROVISIONING_SYMMETRIC_KEY"
EOF
  fi
else
  echo "Cannot run IoT Edge container: PROVISIONING_SOURCE is not set"
  exit
fi

echo '=> creating config.yaml'
cat <<EOF > /etc/iotedge/config.yaml
$provisioning_info
agent:
  name: "edgeAgent"
  type: "docker"
  env: {}
  config:
    image: "mcr.microsoft.com/azureiotedge-agent:1.0"
    auth: {}
hostname: "iotedge-runtime"
connect:
  management_uri: "http://$IOT_DEVICE_HOSTNAME:15580"
  workload_uri: "http://$IOT_DEVICE_HOSTNAME:15581"
listen:
  management_uri: "http://$IP:15580"
  workload_uri: "http://$IP:15581"
homedir: "/var/lib/iotedge"
moby_runtime:
  docker_uri: "/var/run/docker.sock"
  network: "azure-iot-edge"
EOF

cat /etc/iotedge/config.yaml

echo '=> running iotedge daemon'

exec iotedged -c /etc/iotedge/config.yaml


