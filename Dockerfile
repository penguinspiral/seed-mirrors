FROM debian:bullseye-slim

LABEL maintainer="mylesgrindon+github@gmail.com"

WORKDIR /build

RUN apt-get update && \
    apt-get install --no-install-recommends --yes \
                    debmirror \
                    dirmngr \
                    ed \
                    gnupg \
                    patch \
                    rsync

ENTRYPOINT ["/bin/bash", "-c", "conf/docker/entrypoint.sh"]
