#!/usr/bin/env python3
'''Drop the lower rule under the Claude Code prompt.

That rule is the top edge of a box rendered after the input. Editing the
source text does nothing on its own: the executable runs the compiled
bytecode stored beside it. This clears the module bytecode (and its
precomputed source hash) so the edited source is what runs, then takes the
box out of the children array and drops the blank row above the prompt.
The file stays the same size.

Usage: claude-code-drop-bottom-border.py path/to/claude
Exit status: 0 patched or already patched, 2 the prompt was not found, 1 error.
'''

import os
import struct
import sys

TRAILER = b'\n---- Bun! ----\n'
# Offsets is 32 bytes and the trailer is 16, and byte_count excludes both.
GRAPH_TAIL = 48
RECORD = 52
NEEDLE = b'=e(g,{...$b,borderBottom:!1,width:"100%",borderText:'
# One blank row above the prompt. Same length, so the executable does not grow.
GAP_OLD = b'const fF=qs?0:1'
GAP_NEW = b'const fF=0     '
HAS_SOURCE_HASHES = 1 << 5

assert len(GAP_OLD) == len(GAP_NEW)


def is_ident_byte(byte):
    return byte == ord('$') or byte == ord('_') or 48 <= byte <= 57 or 65 <= byte <= 90 or 97 <= byte <= 122


def identifier_before(data, end):
    start = end
    while start > 0 and is_ident_byte(data[start - 1]):
        start -= 1
    name = data[start:end]
    if name == b'' or 48 <= name[0] <= 57:
        return None
    return name


def graph(data):
    trailer_at = data.rfind(TRAILER)
    if trailer_at < 32:
        return None
    byte_count, modules_off, modules_len, _entry, _argv_off, _argv_len, flags = struct.unpack_from(
        '<QIIIIII', data, trailer_at - 32
    )
    payload_len = byte_count + GRAPH_TAIL
    base = trailer_at + len(TRAILER) - payload_len
    if base < 8 or modules_len % RECORD != 0:
        return None
    if struct.unpack_from('<Q', data, base - 8)[0] != payload_len:
        return None
    return base, modules_off, modules_len, flags


def module_covering(data, base, modules_off, modules_len, file_offset):
    relative = file_offset - base
    table = base + modules_off
    count = modules_len // RECORD
    for index in range(count):
        record = table + index * RECORD
        contents_off, contents_len = struct.unpack_from('<II', data, record + 8)
        if contents_off <= relative < contents_off + contents_len:
            return index, record
    return None


def clear_bytecode(data, base, modules_off, modules_len, flags, record, index):
    # length == 0 makes Bun compile this module from source.
    struct.pack_into('<I', data, record + 28, 0)
    if flags & HAS_SOURCE_HASHES:
        hashes = base + modules_off + modules_len
        struct.pack_into('<I', data, hashes + index * 4, 0)


def patch_children(data, needle_at, name):
    window_end = min(len(data), needle_at + 800)
    cursor = needle_at
    already = False
    while cursor < window_end:
        array_at = data.find(b'children:[', cursor, window_end)
        if array_at < 0:
            break
        body = array_at + len(b'children:[')
        end = data.find(b']', body, window_end)
        if end < 0:
            break
        parts = data[body:end].split(b',')
        last = parts[-1]
        if last == name:
            spaces = len(name) - 2
            if spaces < 0:
                return None
            data[end - len(name):end] = b'!1' + b' ' * spaces
            return 'removed'
        if last.strip() == b'!1':
            already = True
        cursor = end + 1
    if already:
        return 'already removed'
    return None


def patch_gap(data):
    old = data.find(GAP_OLD)
    new = data.find(GAP_NEW)
    if old >= 0 and data.find(GAP_OLD, old + 1) < 0 and new < 0:
        data[old:old + len(GAP_OLD)] = GAP_NEW
        return 'removed'
    if old < 0 and new >= 0 and data.find(GAP_NEW, new + 1) < 0:
        return 'already removed'
    return None


def main(path):
    with open(path, 'rb') as handle:
        data = bytearray(handle.read())
    original_len = len(data)
    found = graph(data)
    if found is None:
        print(f'{path}: module graph not found', file=sys.stderr)
        return 2
    base, modules_off, modules_len, flags = found
    needle_at = data.find(NEEDLE)
    if needle_at < 0 or data.find(NEEDLE, needle_at + 1) >= 0:
        print(f'{path}: lower prompt rule not found', file=sys.stderr)
        return 2
    name = identifier_before(data, needle_at)
    if name is None:
        print(f'{path}: lower prompt rule has no name', file=sys.stderr)
        return 2
    covered = module_covering(data, base, modules_off, modules_len, needle_at)
    if covered is None:
        print(f'{path}: lower prompt rule is not in a module', file=sys.stderr)
        return 2
    index, record = covered
    result = patch_children(data, needle_at, name)
    if result is None:
        print(f'{path}: lower prompt rule children not found', file=sys.stderr)
        return 2
    gap = patch_gap(data)
    if gap is None:
        print(f'{path}: prompt gap not found', file=sys.stderr)
        return 2
    clear_bytecode(data, base, modules_off, modules_len, flags, record, index)
    if len(data) != original_len:
        print(f'{path}: patch changed the file size', file=sys.stderr)
        return 1
    temporary = f'{path}.drop-bottom-border.tmp'
    with open(temporary, 'wb') as handle:
        handle.write(data)
    os.chmod(temporary, os.stat(path).st_mode)
    os.replace(temporary, path)
    print(f'{path}: lower prompt rule {result}', file=sys.stderr)
    print(f'{path}: prompt gap {gap}', file=sys.stderr)
    return 0


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    sys.exit(main(sys.argv[1]))
