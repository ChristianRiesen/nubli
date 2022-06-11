FROM node:18-alpine

RUN apk --update add python3 alpine-sdk

RUN mkdir /app

RUN mkdir /app/dist

RUN mkdir /app/dist/lib

RUN mkdir /app/dist/lib/config

COPY ./ /app

WORKDIR /app

RUN npm install

CMD ["node", "dist/lib/server.js"]