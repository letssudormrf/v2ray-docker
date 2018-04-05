FROM alpine:3.7

LABEL maintainer="letssudormrf"

ENV V2RAY_GIT_PATH="https://github.com/v2ray/v2ray-core" \
    CERT="" KEY="" UUID="" WSPATH="" VER=""

RUN apk add --no-cache --virtual .build-deps bash ca-certificates curl \
    && cd /tmp \
    && export VER=$(curl --silent https://api.github.com/repos/${V2RAY_GIT_PATH#**//*/}/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
    && curl -L -H "Cache-Control: no-cache" -o v2ray.zip ${V2RAY_GIT_PATH}/releases/download/$VER/v2ray-linux-64.zip \
    && unzip v2ray.zip \
    && mv v2ray-$VER-linux-64/v2ray /usr/local/bin/ \
    && mv v2ray-$VER-linux-64/v2ctl /usr/local/bin/ \
    && mv v2ray-$VER-linux-64/geoip.dat /usr/local/bin/ \
    && mv v2ray-$VER-linux-64/geosite.dat /usr/local/bin/ \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/*

COPY entrypoint.sh /usr/local/bin/

RUN chmod a+rwx /usr/local/bin/entrypoint.sh /usr/local/bin/v2ray /usr/local/bin/v2ctl

WORKDIR /tmp

VOLUME ["/tmp"]

EXPOSE 8443/tcp 8080/tcp

CMD ["entrypoint.sh"]
