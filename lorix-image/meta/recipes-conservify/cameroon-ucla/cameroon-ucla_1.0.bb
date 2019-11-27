#

DESCRIPTION = "Cameroon UCLA Configuration"
DEPENDS = ""
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
		   file://* \
"

S = "${WORKDIR}"

PACKAGES = "${PN}"
FILES_${PN} = "/etc /home/${USER}/.ssh/id_rsa /home/${USER}/.ssh/id_rsa.pub /home/${USER}/.ssh/authorized_keys"

USER = "admin"

do_compile() {
}

do_install() {
	install -d ${D}/etc/lorix

	install -d ${D}/etc/chirpstack-network-server
	install -m 0644 ${S}/chirpstack-network-server.toml ${D}/etc/chirpstack-network-server/chirpstack-network-server.toml

	install -d ${D}/home/${USER}/.ssh
	install -m 0700 ${S}/id_rsa ${D}/home/${USER}/.ssh/
    install -m 0755 ${S}/id_rsa.pub ${D}/home/${USER}/.ssh/
	install -m 0755 ${S}/authorized_keys ${D}/home/${USER}/.ssh/authorized_keys
}
