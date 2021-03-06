# Hyperchains Playground 🕹️

![GitHub all releases](https://img.shields.io/github/downloads/aeternity/hyperchains_privatenet/total) ![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/aeternity/aeternity) ![GitHub release (latest by date)](https://img.shields.io/github/v/release/aeternity/hyperchains_privatenet)

The [Hyperchains](https://github.com/aeternity/hyperchains-whitepaper) playground provides an isolated environment for Hyperchains node operators with intention to develop their operational skills before Hyperchains release stage.

The deployment is based on [docker-compose](https://docs.docker.com/compose/) setup that runs a Bitcoin node and three [Aeternity](https://github.com/aeternity/aeternity) Hyperchains nodes with predefined configurations.

<p align="center">
  <img src="docs/images/Setup.png" title="hover text">
    <br>
    <em>Deployment schema</em>
</p>

# How to start

Make sure you have Docker [installed](https://docs.docker.com/engine/install/) and running, and then follow these instructions to run the Hyperchains playground:

### 1. Clone the repo:
```bash
git clone https://github.com/aeternity/hyperchains_playground.git
```

### 2. Setup activation criteria:

Open the config [folder](https://github.com/aeternity/hyperchains_playground/tree/master/config/aeternity) and setup Hyperchains activation:

- minimum balance of the staking contract required to start the HC
- minimum amount of unique delegates required to start the HC
- frequency at which we check the criteria
- confirmation depth of the criteria
 
```yaml
### The default configuration if you want to skip this step
hyperchains:
  activation_criteria: { minimum_stake: 1, unique_delegates: 1, check_frequency: 1, confirmation_depth: 0}
```

For more detailed explanation read [activation network guide](#activation-network-guide)

### 4. Configure Bitcoin wallet:

Run Bitcoin container:

```bash
docker-compose run -d --name bitcoin bitcoin
```

Create a new [wallet](https://developer.bitcoin.org/reference/rpc/createwallet.html) (we use “hyperchains” for convenience, feel free to apply different name):

```bash
docker exec bitcoin sh -c 'bitcoin-cli createwallet "hyperchains"'
```

Create a new [address](https://developer.bitcoin.org/reference/rpc/getnewaddress.html) within a new generated wallet:

```bash
docker exec bitcoin sh -c 'bitcoin-cli getnewaddress "hyperchains"'
```

Create Bitcoin [blocks](https://developer.bitcoin.org/reference/rpc/generatetoaddress.html) to get a mining reward and increase initial balance (use an address from a previous step):

```bash
docker exec bitcoin sh -c 'bitcoin-cli generatetoaddress 200 "bcrt1qmtl7a8yl4pps2tvynzw8gx6v6wpewnc8yajele"'
```

Open the config [folder](https://github.com/aeternity/hyperchains_playground/tree/master/config/aeternity) and setup Hyperchains connector:

```yaml
hyperchains:
  setup:
    primary:
      args:
        address: bcrt1qmtl7a8yl4pps2tvynzw8gx6v6wpewnc8yajele
        wallet: hyperchains
```        

Stop Bitcoin container:

```bash
docker stop bitcoin
```

### 5. Configure initial stacking:

Open the config [folder](https://github.com/aeternity/hyperchains_playground/tree/master/config/aeternity) and configure initial stake (you can play with different proportions on each node ([kyiv](https://github.com/aeternity/hyperchains_playground/blob/master/config/aeternity/kyiv.yaml), [krakow](https://github.com/aeternity/hyperchains_playground/blob/master/config/aeternity/krakow.yaml), [munich](https://github.com/aeternity/hyperchains_playground/blob/master/config/aeternity/munich.yaml)) to make an impact on the election result):

```yaml
hyperchains:
  stake: 1000
```

### 6. Run the network:
```bash
docker-compose up -d
```

### 7. Mine PoW blocks to achive Hyperchains activation criteria 
```bash
docker exec bitcoin sh -c 'bitcoin-cli generatetoaddress 200 "bcrt1qmtl7a8yl4pps2tvynzw8gx6v6wpewnc8yajele"'
```

### 8. Check the network transition and distribution of Hyperchains PoS blocks
```bash
docker exec kyiv sh -c 'curl http://localhost:3002/v2/key-blocks/current'
docker exec krakow sh -c 'curl http://localhost:3002/v2/key-blocks/current'
docker exec munich sh -c 'curl http://localhost:3002/v2/key-blocks/current'
```

### 9. Stop the network

```bash
docker-compose down -v
```

<p align="center">
  <img src="docs/images/Playground.gif">
</p>


## Activation network guide

The first HC PoS block MUST fulfill the activation criteria(the state on which we base the block on MUST fulfill the criteria) and the Nth-key predecessor must also fulfill them.
For instance when the config is (100AE, 2, 10, 2) and the criteria were first meet at one microblock in the generation with height 19 then:

- HC can't be enabled at the keyblock at height 20 - although the criteria were meet at the predecesor, the keyblock predecesor at height 18 doesn't pass the criteria
- We never run the check at keyblocks with heights not divisible by 10(21-29 in the example) 
- HC gets enabled at the keyblock at height 30 - the criteria pass at the direct predecessor and the keyblock at height 28 making the keyblock with height 30 eligible to be the first HC block - validators commit to block 29, block 30 is the FIRST to deviate from PoW

More examples(assuming activation at height 30 and where we checked at height 30):

```erlang
%% * (100AE, 2, 10, 0)
%%                     Chain:            K - m - m - K - m - m - K
%%                     Height:           29  29  29  30  30  30  31
%%                     First HC block:               X
%%                     Criteria pass at:     X   X   X   X   X   X
%%                     Criteria checks:           X
%% * (100AE, 2, 10, 1)
%%                     Chain:            K - m - m - K - m - m - K
%%                     Height:           29  29  29  30  30  30  31
%%                     First HC block:               X
%%                     Criteria pass at: X   X   X   X   X   X   X
%%                     Criteria checks:  X        X
%% * (100AE, 2, 1, 1)
%%                     Chain:                 K - m - K - m - m - K - m - m - K
%%                     Height:                28  28  29  29  29  30  30  30  31
%%                     First HC block:                            X
%%                     Criteria pass at:          X   X   X   X   X   X   X   X
%%                     Criteria checks at 30:         X       X
%%                     Criteria checks at 29: X   X
%% * (100AE, 2, 10, 2)
%%                     Chain:                 K - m - K - m - m - K - m - m - K
%%                     Height:                28  28  29  29  29  30  30  30  31
%%                     First HC block:                            X
%%                     Criteria pass at:      X   X   X   X   X   X   X   X   X
%%                     Criteria checks at 30: X         
```


## Configuration notes

The nodes use the `mean15-generic` miner (fastest generic miner).
As the beneficiary key-pair is publicly available, this setup should *not* be connected to public networks.

All local network nodes are configured with the same beneficiary account (for more details on beneficiary see [configuration documentation](https://github.com/aeternity/aeternity/blob/master/docs/configuration.md#beneficiary-account)):
- public key: ak_twR4h7dEcUtc2iSEDv8kB7UFJJDGiEDQCXr85C3fYF8FdVdyo
- private key secret: `secret`
- key-pair binaries can be found in `/node/keys/beneficiary` directory of this repository

By default the localnet has set default mine rate of 1 block per 15 seconds.
It can be changed by setting `AETERNITY_MINE_RATE` environment variable.
The variable is in milliseconds, so to set 1 block per 10 seconds use:

```bash
AETERNITY_MINE_RATE=10000 docker-compose up
```
