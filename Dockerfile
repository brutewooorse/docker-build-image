FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update && apt-get -y upgrade && \
    apt-get -qq install -y build-essential && \
    python3 python3-pip
        

RUN apt-get -qq update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/* && \
    apt-add-repository ppa:qbittorrent-team/qbittorrent-stable && \
    apt-get -qq update && \
    apt-get -qq install -y qbittorrent p7zip-full p7zip-rar aria2 curl pv jq ffmpeg locales python3-lxml && \
    apt-get purge -y software-properties-common
 


COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Installing MegaSDK Python binding
ENV MEGA_SDK_VERSION '3.9.2'
RUN git clone https://github.com/meganz/sdk.git --depth=1 -b v$MEGA_SDK_VERSION ~/sdk \
    && cd ~/sdk \
    && rm -rf .git \
    && ./autogen.sh \
    && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ \
    && python3 setup.py bdist_wheel \
    && cd dist/ \
    && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl \
    && cd ~


RUN apt-get -y purge \
        git g++ gcc autoconf automake \
        m4 libtool qt4-qmake make libqt4-dev libcurl4-openssl-dev \
        libcrypto++-dev libsqlite3-dev libc-ares-dev \
        libsodium-dev libnautilus-extension-dev \
        libssl-dev libfreeimage-dev swig \
        && rm -rf -- /var/lib/apt/lists/* /var/cache/apt/archives/* /etc/apt/sources.list.d/* /var/tmp/* /tmp/* \
        && apt-get -qq -y update && apt-get -qq -y upgrade && apt-get -qq -y autoremove && apt-get -qq -y autoclean

