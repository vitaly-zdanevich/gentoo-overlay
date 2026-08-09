# vitaly-zdanevich-overlay

A personal Gentoo overlay maintained by Vitaly Zdanevich.

The initial package set was recovered from these pull requests:

- [gentoo-zh/overlay#11478](https://github.com/gentoo-zh/overlay/pull/11478) — packages removed by the tree-clean, restored from its pre-removal base commit
- [gentoo-zh/overlay#11035](https://github.com/gentoo-zh/overlay/pull/11035) — `app-misc/flox-bin`
- [gentoo/guru#297](https://github.com/gentoo/guru/pull/297) — `gui-apps/organicmaps` and `media-sound/jriver`
- [gentoo/guru#298](https://github.com/gentoo/guru/pull/298) — `dev-cpp/fast_obj`
- [gentoo/guru#336](https://github.com/gentoo/guru/pull/336) — `dev-python/pyicloud`

## Add the overlay

Install `app-eselect/eselect-repository`, then run:

```sh
eselect repository add vitaly-zdanevich-overlay git https://github.com/vitaly-zdanevich/gentoo-overlay.git
emaint sync -r vitaly-zdanevich-overlay
```

The repository can also be configured manually:

```ini
[vitaly-zdanevich-overlay]
location = /var/db/repos/vitaly-zdanevich-overlay
sync-type = git
sync-uri = https://github.com/vitaly-zdanevich/gentoo-overlay.git
masters = gentoo
auto-sync = yes
```

## Youta

[`media-sound/youta`](media-sound/youta) builds the low-resource
[Youta](https://github.com/vitaly-zdanevich/youta) terminal YouTube audio
player from its tagged source and release vendor archive. Provider and playback
choices are exposed as USE flags.

[`media-sound/youta-bin`](media-sound/youta-bin) installs the official
prebuilt amd64 or arm64 release. It has upstream's fixed default feature set
and uses the human-readable state backend without SQLite; use the source
package when you need compile-time feature selection.

```sh
emerge --ask media-sound/youta
```

Or install the prebuilt release:

```sh
emerge --ask media-sound/youta-bin
```

## Provenance

The initial files were copied from immutable Git commits:

- gentoo-zh pre-removal tree: `945c9c5e9bfcd4dfb468b647691a591967a036ec`
- flox-bin PR head: `a05f1d895ff35843b89c77704aa29f71d2e6cf0f`
- Organic Maps/JRiver PR head: `d9f31f95c71e975ed34f410ae268ffcaf05629ed`
- fast_obj PR head: `9f55b1472043f34707444652ec459b20f9748908`
- pyicloud PR head: `8a4e60cfd345ac0ac22dc89026d43d61d6be2da4`

Historical ebuilds are retained as recovered. Old source archives can disappear
upstream, so check the relevant `Manifest` and `SRC_URI` before relying on an
older version.

## Organic Maps dependencies

All package dependencies declared by both Organic Maps ebuilds, including their
eclass-provided and optional test dependencies, are available in `::gentoo`.
No additional package was imported for dependency closure. The separately
included `dev-cpp/fast_obj` ebuild is not an Organic Maps dependency; Organic
Maps uses a vendored fast_obj source snapshot.

## Continuous integration

The overlay carries the package-validation layers used by gentoo-zh:

- [`pkgcheck`](.github/workflows/pkgcheck.yml) runs for pull requests, pushes to
  `main`, and manual dispatches. Pull requests also receive one updated comment
  that distinguishes newly introduced findings from existing findings.
- [`emerge`](.github/workflows/emerge-on-pr.yml) builds and installs every
  changed package from source in current official Gentoo stage3 containers. It
  tests amd64 desktop OpenRC and systemd profiles, plus the arm64 desktop
  systemd profile for arm64-keyworded packages. Official signed Gentoo binary
  packages are used only for dependencies.

The stage3 container supplies the same current Gentoo userspace that a manually
unpacked stage3 and chroot would provide, without duplicating extraction, mount,
and cleanup logic. Each matrix entry is a separate GitHub Actions job with the
maximum six-hour timeout, so a large package does not consume another package's
budget.

Ebuilds execute inside disposable, unprivileged hosted-runner containers. The
emerge workflow therefore uses the `pull_request` event, a read-only token, no
secrets, and checkouts without persisted credentials. It must not be changed to
`pull_request_target`.

Related documentation and precedents:

- [Official Gentoo Docker images](https://github.com/gentoo/gentoo-docker-images)
- [Gentoo binary package guide](https://wiki.gentoo.org/wiki/Binary_package_guide)
- [pkgcheck GitHub Action](https://github.com/pkgcore/pkgcheck-action)
- [gentoo-zh emerge validation](https://github.com/gentoo-zh/overlay/blob/dbcd200b31ae02761745a536b3a9e6f54a802883/.github/workflows/emerge-on-pr.yml)
- [GitHub-hosted runner specifications](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)
- [GitHub Actions limits](https://docs.github.com/en/actions/reference/limits)

## Known inherited limitations

- `dev-cpp/fast_obj-1.3` patches the build to create a shared library, but its
  submitted `src_install` still tries to install the former static library.
- Localized `app-text/wiki2man_on_rust` builds use dated Wikipedia dump URLs
  that can expire when Wikimedia rotates old dumps.
- `gui-apps/organicmaps-9999` assigns `DEPEND` before `RDEPEND`, so its evaluated
  build dependency metadata omits the runtime atoms. Native merges still pull
  them through `RDEPEND`, but the ordering should be corrected for cross-builds.
