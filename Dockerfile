FROM alpine:3.6
MAINTAINER Adam Dodman <adam.dodman@gmx.com>

ENV UID=904 GID=900

ADD start.sh /start.sh

ARG NZBGET_URL

RUN chmod +x /start.sh \
 && apk add --no-cache openssl unrar p7zip python su-exec tini \
 && if [ -z "$NZBGET_URL" ]; then \
        apk add --no-cache jq && \
        export NZBGET_URL="$(wget -qO- http://nzbget.net/info/nzbget-version-linux.json \ 
                        | sed 's/NZBGet.VersionInfo = //' \
                        | jq -r '.["stable-version"]')" && \
        apk del --no-cache jq; \
    fi \
 && wget -O nzbget.run "$NZBGET_URL" \
 && sh nzbget.run \
 && ln -sfv /nzbget/nzbget /usr/bin/nzbget \
 && rm -rf /nzbget.run \
 && apk del --no-cache openssl

VOLUME ["/config", "/media"]
EXPOSE 6789
ENTRYPOINT ["/sbin/tini", "--", "/start.sh"]
CMD ["nzbget", "-c", "/config/nzbget.conf", "-s"]
