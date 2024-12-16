FROM ubuntu:latest
LABEL MAINTAINER="20241204 <UiLgNoD-kOoLtUo@outlook.com>"
WORKDIR /mnt/sync/data
ADD package /tmp/
RUN cd /tmp/ ; bash install.sh ; rm -fv install.sh
CMD ["run_sync","--config", "/mnt/sync/conf/sync.conf"]
