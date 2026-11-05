# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-single-r1 shell-completion

DESCRIPTION="Google Cloud CLI (gcloud)"
HOMEPAGE="https://cloud.google.com/sdk https://cloud.google.com/cli"
SRC_URI="
	amd64? ( https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${P}-linux-x86_64.tar.gz )
	arm64? ( https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${P}-linux-arm.tar.gz )
"
S="${WORKDIR}/google-cloud-sdk"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}"

QA_PREBUILT="opt/google-cloud-cli/bin/gcloud-crc32c"

src_prepare() {
	default

	# Remove packaging and installer artifacts
	rm -rf deb rpm install.* || die
	rm -rf platform/gsutil/third_party/crcmod_osx || die

	# Remove bundled Python in favor of Portage-managed Python
	rm -rf platform/bundledpythonunix || die
	find -type d -name "python2" -prune -exec rm -rf "{}" + || die

	# Disable internal component updater in package-managed installations
	sed -i -e 's/"disable_updater": false/"disable_updater": true/' \
		lib/googlecloudsdk/core/config.json || die

	python_fix_shebang --force .
}

src_install() {
	dodir /opt/google-cloud-cli
	cp -a . "${ED}"/opt/google-cloud-cli || die

	dosym -r /opt/google-cloud-cli/bin/gcloud /usr/bin/gcloud
	dosym -r /opt/google-cloud-cli/bin/gcloud-crc32c /usr/bin/gcloud-crc32c
	dosym -r /opt/google-cloud-cli/bin/gsutil /usr/bin/gsutil
	dosym -r /opt/google-cloud-cli/bin/bq /usr/bin/bq
	dosym -r /opt/google-cloud-cli/bin/docker-credential-gcloud /usr/bin/docker-credential-gcloud
	dosym -r /opt/google-cloud-cli/bin/git-credential-gcloud.sh /usr/bin/git-credential-gcloud.sh

	newbashcomp completion.bash.inc gcloud
	bashcomp_alias gcloud bq gsutil

	python_optimize "${ED}"/opt/google-cloud-cli
}
