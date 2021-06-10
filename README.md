# Hyperchains Playground 🕹️

![GitHub all releases](https://img.shields.io/github/downloads/aeternity/hyperchains_privatenet/total) ![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/aeternity/aeternity) ![GitHub release (latest by date)](https://img.shields.io/github/v/release/aeternity/hyperchains_privatenet)

The Hyperchains playground provides a *docker-compose* setup that runs a Bitcoin node and three Aeternity Hyperchains nodes with predefined configurations.

## Setup

Make sure you have Docker installed and running, and then follow these instructions to run the Hyperchains playground.

1. Clone the repo:
```
git clone https://github.com/aeternity/hyperchains_playground.git
```

2. Clone `aeternity` inside `hyperchains_playground`:
```
cd hyperchains_playground
git clone -b hyperchains-playground --single-branch https://github.com/aeternity/aeternity.git
```

3. And now run:
```
docker-compose up -d
```

<p align="center">
  <img src="docs/images/Setup.png" title="hover text">
    <br>
    <em>Deployment schema</em>
</p>

### Playing transition scenario

* Election contract deployed by user

<p align="center">
  <img src="docs/images/Playground.gif">
</p>


The nodes use the `mean15-generic` miner (fastest generic miner).
As the beneficiary key-pair is publicly available, this setup should *not* be connected to public networks.

All local network nodes are configured with the same beneficiary account (for more details on beneficiary see [configuration documentation](https://github.com/aeternity/aeternity/blob/master/docs/configuration.md#beneficiary-account)):
- public key: ak_twR4h7dEcUtc2iSEDv8kB7UFJJDGiEDQCXr85C3fYF8FdVdyo
- private key secret: `secret`
- key-pair binaries can be found in `/node/keys/beneficiary` directory of this repository

All APIs (external, internal and state channels websocket) are exposed to the docker host, the URL pattern is as follows:
- external/internal API - http://$DOCKER_HOST_ADDRESS:$NODE_PORT/
- channels API - ws://$DOCKER_HOST_ADDRESS:$NODE_PORT/channel

### 3 Node configuration (default)

The multinode configuration (default) uses a proxy server to allow CORS and URL routing.

Node ports:
- `node1` - port 3001
- `node2` - port 3002
- `node3` - port 3003

For example to access `node2` peer public key, assuming docker host address is `localhost`:

```bash
curl http://localhost:3002/v2/peers/pubkey
```

To start the network:

```bash
docker-compose up -d
```

To destroy the network:

```bash
docker-compose down
```

To cleanup the associated docker volumes, `-v` option could be used:

```bash
docker-compose down -v
```

More details can be found in [`docker-compose` documentation](https://docs.docker.com/compose/reference/).

### Single Node Configuraiton

To use a Single Node Configuration just append `-f singlenode.yml` to the docker-compose command. Example:

```bash
docker-compose -f singlenode.yml up
```

### Image Version

Docker compose uses the `aeternity/aeternity:latest` image by default, it will be pulled from [docker hub](https://hub.docker.com/r/aeternity/aeternity/) if it's not found locally.

To change what node version is used set `IMAGE_TAG` environment variable, e.g.:

```bash
IMAGE_TAG=v4.0.0 docker-compose up -d
```

This configuration is known to work with node versions >= 2.0.0

### Mining Rate

By default the localnet has set default mine rate of 1 block per 15 seconds.
It can be changed by setting `AETERNITY_MINE_RATE` environment variable.
The variable is in milliseconds, so to set 1 block per 10 seconds use:

```bash
AETERNITY_MINE_RATE=10000 docker-compose up
```
