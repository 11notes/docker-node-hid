# :: Header
    FROM arm32v7/node:10.18.0-alpine3.11
    ADD qemu-arm-static /usr/bin

# :: Run
    USER root

    RUN mkdir -p /app \
        && apk --update --no-cache add \
            shadow

    RUN apk --update --no-cache --virtual .build add \
            nodejs-dev npm python3 gcc g++ libusb libusb-dev eudev-dev \
        && npm install node-hid node-hid-stream --build-from-source --prefix /app \
        && apk del .build

    ADD ./source/main.js /app/main.js

# :: docker -u 1000:1000 (no root initiative)
    RUN usermod -u 1000 node \
        && groupmod -g 1000 node \
        && chown -R node:node /app

# :: Volumes
    VOLUME ["/app"]

# :: Start
    USER node
    CMD ["node", "/app/main.js"]