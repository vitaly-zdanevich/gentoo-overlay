# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit optfeature

MY_PN=${PN%-bin}
MY_P=${MY_PN}-${PV}

DESCRIPTION="Prebuilt low-resource YouTube audio TUI with local subscriptions and progress"
HOMEPAGE="https://github.com/vitaly-zdanevich/youta"
SRC_URI="
	amd64? (
		images? (
			https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64.tar.gz
		)
		!images? (
			https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64-text.tar.gz
		)
	)
	arm64? (
		images? (
			https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64.tar.gz
		)
		!images? (
			https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64-text.tar.gz
		)
	)
"

S="${WORKDIR}/${MY_P}-linux-${ARCH}"

# Youta and its selected Rust dependencies are statically included. The
# release binaries use the human-readable state backend and omit SQLite.
# These licenses match the corresponding source package.
LICENSE="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD Boost-1.0 CC0-1.0
	CDLA-Permissive-2.0 ISC LGPL-2.1+ MIT MPL-2.0 Unicode-3.0
	Unicode-DFS-2016 Unlicense ZLIB public-domain
"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"

# Audio flags select corresponding output support in the system mpv package.
# The images flag selects the upstream binary with terminal artwork support.
IUSE="+alsa +images jack pipewire pulseaudio"
REQUIRED_USE="elibc_glibc"

# Preserve upstream's Rust line tables and debug information: Youta includes
# them in diagnostic backtraces.
RESTRICT="strip"

RDEPEND="
	!media-sound/youta
	|| (
		llvm-runtimes/libgcc
		sys-devel/gcc:*
	)
	>=sys-libs/glibc-2.39
	>=media-video/mpv-0.38[alsa?,cli,jack?,pipewire?,pulseaudio?]
	media-video/ffmpeg[openmpt]
	net-misc/yt-dlp[deno]
"

QA_PREBUILT="usr/bin/youta"

src_unpack() {
	default

	if ! use images; then
		mv "${WORKDIR}/${MY_P}-linux-${ARCH}-text" "${S}" ||
			die "failed to normalize the text-only release directory"
	fi
}

src_compile() {
	:
}

src_install() {
	dobin bin/youta

	dodoc README.md config.example.toml
	dodoc docs/ARCHITECTURE.md docs/AUDIOPHILE.md docs/FEASIBILITY.md
}

pkg_postinst() {
	elog "This package installs Youta's fixed upstream release feature set."
	elog "Install media-sound/youta for build-time feature selection."

	if use alsa; then
		elog "List ALSA devices with: mpv --audio-device=help"
	fi

	optfeature "opening links through xdg-open" x11-misc/xdg-utils
	optfeature "Linux virtual-console physical mouse input" sys-libs/gpm
	optfeature "automatic config repository commits and pushes" dev-vcs/git
}
