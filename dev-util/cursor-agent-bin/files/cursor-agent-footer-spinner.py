#!/usr/bin/env python3
"""Move the Cursor Agent CLI's working spinner onto its footer line.

The CLI reserves a row (plus a margin) above the prompt box for the
"Thinking / Generating ... tokens" spinner, and keeps it as a blank
placeholder while idle.  This injects a transform that Ink applies to the
live frame only (never to the transcript): the spinner row is moved to the
right end of the first footer line, and the reserved rows (including any
"Tip:" line under the spinner) are dropped, so working and idle frames have
the same height.  Frames it does not recognise are left untouched.

Usage: cursor-agent-footer-spinner.py path/to/index.js
Exit status: 0 patched or already patched, 2 renderer not found, 1 error.
"""
import os
import re
import sys

MARKER = b"__cursorFooterSpinner"

TRANSFORM = rb"""function __cursorFooterSpinner(frame) {
  const lines = frame.split("\n");
  const escape = /\x1b\[[0-?]*[ -\/]*[@-~]|\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)/y;
  const plain = (s) =>
    s.replace(/\x1b\[[0-?]*[ -\/]*[@-~]|\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)/g, "");
  const blank = (i) => plain(lines[i]).trim() === "";
  const cells = (c) =>
    (c >= 0x1100 && c <= 0x115f) || (c >= 0x2e80 && c <= 0xa4cf) ||
    (c >= 0xac00 && c <= 0xd7a3) || (c >= 0xf900 && c <= 0xfaff) ||
    (c >= 0xfe30 && c <= 0xfe4f) || (c >= 0xff00 && c <= 0xff60) ||
    (c >= 0xffe0 && c <= 0xffe6) || (c >= 0x1f300 && c <= 0x1faff) ||
    (c >= 0x20000 && c <= 0x3fffd) ? 2 : 1;
  const width = (s) => {
    let w = 0;
    for (const ch of plain(s)) w += cells(ch.codePointAt(0));
    return w;
  };
  const fit = (s, max) => {
    if (width(s) <= max) return s;
    let out = "";
    let w = 0;
    for (let i = 0; i < s.length;) {
      escape.lastIndex = i;
      const m = escape.exec(s);
      if (m) {
        out += m[0];
        i += m[0].length;
        continue;
      }
      const ch = String.fromCodePoint(s.codePointAt(i));
      const c = cells(ch.codePointAt(0));
      if (w + c > max - 1) break;
      out += ch;
      w += c;
      i += ch.length;
    }
    return (max > 0 ? out + "\u2026" : "") + "\x1b[0m";
  };
  let top = -1;
  let bottom = -1;
  for (let i = lines.length - 1; i >= 0; i--) {
    const p = plain(lines[i]).trim();
    if (bottom < 0) {
      if (/^\u2580{8,}$/.test(p)) bottom = i;
    } else if (/^\u2584{8,}$/.test(p)) {
      top = i;
      break;
    }
  }
  if (top < 1 || bottom + 1 >= lines.length) return frame;
  let first = top;
  while (first > 0 && !blank(first - 1)) first--;
  const drop = new Set();
  if (first === top) {
    drop.add(top - 1);
    if (top >= 2 && blank(top - 2)) drop.add(top - 2);
  } else {
    let spinner = -1;
    for (let i = first; i < top && spinner < 0; i++) {
      if (/^\s*[\u2800-\u28ff]+\s+\S/.test(plain(lines[i]))) spinner = i;
    }
    if (spinner < 0) return frame;
    const room = (process.stdout.columns || 80) - 2;
    const status = fit(lines[spinner].replace(/^ +/, "").trimEnd(), Math.max(4, room - 4));
    const footer = fit(lines[bottom + 1].trimEnd(), room - 2 - width(status));
    const pad = Math.max(1, room - width(footer) - width(status));
    lines[bottom + 1] = footer + " ".repeat(pad) + status;
    for (let i = spinner; i < top; i++) drop.add(i);
    if (spinner === first && first >= 1) drop.add(first - 1);
  }
  return lines.filter((_, i) => !drop.has(i)).join("\n");
}
"""

HEADER = re.compile(rb'"\.\./ink/dist/ink\.js"\(\w+,\w+,\w+\)\{"use strict";')
RENDER = re.compile(rb"this\.throttledLog\(this\.fullStaticOutput\+(\w+)\)")
REDRAW = b"this.log(this.lastOutput)"


def main(path):
    with open(path, "rb") as f:
        src = f.read()
    if MARKER in src:
        print(f"{path}: already patched")
        return 0
    headers, renders = len(HEADER.findall(src)), len(RENDER.findall(src))
    if headers != 1 or renders != 1:
        print(f"{path}: Ink render loop not found ({headers} headers, {renders} render calls)",
              file=sys.stderr)
        return 2
    src = HEADER.sub(lambda m: m[0] + TRANSFORM, src)
    src = RENDER.sub(lambda m: b"this.throttledLog(this.fullStaticOutput+" + MARKER + b"(" + m[1] + b"))", src)
    src = src.replace(REDRAW, b"this.log(" + MARKER + b"(this.lastOutput))")
    tmp = f"{path}.footer-spinner.tmp"
    with open(tmp, "wb") as f:
        f.write(src)
    os.chmod(tmp, os.stat(path).st_mode)
    os.replace(tmp, path)
    print(f"{path}: patched")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    sys.exit(main(sys.argv[1]))
