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
[provisioning]
source = "manual"
connection_string = "$IOT_DEVICE_CONNSTR"
EOF
  else
read -d '' provisioning_info << EOF
[provisioning]
source = "dps"
global_endpoint = "https://global.azure-devices-provisioning.net"
id_scope = "$PROVISIONING_IDSCOPE"
registration_id = "$PROVISIONING_REGISTRATION_ID"

[provisioning.attestation]
method = "symmetric_key"
symmetric_key = { value = "$PROVISIONING_SYMMETRIC_KEY" }
EOF
  fi
else
  echo "Cannot run IoT Edge container: PROVISIONING_SOURCE is not set"
  exit 1
fi

echo '=> creating config.toml'
cat <<EOF > /etc/aziot/config.toml
auto_reprovisioning_mode = "OnErrorOnly"
prefer_module_identity_cache = false

$provisioning_info

[aziot_keys]

[preloaded_keys]

[cert_issuance]

[preloaded_certs]

[tpm]

[agent]
name = "edgeAgent"
type = "docker"
imagePullPolicy = "on-create"

[agent.config]
image = "mcr.microsoft.com/azureiotedge-agent:1.4"

[agent.config.createOptions]

[agent.env]

[connect]
workload_uri = "unix:///var/run/iotedge/workload.sock"
management_uri = "unix:///var/run/iotedge/mgmt.sock"

[listen]
workload_uri = "fd://aziot-edged.workload.socket"
management_uri = "fd://aziot-edged.mgmt.socket"
min_tls_version = "tls1.0"

[watchdog]
max_retries = "infinite"

[moby_runtime]
uri = "unix:///var/run/docker.sock"
network = "azure-iot-edge"
EOF

cat /etc/aziot/config.toml

echo '=> running aziot-edged daemon'

exec aziot-edged -c /etc/aziot/config.toml
