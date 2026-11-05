#!/usr/bin/env python3
"""Stop the Cursor Agent CLI from leaving blank rows under its footer.

The bundled Ink renderer (log-update) ends every frame with a newline, so the
hidden cursor always rests on an empty row below the UI.  This wraps the
stream log-update writes to: each frame's trailing newline is held back, and
the next frame's leading erase sequence is shortened by one row to match.

When the output shrinks while it fills the screen (for example when the input
box clears after sending a multi-line message), the terminal cannot scroll the
transcript back down, so the freed rows would stay blank under the footer.
The visible screen is then repainted from the tail of the output.

Usage: cursor-agent-trim-bottom-row.py path/to/index.js
Exit status: 0 patched or already patched, 2 renderer not found, 1 error.
"""
import os
import re
import sys

MARKER = b"__cursorTrimBottomRow"

WRAPPER = rb"""function __cursorTrimBottomRow(logUpdate) {
  return (logUpdate.__trimBottomRow ??= {
    create(stream, options = {}) {
      if (options.incremental) return logUpdate.create(stream, options);
      let held = false;
      const out = Object.create(stream);
      out.write = (chunk, ...rest) => {
        if (typeof chunk === "string") {
          if (held) {
            if (chunk.startsWith("\x1b[2K\x1b[1A")) chunk = chunk.slice(8);
            else if (chunk.startsWith("\x1b[2K")) chunk = "\n" + chunk;
          }
          held = chunk.endsWith("\n");
          if (held) chunk = chunk.slice(0, -1);
        }
        return stream.write(chunk, ...rest);
      };
      const log = logUpdate.create(out, options);
      const countLines = (s) => {
        let n = 1;
        for (let i = s.indexOf("\n"); i !== -1; i = s.indexOf("\n", i + 1)) n++;
        return n;
      };
      const tail = (s, k) => {
        let i = s.length;
        while (k-- > 0) {
          i = s.lastIndexOf("\n", i - 1);
          if (i < 0) return s.split("\n");
        }
        return s.slice(i + 1).split("\n");
      };
      let length = 0;
      let lines = 0;
      const render = (output) => {
        log(output);
        if (output.length === length) return;
        length = output.length;
        const count = countLines(output);
        const rows = stream.rows || 0;
        if (count < lines && rows > 0 && count >= rows) {
          stream.write("\x1b[H" + tail(output, rows).map((l) => "\x1b[2K" + l).join("\n"));
          held = true;
        }
        lines = count;
      };
      render.clear = () => {
        length = lines = 0;
        return log.clear();
      };
      render.done = () => {
        if (held) {
          stream.write("\n");
          held = false;
        }
        length = lines = 0;
        return log.done();
      };
      render.sync = log.sync;
      return render;
    },
  });
}
"""

# webpack module header, then its export getter, e.g. r.d(e,{A:()=>i})
PATTERN = re.compile(
    rb'("\.\./ink/dist/log-update\.js"\(\w+,\w+,\w+\)\{"use strict";)'
    rb"(\w+\.d\(\w+,\{\w+:\(\)=>)(\w+)(\}\))"
)


def main(path):
    with open(path, "rb") as f:
        src = f.read()
    if MARKER in src:
        print(f"{path}: already patched")
        return 0
    matches = len(PATTERN.findall(src))
    if matches != 1:
        print(f"{path}: Ink log-update module not found ({matches} matches)", file=sys.stderr)
        return 2
    patched = PATTERN.sub(lambda m: m[1] + WRAPPER + m[2] + MARKER + b"(" + m[3] + b")" + m[4], src)
    tmp = f"{path}.trim-bottom-row.tmp"
    with open(tmp, "wb") as f:
        f.write(patched)
    os.chmod(tmp, os.stat(path).st_mode)
    os.replace(tmp, path)
    print(f"{path}: patched")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    sys.exit(main(sys.argv[1]))
