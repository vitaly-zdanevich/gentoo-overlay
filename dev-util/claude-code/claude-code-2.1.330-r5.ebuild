# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit python-any-r1

DESCRIPTION="Claude Code - an agentic coding tool by Anthropic"
HOMEPAGE="https://claude.com/product/claude-code"

# NOTE(JayF): Claude code's official install method is now curl|bash
#             the script is simple: it fetches the latest version,
#             downloads a manifest of files for that version, and
#             downloads a single binary claude executable matching.
GCS_BUCKET="https://downloads.claude.ai/claude-code-releases"
SRC_URI="
	amd64? (
		elibc_glibc? ( ${GCS_BUCKET}/${PV}/linux-x64/claude -> claude-amd64-glibc-${PV} )
		elibc_musl?  ( ${GCS_BUCKET}/${PV}/linux-x64-musl/claude -> claude-amd64-musl-${PV} )
	)
	arm64? (
		elibc_glibc? ( ${GCS_BUCKET}/${PV}/linux-arm64/claude -> claude-arm64-glibc-${PV} )
		elibc_musl?  ( ${GCS_BUCKET}/${PV}/linux-arm64-musl/claude -> claude-arm64-musl-${PV} )
	)"
S="${WORKDIR}"

# NOTE(JayF): claude-code is only usable via paid subscription and has a
#             clickthrough EULA-type license. Please see $HOMEPAGE for
#             full details.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="amd64 arm64"
QA_PREBUILT="opt/bin/claude"

RDEPEND="sys-apps/ripgrep"
BDEPEND="${PYTHON_DEPS}"

IUSE="cpu_flags_x86_avx cpu_flags_x86_avx2 settings"
REQUIRED_USE="amd64? ( cpu_flags_x86_avx cpu_flags_x86_avx2 )"

RESTRICT="bindist mirror strip"

pkg_setup() {
	python-any-r1_pkg_setup
}

# The distfile is one executable, not an archive. Copy it into WORKDIR so
# src_prepare can change it; src_install installs that copy. ::gentoo and
# bentoo install ${DISTDIR} directly, so a patch never reaches the binary.
src_unpack() {
	cp "${DISTDIR}/${A}" "${WORKDIR}/claude" || die
}

src_prepare() {
	default
	# The lower rule is a box in the bundled source, and one blank row sits above
	# the prompt. Bun runs compiled bytecode beside that source, so the script
	# edits both and clears that module's bytecode. A miss leaves it unchanged.
	"${EPYTHON}" "${FILESDIR}"/claude-code-drop-bottom-border.py claude ||
		ewarn "drop-bottom-border: prompt frame not found in this release; leaving it unpatched"
}

src_install() {
	exeinto /opt/bin
	newexe claude claude

	insinto /etc/${PN}
	newins "${FILESDIR}/managed-settings-native.json" managed-settings.json

	# Off by default: ~/.claude stays in charge. These files override that.
	if use settings; then
		# CLAUDE_CODE_PLUGIN_DIRS is a path.delimiter list of absolute plugin roots.
		dodir /usr/share/${PN}
		cp -a "${FILESDIR}"/spinner-to-status "${ED}/usr/share/${PN}/" || die

		insinto /etc/${PN}/managed-settings.d
		cat > "${T}"/spinner-to-status.json <<-EOF || die
		{
			"env": {
				"CLAUDE_CODE_PLUGIN_DIRS": "${EPREFIX}/usr/share/${PN}/spinner-to-status"
			}
		}
		EOF
		doins "${T}"/spinner-to-status.json

		# Unset tui lets Claude pick fullscreen. Pin the classic renderer.
		cat > "${T}"/tui.json <<-EOF || die
		{
			"tui": "default"
		}
		EOF
		doins "${T}"/tui.json

		# The official marketplace needs no extraKnownMarketplaces entry for this id.
		cat > "${T}"/defaults.json <<-EOF || die
		{
			"theme": "dark",
			"enabledPlugins": {
				"gopls-lsp@claude-plugins-official": true
			},
			"permissions": {
				"allow": [
					"WebFetch(domain:docs.cloud.google.com)"
				]
			},
			"modelSettings": {
				"claude-opus-5-5": {
					"effortLevel": "high"
				}
			}
		}
		EOF
		doins "${T}"/defaults.json
	fi
}

pkg_postinst() {
	if ! grep -q DISABLE_INSTALLATION_CHECKS /etc/claude-code/managed-settings.json; then
		ewarn "Ensure you run etc-update or dispatch-conf before executing claude."
		ewarn "Failure to properly integrate changes to /etc/claude-code/managed-settings.json"
		ewarn "may lead to claude installing itself to your homedir without asking."
	fi
}
