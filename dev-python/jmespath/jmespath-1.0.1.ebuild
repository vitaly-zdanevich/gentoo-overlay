# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="JSON Matching Expressions"
HOMEPAGE="https://github.com/jmespath/jmespath.py/ https://pypi.org/project/jmespath/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# OCI CLI 3.94.1 requires jmespath <= 1.0.1.
distutils_enable_tests pytest
