## Dump
```
$ docker build . -t dapp
$ docker save dapp > ../images/dapp.tar
```

## Load
```
$ docker load < ../images/dapp.tar
```

## Run
```
$ docker run -p 8080:8080 -v $(pwd):/srv/app/ dapp npm i
$ docker run -p 8080:8080 -v $(pwd):/srv/app/ dapp npm run start
```
