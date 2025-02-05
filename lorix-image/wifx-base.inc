IMAGE_FEATURES += "ssh-server-openssh package-management"

TOOLCHAIN_HOST_TASK_append = " golang-cross-canadian-${TRANSLATED_TARGET_ARCH}"
EXTRA_OECONF_remove = "${DISABLE_STATIC}"

IMAGE_INSTALL = "\
    packagegroup-core-boot \
    packagegroup-core-full-cmdline \
    packagegroup-base-usbgadget \
    kernel-modules \
    lrzsz \
    setserial \
    opkg \
    iperf \
    start-stop-daemon-ext \
    \
    nbench-byte \
    lmbench \
    \
    i2c-tools \
    devmem2 \
    dosfstools \
    mtd-utils \
    dtc \
    dtc-misc \
    iproute2 \
    iptables \
    resolvconf \
    bridge-utils \
    evtest \
    gdbserver \
    usbutils \
    wget \
	rsync \
    ntp \
    \
    openssl \
    openssl-misc \
    ca-certificates \
    sudo \
    \
    perl \
    \
    reset-lgw \
    factory-reset \
    lora-gateway \
    update-gwid \
    loriot \
    packet-forwarder \
    ttn-packet-forwarder \
	kersing-packet-forwarder \
    clouds-manager \
    \
    vim \
    tmux \
    \
    postgresql \
    postgresql-contrib \
    postgresql-client \
    redis \
    \
    chirpstack-gateway-bridge \
    chirpstack-application-server \
    chirpstack-network-server \
    mosquitto \
    mosquitto-clients \
    \
    cameroon-ucla \
    \
    ${CORE_IMAGE_EXTRA_INSTALL} \
    "

PREFERRED_VERSION_postgresql = "9.5.0"
PREFERRED_VERSION_postgresql-contrib = "9.5.0"
PREFERRED_VERSION_postgresql-client = "9.5.0"

inherit core-image
inherit extrausers

# Add admin user in sudoers group
update_sudoers(){
    sed -i 's/# %sudo.*/%sudo ALL=(ALL) NOPASSWD: ALL/' ${IMAGE_ROOTFS}/etc/sudoers
}
ROOTFS_POSTPROCESS_COMMAND += "update_sudoers;"

# Create the admin main user
EXTRA_USERS_PARAMS = " \
    useradd -p '\$1\$7yCVHKVM\$O1Y5Ef1LTurwyWrBPVBum/' admin; \
    usermod -a -G sudo admin; \
    "
