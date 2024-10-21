FROM mcr.microsoft.com/dotnet/sdk:6.0

ARG OPENRA_RELEASE_VERSION=1.04
ARG OPENRA_RELEASE_TYPE=release

# https://www.openra.net/download/
#ENV OPENRA_RELEASE_VERSION=${OPENRA_RELEASE_VERSION:-20200503}
ENV OPENRA_RELEASE_TYPE=${OPENRA_RELEASE_TYPE:-release}
ENV OPENRA_RELEASE=${OPENRA_RELEASE:-https://github.com/Inq8/CAMod/archive/refs/tags/${OPENRA_RELEASE_VERSION}.tar.gz}

RUN set -xe; \
        echo "=================================================================="; \
        echo "Building OpenRA:"; \
        echo "  version:\t${OPENRA_RELEASE_VERSION}"; \
        echo "  type:   \t${OPENRA_RELEASE_TYPE}"; \
        echo "  source: \t${OPENRA_RELEASE}"; \
        echo "=================================================================="; \
        \
        apt-get update; \
        apt-get -y upgrade; \
        apt-get install -y --no-install-recommends \
                    ca-certificates \
                    curl \
                    liblua5.1 \
                    libsdl2-2.0-0 \
                    libopenal1 \
                    make \
                    patch \
                    unzip \
                    xdg-utils \
                    zenity \
                    wget \
                    python3 \
                    nano \
                  ;

RUN set -xe; \
        echo "=================================================================="; \
        echo "Building OpenRA:"; \
        echo "  version:\t${OPENRA_RELEASE_VERSION}"; \
        echo "  type:   \t${OPENRA_RELEASE_TYPE}"; \
        echo "  source: \t${OPENRA_RELEASE}"; \
        echo "=================================================================="; \
        \
        useradd -d /home/openra -m -s /sbin/nologin openra; \
        mkdir /home/openra/source; \
        cd /home/openra/source; \
        curl -L $OPENRA_RELEASE | tar xz; \
        cd CAmod-$OPENRA_RELEASE_VERSION; \
        ./fetch-engine.sh;
        
RUN set -xe; \
        echo "=================================================================="; \
        echo "Compile OpenRA:"; \
        echo "=================================================================="; \
        \
        cd /home/openra/source/CAmod-$OPENRA_RELEASE_VERSION; \
        make version VERSION=$OPENRA_RELEASE_VERSION; \
        make all VERSION=$OPENRA_RELEASE_VERSION; \
        mkdir -p /home/openra/lib/openra; \
        mv /home/openra/source/CAmod-$OPENRA_RELEASE_VERSION/* /home/openra/lib/openra; \
        # /Hack
        mkdir /home/openra/.openra \
              /home/openra/.openra/Logs \
              /home/openra/.openra/maps \
            ;\
        chown -R openra:openra /home/openra/.openra; \
        rm -rf /var/lib/apt/lists/* \
               /var/cache/apt/archives/*

EXPOSE 1234

USER openra

WORKDIR /home/openra/lib/openra
VOLUME ["/home/openra/.openra"]
VOLUME ["/home/openra/lib/openra"]

CMD [ "/home/openra/lib/openra/launch-dedicated.sh" ]

# annotation labels according to
# https://github.com/opencontainers/image-spec/blob/v1.0.1/annotations.md#pre-defined-annotation-keys
LABEL org.opencontainers.image.title="OpenRA CAmod dedicated server"
LABEL org.opencontainers.image.description="Image to run a server instance for OpenRA CA"
LABEL org.opencontainers.image.url="https://github.com/tolsendev/openra-camod-docker"
LABEL org.opencontainers.image.documentation="https://github.com/tolsendev/openra-camod-docker#readme"
LABEL org.opencontainers.image.version=${OPENRA_RELEASE_VERSION}
LABEL org.opencontainers.image.licenses="MIT"
