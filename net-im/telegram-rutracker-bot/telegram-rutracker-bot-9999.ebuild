# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.85.0"

inherit cargo git-r3 systemd

DESCRIPTION="Unofficial Telegram bot for RuTracker search, torrent downloads, and seeding"
HOMEPAGE="https://github.com/vitaly-zdanevich/bot_telegram_rutracker"
EGIT_REPO_URI="https://github.com/vitaly-zdanevich/bot_telegram_rutracker.git"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0 ZLIB
"
SLOT="0"
IUSE="+local-bot-api"

DEPEND="
	app-arch/xz-utils:=
"
RDEPEND="
	${DEPEND}
	acct-group/telegram-rutracker-bot
	acct-user/telegram-rutracker-bot
	local-bot-api? ( net-im/telegram-bot-api )
"
BDEPEND="
	dev-build/cmake
	virtual/pkgconfig
"

DOCS=( README.md )

QA_FLAGS_IGNORED="
	usr/bin/rutracker-catalog-updater
	usr/bin/telegram-rutracker-poller
	usr/bin/telegram-rutracker-vm-worker
"

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_prepare() {
	default
	# Drop upstream ARM-specific rustflags so Portage controls target flags.
	rm -f .cargo/config.toml || die
}

src_compile() {
	# Let Portage strip installed binaries instead of Cargo pre-stripping.
	export CARGO_PROFILE_RELEASE_STRIP=false
	cargo_src_compile \
		--bin telegram-rutracker-vm-worker \
		--bin telegram-rutracker-poller \
		--bin rutracker-catalog-updater
}

src_install() {
	dobin "$(cargo_target_dir)/telegram-rutracker-vm-worker"
	dobin "$(cargo_target_dir)/telegram-rutracker-poller"
	dobin "$(cargo_target_dir)/rutracker-catalog-updater"

	insinto /etc
	doins "${FILESDIR}/telegram-rutracker-bot.env"
	fperms 0600 /etc/telegram-rutracker-bot.env

	newinitd "${FILESDIR}/telegram-rutracker-vm-worker.initd" telegram-rutracker-vm-worker
	newinitd "${FILESDIR}/telegram-rutracker-poller.initd" telegram-rutracker-poller

	systemd_dounit "${FILESDIR}/telegram-rutracker-vm-worker.service"
	systemd_dounit "${FILESDIR}/telegram-rutracker-poller.service"
	systemd_dounit "${FILESDIR}/rutracker-catalog-updater.service"
	systemd_dounit "${FILESDIR}/rutracker-catalog-updater.timer"

	keepdir /var/lib/telegram-rutracker-bot \
		/var/lib/telegram-rutracker-bot/tmp \
		/var/lib/telegram-rutracker-bot/image-cache \
		/var/lib/telegram-rutracker-bot/catalog
	fowners telegram-rutracker-bot:telegram-rutracker-bot \
		/var/lib/telegram-rutracker-bot \
		/var/lib/telegram-rutracker-bot/tmp \
		/var/lib/telegram-rutracker-bot/image-cache \
		/var/lib/telegram-rutracker-bot/catalog
	fperms 0750 \
		/var/lib/telegram-rutracker-bot \
		/var/lib/telegram-rutracker-bot/tmp \
		/var/lib/telegram-rutracker-bot/image-cache \
		/var/lib/telegram-rutracker-bot/catalog

	einstalldocs
}

pkg_postinst() {
	elog "Configure secrets and options in /etc/telegram-rutracker-bot.env."
	elog "OpenRC (webhook worker): rc-update add telegram-rutracker-vm-worker default && rc-service telegram-rutracker-vm-worker start"
	elog "OpenRC (long-polling): rc-update add telegram-rutracker-poller default && rc-service telegram-rutracker-poller start"
	elog "Do not enable vm-worker and poller simultaneously."
}
