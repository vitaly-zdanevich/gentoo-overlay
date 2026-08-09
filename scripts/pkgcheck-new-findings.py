#!/usr/bin/env python3
"""Print pkgcheck findings introduced by a pull request.

pkgcheck's plain output prints a package on an unindented line and its findings
on the following indented lines. Findings are matched by package, check name,
and version so a message-only or line-number change is not reported as new.

Usage: pkgcheck-new-findings.py BASE_REPORT HEAD_REPORT
"""

from collections import Counter
from pathlib import Path
import sys


def parse_report(path):
	"""Return ordered ``(identity, output line)`` findings from a report."""
	findings = []
	package = None

	with Path(path).open(encoding='utf-8') as report:
		for raw_line in report:
			line = raw_line.rstrip('\n')
			if not line:
				continue
			if not line.startswith(' '):
				package = line
				continue
			if package is None:
				continue

			keyword, _, rest = line.strip().partition(': ')
			version = rest.split(':', 1)[0] if rest.startswith('version ') else ''
			findings.append(((package, keyword, version), line))

	return findings


def added_findings(base_findings, head_findings):
	"""Return findings in the head report that are absent from the base report."""
	remaining = Counter(identity for identity, _ in base_findings)
	added = []

	for identity, line in head_findings:
		if remaining[identity]:
			remaining[identity] -= 1
		else:
			added.append((identity, line))

	return added


def render_findings(findings):
	"""Render ordered findings in pkgcheck's package-grouped plain format."""
	lines = []
	package = None

	for (finding_package, _, _), line in findings:
		if finding_package != package:
			if package is not None:
				lines.append('')
			lines.append(finding_package)
			package = finding_package
		lines.append(line)

	return '\n'.join(lines) + ('\n' if lines else '')


def main(arguments=None):
	"""Compare two report paths from ``arguments`` and write new findings."""
	arguments = sys.argv[1:] if arguments is None else arguments
	if len(arguments) != 2:
		print(__doc__.rstrip(), file=sys.stderr)
		return 2

	base_findings = parse_report(arguments[0])
	head_findings = parse_report(arguments[1])
	sys.stdout.write(render_findings(added_findings(base_findings, head_findings)))
	return 0


if __name__ == '__main__':
	raise SystemExit(main())
