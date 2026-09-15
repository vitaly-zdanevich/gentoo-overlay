/**
 * Map Twig's npm lockfile to archives fetched and verified by Portage.
 *
 * `uris package-lock.json` prints SRC_URI entries for Linux x64/glibc.
 * `prepare source-directory distfiles-directory` rewrites resolved URLs to
 * local file specifications before npm ci --offline --ignore-scripts --no-audit
 * --no-fund.
 *
 * The complete dependency graph, versions and npm integrity digests remain
 * unchanged. Foreign optional packages retain local paths without requiring
 * their archives; npm's platform selection skips those packages. This helper
 * never downloads packages or runs lifecycle scripts.
 */
import { createHash } from 'node:crypto';
import { accessSync, constants, readFileSync, statSync, writeFileSync } from 'node:fs';
import { basename, join, resolve } from 'node:path';

const target = { os: 'linux', cpu: 'x64', libc: 'glibc' };

/** Match npm platform constraints, including exclusions such as !darwin. */
function matchesPlatform(constraint, value) {
	if (constraint === undefined) return true;
	const values = Array.isArray(constraint) ? constraint : [constraint];
	if (!values.every(item => typeof item === 'string')) {
		throw new Error('unsupported npm platform constraint');
	}
	if (values.includes(`!${value}`)) return false;
	const allowed = values.filter(item => !item.startsWith('!'));
	return allowed.length === 0 || allowed.includes('any') || allowed.includes(value);
}

/** Accept registry tarballs only and derive a stable, collision-resistant name. */
function archiveName(url) {
	if (typeof url !== 'string' || !/^https:\/\/registry\.npmjs\.org\/(?:@[-a-z0-9._~]+\/)?[-a-z0-9._~]+\/-\/[-a-zA-Z0-9._~+]+\.tgz$/.test(url)) {
		throw new Error(`unsupported npm archive URL: ${url}`);
	}
	const digest = createHash('sha256').update(url).digest('hex').slice(0, 16);
	return `npm-${digest}-${basename(url)}`;
}

/** Validate the complete lockfile before producing output or modifying it. */
function readPackages(lockfile) {
	const lock = JSON.parse(readFileSync(lockfile, 'utf8'));
	if (lock.lockfileVersion !== 3 || !lock.packages || typeof lock.packages !== 'object') {
		throw new Error('expected an npm lockfileVersion 3 packages map');
	}
	const entries = [];
	for (const [path, entry] of Object.entries(lock.packages)) {
		if (path === '') continue;
		const filename = archiveName(entry.resolved);
		if (typeof entry.integrity !== 'string' || !entry.integrity) {
			throw new Error(`missing integrity for ${path}`);
		}
		const selected = Object.entries(target).every(([field, value]) => matchesPlatform(entry[field], value));
		if (!selected && !entry.optional) {
			throw new Error(`required package ${path} does not support linux x64 glibc`);
		}
		entries.push({ entry, filename, selected });
	}
	return { lock, entries };
}

/** Print unique archives in URL order so version bumps produce stable diffs. */
function printUris(lockfile) {
	const { entries } = readPackages(lockfile);
	const archives = new Map(entries.filter(item => item.selected).map(item => [item.entry.resolved, item.filename]));
	for (const url of [...archives.keys()].sort()) {
		process.stdout.write(`${url} -> ${archives.get(url)}\n`);
	}
}

/** Check required distfiles, then rewrite URLs while preserving lock metadata. */
function prepare(source, distdir) {
	const lockfile = join(source, 'package-lock.json');
	const { lock, entries } = readPackages(lockfile);
	for (const { filename, selected } of entries) {
		if (!selected) continue;
		const archive = resolve(distdir, filename);
		try {
			accessSync(archive, constants.R_OK);
			if (!statSync(archive).isFile()) throw new Error('not a regular file');
		} catch {
			throw new Error(`missing or unreadable distfile: ${archive}`);
		}
	}
	for (const { entry, filename } of entries) {
		// npm treats percent escapes literally in lockfile file URLs. Its file:
		// path syntax also supports DISTDIR locations containing spaces.
		entry.resolved = `file:${resolve(distdir, filename)}`;
	}
	writeFileSync(lockfile, `${JSON.stringify(lock, null, '\t')}\n`);
}

try {
	const [mode, ...args] = process.argv.slice(2);
	if (mode === 'uris' && args.length === 1) {
		printUris(args[0]);
	} else if (mode === 'prepare' && args.length === 2) {
		prepare(args[0], args[1]);
	} else {
		throw new Error('usage: npm-offline.mjs uris LOCKFILE | prepare SOURCE DISTDIR');
	}
} catch (error) {
	process.stderr.write(`npm-offline: ${error.message}\n`);
	process.exitCode = 1;
}
