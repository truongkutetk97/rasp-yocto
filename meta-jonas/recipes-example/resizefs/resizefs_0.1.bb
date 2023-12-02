SUMMARY = "Resize File System Service"
DESCRIPTION = "Systemd service to resize the file system"
SECTION = "system/base"

LICENSE = "CLOSED"


SRC_URI = "file://resizefs.service \
           file://resizerootfs \
           "
inherit systemd

SYSTEMD_SERVICE:${PN} = "resizefs.service"

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/resizefs.service ${D}${systemd_system_unitdir}

    install -d ${D}/usr/sbin
    install -m 0777 ${WORKDIR}/resizerootfs ${D}/usr/sbin
}

FILES:${PN} += "${systemd_system_unitdir}/resizefs.service"
FILES:${PN} += "/usr/sbin/resizerootfs"
