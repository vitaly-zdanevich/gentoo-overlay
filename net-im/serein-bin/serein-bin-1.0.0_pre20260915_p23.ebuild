# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

MY_PV=${PV/_pre/-nightly.}
MY_PV=${MY_PV/_p/.}
MY_DEB_VERSION=${MY_PV/-/.}

DESCRIPTION="Unofficial native Discord client written in Rust (prebuilt)"
HOMEPAGE="https://github.com/ViceVerse-cz/Serein"
SRC_URI="
	https://github.com/ViceVerse-cz/Serein/releases/download/v${MY_PV}/serein-v${MY_PV}-Linux-ubuntu-26.04-serein_${MY_DEB_VERSION}-1_amd64.deb -> ${P}.deb
	https://github.com/ViceVerse-cz/Serein/archive/refs/tags/v${MY_PV}.tar.gz -> serein-${PV}.gh.tar.gz
"
S="${WORKDIR}"

LICENSE="|| ( Apache-2.0 MIT )"
# Statically linked Rust dependencies and embedded fonts and graphics.
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD-2 BSD Boost-1.0
	CC-BY-4.0 CC0-1.0 CDLA-Permissive-2.0 ISC MIT MPL-2.0 OFL-1.1
	Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="-* ~amd64"
REQUIRED_USE="elibc_glibc"

# The Ubuntu 26.04 release references GLIBC_2.43. Graphics backends and
# GStreamer codecs are loaded at runtime and do not all appear in DT_NEEDED.
RDEPEND="
	!net-im/serein
	dev-libs/glib:2
	dev-libs/wayland
	>=gui-libs/gtk-4.10:4
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/gst-plugins-bad:1.0
	media-libs/gst-plugins-base:1.0
	media-libs/gst-plugins-good:1.0
	media-libs/gstreamer:1.0
	media-libs/libglvnd
	media-libs/vulkan-loader
	media-plugins/gst-plugins-libav:1.0
	net-libs/libsoup:3.0
	>=net-libs/webkit-gtk-2.40:6
	sys-apps/dbus
	sys-apps/xdg-desktop-portal
	sys-devel/gcc:*
	>=sys-libs/glibc-2.43
	virtual/secret-service
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-misc/xdg-utils
"

QA_PREBUILT="usr/bin/serein"

src_install() {
	dobin usr/bin/serein
	domenu usr/share/applications/cz.viceverse.serein.desktop
	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor

	# Preserve upstream's bundled component notices and corresponding sources.
	dodoc -r usr/share/doc/serein/.
	docinto source
	dodoc -r "Serein-${MY_PV}/vendor/hpke-rs"
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "Serein requires a running Secret Service provider in your desktop session."
	elog "Enable a portal backend for file dialogs, such as xdg-desktop-portal-gtk."
}
