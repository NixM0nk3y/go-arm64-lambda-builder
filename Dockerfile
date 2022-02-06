#
#
#

FROM public.ecr.aws/amazonlinux/amazonlinux:2

LABEL maintainer="Nick Gregory <docker@openenterprise.co.uk>"

ARG SAMCLI_VERSION="1.37.0"

ARG GOLANG_VERSION="1.17.6"
ARG GOLANG_SHA256="82c1a033cce9bc1b47073fd6285233133040f0378439f3c4659fe77cc534622a"

RUN yum install -d1 -y \
    tar \
    gzip \
    unzip \
    python3 \
    jq \
    git \
    grep \
    curl \
    make \
    rsync \
    gcc-c++ \
    binutils \
    procps \
    python3-devel \
    libgmp3-dev \
    zlib1g-dev \
    liblzma-dev \
    libxslt-devel \
    libmpc-devel \
    && yum clean all

RUN cd /tmp \
    && echo "==> Downloading Golang..." \
    && curl -fSL  https://go.dev/dl/go${GOLANG_VERSION}.linux-arm64.tar.gz -o go${GOLANG_VERSION}.linux-arm64.tar.gz \
    && sha256sum go${GOLANG_VERSION}.linux-arm64.tar.gz \
    && echo "${GOLANG_SHA256}  go${GOLANG_VERSION}.linux-arm64.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf /tmp/go${GOLANG_VERSION}.linux-arm64.tar.gz \
    && rm /tmp/go${GOLANG_VERSION}.linux-arm64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPROXY=direct

# basic build deps
RUN yum install -d1 -y pcre2-devel \
    && yum clean all

ENV LANG=en_US.UTF-8

# Wheel is required by SAM CLI to build libraries like cryptography. It needs to be installed in the system
# Python for it to be picked up during `sam build`
RUN pip3 install wheel \
    && cd /tmp \
    && git clone https://github.com/aws/aws-sam-cli.git \
    && cd aws-sam-cli \
    && git checkout v${SAMCLI_VERSION} \
    && pip3 install --no-cache-dir install -r requirements/base.txt \
    && pip3 install --no-cache-dir install . \
    && rm -rf /tmp/aws-sam-cli


