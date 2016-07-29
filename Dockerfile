FROM alpine:3.4

MAINTAINER "Adam Dodman <adam.dodman@gmx.com>"

ADD start.sh /

RUN chmod +x /start.sh \
 && adduser -S -u 236 -H -s /usr/sbin/nologin nzbget \
 && apk add --no-cache openssl \
 && wget -O nzbget.run `wget -qO- http://nzbget.net/info/nzbget-version-linux.json | sed -n "s/^.*stable-download.*: \"\(.*\)\".*/\1/p"` \
 && sh nzbget.run \
 && rm -rf /nzbget.run \
 && apk del --no-cache openssl

USER nzbget
CMD /start.sh
VOLUME /config
VOLUME /media
EXPOSE 6789
