FROM debian:stretch
LABEL maintainer="Egon Kidmose <kidmose@gmail.com>"

ARG USER=torbrowser

# Install torbrowser-launcher
RUN set -x && \
    printf "deb http://deb.debian.org/debian stretch-backports main contrib" > /etc/apt/sources.list.d/stretch-backports.list && \
    apt-get update && \
    apt-get -y install \
    gosu `# To "drop" root` \
    libxt6 `# to avoid: libXt.so.6: cannot open shared object file: No such file or directory` \
    torbrowser-launcher \
    && rm -rf /var/lib/apt/lists/*

# Customisations
RUN set -x && \
    useradd $USER && \
    mkdir -p /home/$USER/Downloads && \
    chown -R $USER:$USER /home/$USER/

# TODO: Persisten config

WORKDIR /home/$USER

ADD entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
