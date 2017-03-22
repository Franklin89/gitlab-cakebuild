FROM ubuntu:16.04

# Install Dependencies
RUN echo "deb [arch=amd64] http://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893 \
    && apt-get update \
	&& apt-get install -y \
    curl \
    gettext \
    libunwind8 \
    libcurl4-openssl-dev \
    libicu-dev \
    libssl-dev \
    git \
    ca-certificates \
    openssl \
    # .NET Core SDK
    dotnet-dev-1.0.1 \
 && rm -rf /var/lib/apt/lists/*

# Install mono
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF

RUN echo "deb http://download.mono-project.com/repo/debian wheezy/snapshots/4.2.3.4 main" > /etc/apt/sources.list.d/mono-xamarin.list \
	&& apt-get update \
	&& apt-get install -y mono-devel ca-certificates-mono fsharp mono-vbnc nuget \
	&& rm -rf /var/lib/apt/lists/*

# Install stable Node.js and related build tools
RUN curl -sL https://git.io/n-install | bash -s -- -ny - \
    && ~/n/bin/n stable \
    && npm install -g bower grunt gulp n \
    && rm -rf ~/n

# Install docker
ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 17.03.0-ce
ENV DOCKER_SHA256 4a9766d99c6818b2d54dc302db3c9f7b352ad0a80a2dc179ec164a3ba29c2d3e

RUN set -x \
	&& curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
	&& echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
	&& tar -xzvf docker.tgz \
	&& mv docker/* /usr/local/bin/ \
	&& rmdir docker \
	&& rm docker.tgz

ENV DOCKER_COMPOSE_VERSION 1.8.0

RUN set -x \
 && curl -fSL "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m`" -o /usr/local/bin/docker-compose \
 && chmod +x /usr/local/bin/docker-compose

# Prime dotnet
RUN mkdir dotnettest \
    && cd dotnettest \
    && dotnet new mvc --auth None --framework netcoreapp1.1 \
    && dotnet restore \
    && dotnet build \
    && cd .. \
    && rm -r dotnettest

# Display info installed components
RUN docker -v
RUN docker-compose -v
RUN gulp --version
RUN npm --version
RUN mono --version
RUN dotnet --info