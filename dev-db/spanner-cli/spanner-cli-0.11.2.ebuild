# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="Interactive command line tool for Cloud Spanner"
HOMEPAGE="https://github.com/cloudspannerecosystem/spanner-cli"
SRC_URI="
	https://github.com/cloudspannerecosystem/spanner-cli/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
	https://github.com/vitaly-zdanevich/gentoo-overlay/releases/download/${P}/${P}-vendor.tar.xz
"

LICENSE="Apache-2.0"
# Dependent module licenses
LICENSE+="
	BSD MIT
"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-lang/go-1.24"

DOCS=( README.md )

src_prepare() {
	default
	# upstream takes the version from the build info, which is "(devel)" when built from a tarball
	sed -i \
		-e 's/info, ok := debug.ReadBuildInfo()/_, ok := debug.ReadBuildInfo()/' \
		-e "s/return info.Main.Version/return \"v${PV}\"/" \
		main.go || die
}

src_compile() {
	ego build -o ${PN}
}

src_test() {
	ego test ./...
}

src_install() {
	dobin ${PN}
	einstalldocs
}
