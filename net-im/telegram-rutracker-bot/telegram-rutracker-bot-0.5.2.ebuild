# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	adler2@2.0.1
	aho-corasick@1.1.4
	allocator-api2@0.2.21
	android_system_properties@0.1.5
	anyhow@1.0.102
	arc-swap@1.9.1
	arrayvec@0.7.6
	assert_cfg@0.1.0
	async-compression@0.4.42
	async-stream-impl@0.3.6
	async-stream@0.3.6
	async-trait@0.1.89
	atoi@2.0.0
	atomic-waker@1.1.2
	autocfg@1.5.1
	aws-lc-rs@1.17.0
	aws-lc-sys@0.41.0
	aws_lambda_events@1.2.0
	axum-core@0.5.6
	axum-extra@0.10.3
	axum@0.8.9
	backon@1.6.0
	base64@0.22.1
	bincode@2.0.1
	bincode_derive@2.0.1
	bitflags@2.13.0
	bitvec@1.0.1
	block-buffer@0.10.4
	block-buffer@0.12.1
	bs58@0.5.1
	bstr@1.12.1
	bumpalo@3.20.3
	byteorder@1.5.0
	bytes@1.11.1
	cc@1.2.64
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	chardetng@0.1.17
	chrono@0.4.45
	cmake@0.1.58
	cmov@0.5.4
	compression-codecs@0.4.38
	compression-core@0.4.32
	const-oid@0.10.2
	const_panic@0.2.15
	conv@0.3.3
	cookie@0.18.1
	cookie_store@0.22.1
	core-foundation-sys@0.8.7
	cpufeatures@0.2.17
	cpufeatures@0.3.0
	crc32fast@1.5.0
	crossbeam-deque@0.8.6
	crossbeam-epoch@0.9.18
	crossbeam-utils@0.8.21
	crypto-common@0.1.7
	crypto-common@0.2.2
	cssparser-macros@0.6.1
	cssparser@0.35.0
	ctutils@0.4.2
	custom_derive@0.1.7
	darling@0.23.0
	darling_core@0.23.0
	darling_macro@0.23.0
	dashmap@6.2.1
	data-encoding@2.11.0
	deranged@0.5.8
	derive_more-impl@2.1.1
	derive_more@2.1.1
	digest@0.10.7
	digest@0.11.3
	directories@6.0.0
	dirs-sys@0.5.0
	displaydoc@0.2.6
	document-features@0.2.12
	dontfrag@1.0.1
	dtoa-short@0.3.5
	dtoa@1.0.11
	dunce@1.0.5
	dyn-clone@1.0.20
	ego-tree@0.10.0
	either@1.16.0
	encoding_rs@0.8.35
	equivalent@1.0.2
	errno@0.3.14
	fallible-iterator@0.3.0
	fallible-streaming-iterator@0.1.9
	fastrand@2.4.1
	find-msvc-tools@0.1.9
	flate2@1.1.9
	foldhash@0.1.5
	foldhash@0.2.0
	form_urlencoded@1.2.2
	fs_extra@1.3.0
	funty@2.0.0
	futf@0.1.5
	futures-channel@0.3.32
	futures-core@0.3.32
	futures-executor@0.3.32
	futures-io@0.3.32
	futures-macro@0.3.32
	futures-sink@0.3.32
	futures-task@0.3.32
	futures-timer@3.0.4
	futures-util@0.3.32
	futures@0.3.32
	fxhash@0.2.1
	generic-array@0.12.4
	generic-array@0.14.7
	getopts@0.2.24
	getrandom@0.2.17
	getrandom@0.3.4
	getrandom@0.4.3
	gloo-timers@0.3.0
	governor@0.10.4
	hashbrown@0.12.3
	hashbrown@0.14.5
	hashbrown@0.15.5
	hashbrown@0.16.1
	hashbrown@0.17.1
	hashlink@0.10.0
	hermit-abi@0.5.2
	hex@0.4.3
	hmac@0.13.0
	html-escape@0.2.13
	html5ever@0.35.0
	http-body-util@0.1.3
	http-body@1.0.1
	http-serde@2.1.1
	http@1.4.2
	httparse@1.10.1
	httpdate@1.0.3
	hybrid-array@0.4.12
	hyper-rustls@0.27.9
	hyper-util@0.1.20
	hyper@1.10.1
	iana-time-zone-haiku@0.1.2
	iana-time-zone@0.1.65
	icu_collections@2.2.0
	icu_locale_core@2.2.0
	icu_normalizer@2.2.0
	icu_normalizer_data@2.2.0
	icu_properties@2.2.0
	icu_properties_data@2.2.0
	icu_provider@2.2.0
	ident_case@1.0.1
	idna@1.1.0
	idna_adapter@1.2.2
	indexmap@1.9.3
	indexmap@2.14.0
	intervaltree@0.2.7
	ipnet@2.12.0
	itertools@0.10.5
	itertools@0.14.0
	itoa@1.0.18
	jobserver@0.1.34
	js-sys@0.3.102
	lambda_http@1.2.1
	lambda_runtime@1.2.1
	lambda_runtime_api_client@1.0.3
	lava_torrent@0.11.1
	lazy_static@1.5.0
	leaky-bucket@1.1.2
	libc@0.2.186
	libredox@0.1.17
	librqbit-bencode@9.0.0-rc.0
	librqbit-buffers@9.0.0-rc.0
	librqbit-clone-to-owned@9.0.0-rc.0
	librqbit-core@9.0.0-rc.0
	librqbit-dht@9.0.0-rc.0
	librqbit-dualstack-sockets@0.7.0
	librqbit-lsd@9.0.0-rc.0
	librqbit-peer-protocol@9.0.0-rc.0
	librqbit-sha1-wrapper@9.0.0-rc.0
	librqbit-tracker-comms@9.0.0-rc.0
	librqbit-upnp@9.0.0-rc.0
	librqbit-utp@0.7.0
	librqbit@9.0.0-rc.0
	libsqlite3-sys@0.35.0
	linux-raw-sys@0.12.1
	litemap@0.8.2
	litrs@1.0.0
	lock_api@0.4.14
	log@0.4.32
	lru-slab@0.1.2
	lzma-sys@0.1.20
	mac@0.1.1
	markup5ever@0.35.0
	match_token@0.35.0
	matchers@0.2.0
	matchit@0.8.4
	memchr@2.8.2
	memmap2@0.9.10
	metrics@0.24.6
	mime@0.3.17
	mime_guess@2.0.5
	miniz_oxide@0.8.9
	mio@1.2.1
	network-interface@2.0.5
	new_debug_unreachable@1.0.6
	nix@0.30.1
	nonzero_ext@0.3.0
	nu-ansi-term@0.50.3
	num-complex@0.2.4
	num-conv@0.2.2
	num-integer@0.1.46
	num-iter@0.1.45
	num-rational@0.2.4
	num-traits@0.2.19
	num@0.2.1
	num_cpus@1.17.0
	once_cell@1.21.4
	option-ext@0.2.0
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	percent-encoding@2.3.2
	phf@0.11.3
	phf_codegen@0.11.3
	phf_generator@0.11.3
	phf_macros@0.11.3
	phf_shared@0.11.3
	pin-project-internal@1.1.13
	pin-project-lite@0.2.17
	pin-project@1.1.13
	pkg-config@0.3.33
	portable-atomic-util@0.2.7
	portable-atomic@1.13.1
	potential_utf@0.1.5
	powerfmt@0.2.0
	ppv-lite86@0.2.21
	precomputed-hash@0.1.1
	proc-macro2@1.0.106
	psl-types@2.0.11
	publicsuffix@2.3.0
	quanta@0.12.6
	query_map@0.7.0
	quick-xml@0.38.4
	quinn-proto@0.11.14
	quinn-udp@0.5.14
	quinn@0.11.9
	quote@1.0.45
	r-efi@5.3.0
	r-efi@6.0.0
	radium@0.7.0
	rand@0.8.6
	rand@0.9.4
	rand_chacha@0.9.0
	rand_core@0.6.4
	rand_core@0.9.5
	rapidhash@4.4.1
	raw-cpuid@11.6.0
	rayon-core@1.13.0
	rayon@1.12.0
	redox_syscall@0.5.18
	redox_users@0.5.2
	ref-cast-impl@1.0.25
	ref-cast@1.0.25
	regex-automata@0.4.14
	regex-syntax@0.8.11
	regex@1.12.4
	reqwest@0.12.28
	ring@0.17.14
	ringbuf@0.4.8
	rlimit@0.10.2
	rusqlite@0.37.0
	rustc-hash@2.1.2
	rustc_version@0.4.1
	rustix@1.1.4
	rustls-pki-types@1.14.1
	rustls-webpki@0.103.13
	rustls@0.23.40
	rustversion@1.0.22
	ryu@1.0.23
	same-file@1.0.6
	schemars@0.9.0
	schemars@1.2.1
	scopeguard@1.2.0
	scraper@0.24.0
	selectors@0.31.0
	semver@1.0.28
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_html_form@0.2.8
	serde_json@1.0.150
	serde_path_to_error@0.1.20
	serde_urlencoded@0.7.1
	serde_with@3.21.0
	serde_with_macros@3.21.0
	servo_arc@0.4.3
	sha1@0.10.6
	sha2@0.11.0
	sharded-slab@0.1.7
	shlex@2.0.1
	simd-adler32@0.3.9
	siphasher@1.0.3
	size_format@1.0.2
	slab@0.4.12
	smallvec@1.15.2
	socket2@0.6.4
	spinning_top@0.3.0
	stable_deref_trait@1.2.1
	string_cache@0.8.9
	string_cache_codegen@0.5.4
	strsim@0.11.1
	subtle@2.6.1
	syn@2.0.118
	sync_wrapper@1.0.2
	synstructure@0.13.2
	tap@1.0.1
	tempfile@3.27.0
	tendril@0.4.3
	thiserror-impl@1.0.69
	thiserror-impl@2.0.18
	thiserror@1.0.69
	thiserror@2.0.18
	thread_local@1.1.9
	time-core@0.1.9
	time-macros@0.2.29
	time@0.3.49
	tinystr@0.8.3
	tinyvec@1.11.0
	tinyvec_macros@0.1.1
	tokio-macros@2.7.0
	tokio-rustls@0.26.4
	tokio-socks@0.5.3
	tokio-stream@0.1.18
	tokio-util@0.7.18
	tokio@1.52.3
	tower-http@0.6.11
	tower-layer@0.3.3
	tower-service@0.3.3
	tower@0.5.3
	tracing-attributes@0.1.31
	tracing-core@0.1.36
	tracing-log@0.2.0
	tracing-serde@0.2.0
	tracing-subscriber@0.3.23
	tracing@0.1.44
	try-lock@0.2.5
	typenum@1.20.1
	typewit@1.15.2
	unicase@2.9.0
	unicode-ident@1.0.24
	unicode-width@0.2.2
	untrusted@0.7.1
	untrusted@0.9.0
	unty@0.0.4
	url@2.5.8
	urlencoding@2.1.3
	utf-8@0.7.6
	utf8-width@0.1.8
	utf8_iter@1.0.4
	uuid@1.23.3
	valuable@0.1.1
	vcpkg@0.2.15
	version_check@0.9.5
	virtue@0.0.18
	walkdir@2.5.0
	want@0.3.1
	wasi@0.11.1+wasi-snapshot-preview1
	wasip2@1.0.4+wasi-0.2.12
	wasm-bindgen-futures@0.4.75
	wasm-bindgen-macro-support@0.2.125
	wasm-bindgen-macro@0.2.125
	wasm-bindgen-shared@0.2.125
	wasm-bindgen@0.2.125
	wasm-streams@0.4.2
	web-sys@0.3.102
	web-time@1.1.0
	web_atoms@0.1.3
	webpki-roots@1.0.8
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-util@0.1.11
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-collections@0.3.2
	windows-core@0.62.2
	windows-future@0.3.2
	windows-implement@0.60.2
	windows-interface@0.59.3
	windows-link@0.2.1
	windows-numerics@0.3.1
	windows-result@0.4.1
	windows-strings@0.5.1
	windows-sys@0.52.0
	windows-sys@0.60.2
	windows-sys@0.61.2
	windows-targets@0.52.6
	windows-targets@0.53.5
	windows-threading@0.2.1
	windows@0.62.2
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_gnullvm@0.53.1
	windows_aarch64_msvc@0.52.6
	windows_aarch64_msvc@0.53.1
	windows_i686_gnu@0.52.6
	windows_i686_gnu@0.53.1
	windows_i686_gnullvm@0.52.6
	windows_i686_gnullvm@0.53.1
	windows_i686_msvc@0.52.6
	windows_i686_msvc@0.53.1
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnu@0.53.1
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_gnullvm@0.53.1
	windows_x86_64_msvc@0.52.6
	windows_x86_64_msvc@0.53.1
	wit-bindgen@0.57.1
	writeable@0.6.3
	wyz@0.5.1
	xz2@0.1.7
	yoke-derive@0.8.2
	yoke@0.8.3
	zerocopy-derive@0.8.52
	zerocopy@0.8.52
	zerofrom-derive@0.1.7
	zerofrom@0.1.8
	zeroize@1.9.0
	zerotrie@0.2.4
	zerovec-derive@0.11.3
	zerovec@0.11.6
	zmij@1.0.21
"

RUST_MIN_VER="1.85.0"

inherit cargo systemd

DESCRIPTION="Unofficial Telegram bot for RuTracker search, torrent downloads, and seeding"
HOMEPAGE="https://github.com/vitaly-zdanevich/bot_telegram_rutracker"
SRC_URI="
	https://github.com/vitaly-zdanevich/bot_telegram_rutracker/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"
S="${WORKDIR}/bot_telegram_rutracker-${PV}"

LICENSE="MIT"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 BSD CDLA-Permissive-2.0 ISC MIT MPL-2.0 Unicode-3.0 ZLIB
"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
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
