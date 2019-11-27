require postgresql.inc

LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=3a9c1120056a102a8c8c4013cd828dce"

PR = "${INC_PR}.0"

SRC_URI += "\
	file://not-check-libperl.patch \
"

SRC_URI[md5sum] = "e58fffe9359e311ead94490a06b7147c"
SRC_URI[sha256sum] = "f1c0d3a1a8aa8c92738cab0153fbfffcc4d4158b3fee84f7aa6bfea8283978bc"
