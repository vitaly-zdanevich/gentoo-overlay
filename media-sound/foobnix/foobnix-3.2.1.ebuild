# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit desktop python-single-r1 virtualx xdg

DESCRIPTION="GTK music player with local libraries, CUE sheets and Internet radio"
HOMEPAGE="https://github.com/foobnix/foobnix"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/foobnix/foobnix.git"
else
	SRC_URI="https://github.com/foobnix/foobnix/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="+nls test X"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

RDEPEND="
	!media-sound/foobnix-bin
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
BDEPEND="${BDEPEND}
	${PYTHON_DEPS}
	nls? ( sys-devel/gettext )
	test? ( ${RDEPEND} )
"

PATCHES=( "${FILESDIR}/${PN}-3.2.1-modern-apis.patch" )
DOCS=( README.md CHANGELOG )

src_prepare() {
	default

	# setup.py uses removed distutils APIs and performs installation side effects.
	# Install this pure-Python application directly, with the selected interpreter.
	sed -i "s/^FOOBNIX_VERSION=.*/FOOBNIX_VERSION='${PV}'/" \
		foobnix/version.py || die
	sed -i "s|\"/usr/|\"${EPREFIX}/usr/|g" \
		foobnix/gui/service/{path,radio}_service.py || die
	sed -i "s|gettext.install(APP_NAME)|gettext.install(APP_NAME, '${EPREFIX}/usr/share/locale')|" \
		foobnix/util/localization.py || die

	# unittest removed these aliases in Python 3.12.
	sed -i 's/assertEquals(/assertEqual(/g' \
		test/test_{sorting,text_utils,time_utils,version}.py || die
}

src_compile() {
	if use nls; then
		local po
		for po in po/*.po; do
			msgfmt "${po}" -o "${po%.po}.mo" || die
		done
	fi
}

src_test() {
	# Account-dependent integration suites contact obsolete online services.
	# Run the offline suites plus GUI, generated audio and mocked download tests.
	local -x PYTHONPATH="${S}${PYTHONPATH:+:${PYTHONPATH}}"
	virtx "${PYTHON}" "${FILESDIR}/${PN}-3.2.1-tests.py" --upstream
}

src_install() {
	python_domodule foobnix
	python_newscript foobnix.py foobnix
	insinto /usr/share/foobnix
	doins -r share/foobnix/{images,radio}
	domenu share/applications/foobnix.desktop
	doicon share/pixmaps/foobnix.png
	doman docs/foobnix.1
	use nls && domo po/*.mo
	einstalldocs
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "Foobnix's Last.fm and VK integrations use legacy upstream APIs."
	elog "Local playback is supported; those online integrations may not work."
}
