FROM ubuntu:20.04
WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y git gperf make cmake clang-10 libc++-dev libc++abi-dev libssl-dev zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git && cd telegram-bot-api && \
    git checkout 81f2983 && mkdir build && cd build && \
    CXXFLAGS="-stdlib=libc++" CC=/usr/bin/clang-10 CXX=/usr/bin/clang++-10 \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. && \
    cmake --build . --target install -- -j $(nproc) && cd /root/bin && \
    ls -l /root/telegram-bot-api*
    
RUN apt-get -y update && apt-get -y upgrade && \
        apt-get install -y software-properties-common && \
        add-apt-repository -y ppa:qbittorrent-team/qbittorrent-stable && \
        apt-get install -y python3 python3-pip python3-lxml aria2 \
        qbittorrent-nox tzdata p7zip-full p7zip-rar xz-utils curl pv jq \
        ffmpeg locales wget unzip neofetch git make g++ gcc automake \
        autoconf libtool libcurl4-openssl-dev qt5-default \
        libsodium-dev libssl-dev libcrypto++-dev libc-ares-dev \
        libsqlite3-dev libfreeimage-dev swig libboost-all-dev \
        libpthread-stubs0-dev zlib1g-dev

# Installing MegaSDK Python binding
ENV MEGA_SDK_VERSION='3.9.2'
RUN git clone https://github.com/meganz/sdk.git mega-sdk/ && cd mega-sdk/ && \
    git checkout v$MEGA_SDK_VERSION && \
    ./autogen.sh && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples && \
    make -j $(nproc) && cd bindings/python/ && python3 setup.py bdist_wheel

RUN apt-get -y purge \
        git g++ gcc autoconf automake \
        m4 libtool qt4-qmake make libqt4-dev libcurl4-openssl-dev \
        libcrypto++-dev libsqlite3-dev libc-ares-dev \
        libsodium-dev libnautilus-extension-dev \
        libssl-dev libfreeimage-dev swig \
        && rm -rf -- /var/lib/apt/lists/* /var/cache/apt/archives/* /etc/apt/sources.list.d/* /var/tmp/* /tmp/* \
        && apt-get -qq -y update && apt-get -qq -y upgrade && apt-get -qq -y autoremove && apt-get -qq -y autoclean

