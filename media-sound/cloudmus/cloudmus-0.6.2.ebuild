# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit cmake desktop python-single-r1 xdg

DESCRIPTION="Native Qt music player for Yandex Music, YouTube Music and local files"
HOMEPAGE="https://cloudmus.app/ https://github.com/cloudmus/cloudmus"
SRC_URI="https://github.com/cloudmus/cloudmus/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

# Manrope fonts and Ocean notification sounds are embedded in the executable.
LICENSE="CC-BY-SA-4.0 MIT OFL-1.1"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+local test wayland X +yandex-music +youtube-music"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

DEPEND="
	>=dev-qt/qtbase-6.9:6[dbus,gui,network,widgets,wayland?,X?]
	dev-qt/qtsvg:6
	>=media-libs/taglib-2.2:0=
	media-video/mpv:=[libmpv]
	wayland? (
		dev-libs/wayland
		dev-qt/qtbase:6=
	)
	X? ( x11-libs/libxcb:= )
"
RDEPEND="${DEPEND}
	!media-sound/cloudmus-bin
	${PYTHON_DEPS}
	dev-qt/qtbase:6[ssl]
	$(python_gen_cond_dep '
		>=dev-python/jsonschema-4.17[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-6[${PYTHON_USEDEP}]
		local? ( >=media-libs/mutagen-1.47[${PYTHON_USEDEP}] )
		yandex-music? ( >=dev-python/yandex-music-3.0[${PYTHON_USEDEP}] )
		youtube-music? (
			>=dev-python/ytmusicapi-1.8[${PYTHON_USEDEP}]
			<dev-python/ytmusicapi-2[${PYTHON_USEDEP}]
			>=net-misc/yt-dlp-2026.08.19[${PYTHON_USEDEP}]
		)
		yandex-music? ( >=dev-python/pysocks-1.7[${PYTHON_USEDEP}] )
		youtube-music? ( >=dev-python/pysocks-1.7[${PYTHON_USEDEP}] )
	')
"
BDEPEND="
	${PYTHON_DEPS}
	dev-qt/qttools:6[linguist]
	virtual/pkgconfig
	wayland? ( dev-util/wayland-scanner )
	$(python_gen_cond_dep '
		dev-python/jinja2[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		test? (
			>=dev-python/pytest-8[${PYTHON_USEDEP}]
			>=dev-python/pytest-asyncio-0.23[${PYTHON_USEDEP}]
		)
	')
"

CMAKE_USE_DIR="${S}/fronts/qt"
PATCHES=( "${FILESDIR}/${P}-system-integration.patch" )
DOCS=( LICENSE README.md CHANGELOG.md docs/development.md )

src_prepare() {
	# Formatting generated code is unnecessary and would detect clang-format
	# outside the declared build dependencies. Generate before cmake_src_prepare
	# so compilation also works with a read-only source directory.
	default
	sed -i '/_clang_format_inplace(\[models_h, rpc_methods_h, rpc_methods_cpp\])/d' \
		protocol/codegen/generate.py || die
	"${PYTHON}" protocol/codegen/generate.py --lang python cpp || die
	cmake_prepare
}

src_configure() {
	# Portage owns compiler/linker selection. Release telemetry credentials are
	# deliberately unset, and system TagLib prevents FetchContent downloads.
	local -x CLOUDMUS_GA4_MEASUREMENT_ID=
	local -x CLOUDMUS_SENTRY_DSN=
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
		-DCLOUDMUS_CCACHE=OFF
		-DCLOUDMUS_FAST_LINKER=OFF
		-DCLOUDMUS_PREGENERATED_PROTOCOL=ON
		-DCLOUDMUS_SENTRY=OFF
		-DCLOUDMUS_VERSION_OVERRIDE="${PV}"
		-DCLOUDMUS_WAYLAND=$(usex wayland)
		-DCLOUDMUS_X11=$(usex X)
		-DCMAKE_REQUIRE_FIND_PACKAGE_TagLib=ON
	)
	cmake_src_configure
}

src_test() {
	QT_QPA_PLATFORM=offscreen cmake_src_test

	local backend flag
	local tests=( backends/py-rpc-common/tests )
	local -x PYTHONPATH="${S}/backends/py-rpc-common"
	for backend in local-folder yandex-music youtube-music; do
		flag=${backend/local-folder/local}
		if use "${flag}"; then
			PYTHONPATH+=":${S}/backends/${backend}"
			tests+=( "backends/${backend}/tests" )
		fi
	done
	local EPYTEST_PLUGINS=( pytest-asyncio )
	epytest "${tests[@]}"
}

src_install() {
	# Upstream's CMake project only builds binaries; it has no install target.
	dobin "${BUILD_DIR}/bin/cloudmus-qt"
	python_domodule backends/py-rpc-common/rpc_common

	local backend flag
	for backend in local-folder yandex-music youtube-music; do
		flag=${backend/local-folder/local}
		use "${flag}" || continue
		python_domodule "backends/${backend}"/cloudmus_backend_*

		# Use the selected Python implementation and keep all paths relative to
		# the system manifest directory, leaving user configuration untouched.
		sed -e "s|\"python3\"|\"${PYTHON}\"|" \
			-e "s|\"icon.svg\"|\"${backend}.svg\"|" \
			"backends/${backend}/manifest.json" > "${T}/${backend}.json" || die
		insinto /usr/share/cloudmus/backends.d
		doins "${T}/${backend}.json"
		newins "backends/${backend}/icon.svg" "${backend}.svg"
	done

	domenu packaging/appimage/cloudmus-qt.desktop
	newicon -s scalable art/logo.svg cloudmus-qt.svg
	einstalldocs
	newdoc fronts/qt/resources/fonts/OFL.txt Manrope-OFL.txt
	newdoc fronts/qt/resources/sounds/LICENSE.md Ocean-sounds-LICENSE.md
}
