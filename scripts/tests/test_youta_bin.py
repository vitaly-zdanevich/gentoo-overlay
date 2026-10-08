"""Regression tests for Youta manuals and Portage-managed binary debug data."""

import itertools
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
PACKAGE_DIRECTORY = REPOSITORY_ROOT / 'media-sound' / 'youta-bin'
MANUAL_BYTES = b'.TH YOUTA 1\n.SH NAME\nyouta \\- fixture manual\n'


class YoutaBinTest(unittest.TestCase):
	"""Check the newest release ebuild without installing system packages."""

	def setUp(self):
		"""Select the latest numeric release, including packaging revisions."""
		self.ebuild = max(
			PACKAGE_DIRECTORY.glob('youta-bin-*.ebuild'),
			key=lambda path: tuple(int(part) for part in re.findall(r'\d+', path.stem)),
		)
		self.version = self.ebuild.stem.removeprefix('youta-bin-').split('-r')[0]

	def evaluate(self, script, **variables):
		"""Evaluate the ebuild with only the helpers needed by these tests."""
		result = subprocess.run(
			['bash', '-ec', 'inherit() { :; }; source "$1"; ' + script, 'test', str(self.ebuild)],
			env={
				**os.environ,
				'PN': 'youta-bin',
				'PV': self.version,
				'WORKDIR': '/unused',
				'RESTRICT': '',
				**variables,
			},
			capture_output=True,
			text=True,
			check=False,
		)
		self.assertEqual(result.returncode, 0, result.stderr)
		return result.stdout

	def test_stripping_is_not_restricted(self):
		"""Let Portage strip by default or preserve the user's debug data."""
		for features in ('', 'splitdebug', 'nostrip'):
			with self.subTest(features=features):
				output = self.evaluate(
					'printf "%s\\n%s\\n" "${RESTRICT}" "${FEATURES}"',
					FEATURES=features,
				).splitlines()
				self.assertNotIn('strip', output[0].split())
				self.assertEqual(output[1], features)

	def test_manual_source_is_pinned_to_the_binary_release(self):
		"""Fetch the manual from the binary's tag under a versioned distfile name."""
		tokens = self.evaluate('printf "%s\\n" "${SRC_URI}"').split()
		expected = [
			f'https://raw.githubusercontent.com/vitaly-zdanevich/youta/v{self.version}/man/youta.1',
			'->',
			f'youta-{self.version}.1',
		]
		self.assertEqual(sum(tokens[index:index + 3] == expected for index in range(len(tokens))), 1)

	def test_installs_unmodified_release_files_for_all_variants(self):
		"""Stage each binary intact and install its manual under the shared name."""
		for arch, images, qr, gpm, gui in itertools.product(
			('amd64', 'arm64', 'x86'), (False, True), (False, True), (False, True), (False, True),
		):
			with self.subTest(arch=arch, images=images, qr=qr, gpm=gpm, gui=gui):
				with tempfile.TemporaryDirectory() as temporary_directory:
					root = Path(temporary_directory)
					distdir = root / 'distfiles'
					bindir = root / 'image' / 'usr' / 'bin'
					mandir = root / 'image' / 'usr' / 'share' / 'man' / 'man1'
					distdir.mkdir()
					bindir.mkdir(parents=True)
					mandir.mkdir(parents=True)
					manual_distfile = distdir / f'youta-{self.version}.1'
					manual_distfile.write_bytes(MANUAL_BYTES)
					release_arch = 'i686' if arch == 'x86' else arch
					suffix = ('' if images else '-text') + ('' if qr else '-no-qr') + ('' if gpm else '-no-gpm')
					files = {'youta': f'youta-{self.version}-linux-{release_arch}{suffix}'}
					if gui:
						files['youta-gui'] = f'youta-gui-{self.version}-linux-{release_arch}'
					for filename in files.values():
						(distdir / filename).write_bytes(b'mock executable with debug information\0' + filename.encode())
					self.evaluate(
						'use() { [[ " ${USE} " == *" $1 "* ]]; }; '
						'newbin() { cp -- "$1" "${TEST_BINDIR}/$2"; }; '
						'newman() { cp -- "$1" "${TEST_MANDIR}/$2"; }; src_install',
						ARCH=arch,
						USE=' '.join(flag for flag, enabled in zip(('images', 'qr', 'gpm', 'gui'), (images, qr, gpm, gui)) if enabled),
						DISTDIR=str(distdir),
						TEST_BINDIR=str(bindir),
						TEST_MANDIR=str(mandir),
					)
					self.assertEqual({path.name for path in bindir.iterdir()}, set(files))
					for executable, filename in files.items():
						expected = b'mock executable with debug information\0' + filename.encode()
						self.assertEqual((bindir / executable).read_bytes(), expected)
						self.assertEqual((distdir / filename).read_bytes(), expected)
					self.assertEqual({path.name for path in mandir.iterdir()}, {'youta.1'})
					self.assertEqual((mandir / 'youta.1').read_bytes(), MANUAL_BYTES)
					self.assertEqual(manual_distfile.read_bytes(), MANUAL_BYTES)


class YoutaSourceManualTest(unittest.TestCase):
	"""Check that source installs use the manual included in the release tree."""

	def test_installs_shipped_manual_with_and_without_gui(self):
		"""Install the fixture manual for both source frontend configurations."""
		package_directory = REPOSITORY_ROOT / 'media-sound' / 'youta'
		ebuild = max(
			package_directory.glob('youta-*.ebuild'),
			key=lambda path: tuple(int(part) for part in re.findall(r'\d+', path.stem)),
		)
		version = ebuild.stem.removeprefix('youta-').split('-r')[0]
		for gui in (False, True):
			with self.subTest(gui=gui), tempfile.TemporaryDirectory() as temporary_directory:
				root = Path(temporary_directory)
				source = root / f'youta-{version}'
				manual = source / 'man' / 'youta.1'
				mandir = root / 'image' / 'usr' / 'share' / 'man' / 'man1'
				manual.parent.mkdir(parents=True)
				manual.write_bytes(MANUAL_BYTES)
				mandir.mkdir(parents=True)
				result = subprocess.run(
					[
						'bash', '-ec',
						'inherit() { :; }; source "$1"; '
						'use() { [[ " ${USE} " == *" $1 "* ]]; }; '
						'cargo_src_install() { :; }; cargo_target_dir() { printf /unused; }; '
						'dobin() { :; }; dodoc() { :; }; '
						'doman() { cp -- "$1" "${TEST_MANDIR}/${1##*/}"; }; '
						'cd "${S}"; src_install',
						'test', str(ebuild),
					],
					env={
						**os.environ,
						'PN': 'youta',
						'PV': version,
						'P': f'youta-{version}',
						'S': str(source),
						'USE': 'gui' if gui else '',
						'TEST_MANDIR': str(mandir),
					},
					capture_output=True,
					text=True,
					check=False,
				)
				self.assertEqual(result.returncode, 0, result.stderr)
				self.assertEqual({path.name for path in mandir.iterdir()}, {'youta.1'})
				self.assertEqual((mandir / 'youta.1').read_bytes(), MANUAL_BYTES)
				self.assertEqual(manual.read_bytes(), MANUAL_BYTES)


if __name__ == '__main__':
	unittest.main()
