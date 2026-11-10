# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Prebuilt two-panel Evernote TUI with embedded Vim"
HOMEPAGE="https://github.com/vitaly-zdanevich/evertui"
SRC_URI="
	amd64? (
		https://github.com/vitaly-zdanevich/evertui/releases/download/${PV}/evertui-linux-x86_64.tar.gz
			-> ${P}-linux-x86_64.tar.gz
	)
	arm64? (
		https://github.com/vitaly-zdanevich/evertui/releases/download/${PV}/evertui-linux-aarch64.tar.gz
			-> ${P}-linux-aarch64.tar.gz
	)
"
S="${WORKDIR}"

# Includes the statically linked Rust dependencies from the source package.
LICENSE="GPL-3 Apache-2.0 BSD CDLA-Permissive-2.0 ISC MIT Unicode-3.0 ZLIB"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
REQUIRED_USE="elibc_glibc"

# Both release architectures require GLIBC_2.39 and libgcc_s.so.1.
RDEPEND="
	!app-doc/evertui
	app-editors/vim
	sys-apps/util-linux
	|| (
		llvm-runtimes/libgcc
		sys-devel/gcc:*
	)
	>=sys-libs/glibc-2.39
"

QA_PREBUILT="usr/bin/evertui"

src_compile() {
	:
}

src_install() {
	dobin evertui
}
