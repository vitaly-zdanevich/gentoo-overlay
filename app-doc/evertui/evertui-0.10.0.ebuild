# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.88.0"

inherit cargo

DESCRIPTION="Two-panel Evernote TUI with embedded Vim"
HOMEPAGE="https://github.com/vitaly-zdanevich/evertui"
SRC_URI="
	https://github.com/vitaly-zdanevich/evertui/archive/refs/tags/${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/vitaly-zdanevich/evertui/releases/download/${PV}/vendor.tar.gz
		-> ${P}-vendor.tar.gz
"

LICENSE="GPL-3"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD CDLA-Permissive-2.0 ISC MIT Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	!app-doc/evertui-bin
	app-editors/vim
	sys-apps/util-linux
"
BDEPEND="
	test? (
		app-editors/vim
		sys-apps/util-linux
	)
"

DOCS=( README.md )

# rust does not use *FLAGS from make.conf, silence portage warning
QA_FLAGS_IGNORED="usr/bin/evertui"

ECARGO_VENDOR="${WORKDIR}/vendor"

src_prepare() {
	rm -r "${WORKDIR}/.cargo" || die
	default
}

src_install() {
	# Avoid cargo install's user-facing PATH hint for Portage's staging directory.
	dobin "$(cargo_target_dir)/evertui"
	einstalldocs
}
