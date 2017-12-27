## Dump
```
$ docker build . -t contract
$ docker save contract > ../images/contract.tar
```

## Load
```
$ docker load < ../images/contract.tar
```

## Run
```
$ docker run -v $(pwd):/srv/app/ contract --optimize --abi --bin /srv/app/fundraiser.sol
```