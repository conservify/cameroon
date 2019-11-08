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
WORKDIR /home/worker
RUN mkdir -p /home/worker/build/temp
ADD yocto /home/worker
ADD build.sh /home/worker
RUN chown -R worker. /home/worker

USER worker
CMD [ "./build.sh" ]