# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python Circuit Breaker pattern implementation"
HOMEPAGE="https://github.com/fabfuel/circuitbreaker https://pypi.org/project/circuitbreaker/"

LICENSE="BSD-3-Clause"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
