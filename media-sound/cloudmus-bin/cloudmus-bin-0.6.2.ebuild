# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

MY_PN=${PN%-bin}
MY_P=${MY_PN}-${PV}
APPIMAGE="CloudMus-${PV}-x86_64.AppImage"

DESCRIPTION="Prebuilt CloudMus music player for Yandex Music, YouTube Music and local files"
HOMEPAGE="https://cloudmus.app/ https://github.com/cloudmus/cloudmus"
SRC_URI="
	https://github.com/cloudmus/cloudmus/releases/download/${PV}/${APPIMAGE}
	https://github.com/cloudmus/cloudmus/archive/refs/tags/${PV}.tar.gz -> ${MY_P}.tar.gz
"
S="${WORKDIR}/squashfs-root"

# Includes bundled Qt, mpv/FFmpeg, Python, service libraries and artwork.
# The source archive supplies CloudMus's own license and artwork notices.
LICENSE="
	Apache-2.0 BSD BSD-2 Boost-1.0 CC-BY-SA-4.0 CC0-1.0
	GPL-2+ GPL-3+ ISC LGPL-2.1+ LGPL-3 LGPL-3+ MIT MPL-2.0
	OFL-1.1 openssl PSF-2 Unlicense ZLIB
"
SLOT="0"
KEYWORDS="-* ~amd64"
REQUIRED_USE="elibc_glibc"
RESTRICT="bindist strip test"

# These libraries are intentionally supplied by the host, as confirmed from
# DT_NEEDED across the extracted AppImage (including its Qt/Python plugins).
RDEPEND="
	!media-sound/cloudmus
	|| ( llvm-runtimes/libgcc sys-devel/gcc:* )
	dev-libs/wayland
	media-libs/fontconfig
	media-libs/freetype
	media-libs/mesa[gbm(+)]
	>=sys-libs/glibc-2.31
	sys-libs/libxcrypt[compat]
	x11-libs/libdrm
	x11-libs/libX11
"
BDEPEND="dev-util/patchelf"

# Preserve the upstream binaries and their relative library search paths.
QA_PREBUILT="opt/${MY_PN}/*"

src_unpack() {
	unpack "${MY_P}.tar.gz"
	cp "${DISTDIR}/${APPIMAGE}" "${WORKDIR}/${APPIMAGE}" || die
	chmod +x "${WORKDIR}/${APPIMAGE}" || die
	"${WORKDIR}/${APPIMAGE}" --appimage-extract > /dev/null || die
}

src_prepare() {
	default

	# linuxdeploy placed an $ORIGIN path in DT_NEEDED. Express the same
	# dependency through RUNPATH so Portage can also resolve its SONAME.
	patchelf --replace-needed '$ORIGIN/../lib/libpython3.11.so.1.0' \
		libpython3.11.so.1.0 --set-rpath '$ORIGIN' \
		usr/python-runtime/lib/libpython3.so || die
}

src_install() {
	# Keep AppRun: it creates the backend manifests and selects the bundled
	# Python interpreter. Extracting at build time avoids a FUSE dependency.
	dodir "/opt/${MY_PN}"
	cp -a . "${ED}/opt/${MY_PN}/" || die
	# Autostart must invoke AppRun as well, because the Qt executable alone
	# does not register the bundled backends. Upstream uses APPIMAGE for this.
	cat > "${T}/cloudmus-qt" <<-EOF || die
		#!/bin/sh
		APPIMAGE="${EPREFIX}/usr/bin/cloudmus-qt" exec "${EPREFIX}/opt/${MY_PN}/AppRun" "\$@"
	EOF
	dobin "${T}/cloudmus-qt"
	domenu usr/share/applications/cloudmus-qt.desktop
	doicon -s 512 usr/share/icons/hicolor/512x512/apps/cloudmus-qt.png
	dodoc "${WORKDIR}/${MY_P}/"{LICENSE,README.md,CHANGELOG.md}
	newdoc "${WORKDIR}/${MY_P}/fronts/qt/resources/fonts/OFL.txt" Manrope-OFL.txt
	newdoc "${WORKDIR}/${MY_P}/fronts/qt/resources/sounds/LICENSE.md" Ocean-sounds-LICENSE.md
}
