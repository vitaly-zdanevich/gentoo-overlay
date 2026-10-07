# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Oracle Cloud Infrastructure Python SDK"
HOMEPAGE="https://github.com/oracle/oci-python-sdk https://pypi.org/project/oci/"

LICENSE="|| ( UPL-1.0 Apache-2.0 )"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"

RDEPEND="
	dev-python/certifi[${PYTHON_USEDEP}]
	>=dev-python/python-dateutil-2.5.3[${PYTHON_USEDEP}]
	>=dev-python/pytz-2016.10[${PYTHON_USEDEP}]
	>=dev-python/urllib3-2.6.3[${PYTHON_USEDEP}]
	>=dev-python/circuitbreaker-1.3.1[${PYTHON_USEDEP}]
	<dev-python/circuitbreaker-3[${PYTHON_USEDEP}]
	>=dev-python/crc32c-2.8[${PYTHON_USEDEP}]
	>=dev-python/cryptography-3.2.1[${PYTHON_USEDEP}]
	<dev-python/cryptography-51[${PYTHON_USEDEP}]
	>=dev-python/pyopenssl-26.2.0[${PYTHON_USEDEP}]
	<dev-python/pyopenssl-27[${PYTHON_USEDEP}]
	>=dev-python/pyjwt-2.12.0[${PYTHON_USEDEP}]
	>=dev-python/python-pkcs11-0.9.4[${PYTHON_USEDEP}]
	>=dev-python/aiohttp-3.10.11[${PYTHON_USEDEP}]
	<dev-python/aiohttp-4[${PYTHON_USEDEP}]
"
