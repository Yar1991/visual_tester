FROM n8nio/n8n:latest

USER root

RUN chmod o+rx /home/node

RUN npm install -g --prefix /usr/local pngjs pixelmatch

ENV NODE_PATH=/usr/local/lib/node_modules

USER node

WORKDIR /home/node
