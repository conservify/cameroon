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
FILES_${PN} = "/etc /usr/bin /root/.ssh /home/admin/.ssh/id_rsa /home/admin/.ssh/id_rsa.pub /home/admin/.ssh/authorized_keys"

# Quick hack on my part.
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

do_compile() {
}

do_install() {
	install -d ${D}/etc/lorix

	install -d ${D}/etc/chirpstack-network-server
	install -m 0644 ${S}/chirpstack-network-server.toml ${D}/etc/chirpstack-network-server/chirpstack-network-server.toml

	install -d ${D}/root/.ssh
	install -m 0600 ${S}/id_rsa ${D}/root/.ssh/
	install -m 0644 ${S}/id_rsa.pub ${D}/root/.ssh/
	install -m 0644 ${S}/authorized_keys ${D}/root/.ssh/authorized_keys

	install --owner=1000 -d ${D}/home/admin/.ssh
	install --owner=1000 -m 0600 ${S}/id_rsa ${D}/home/admin/.ssh/
	install --owner=1000 -m 0644 ${S}/id_rsa.pub ${D}/home/admin/.ssh/
	install --owner=1000 -m 0644 ${S}/authorized_keys ${D}/home/admin/.ssh/authorized_keys

	install -d ${D}/usr/bin
	for f in ${S}/bin/*; do
		install -m 0755 $f ${D}/usr/bin
	done

	install -d ${D}/etc/cron.daily
	install -m 0755 ${S}/bin/backup-to-card.sh ${D}/etc/cron.daily

	install -d ${D}/etc/init.d
	install -m 0755 ${S}/conservify-startup ${D}/etc/init.d/conservify-startup

	install -d ${D}/etc/rc3.d
	cd ${D}/etc/rc3.d
	ln -s ../init.d/conservify-startup S10conservify-startup

	install -d ${D}/etc/rc5.d
	cd ${D}/etc/rc5.d
	ln -s ../init.d/conservify-startup S10conservify-startup

	install -d ${D}/etc/logrotate.d
	install -m 0644 ${S}/logrotations ${D}/etc/logrotate.d/logrotations

	install -d ${D}/etc/conservify-schema

	install -d ${D}/etc/conservify-schema/postgres
	for f in ${S}/schema/postgres/*.sql; do
		install -m 0644 $f ${D}/etc/conservify-schema/postgres/
	done

	install -d ${D}/etc/conservify-schema/chirpstack_as
	for f in ${S}/schema/chirpstack_as/*.sql; do
		install -m 0644 $f ${D}/etc/conservify-schema/chirpstack_as/
	done

	install -d ${D}/etc/conservify-schema/chirpstack_as_data
	for f in ${S}/schema/chirpstack_as_data/*.sql; do
		install -m 0644 $f ${D}/etc/conservify-schema/chirpstack_as_data/
	done

	install -d ${D}/etc/conservify-schema/chirpstack_ns
	for f in ${S}/schema/chirpstack_ns/*.sql; do
		install -m 0644 $f ${D}/etc/conservify-schema/chirpstack_ns/
	done
}
