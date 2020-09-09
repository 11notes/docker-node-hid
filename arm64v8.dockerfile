# :: Builder
    FROM alpine AS builder
    ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz
    RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . && mv qemu-3.0.0+resin-aarch64/qemu-aarch64-static .

# :: Header
    FROM arm64v8/node:12.18.3-alpine3.11
    COPY --from=builder qemu-aarch64-static /usr/bin

# :: Run
    USER root

    RUN mkdir -p /node \
        && apk --update --no-cache add \
            shadow libusb libusb-dev eudev-dev            

    RUN apk --update --no-cache --virtual .build add \
            nodejs-dev linux-headers npm python3 gcc g++ make \
        && npm install node-hid node-hid-stream --build-from-source --prefix /node \
        && apk del .build

    COPY ./source/node /node

    # :: docker -u 1000:1000 (no root initiative)
        RUN usermod -u 1000 node \
            && groupmod -g 1000 node \
            && chown -R node:node /node

# :: Start
    USER node
    CMD ["node", "/node/main.js"]