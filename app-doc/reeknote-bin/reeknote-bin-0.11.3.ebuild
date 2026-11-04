# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit optfeature

DESCRIPTION="Prebuilt Evernote CLI with audio playback and terminal images"
HOMEPAGE="https://github.com/vitaly-zdanevich/reeknote"
SRC_URI="
	amd64? (
		https://github.com/vitaly-zdanevich/reeknote/releases/download/${PV}/reeknote-linux-x86_64.tar.gz
			-> ${P}-linux-x86_64.tar.gz
	)
	arm64? (
		https://github.com/vitaly-zdanevich/reeknote/releases/download/${PV}/reeknote-linux-aarch64.tar.gz
			-> ${P}-linux-aarch64.tar.gz
	)
"
S="${WORKDIR}"

# Includes the statically linked Rust dependencies from the source package.
LICENSE="GPL-3 Apache-2.0 BSD CDLA-Permissive-2.0 ISC MIT Unicode-3.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"

# Both release architectures require GLIBC_2.39 and libgcc_s.so.1.
RDEPEND="
	!app-doc/reeknote
	|| (
		llvm-runtimes/libgcc
		sys-devel/gcc:*
	)
	>=sys-libs/glibc-2.39
"

QA_PREBUILT="usr/bin/reeknote usr/bin/rnsync"

src_compile() {
	:
}

src_install() {
	dobin reeknote rnsync
}

pkg_postinst() {
	optfeature "audio attachment playback" media-video/mpv
	optfeature "inline image display in Kitty-compatible terminals" x11-terms/kitty
}
