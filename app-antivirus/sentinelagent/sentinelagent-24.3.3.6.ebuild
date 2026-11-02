# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd unpacker

MY_PV="${PV//./_}"

DESCRIPTION="SentinelOne Endpoint Protection Linux agent"
HOMEPAGE="https://www.sentinelone.com/"
SRC_URI="SentinelAgent_linux_x86_64_v${MY_PV}.deb"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist fetch mirror strip"
REQUIRED_USE="elibc_glibc"

BDEPEND="
	acct-group/sentinelone
	acct-user/sentinelone
"
IDEPEND="
	acct-group/sentinelone
	acct-user/sentinelone
"
RDEPEND="
	acct-group/sentinelone
	acct-user/sentinelone
	app-arch/tar
	sys-apps/coreutils
	sys-apps/kmod
	sys-apps/util-linux
	sys-devel/gcc:*[cxx]
	>=sys-libs/glibc-2.17
	sys-process/procps
	virtual/zlib:=
"

QA_PREBUILT="opt/sentinelone/*"
PROVIDES_EXCLUDE="/opt/sentinelone/lib/*"
REQUIRES_EXCLUDE="libelf.so.0 libresolver.so"

pkg_nofetch() {
	einfo "Download ${A} from your SentinelOne management console"
	einfo "and place it into your DISTDIR directory."
}

src_unpack() {
	unpack_deb "${A}"
}

src_prepare() {
	default

	# Upstream sets unnecessary sticky bits on 0700 directories in the deb
	# payload; strip them so directory modes match under both root and userpriv.
	find opt/sentinelone -type d -exec chmod a-t {} + || die

	# Provide a default SERVICE_TYPE in installation_params.json so sentinelctl
	# works before pkg_postinst or the init script updates it.
	chmod u+w opt/sentinelone/configuration/installation_params.json || die
	cat > opt/sentinelone/configuration/installation_params.json <<-EOF || die
	{
	    "PACKAGE_TYPE": "deb",
	    "SERVICE_TYPE": "sysvinit"
	}
	EOF
	chmod 0400 opt/sentinelone/configuration/installation_params.json || die
}

src_install() {
	local dir rc_file root_path
	local shell_rc_files=(
		.profile
		.login
		.shrc
		.bashrc
		.zshrc
		.tcshrc
		.kshrc
	)
	local root_owned_paths=(
		home
		bin
		lib
		configuration/sentineld
		configuration/sentinelone.service
		ebpfs
	)

	dodir /opt
	cp -a opt/sentinelone "${ED}"/opt/ || die

	while IFS= read -r -d '' dir; do
		keepdir "/${dir}"
	done < <(find opt/sentinelone -type d -empty -print0)
	keepdir /opt/sentinelone/cgroups/memory

	for rc_file in "${shell_rc_files[@]}"; do
		dosym -r /opt/sentinelone/home/login.sh "/opt/sentinelone/home/${rc_file}"
	done

	fowners -h -R sentinelone:sentinelone /opt/sentinelone
	for root_path in "${root_owned_paths[@]}"; do
		fowners -h -R root:root "/opt/sentinelone/${root_path}"
	done

	# Enable crash dumps, matching upstream postinst enable_crash_dumps().
	fowners -h -R root:sentinelone /opt/sentinelone/bin
	fperms 0750 /opt/sentinelone/bin
	fperms 0740 /opt/sentinelone/bin/sentinelone-agent

	dosym -r /opt/sentinelone/bin/sentinelctl /usr/bin/sentinelctl

	systemd_dounit opt/sentinelone/configuration/sentinelone.service
	newinitd "${FILESDIR}"/sentinelone.initd sentinelone

	dodoc "${FILESDIR}"/README.gentoo
}

pkg_postinst() {
	if [[ -z ${ROOT} ]]; then
		local service_type="sysvinit"
		[[ -d /run/systemd/system ]] && service_type="systemd"
		"${EROOT}"/opt/sentinelone/bin/sentinelctl control set-service-type "${service_type}" >/dev/null ||
			ewarn "Failed to set SentinelOne service type to ${service_type}"
	fi

	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "Register SentinelAgent with your management console site token:"
		elog "  sentinelctl management token set <SITE_TOKEN>"
		elog "Enable and start the service with OpenRC:"
		elog "  rc-update add sentinelone default && rc-service sentinelone start"
		elog "Or with systemd:"
		elog "  systemctl enable --now sentinelone"
	fi
}
