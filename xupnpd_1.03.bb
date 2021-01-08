SUMMARY = "xupnpd - eXtensible UPnP agent"
DESCRIPTION = "This program is a light DLNA Media Server which provides ContentDirectory:1 service for sharing IPTV unicast streams over local area network (with udpxy for multicast to HTTP unicast conversion).\
 The program shares UTF8-encoded M3U playlists with links over local area network as content of the directory.\
 You can watch HDTV broadcasts (multicast or unicast) and listen Internet Radio in IP network without transcoding and PC."
AUTHOR = "Anton Burdinuk <clark15@gmail.com>"

SECTION = "network"
HOMEPAGE = "http://xupnpd.org/"
DEPENDS = "openssl"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=193ff0a3bc8b0d2cb0d1d881586d3388"

PR = "r11"
PV = "1.03"

SRC_URI = " \
	git://github.com/rdamas/xupnpd.git;branch=release;tag=v${PV}-${PR} \
	"

S = "${WORKDIR}/git"
B = "${S}/src"

inherit base

do_configure() {
    :
}

do_compile() {
    oe_runmake -C ${B} CC='${CC}' CXX='${CXX}'
}

do_install() {
    oe_runmake "DESTDIR=${D}" PREFIX=/usr install
    install -d ${D}/etc/init.d
    install -m 0755 ${S}/meta/etc/init.d/xupnpd.sh ${D}/etc/init.d/xupnpd.sh
}

pkg_postinst_${PN}() {
#!/bin/sh
if type update-rc.d >/dev/null 2>/dev/null; then
	if [ -n "$D" ]; then
		OPT="-r $D"
	else
		OPT="-s"
	fi
	update-rc.d $OPT xupnpd.sh start 95 3 . stop 10 0 .
fi
}

pkg_postrm_${PN}() {
#!/bin/sh
if type update-rc.d >/dev/null 2>/dev/null; then
	if [ -n "$D" ]; then
		OPT="-f -r $D"
	else
		OPT="-f"
	fi
	update-rc.d $OPT xupnpd.sh remove
fi
exit 0
}

pkg_preinst_${PN}() {
#!/bin/sh
killall -q xupnpd
if type update-rc.d >/dev/null 2>/dev/null; then
	if [ -n "$D" ]; then
		OPT="-f -r $D"
	else
		OPT="-f"
	fi
	update-rc.d $OPT xupnpd.sh remove
fi
exit 0
}

pkg_prerm_${PN}() {
#!/bin/sh
if [ -z "$D" ]; then
	killall -q xupnpd
fi
exit 0
}
