# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Generate simple tables in terminals from a nested list of strings"
HOMEPAGE="https://github.com/matthewdeanmartin/terminaltables https://pypi.org/project/terminaltables/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
