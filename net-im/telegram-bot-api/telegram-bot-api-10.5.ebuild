# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake systemd

BOT_API_COMMIT="5df614c91dab8662cfbb24a501ec89949fdcfebb"
TD_COMMIT="f10611ee1f03f91ddae8185483a1ccfd3d664668"

DESCRIPTION="Telegram Bot API server built on TDLib"
HOMEPAGE="https://github.com/tdlib/telegram-bot-api"
SRC_URI="
	https://github.com/tdlib/telegram-bot-api/archive/${BOT_API_COMMIT}.tar.gz -> ${P}.tar.gz
	https://github.com/tdlib/td/archive/${TD_COMMIT}.tar.gz -> ${P}-td-${TD_COMMIT:0:12}.tar.gz
"
S="${WORKDIR}/${PN}-${BOT_API_COMMIT}"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
	dev-libs/openssl:0=
	virtual/zlib:=
"
RDEPEND="
	${DEPEND}
	acct-group/telegram-bot-api
	acct-user/telegram-bot-api
"
BDEPEND="
	dev-util/gperf
"

DOCS=( README.md )

src_unpack() {
	default
	rmdir "${S}/td" || die
	mv "${WORKDIR}/td-${TD_COMMIT}" "${S}/td" || die
}

src_install() {
	cmake_src_install

	newinitd "${FILESDIR}/telegram-bot-api.initd" telegram-bot-api
	newconfd "${FILESDIR}/telegram-bot-api.confd" telegram-bot-api
	fperms 0600 /etc/conf.d/telegram-bot-api

	systemd_dounit "${FILESDIR}/telegram-bot-api.service"

	keepdir /var/lib/telegram-bot-api /var/lib/telegram-bot-api/tmp
	fowners telegram-bot-api:telegram-bot-api /var/lib/telegram-bot-api /var/lib/telegram-bot-api/tmp
	fperms 0750 /var/lib/telegram-bot-api /var/lib/telegram-bot-api/tmp
}

pkg_postinst() {
	elog "Configure TELEGRAM_API_ID and TELEGRAM_API_HASH in /etc/conf.d/telegram-bot-api."
	elog "OpenRC: rc-update add telegram-bot-api default && rc-service telegram-bot-api start"
	elog "systemd: systemctl enable --now telegram-bot-api"
}
