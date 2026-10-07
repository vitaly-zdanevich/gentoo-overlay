# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

# Match the top-level directory in the PyPI sdist.
S="${WORKDIR}/oci-cli-${PV}"

DESCRIPTION="Oracle Cloud Infrastructure CLI"
HOMEPAGE="https://github.com/oracle/oci-cli https://pypi.org/project/oci-cli/"

LICENSE="|| ( UPL-1.0 Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	>=dev-python/setuptools-78.1.1[${PYTHON_USEDEP}]
	<dev-python/setuptools-84[${PYTHON_USEDEP}]
"

# The optional upstream db extra requires cx-Oracle, which Gentoo does not package.
RDEPEND="
	=dev-python/oci-2.187.1[${PYTHON_USEDEP}]
	>=dev-python/arrow-1.0.0[${PYTHON_USEDEP}]
	<dev-python/arrow-2[${PYTHON_USEDEP}]
	>=dev-python/certifi-2025.1.31[${PYTHON_USEDEP}]
	>=dev-python/click-8.3.3[${PYTHON_USEDEP}]
	<dev-python/click-8.4.3[${PYTHON_USEDEP}]
	>=dev-python/cryptography-3.2.1[${PYTHON_USEDEP}]
	<dev-python/cryptography-51[${PYTHON_USEDEP}]
	>=dev-python/jmespath-0.10.0[${PYTHON_USEDEP}]
	<dev-python/jmespath-1.0.2[${PYTHON_USEDEP}]
	>=dev-python/prompt-toolkit-3.0.38[${PYTHON_USEDEP}]
	>=dev-python/pyopenssl-26.2.0[${PYTHON_USEDEP}]
	<dev-python/pyopenssl-27[${PYTHON_USEDEP}]
	>=dev-python/python-dateutil-2.5.3[${PYTHON_USEDEP}]
	<dev-python/python-dateutil-3[${PYTHON_USEDEP}]
	>=dev-python/pytz-2016.10[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-5.4[${PYTHON_USEDEP}]
	>=dev-python/setuptools-78.1.1[${PYTHON_USEDEP}]
	<dev-python/setuptools-84[${PYTHON_USEDEP}]
	>=dev-python/six-1.15.0[${PYTHON_USEDEP}]
	<dev-python/six-2[${PYTHON_USEDEP}]
	=dev-python/terminaltables-3.1.10[${PYTHON_USEDEP}]
"
