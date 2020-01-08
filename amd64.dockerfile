# :: Header
    FROM node:10.18.0-alpine3.11

# :: Run
    USER root

    RUN mkdir -p /app \
        && apk --update --no-cache add \
            shadow libusb libusb-dev eudev-dev            

    RUN apk --update --no-cache --virtual .build add \
            nodejs-dev linux-headers npm python3 gcc g++ make \
        && npm install node-hid node-hid-stream --build-from-source --prefix /app \
        && apk del .build

    ADD ./source/main.js /app/main.js

# :: docker -u 1000:1000 (no root initiative)
    RUN usermod -u 1000 node \
        && groupmod -g 1000 node \
        && chown -R node:node /app

# :: Start
    USER node
    CMD ["node", "/app/main.js"]