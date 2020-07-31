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
prysm.sh beacon-chain --verbosity info \
--disable-discv5 \
--interop-eth1data-votes \
--interop-genesis-time $(date +%s) \
--interop-num-validators 64 \
--rpc-host $(ipconfig getifaddr en0)
```

### SSH into your Lattice1 and run the validator

```
cd /mnt/mmcblk0p1 && ./validator --keymanager=interop --keymanageropts='{"keys":64}' --datadir $PWD --beacon-rpc-provider XXX.XXX.XXX.XXX:4000 --force-clear-db --disable-accounts-v2
```
