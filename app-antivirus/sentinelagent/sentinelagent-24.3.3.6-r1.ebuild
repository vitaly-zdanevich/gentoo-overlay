# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-info systemd unpacker

MY_PV="${PV//./_}"

DESCRIPTION="SentinelOne Endpoint Protection Linux agent"
HOMEPAGE="https://www.sentinelone.com/"
SRC_URI="SentinelAgent_linux_x86_64_v${MY_PV}.deb"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="systemd"
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
	sys-devel/gcc:*[cxx]
	>=sys-libs/glibc-2.17
	virtual/zlib:=
"

QA_PREBUILT="opt/sentinelone/*"
# Exclude bundled third-party sonames while retaining internal sonames so
# Portage records a non-empty PROVIDES entry for /opt/sentinelone/lib/*.so.
PROVIDES_EXCLUDE="libbpf.so.1 libelf.so.0"

CONFIG_CHECK="
	~BPF
	~BPF_SYSCALL
	~BPF_JIT
	~DEBUG_INFO_BTF
	~KPROBES
	~KPROBE_EVENTS
	~UPROBES
	~UPROBE_EVENTS
	~FTRACE
	~FUNCTION_TRACER
	~DYNAMIC_FTRACE
	~FTRACE_SYSCALLS
	~BPF_EVENTS
	~BPF_LSM
	~SECURITYFS
"
WARNING_BPF_SYSCALL="CONFIG_BPF_SYSCALL is needed for the agent to load eBPF programs."
WARNING_DEBUG_INFO_BTF="CONFIG_DEBUG_INFO_BTF is needed for CO-RE eBPF on non-standard vendor kernels."
WARNING_KPROBES="CONFIG_KPROBES is needed for SentinelOne kernel dynamic tracing."
WARNING_FUNCTION_TRACER="CONFIG_FUNCTION_TRACER is required for available_filter_functions."
WARNING_FTRACE_SYSCALLS="CONFIG_FTRACE_SYSCALLS is needed for monitoring syscall events (e.g. kill, exit)."
WARNING_BPF_LSM="CONFIG_BPF_LSM is needed for SentinelOne anti-tamper security hooks."
WARNING_SECURITYFS="CONFIG_SECURITYFS is needed for accessing LSM interfaces at /sys/kernel/security."

pkg_setup() {
	linux-info_pkg_setup
	if linux_config_exists; then
		local lsm
		lsm=$(linux_chkconfig_string LSM)
		if [[ -n ${lsm} && ${lsm} != *bpf* ]]; then
			ewarn "CONFIG_LSM does not include 'bpf'. SentinelOne BPF LSM anti-tamper"
			ewarn "hooks require 'bpf' in CONFIG_LSM or 'lsm=...,bpf' in kernel cmdline."
		fi
	fi
}

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

	# Mark bundled private shared libraries owner-executable up front so
	# Portage's 80libraries check does not chmod +x them to 0711.
	chmod 0700 opt/sentinelone/lib/*.so || die

	# Write SERVICE_TYPE directly into installation_params.json; sentinelctl's
	# set-service-type command aborts if SERVICE_TYPE is already present.
	chmod u+w opt/sentinelone/configuration/installation_params.json || die
	cat > opt/sentinelone/configuration/installation_params.json <<-EOF || die
	{
	    "PACKAGE_TYPE": "deb",
	    "SERVICE_TYPE": "$(usex systemd systemd sysvinit)"
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
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "Register SentinelAgent with your management console site token:"
		elog "  sentinelctl management token set <SITE_TOKEN>"
		elog "Enable and start the service with OpenRC:"
		elog "  rc-update add sentinelone default && rc-service sentinelone start"
		elog "Or with systemd:"
		elog "  systemctl enable --now sentinelone"
	fi
}
