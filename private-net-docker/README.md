## Dump
```
$ docker build . -t private-net-docker
$ docker save private-net-docker > ../images/private-net-docker.tar
```

## Load
```
$ docker load < ../images/private-net-docker.tar
```

## Run
```
$ docker run -v $(pwd):/root/ private-net-docker init /root/genesis.json
$ docker run -v $(pwd):/root/ -it private-net-docker account new
```

Replace `YOUR_ADDRESS` with created address.

Start mining
```
$ docker run -p 8545:8545 -p 8546:8546 -v $(pwd):/root/ private-net-docker --etherbase=0x<YOUR_ADDRESS> --networkid 42 --mine --minerthreads=1 --rpc --rpcaddr 0.0.0.0 --rpcapi "db,eth,net,web3,personal"

$ docker run -p 8545:8545 -v $(pwd):/root/ --cpus=0.3 private-net-docker --etherbase=0x<YOUR_ADDRESS> --networkid 42 --mine --minerthreads=1 --rpc --rpcaddr 0.0.0.0 --rpcapi "db,eth,net,web3,personal" --cpus=0.3
```

```
/Applications/Mist.app/Contents/MacOS/Mist --rpc http://localhost:8545 --swarmurl "null"
```