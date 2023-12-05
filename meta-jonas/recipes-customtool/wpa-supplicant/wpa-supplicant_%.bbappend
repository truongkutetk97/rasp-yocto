FILESEXTRAPATHS:prepend := "${THISDIR}/wpa-supplicant:"

SRC_URI:append = " \
    file://25-wlan.network \
    file://wpa_supplicant-wlan0.conf \
"

do_install:append () {
    install -d ${D}${sysconfdir}/wpa_supplicant
    install -m 0644 ${WORKDIR}/wpa_supplicant-wlan0.conf ${D}${sysconfdir}/wpa_supplicant/wpa_supplicant-wlan0.conf
    install -D -m0644 ${WORKDIR}/25-wlan.network ${D}${systemd_unitdir}/network/25-wlan.network

}

SYSTEMD_SERVICE:${PN} = "wpa_supplicant@wlan0.service"
SYSTEMD_AUTO_ENABLE = "enable"

FILES:${PN} += "\
    ${systemd_unitdir}/network/25-wlan.network \
"