"""Check evertui source and binary packaging without installing system packages."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


OVERLAY_ROOT = Path(__file__).resolve().parents[2]
SOURCE_PACKAGE_DIRECTORY = OVERLAY_ROOT / 'app-doc' / 'evertui'
BIN_PACKAGE_DIRECTORY = OVERLAY_ROOT / 'app-doc' / 'evertui-bin'


class EvertuiSourceTest(unittest.TestCase):
	"""Exercise the latest source ebuild with mock Cargo build outputs."""

	def setUp(self):
		ebuilds = list(SOURCE_PACKAGE_DIRECTORY.glob('evertui-*.ebuild'))
		self.assertTrue(ebuilds, 'The evertui source ebuild must exist')
		self.ebuild = max(
			ebuilds,
			key=lambda path: tuple(int(part) for part in re.findall(r'\d+', path.stem)),
		)
		self.version = self.ebuild.stem.removeprefix('evertui-').split('-r')[0]

	def install(self, source, image, target):
		(image / 'usr' / 'bin').mkdir(parents=True, exist_ok=True)
		(image / 'usr' / 'share' / 'doc').mkdir(parents=True, exist_ok=True)
		return subprocess.run(
			[
				'bash', '-ec',
				'inherit() { :; }; source "$1"; '
				'cargo() { printf "Unexpected cargo invocation\\n" >&2; return 99; }; '
				'cargo_src_install() { cargo install; }; '
				'cargo_target_dir() { printf "%s" "${TEST_TARGET_DIR}"; }; '
				'dobin() { install -m755 -- "$@" "${TEST_BINDIR}/"; }; '
				'einstalldocs() { install -m644 -- "${DOCS[@]}" "${TEST_DOCDIR}/"; }; '
				'cd "${S}"; src_install',
				'test', str(self.ebuild),
			],
			env={
				**os.environ,
				'PN': 'evertui',
				'PV': self.version,
				'P': f'evertui-{self.version}',
				'S': str(source),
				'WORKDIR': str(source.parent),
				'TEST_TARGET_DIR': str(target),
				'TEST_BINDIR': str(image / 'usr' / 'bin'),
				'TEST_DOCDIR': str(image / 'usr' / 'share' / 'doc'),
			},
			capture_output=True,
			text=True,
			check=False,
		)

	def test_stages_executable_and_docs_without_cargo_install(self):
		for target_name in (
			'target/release',
			'target/debug',
			'target/aarch64-unknown-linux-gnu/release',
			'absolute build/debug',
		):
			with self.subTest(target=target_name), tempfile.TemporaryDirectory() as directory:
				root = Path(directory)
				source = root / 'source'
				image = root / 'staged image'
				target = Path(target_name)
				if target_name.startswith('absolute'):
					target = root / target
				build = source / target
				build.mkdir(parents=True)
				source.mkdir(exist_ok=True)
				payload = b'mock executable: evertui\0debug data'
				(build / 'evertui').write_bytes(payload)
				(build / 'unrelated-binary').write_bytes(b'not part of this package')
				(source / 'README.md').write_text('Mock README\n')
				result = self.install(source, image, target)
				self.assertEqual(result.returncode, 0, result.stderr)
				self.assertEqual(result.stderr, '')
				bindir = image / 'usr' / 'bin'
				self.assertEqual({path.name for path in bindir.iterdir()}, {'evertui'})
				self.assertEqual((bindir / 'evertui').read_bytes(), payload)
				self.assertEqual((bindir / 'evertui').stat().st_mode & 0o777, 0o755)
				self.assertEqual((image / 'usr' / 'share' / 'doc' / 'README.md').read_text(), 'Mock README\n')


class EvertuiBinTest(unittest.TestCase):
	"""Exercise the latest binary ebuild with release-file fixtures."""

	def setUp(self):
		ebuilds = list(BIN_PACKAGE_DIRECTORY.glob('evertui-bin-*.ebuild'))
		self.assertTrue(ebuilds, 'The evertui-bin ebuild must exist')
		self.ebuild = max(
			ebuilds,
			key=lambda path: tuple(int(part) for part in re.findall(r'\d+', path.stem)),
		)
		self.version = self.ebuild.stem.removeprefix('evertui-bin-').split('-r')[0]

	def evaluate(self, script, **variables):
		result = subprocess.run(
			['bash', '-ec', 'inherit() { :; }; source "$1"; ' + script, 'test', str(self.ebuild)],
			env={
				**os.environ,
				'PN': 'evertui-bin',
				'PV': self.version,
				'P': f'evertui-bin-{self.version}',
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
		expected = []
		for arch, release_arch in [('amd64', 'x86_64'), ('arm64', 'aarch64')]:
			expected.extend([
				f'{arch}?', '(',
				f'https://github.com/vitaly-zdanevich/evertui/releases/download/{self.version}/evertui-linux-{release_arch}.tar.gz',
				'->', f'evertui-bin-{self.version}-linux-{release_arch}.tar.gz', ')',
			])
		self.assertEqual(self.evaluate('printf "%s" "${SRC_URI}"').split(), expected)
		self.assertEqual(
			self.evaluate('printf "%s" "${KEYWORDS}"').split(),
			['-*', '~amd64', '~arm64'],
		)

	def test_runtime_requirements_and_source_package_conflict(self):
		self.assertEqual(self.evaluate('printf "%s" "${REQUIRED_USE}"'), 'elibc_glibc')
		self.assertEqual(
			self.evaluate('printf "%s" "${RDEPEND}"').split(),
			[
				'!app-doc/evertui',
				'app-editors/vim',
				'sys-apps/util-linux',
				'||', '(', 'llvm-runtimes/libgcc', 'sys-devel/gcc:*', ')',
				'>=sys-libs/glibc-2.39',
			],
		)
		self.assertEqual(self.evaluate('printf "%s" "${QA_PREBUILT}"').split(), ['usr/bin/evertui'])

	def test_installs_executable_for_each_architecture(self):
		for arch in ('amd64', 'arm64'):
			with self.subTest(arch=arch), tempfile.TemporaryDirectory() as directory:
				root = Path(directory)
				work = root / 'work'
				bindir = root / 'image' / 'usr' / 'bin'
				work.mkdir()
				bindir.mkdir(parents=True)
				payload = f'{arch} mock executable: evertui\0debug information'.encode()
				(work / 'evertui').write_bytes(payload)
				self.evaluate(
					'dobin() { install -m755 -- "$@" "${TEST_BINDIR}/"; }; '
					'cd "${S}"; src_install',
					ARCH=arch,
					WORKDIR=str(work),
					TEST_BINDIR=str(bindir),
				)
				self.assertEqual({path.name for path in bindir.iterdir()}, {'evertui'})
				self.assertEqual((bindir / 'evertui').read_bytes(), payload)
				self.assertEqual((bindir / 'evertui').stat().st_mode & 0o777, 0o755)
