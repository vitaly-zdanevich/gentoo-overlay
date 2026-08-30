# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit optfeature

MY_PN=${PN%-bin}
MY_P=${MY_PN}-${PV}

DESCRIPTION="Prebuilt Youta terminal player with an optional desktop GUI"
HOMEPAGE="https://github.com/vitaly-zdanevich/youta"
SRC_URI="
	amd64? (
		images? (
			qr? (
				gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64 )
				!gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64-no-gpm )
			)
			!qr? (
				gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64-no-qr )
				!gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64-no-qr-no-gpm )
			)
		)
		!images? (
			qr? (
				gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64-text )
				!gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64-text-no-gpm )
			)
			!qr? (
				gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64-text-no-qr )
				!gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-amd64-text-no-qr-no-gpm )
			)
		)
		gui? (
			https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/youta-gui-${PV}-linux-amd64
		)
	)
	arm64? (
		images? (
			qr? (
				gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64 )
				!gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64-no-gpm )
			)
			!qr? (
				gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64-no-qr )
				!gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64-no-qr-no-gpm )
			)
		)
		!images? (
			qr? (
				gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64-text )
				!gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64-text-no-gpm )
			)
			!qr? (
				gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64-text-no-qr )
				!gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-arm64-text-no-qr-no-gpm )
			)
		)
		gui? (
			https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/youta-gui-${PV}-linux-arm64
		)
	)
	x86? (
		images? (
			qr? (
				gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-i686 )
				!gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-i686-no-gpm )
			)
			!qr? (
				gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-i686-no-qr )
				!gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-i686-no-qr-no-gpm )
			)
		)
		!images? (
			qr? (
				gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-i686-text )
				!gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-i686-text-no-gpm )
			)
			!qr? (
				gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-i686-text-no-qr )
				!gpm? ( https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/${MY_P}-linux-i686-text-no-qr-no-gpm )
			)
		)
		gui? (
			https://github.com/vitaly-zdanevich/youta/releases/download/v${PV}/youta-gui-${PV}-linux-i686
		)
	)
"

S="${WORKDIR}"

# Youta and its selected Rust dependencies are statically included. The
# release binaries use the human-readable state backend and omit SQLite.
# These licenses match the corresponding source package.
LICENSE="
	0BSD Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD Boost-1.0 CC0-1.0
	CDLA-Permissive-2.0 ISC LGPL-2.1+ MIT MPL-2.0 Unicode-3.0
	Unicode-DFS-2016 Unlicense ZLIB public-domain
"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64 ~x86"

# Audio flags select corresponding output support in the system mpv package.
# Images and QR select a TUI variant; GUI adds the standalone desktop program.
IUSE="+alsa cpu_flags_x86_sse2 gpm gui +images jack pipewire pulseaudio +qr"
REQUIRED_USE="
	elibc_glibc
	x86? ( cpu_flags_x86_sse2 )
"

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
	app-arch/unrar
	>=media-video/mpv-0.38[alsa?,cli,jack?,pipewire?,pulseaudio?]
	media-video/ffmpeg[openmpt]
	gpm? ( sys-libs/gpm )
	gui? (
		dev-libs/libayatana-appindicator
		>=net-libs/webkit-gtk-2.40:4.1
		sys-apps/dbus
		x11-libs/gtk+:3
	)
	x86? (
		>=dev-libs/quickjs-ng-0.12.0
		net-misc/yt-dlp[-deno]
	)
	!x86? ( net-misc/yt-dlp[deno] )
"

QA_PREBUILT="usr/bin/youta usr/bin/youta-gui"

src_unpack() {
	:
}

src_compile() {
	:
}

src_install() {
	# Gentoo's x86 keyword consumes the upstream Rust i686 release target.
	local release_arch=${ARCH}
	[[ ${ARCH} == x86 ]] && release_arch=i686

	local executable_suffix=
	if ! use images; then
		executable_suffix=-text
	fi
	if ! use qr; then
		executable_suffix+=-no-qr
	fi
	if ! use gpm; then
		executable_suffix+=-no-gpm
	fi

	newbin \
		"${DISTDIR}/${MY_P}-linux-${release_arch}${executable_suffix}" \
		youta

	if use gui; then
		newbin \
			"${DISTDIR}/youta-gui-${PV}-linux-${release_arch}" \
			youta-gui
	fi
}

pkg_postinst() {
	elog "This package installs Youta's fixed upstream provider set."
	elog "Install media-sound/youta for build-time feature selection."

	if use gui; then
		elog "The gui USE flag installed both youta and youta-gui."
	fi

	if use alsa; then
		elog "List ALSA devices with: mpv --audio-device=help"
	fi
	if use gpm; then
		elog "GPM mouse input requires the GPM daemon to be running."
		elog "On OpenRC: rc-service gpm start"
	fi

	optfeature "opening links through xdg-open" x11-misc/xdg-utils
	optfeature "local audio fingerprinting through AcoustID" "media-libs/chromaprint[tools]"
	optfeature "automatic config repository commits and pushes" dev-vcs/git
}
