# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="System user for app-antivirus/sentinelagent"
KEYWORDS="~amd64"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( sentinelone )
ACCT_USER_HOME=/opt/sentinelone/home
ACCT_USER_HOME_OWNER=root:root
ACCT_USER_HOME_PERMS=0700
ACCT_USER_SHELL=/sbin/nologin

acct-user_add_deps
