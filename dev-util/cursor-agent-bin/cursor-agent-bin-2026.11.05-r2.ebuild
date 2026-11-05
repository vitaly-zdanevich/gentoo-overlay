# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit pax-utils python-any-r1

MY_HASH="86047df"
MY_PV="${PV}-${MY_HASH}"

DESCRIPTION="Cursor Agent CLI - Autonomous terminal coding agent"
HOMEPAGE="https://cursor.com/"
SRC_URI="
	amd64? (
		https://downloads.cursor.com/lab/${MY_PV}/linux/x64/agent-cli-package.tar.gz
			-> ${P}-amd64.tar.gz
	)
	arm64? (
		https://downloads.cursor.com/lab/${MY_PV}/linux/arm64/agent-cli-package.tar.gz
			-> ${P}-arm64.tar.gz
	)
"
S="${WORKDIR}/dist-package"

LICENSE="cursor"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE="+footer-spinner +trim-bottom-row"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-misc/ca-certificates
	virtual/zlib
"
BDEPEND="
	footer-spinner? ( ${PYTHON_DEPS} )
	trim-bottom-row? ( ${PYTHON_DEPS} )
"

QA_PREBUILT="*"

pkg_setup() {
	if use footer-spinner || use trim-bottom-row; then
		python-any-r1_pkg_setup
	fi
}

src_prepare() {
	default

	# The built-in updater installs into ~/.local and shadows /usr/bin/agent.
	sed -i 's|"$SCRIPT_DIR/index.js" "$@"|"$SCRIPT_DIR/index.js" --disable-auto-update "$@"|' \
		cursor-agent || die
	grep -q -- --disable-auto-update cursor-agent ||
		ewarn "Launcher format changed; the built-in auto-updater is still enabled"

	if use trim-bottom-row; then
		"${EPYTHON}" "${FILESDIR}"/cursor-agent-trim-bottom-row.py index.js ||
			ewarn "trim-bottom-row: renderer not found in this release; leaving it unpatched"
	fi
	if use footer-spinner; then
		"${EPYTHON}" "${FILESDIR}"/cursor-agent-footer-spinner.py index.js ||
			ewarn "footer-spinner: render loop not found in this release; leaving it unpatched"
	fi
}

src_install() {
	dodir /opt/cursor-agent
	cp -a . "${ED}/opt/cursor-agent/" || die

	pax-mark m "${ED}/opt/cursor-agent/node"
	if [[ -f "${ED}/opt/cursor-agent/cursor-agent-sea" ]]; then
		pax-mark m "${ED}/opt/cursor-agent/cursor-agent-sea"
	fi
	if [[ -f "${ED}/opt/cursor-agent/cursor-agent-worker-sea" ]]; then
		pax-mark m "${ED}/opt/cursor-agent/cursor-agent-worker-sea"
	fi

	dosym -r /opt/cursor-agent/cursor-agent /usr/bin/cursor-agent
	dosym cursor-agent /usr/bin/agent
}
