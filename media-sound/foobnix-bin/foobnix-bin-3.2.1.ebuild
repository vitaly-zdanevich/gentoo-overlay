# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit desktop python-single-r1 unpacker xdg

DESCRIPTION="Prepackaged Foobnix GTK music player from deb-multimedia"
HOMEPAGE="https://github.com/foobnix/foobnix"
SRC_URI="https://www.deb-multimedia.org/pool/main/f/foobnix-dmo/foobnix_${PV}-dmo3_all.deb"
S="${WORKDIR}/usr/lib/python3/dist-packages"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+nls X"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="test"

# The Debian package contains portable Python, not a bundled interpreter.
RDEPEND="
	!media-sound/foobnix
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/chardet[${PYTHON_USEDEP}]
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/pygobject:3[cairo,${PYTHON_USEDEP}]
		dev-python/pylast[${PYTHON_USEDEP}]
		dev-python/simplejson[${PYTHON_USEDEP}]
		media-libs/mutagen[${PYTHON_USEDEP}]
	')
	gnome-base/librsvg:2
	media-libs/gstreamer:1.0[introspection]
	media-libs/gst-plugins-base:1.0[introspection,ogg,vorbis]
	media-libs/gst-plugins-good:1.0
	media-plugins/gst-plugins-meta:1.0
	media-plugins/gst-plugins-soup:1.0
	net-libs/libsoup:3.0[introspection]
	net-libs/webkit-gtk:4.1[introspection]
	x11-libs/gdk-pixbuf:2[gif,jpeg]
	x11-libs/gtk+:3[introspection]
	x11-libs/libnotify[introspection]
	X? ( dev-libs/keybinder:3[introspection] )
"
BDEPEND="${PYTHON_DEPS} $(unpacker_src_uri_depends)"

PATCHES=( "${FILESDIR}/foobnix-3.2.1-modern-apis.patch" )

src_prepare() {
	default

	# Keep the distribution package usable with Gentoo's current Python and GTK.
	sed -i "s/^FOOBNIX_VERSION=.*/FOOBNIX_VERSION='${PV}'/" \
		foobnix/version.py || die
	sed -i "s|\"/usr/|\"${EPREFIX}/usr/|g" \
		foobnix/gui/service/{path,radio}_service.py || die
	sed -i "s|gettext.install(APP_NAME)|gettext.install(APP_NAME, '${EPREFIX}/usr/share/locale')|" \
		foobnix/util/localization.py || die

	# Let Portage apply the user's documentation compression settings.
	gzip -d "${WORKDIR}/usr/share/man/man1/foobnix.1.gz" \
		"${WORKDIR}/usr/share/doc/foobnix/"*.gz || die
}

src_install() {
	python_domodule foobnix
	python_newscript "${WORKDIR}/usr/bin/foobnix" foobnix
	insinto /usr/share/foobnix
	doins -r "${WORKDIR}/usr/share/foobnix/"{images,radio}
	domenu "${WORKDIR}/usr/share/applications/foobnix.desktop"
	doicon "${WORKDIR}/usr/share/pixmaps/foobnix.png"
	doman "${WORKDIR}/usr/share/man/man1/foobnix.1"
	if use nls; then
		insinto /usr/share/locale
		doins -r "${WORKDIR}/usr/share/locale/"*
	fi
	dodoc "${WORKDIR}/usr/share/doc/foobnix/"{changelog*,copyright}
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "Foobnix's Last.fm and VK integrations use legacy upstream APIs."
	elog "Local playback is supported; those online integrations may not work."
}
