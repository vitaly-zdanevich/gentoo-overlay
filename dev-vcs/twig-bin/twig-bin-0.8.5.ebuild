# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

MY_PN=${PN%-bin}

DESCRIPTION="Desktop Git client with a visual commit graph"
HOMEPAGE="https://github.com/kitarasenka/twig https://kitarasenka.github.io/twig/"
SRC_URI="https://github.com/kitarasenka/twig/releases/download/twig-v${PV}/Twig-${PV}-linux-amd64.deb"
S="${WORKDIR}"

# Upstream declares UNLICENSED and provides no redistribution permission.
# Keep Electron's bundled third-party notices with the installed application.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist mirror strip test"

RDEPEND="
	!dev-vcs/twig
	|| (
		llvm-runtimes/libgcc
		sys-devel/gcc:*
	)
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-crypt/libsecret
	app-shells/bash
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	dev-vcs/git
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-misc/openssh
	net-print/cups
	sys-apps/coreutils
	sys-apps/dbus
	sys-apps/util-linux
	>=sys-libs/glibc-2.25
	virtual/libudev
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/libnotify
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="opt/${MY_PN}/*"

src_prepare() {
	default

	mv "opt/🌱 Twig" "opt/${MY_PN}" || die
	# Chromium uses unprivileged user namespaces; do not install a setuid helper.
	rm "opt/${MY_PN}/chrome-sandbox" || die
	# This unused Debian profile embeds upstream's original installation path.
	rm "opt/${MY_PN}/resources/apparmor-profile" || die
	sed -i "s|^Exec=.*|Exec=${EPREFIX}/usr/bin/${MY_PN} %U|" \
		"usr/share/applications/${MY_PN}.desktop" || die
}

src_install() {
	# Preserve the upstream fontconfig launcher and executable Electron helpers.
	dodir /opt
	cp -a "opt/${MY_PN}" "${ED}/opt/" || die
	dosym -r "/opt/${MY_PN}/${MY_PN}" "/usr/bin/${MY_PN}"
	domenu "usr/share/applications/${MY_PN}.desktop"
	doicon -s 1024 "usr/share/icons/hicolor/1024x1024/apps/${MY_PN}.png"
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Twig requires unprivileged user namespaces for its Chromium sandbox."
	elog "Enable CONFIG_USER_NS and allow user namespaces in your system policy."
}
