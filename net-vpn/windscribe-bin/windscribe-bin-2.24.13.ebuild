EAPI=8

inherit desktop systemd unpacker

DESCRIPTION="Windscribe VPN desktop client (prebuilt binary)"
HOMEPAGE="https://windscribe.com/download https://github.com/Windscribe/Desktop-App"
SRC_URI="https://github.com/Windscribe/Desktop-App/releases/download/v${PV}/windscribe_${PV}_amd64.deb -> ${P}.deb"

S=${WORKDIR}

LICENSE="GPL-2 LGPL-2.1+ LGPL-3 MIT Apache-2.0 Boost-1.0 curl ZLIB BSD"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip"
REQUIRED_USE="elibc_glibc"

BDEPEND="acct-group/windscribe"
IDEPEND="acct-group/windscribe acct-user/windscribe"
RDEPEND="
	acct-group/windscribe
	acct-user/windscribe
	app-admin/sudo
	app-arch/brotli
	app-arch/zstd
	app-crypt/gnupg
	app-misc/ca-certificates
	app-shells/bash
	dev-libs/glib:2
	dev-libs/libnl
	dev-libs/libpcre2
	dev-libs/wayland
	>=sys-libs/glibc-2.35
	media-libs/fontconfig
	media-libs/freetype
	media-libs/harfbuzz
	media-libs/libglvnd
	net-firewall/nftables
	net-misc/iputils
	net-wireless/iw
	sys-apps/acl
	sys-apps/coreutils
	sys-apps/dbus
	sys-apps/iproute2
	sys-apps/net-tools
	sys-auth/polkit
	sys-libs/libcap-ng
	sys-process/procps
	sys-process/psmisc
	virtual/libudev
	virtual/zlib
	x11-libs/libX11
	x11-libs/libdrm
	x11-libs/libxcb
	x11-libs/xcb-util
	x11-libs/xcb-util-cursor
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
	x11-libs/libxkbcommon[X]
"

QA_PREBUILT="*"

src_unpack() {
	unpack_deb "${A}"
}

src_install() {
	dodir /opt
	cp -a opt/windscribe "${ED}"/opt/ || die
	fowners -R root:root /opt/windscribe
	fowners root:windscribe /opt/windscribe/Windscribe
	fperms 2755 /opt/windscribe/Windscribe

	dosym -r /opt/windscribe/windscribe-cli /usr/bin/windscribe-cli

	insinto /etc/windscribe/autostart
	doins etc/windscribe/autostart/windscribe.desktop

	insinto /etc/windscribe
	printf 'gentoo\n' > "${T}"/platform || die
	doins "${T}"/platform

	domenu usr/share/applications/windscribe.desktop

	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor

	systemd_dounit usr/lib/systemd/system/windscribe-helper.service
	newinitd "${FILESDIR}"/windscribe-helper.initd windscribe-helper

	dodoc opt/windscribe/open_source_licenses.txt "${FILESDIR}"/README.gentoo
}

pkg_postinst() {
	elog "Windscribe's privileged helper is required for VPN connections."
	elog "Enable it with systemd: systemctl enable --now windscribe-helper"
	elog "Or with OpenRC: rc-update add windscribe-helper default && rc-service windscribe-helper start"
	elog "Update this package through Portage; upstream self-updates are disabled."
}
