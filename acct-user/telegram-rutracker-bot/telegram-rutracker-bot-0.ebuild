# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="System user for net-im/telegram-rutracker-bot"
KEYWORDS="~amd64 ~arm64"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( telegram-rutracker-bot )
ACCT_USER_HOME=/var/lib/telegram-rutracker-bot
ACCT_USER_HOME_PERMS=0750
ACCT_USER_SHELL=/sbin/nologin

acct-user_add_deps
