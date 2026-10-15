# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 optfeature shell-completion wrapper

MY_PV=${PV/_p/.}

DESCRIPTION="youtube-dl fork with additional features and fixes"
HOMEPAGE="https://github.com/yt-dlp/yt-dlp/"
# CloudMus 0.6.2 pins this nightly for YouTube stream extraction.
SRC_URI="https://github.com/yt-dlp/yt-dlp-nightly-builds/releases/download/${MY_PV}/${PN}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+deno"

RDEPEND="
	dev-python/pycryptodome[${PYTHON_USEDEP}]
	=dev-python/yt-dlp-ejs-0.8*[${PYTHON_USEDEP}]
	deno? ( >=dev-lang/deno-bin-2.6.6 )
"
BDEPEND="test? ( media-video/ffmpeg[webp] )"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	# Match Gentoo's offline test exclusions for sandbox-sensitive networking
	# and the optional, version-sensitive websockets transport.
	local EPYTEST_DESELECT=(
		test/test_networking.py::TestHTTPRequestHandler::test_connect_timeout
		test/test_networking.py::TestYoutubeDLNetworking::test_proxy\[None-expected2\]
		test/test_websockets.py
	)
	epytest -m 'not download'
}

python_install_all() {
	dodoc README.md Changelog.md supportedsites.md
	doman yt-dlp.1
	rm -r -- "${ED}"/usr/share/doc/yt_dlp || die
	dobashcomp completions/bash/yt-dlp
	dofishcomp completions/fish/yt-dlp.fish
	dozshcomp completions/zsh/_yt-dlp
	make_wrapper youtube-dl "yt-dlp --compat-options youtube-dl"
}

pkg_postinst() {
	optfeature "merging tracks and processing streamed media" media-video/ffmpeg
	optfeature "embedding metadata thumbnails" media-libs/mutagen
	optfeature "decrypting Chromium browser cookies" dev-python/secretstorage
	if use !deno; then
		elog "YouTube needs a JavaScript runtime; enable USE=deno for the supported default."
	fi
}
