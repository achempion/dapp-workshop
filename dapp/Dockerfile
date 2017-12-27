FROM node:8

RUN npm install -g webpack-dev-server

ADD ./package.json /srv/app/
ADD ./package-lock.json /srv/app/

WORKDIR /srv/app

RUN npm install

ADD ./ /srv/app/