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
FILES_${PN} = "/etc"

do_compile() {
}

do_install() {
	install -d ${D}/etc/lorix
	install -m 0644 ${S}/test.conf ${D}/etc/lorix
}
