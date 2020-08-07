# Eth2 Validator on Lattice 1

This repo contains the dockerfile and associated resources needed to configure, cross compile and run an eth2 validator on the lattice1.

### Build the container

```
docker build -t jrhea/lattice1 .
```
> Note: This step will take a long time to complete

### Run contain and drop into a shell

```
docker run -it jrhea/lattice1 /bin/bash
```

### Copy validator to the Lattice1:

```
scp /root/work/prysm/validator/validator root@lattice-c23c:/mnt/mmcblk0p1/
```

### Install Prysm

Refer to the Prysm documentation [here](https://docs.prylabs.network/docs/install/install-with-script).

### Start Prysm from host machine

```
CURRENT_TIME=$(date +%s)
GENESIS_TIME=$((CURRENT_TIME + 90))
IP_ADDRESS=XXX.XXX.XXX.XXX

prysm.sh beacon-chain --verbosity info \
--force-clear-db \
--disable-discv5 \
--interop-eth1data-votes \
--interop-genesis-time $GENESIS_TIME \
--interop-num-validators 64 \
--rpc-host $IP_ADDRESS \
--p2p-tcp-port 9000 \
--p2p-udp-port 9000 \
--deposit-contract 0x8A04d14125D0FDCDc742F4A05C051De07232EDa4

```

### SSH into your Lattice1 and run the validator

```
cd /mnt/mmcblk0p1 && ./validator --keymanager=interop --keymanageropts='{"keys":64}' --datadir $PWD --beacon-rpc-provider XXX.XXX.XXX.XXX:4000 --force-clear-db --disable-accounts-v2
```
