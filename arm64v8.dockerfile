# :: Builder
    FROM alpine AS builder
    ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz
    RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . && mv qemu-3.0.0+resin-arm/qemu-arm-static .

# :: Header
    FROM arm64v8/node:10.18.0-alpine3.11
    COPY --from=builder qemu-arm-static /usr/bin

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

# :: Volumes
    VOLUME ["/app"]

# :: Start
    USER node
    CMD ["node", "/app/main.js"]