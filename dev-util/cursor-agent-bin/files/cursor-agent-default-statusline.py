#!/usr/bin/env python3
"""Make a packaged status line the Cursor Agent CLI's default.

The CLI only runs a status line command when cli-config.json has a
"statusLine" entry.  This patches the one place that reads it, so that the
given command is used when the entry is missing.  A "statusLine" in the
user's config still wins.

Usage: cursor-agent-default-statusline.py path/to/dist-package command
Exit status: 0 patched or already patched, 2 config read not found, 1 error.
"""
import json
import os
import re
import sys
from pathlib import Path

MARKER = b"__cursorDefaultStatusLine"

# {text, padding} = useStatusLine(config.statusLine, payload, cwd, signal)
PATTERN = re.compile(rb"(\{text:\w+,padding:\w+\}=\(0,\w+\.\w+\)\()(\w+)\.statusLine,")


def main(root, command):
    found = []
    for path in sorted(Path(root).glob("*.js")):
        src = path.read_bytes()
        if MARKER in src:
            print(f"{path}: already patched")
            return 0
        count = len(PATTERN.findall(src))
        if count:
            found.append((path, src, count))
    total = sum(count for _, _, count in found)
    if total != 1:
        print(f"{root}: status line config read not found ({total} matches)", file=sys.stderr)
        return 2
    path, src, _ = found[0]
    default = b"/*" + MARKER + b'*/{type:"command",command:' + json.dumps(command).encode() + b"}"
    src = PATTERN.sub(lambda m: m[1] + b"(" + m[2] + b".statusLine??" + default + b"),", src)
    tmp = path.with_name(path.name + ".default-statusline.tmp")
    tmp.write_bytes(src)
    os.chmod(tmp, path.stat().st_mode)
    os.replace(tmp, path)
    print(f"{path}: patched")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    sys.exit(main(sys.argv[1], sys.argv[2]))
