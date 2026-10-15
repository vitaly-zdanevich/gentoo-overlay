# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="Unofficial Python client for the Yandex Music API"
HOMEPAGE="https://ym.marshal.dev/ https://github.com/MarshalX/yandex-music-api"
SRC_URI="https://github.com/MarshalX/yandex-music-api/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
S="${WORKDIR}/yandex-music-api-${PV}"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/requests[socks5,${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.4.0[${PYTHON_USEDEP}]
"

# Optional accelerators and Ynison tests skip themselves when unavailable.
EPYTEST_PLUGINS=()
distutils_enable_tests pytest
