"""Check source-package installation using mock Cargo build outputs."""

import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


PACKAGE_DIRECTORY = Path(__file__).resolve().parents[2] / 'app-doc' / 'reeknote'


class ReeknoteSourceTest(unittest.TestCase):
	"""Exercise the latest source ebuild without compiling or installing packages."""

	def setUp(self):
		"""Select the latest source release, including packaging revisions."""
		self.ebuild = max(
			PACKAGE_DIRECTORY.glob('reeknote-*.ebuild'),
			key=lambda path: tuple(int(part) for part in re.findall(r'\d+', path.stem)),
		)
		self.version = self.ebuild.stem.removeprefix('reeknote-').split('-r')[0]

	def install(self, source, image, target):
		"""Stage files with mocked eclass helpers, rejecting any Cargo installation."""
		(image / 'usr' / 'bin').mkdir(parents=True)
		(image / 'usr' / 'share' / 'doc').mkdir(parents=True)
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
				'PN': 'reeknote',
				'PV': self.version,
				'P': f'reeknote-{self.version}',
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

	def test_stages_both_commands_and_docs_without_cargo_install(self):
		"""Honor eclass target paths, preserve file bytes, and emit no PATH warning."""
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
				files = {name: f'mock executable: {name}\0debug data'.encode() for name in ('reeknote', 'rnsync')}
				for name, content in files.items():
					(build / name).write_bytes(content)
				(build / 'unrelated-binary').write_bytes(b'not part of this package')
				(source / 'README.md').write_text('Mock README\n')
				result = self.install(source, image, target)
				self.assertEqual(result.returncode, 0, result.stderr)
				self.assertEqual(result.stderr, '')
				bindir = image / 'usr' / 'bin'
				self.assertEqual({path.name for path in bindir.iterdir()}, set(files))
				for name, content in files.items():
					self.assertEqual((bindir / name).read_bytes(), content)
					self.assertEqual((bindir / name).stat().st_mode & 0o777, 0o755)
					self.assertEqual((build / name).read_bytes(), content)
				self.assertEqual((image / 'usr' / 'share' / 'doc' / 'README.md').read_text(), 'Mock README\n')

	def test_missing_build_output_fails_installation(self):
		"""Do not silently succeed when either required executable is absent."""
		for missing in ('reeknote', 'rnsync'):
			with self.subTest(missing=missing), tempfile.TemporaryDirectory() as directory:
				root = Path(directory)
				source = root / 'source'
				target = Path('target/release')
				build = source / target
				build.mkdir(parents=True)
				for name in ('reeknote', 'rnsync'):
					if name != missing:
						(build / name).write_bytes(b'mock executable')
				(source / 'README.md').write_text('Mock README\n')
				result = self.install(source, root / 'image', target)
				self.assertNotEqual(result.returncode, 0)
				self.assertIn(str(target / missing), result.stderr)


if __name__ == '__main__':
	unittest.main()
