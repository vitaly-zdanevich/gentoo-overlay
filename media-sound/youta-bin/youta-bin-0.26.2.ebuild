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
			qr? (
				https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64.tar.gz
			)
			!qr? (
				https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64-no-qr.tar.gz
			)
		)
		!images? (
			qr? (
				https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64-text.tar.gz
			)
			!qr? (
				https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64-text-no-qr.tar.gz
			)
		)
	)
	arm64? (
		images? (
			qr? (
				https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64.tar.gz
			)
			!qr? (
				https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64-no-qr.tar.gz
			)
		)
		!images? (
			qr? (
				https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64-text.tar.gz
			)
			!qr? (
				https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64-text-no-qr.tar.gz
			)
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
# The images and qr flags independently select the matching upstream binary.
IUSE="+alsa +images jack pipewire pulseaudio +qr"
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

	local archive_suffix=
	if ! use images; then
		archive_suffix=-text
	fi
	if ! use qr; then
		archive_suffix+=-no-qr
	fi
	if [[ -n ${archive_suffix} ]]; then
		mv "${WORKDIR}/${MY_P}-linux-${ARCH}${archive_suffix}" "${S}" ||
			die "failed to normalize the selected release directory"
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
	optfeature "local audio fingerprinting through AcoustID" "media-libs/chromaprint[tools]"
	optfeature "automatic config repository commits and pushes" dev-vcs/git
}
