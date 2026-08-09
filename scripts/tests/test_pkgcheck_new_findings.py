"""Tests for the pkgcheck pull-request report comparison helper."""

from pathlib import Path
import subprocess
import tempfile
import unittest


REPOSITORY_ROOT = Path(__file__).resolve().parents[2]
SCRIPT = REPOSITORY_ROOT / 'scripts' / 'pkgcheck-new-findings.py'


class PkgcheckNewFindingsTest(unittest.TestCase):
	"""Exercise the helper with representative pkgcheck report data."""

	def compare(self, base_report, head_report):
		"""Run the helper against temporary mock reports."""
		with tempfile.TemporaryDirectory() as temporary_directory:
			temporary_path = Path(temporary_directory)
			base_path = temporary_path / 'base.txt'
			head_path = temporary_path / 'head.txt'
			base_path.write_text(base_report, encoding='utf-8')
			head_path.write_text(head_report, encoding='utf-8')
			return subprocess.run(
				[str(SCRIPT), str(base_path), str(head_path)],
				check=False,
				capture_output=True,
				text=True,
			)

	def test_omits_existing_findings_and_groups_new_ones(self):
		"""Message changes do not make an otherwise identical finding new."""
		base_report = '''app-misc/example
  ExistingCheck: version 1.0: old message
  PackageCheck: old package message
'''
		head_report = '''app-misc/example
  ExistingCheck: version 1.0: message with a new line number
  PackageCheck: changed package message
  NewCheck: version 1.0: new issue
app-misc/new-package
  NewPackageCheck: new package issue
'''

		result = self.compare(base_report, head_report)

		self.assertEqual(result.returncode, 0, result.stderr)
		self.assertEqual(
			result.stdout,
			'''app-misc/example
  NewCheck: version 1.0: new issue

app-misc/new-package
  NewPackageCheck: new package issue
''',
		)

	def test_preserves_multiple_findings_with_the_same_identity(self):
		"""A duplicate check is compared as a multiset instead of being dropped."""
		base_report = '''app-misc/example
  DuplicateCheck: version 1.0: first issue
'''
		head_report = '''app-misc/example
  DuplicateCheck: version 1.0: first issue moved
  DuplicateCheck: version 1.0: second issue
'''

		result = self.compare(base_report, head_report)

		self.assertEqual(result.returncode, 0, result.stderr)
		self.assertEqual(
			result.stdout,
			'''app-misc/example
  DuplicateCheck: version 1.0: second issue
''',
		)

	def test_treats_a_different_version_as_new(self):
		"""Version-scoped findings remain distinct across ebuild versions."""
		base_report = '''app-misc/example
  VersionCheck: version 1.0: issue
'''
		head_report = '''app-misc/example
  VersionCheck: version 2.0: issue
'''

		result = self.compare(base_report, head_report)

		self.assertEqual(result.returncode, 0, result.stderr)
		self.assertEqual(result.stdout, head_report)

	def test_empty_reports_produce_no_output(self):
		"""Two empty reports are a successful comparison with no findings."""
		result = self.compare('', '')

		self.assertEqual(result.returncode, 0, result.stderr)
		self.assertEqual(result.stdout, '')

	def test_requires_two_report_paths(self):
		"""An invocation without both report paths explains its usage."""
		result = subprocess.run(
			[str(SCRIPT)],
			check=False,
			capture_output=True,
			text=True,
		)

		self.assertEqual(result.returncode, 2)
		self.assertIn('Usage:', result.stderr)


if __name__ == '__main__':
	unittest.main()
