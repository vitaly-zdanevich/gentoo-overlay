"""Check Reeknote binary packaging without installing system packages."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


PACKAGE_DIRECTORY = Path(__file__).resolve().parents[2] / 'app-doc' / 'reeknote-bin'


class ReeknoteBinTest(unittest.TestCase):
	"""Exercise the latest binary ebuild with small release-file fixtures."""

	def setUp(self):
		"""Select the latest release, including packaging revisions."""
		ebuilds = list(PACKAGE_DIRECTORY.glob('reeknote-bin-*.ebuild'))
		self.assertTrue(ebuilds, 'The Reeknote binary ebuild must exist')
		self.ebuild = max(
			ebuilds,
			key=lambda path: tuple(int(part) for part in re.findall(r'\d+', path.stem)),
		)
		self.version = self.ebuild.stem.removeprefix('reeknote-bin-').split('-r')[0]

	def evaluate(self, script, **variables):
		"""Source the ebuild with mocked helpers and explicit Portage variables."""
		result = subprocess.run(
			['bash', '-ec', 'inherit() { :; }; source "$1"; ' + script, 'test', str(self.ebuild)],
			env={
				**os.environ,
				'PN': 'reeknote-bin',
				'PV': self.version,
				'P': f'reeknote-bin-{self.version}',
				'WORKDIR': '/unused',
				'BDEPEND': '',
				'DEPEND': '',
				'RESTRICT': '',
				**variables,
			},
			capture_output=True,
			text=True,
			check=False,
		)
		self.assertEqual(result.returncode, 0, result.stderr)
		return result.stdout

	def test_archive_names_are_versioned_and_architecture_specific(self):
		"""Map Gentoo architectures to release assets without distfile collisions."""
		expected = []
		for arch, release_arch in [('amd64', 'x86_64'), ('arm64', 'aarch64')]:
			expected.extend([
				f'{arch}?', '(',
				f'https://github.com/vitaly-zdanevich/reeknote/releases/download/{self.version}/reeknote-linux-{release_arch}.tar.gz',
				'->', f'reeknote-bin-{self.version}-linux-{release_arch}.tar.gz', ')',
			])
		self.assertEqual(self.evaluate('printf "%s" "${SRC_URI}"').split(), expected)
		self.assertEqual(
			self.evaluate('printf "%s" "${KEYWORDS}"').split(),
			['-*', '~amd64', '~arm64'],
		)

	def test_runtime_requirements_and_source_package_conflict(self):
		"""Reject musl and source-package collisions without requiring Rust."""
		self.assertEqual(self.evaluate('printf "%s" "${REQUIRED_USE}"'), 'elibc_glibc')
		self.assertEqual(
			self.evaluate('printf "%s" "${RDEPEND}"').split(),
			['!app-doc/reeknote', '||', '(', 'llvm-runtimes/libgcc', 'sys-devel/gcc:*', ')', '>=sys-libs/glibc-2.39'],
		)
		self.assertEqual(self.evaluate('printf "%s%s" "${BDEPEND}" "${DEPEND}"'), '')
		self.assertEqual(self.evaluate('src_compile'), '')

	def test_installs_both_executables_for_each_architecture(self):
		"""Stage the release files unchanged under their shared command names."""
		for arch in ('amd64', 'arm64'):
			with self.subTest(arch=arch), tempfile.TemporaryDirectory() as directory:
				root = Path(directory)
				work = root / 'work'
				bindir = root / 'image' / 'usr' / 'bin'
				work.mkdir()
				bindir.mkdir(parents=True)
				files = {
					name: f'{arch} mock executable: {name}\0debug information'.encode()
					for name in ('reeknote', 'rnsync')
				}
				for name, content in files.items():
					(work / name).write_bytes(content)
				self.evaluate(
					'dobin() { install -m755 -- "$@" "${TEST_BINDIR}/"; }; '
					'cd "${S}"; src_install',
					ARCH=arch,
					WORKDIR=str(work),
					TEST_BINDIR=str(bindir),
				)
				self.assertEqual({path.name for path in bindir.iterdir()}, set(files))
				for name, content in files.items():
					self.assertEqual((bindir / name).read_bytes(), content)
					self.assertEqual((bindir / name).stat().st_mode & 0o777, 0o755)
					self.assertEqual((work / name).read_bytes(), content)

	def test_optional_audio_and_image_tools(self):
		"""Keep mpv and Kitty optional, matching the source package."""
		self.assertEqual(
			self.evaluate('optfeature() { printf "%s\\n" "$2"; }; pkg_postinst').splitlines(),
			['media-video/mpv', 'x11-terms/kitty'],
		)

	def test_portage_controls_binary_stripping(self):
		"""Mark only the prebuilt executables and respect the user's debug policy."""
		self.assertEqual(
			self.evaluate('printf "%s" "${QA_PREBUILT}"').split(),
			['usr/bin/reeknote', 'usr/bin/rnsync'],
		)
		for features in ('', 'splitdebug', 'nostrip'):
			with self.subTest(features=features):
				self.assertNotIn('strip', self.evaluate('printf "%s" "${RESTRICT}"', FEATURES=features).split())
				self.assertEqual(self.evaluate('printf "%s" "${FEATURES}"', FEATURES=features), features)


if __name__ == '__main__':
	unittest.main()
