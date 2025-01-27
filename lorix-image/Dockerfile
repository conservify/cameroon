FROM ubuntu:16.04

RUN apt-get update && apt-get -y install gawk wget git-core vim \
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

RUN git clone git://git.yoctoproject.org/poky -b krogoth
RUN git clone git://git.openembedded.org/meta-openembedded -b krogoth
RUN git clone git://github.com/Wifx/meta-wifx.git -b krogoth
RUN git clone git://github.com/Wifx/meta-golang.git golang/meta-golang -b master
RUN git clone git://git.yoctoproject.org/meta-maker -b master && cd meta-maker && git checkout -b working c039fafa7a0276769d0928d16bdacd2012f2aff6
RUN git clone git://github.com/brocaar/chirpstack-gateway-os.git

RUN mkdir -p /home/worker/yocto/poky/build-wifx/downloads
RUN mkdir -p /home/worker/yocto/poky/build-wifx/sstate-cache
RUN mkdir -p /home/worker/yocto/poky/build-wifx/tmp/deploy/images

ADD --chown=worker:worker conf poky/build-wifx/conf
ADD --chown=worker:worker wifx-base.inc meta-wifx/recipes-wifx/images/wifx-base.inc
ADD --chown=worker:worker build.sh /home/worker
ADD --chown=worker:worker meta conservify

ADD --chown=worker:worker meta-wifx.patch /home/worker/yocto/meta-wifx
RUN cd /home/worker/yocto/meta-wifx && git apply meta-wifx.patch

ADD --chown=worker:worker meta-golang.patch /home/worker/yocto/golang/meta-golang
RUN cd /home/worker/yocto/golang/meta-golang && git apply meta-golang.patch

WORKDIR /home/worker