FROM ubuntu:latest
LABEL MAINTAINER="20241204 <UiLgNoD-kOoLtUo@outlook.com>"
ADD package /tmp/
RUN apt-get update \
    ; apt-get -qy install wget \
    ; wget https://download-cdn.resilio.com/stable/linux/x64/0/resilio-sync_x64.tar.gz \
    -O"/tmp/sync.tar.gz" \
    ; tar xf /tmp/sync.tar.gz -C /usr/bin rslsync \
    ; mv -fv /tmp/sync.conf /etc/ \
    ; mv -fv /tmp/ResilioSyncPro.btskey /etc/ \
    ; mv -fv /tmp/run_sync /usr/bin/ \
    ; chmod -v +x /usr/bin/run_sync \
    ; rm -f /tmp/sync.tar.gz \
    ; mkdir -pv /mnt/sync \
    ; apt-get -qy purge wget

CMD ["run_sync","--config", "/mnt/sync/conf/sync.conf"]
