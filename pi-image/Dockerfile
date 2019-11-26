FROM ubuntu:16.04

RUN apt-get update && apt-get -y install gawk wget git-core \
    diffstat unzip texinfo gcc-multilib build-essential \
    chrpath socat cpio python python3 python3-pip \
    python3-pexpect xz-utils debianutils iputils-ping \
    libsdl1.2-dev xterm tar locales gawk wget git-core diffstat \
    zip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm

RUN rm /bin/sh && ln -s bash /bin/sh

RUN locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN useradd -ms /bin/bash worker
WORKDIR /home/worker/yocto

RUN chown -R worker. ~worker

USER worker

RUN git clone git://git.yoctoproject.org/poky -b thud

WORKDIR /home/worker/yocto/poky
RUN git clone git://git.yoctoproject.org/meta-raspberrypi -b thud

RUN mkdir -p /home/worker/yocto/poky/build/downloads
RUN mkdir -p /home/worker/yocto/poky/build/sstate-cache
RUN mkdir -p /home/worker/yocto/poky/build/tmp/deploy/images

ADD --chown=worker:worker conf /home/worker/yocto/poky/build/conf
ADD --chown=worker:worker build.sh /home/worker

WORKDIR /home/worker
