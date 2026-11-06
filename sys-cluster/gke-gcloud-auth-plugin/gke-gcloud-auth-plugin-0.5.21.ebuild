# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Build timestamp of the gcloud component tarball, see "gke-gcloud-auth-plugin-linux-*"
# in https://dl.google.com/dl/cloudsdk/channels/rapid/components-2.json
BUILD_TS="20261030071842"
COMPONENT_URI="https://dl.google.com/dl/cloudsdk/channels/rapid/components/google-cloud-sdk-${PN}"

DESCRIPTION="kubectl credential plugin for Google Kubernetes Engine (GKE)"
HOMEPAGE="
	https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl
	https://github.com/kubernetes/cloud-provider-gcp
"
SRC_URI="
	amd64? ( ${COMPONENT_URI}-linux-x86_64-${BUILD_TS}.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( ${COMPONENT_URI}-linux-arm-${BUILD_TS}.tar.gz -> ${P}-arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

QA_PREBUILT="usr/bin/${PN}"

src_install() {
	dobin bin/${PN}
}
