EAPI=8

inherit acct-user

DESCRIPTION="System user for net-vpn/windscribe-bin"
KEYWORDS="~amd64"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( windscribe )
ACCT_USER_HOME=/var/lib/windscribe
ACCT_USER_HOME_PERMS=0750
ACCT_USER_SHELL=/sbin/nologin

acct-user_add_deps
