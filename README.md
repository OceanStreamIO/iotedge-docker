# iotedge-runtime
### Run the [Azure IoT Edge](https://azure.microsoft.com/en-us/services/iot-edge/) runtime in a Docker container

This project is based on the [Azure IoT Edge dev tool](https://github.com/Azure/iotedgedev), but it only contains the Docker image needed to run the Azure IoT Edge runtime in a container.

It is supposed to be used mostly in local development environments and it's wrapped in an NPM package.

## Installation
To install via NPM, simply run:

```sh
$ npm install iotedge
```

Otherwise, clone the project from Github:
```sh
$ git clone git@github.com:pineviewlabs/iotedge-docker.git
```

## Usage

### 1. Building the Docker image

Using NPM:

```sh
$ npx build-iotedge
```

or build the docker image manually with:

```sh
$ docker build . -t iotedge-runtime
```

This will create a Docker image tagged `iotedge-runtime`.

### 2. Set the Device Connection String

Go to the [Azure Portal](https://portal.azure.com/), then go to your IoT Hub and click on IoT Edge from under the **Automatic Device Management** section.

Select an existing device that you would like to use or create a new one. Once on the device page, copy one of the two connection strings (either the _Primary Connection String_ or the _Secondary Connection String_).
You will need to set the connection string you have just grabbed as an environment variable, named `IOT_DEVICE_CONNSTR`.

**Example**:
```sh
$ export IOT_DEVICE_CONNSTR='HostName=iothub0730.azure-devices.net;DeviceId=myEdgeDevice;SharedAccessKey=zfD73oX3agHTlT0rOvjPnYTkxRPw/k3U0exEGBDWQ5A='
```                                                                                           
                                                                                          
### 3. Run the Docker image

Using NPM:
```sh
$ npx start-iotedge
```

Or run the container using the provided `run-container.sh` script in the `bin` folder:

```sh
$ ./bin/run-container.sh
```

A container named `iotedgec` will be created and inside the container the `iotedged` daemon will be started. If everything is working correctly you will see the daemon output log.

The IoT Edge runtime and its associated modules (which are running as independent containers) are using a Docker network called `azure-iot-edge`. The script also creates the network, if it doesn't already exist.

The daemon will use the default ip address assigned by Docker to the container (most probably will be 172.17.0.2). The discovery is automatically done in the `rund.sh` script located in the lib folder.

## Using the `iotedge` CLI tool

This package also provides a cli utility which helps with development, debugging, and troubleshooting of issues. You can use it in two ways:

Via NPM:
```sh
$ npx iotedge
``` 

or running the provided `iotedge.sh` script directly:

```sh
$ ./bin/iotedge.sh
```

This tool forwards the arguments to the `iotedge` CLI tool available in the main runtime container.  

For example:

```sh
$ ./bin/iotedge.sh list
```

is equivalent to:
```sh
docker exec iotedgec iotedge -H http://172.17.0.2:15580 list
```
