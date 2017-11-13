FROM alpine:3.6
MAINTAINER Adam Dodman <adam.dodman@gmx.com>

ENV UID=904 GID=900

ARG NZBGET_TAG
ARG CXXFLAGS="-Ofast -pipe -fstack-protector-strong"
ARG LDFLAGS="-Wl,-O1,--sort-common -Wl,-s"

WORKDIR /tmp

RUN apk add --no-cache \
        unrar p7zip su-exec tini \
        libxml2 zlib openssl ca-certificates \
 && apk add --no-cache -t build_deps \
        git g++ make autoconf \
        libxml2-dev zlib-dev openssl-dev \
    \
 && if [ -z "$NZBGET_TAG" ]; then \
        apk add --no-cache jq && \
        export NZBGET_TAG="$(wget -qO- http://nzbget.net/info/nzbget-version-linux.json \
                        | sed 's/NZBGet.VersionInfo = //' \
                        | jq -r '.["stable-version"]' \
                        | sed 's/^/v/;s/testing-//g')" && \
        apk del --no-cache jq; \
    fi \
    \
 && git clone https://github.com/nzbget/nzbget.git . \
 && git checkout develop \
 # ensure we're attached to develop after checkout \
 && git reset $NZBGET_TAG --hard \
 && ./configure --disable-curses --disable-dependency-tracking \
 && make -j$(nproc 2>/dev/null || grep processor /proc/cpuinfo | wc -l || echo 1) \
    \
 && sed -i 's|\(^AppDir=\).*|\1/nzbget|; \
            s|\(^WebDir=\).*|\1/${AppDir}/webui|; \
            s|\(^MainDir=\).*|\1/downloads|; \
            s|\(^LogFile=\).*|\1/config/nzbget.log|; \
            s|\(^ConfigTemplate=\).*|\1/${AppDir}/nzbget.conf|; \
            s|\(^OutputMode=\).*|\1loggable|' nzbget.conf \
 && sed -i "s|\\(^UnrarCmd=\\).*|\\1$(which unrar)|; \
            s|\\(^SevenZipCmd=\\).*|\\1$(which 7z)|; \
            s|\\(^CertStore=\\).*|\\1/etc/ssl/certs/ca-certificates.crt|; \
            s|\\(^CertCheck=\\).*|\\1yes|" nzbget.conf \
 && mkdir /nzbget /downloads \
 && mv nzbget nzbget.conf webui COPYING /nzbget \
 && ln -sfv ../../nzbget/nzbget /usr/bin \
    \
 && find /tmp -mindepth 1 -delete \
 && apk del --no-cache build_deps

WORKDIR /nzbget

COPY entrypoint .
RUN chmod +x entrypoint

VOLUME ["/config", "/media"]
EXPOSE 6789
ENTRYPOINT ["/sbin/tini", "--", "/nzbget/entrypoint"]
CMD ["nzbget", "-c", "/config/nzbget.conf", "-s"]
