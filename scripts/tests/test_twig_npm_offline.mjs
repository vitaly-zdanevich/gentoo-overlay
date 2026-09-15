/** Exercise Twig's offline dependency mapping with local, synthetic npm packages. */
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';

const helper = fileURLToPath(new URL('../../dev-vcs/twig/files/npm-offline.mjs', import.meta.url));
const registry = 'https://registry.npmjs.org';

/** Create a temporary source tree and clean it after the test. */
function fixture(context, packages) {
	const directory = mkdtempSync(join(tmpdir(), 'twig-npm-offline-test-'));
	context.after(() => rmSync(directory, { recursive: true, force: true }));
	const source = join(directory, 'source');
	const distdir = join(directory, 'dist files');
	mkdirSync(source);
	mkdirSync(distdir);
	const lock = {
		name: 'offline-fixture', version: '1.0.0', lockfileVersion: 3,
		packages: { '': { name: 'offline-fixture', version: '1.0.0' }, ...packages },
	};
	const lockfile = join(source, 'package-lock.json');
	writeFileSync(lockfile, JSON.stringify(lock));
	return { directory, source, distdir, lock, lockfile };
}

/** Run the standalone helper through its public command-line interface. */
function run(...args) {
	return spawnSync(process.execPath, [helper, ...args], { encoding: 'utf8' });
}

/** Return the advertised URL and distfile name for each SRC_URI line. */
function uris(lockfile) {
	const result = run('uris', lockfile);
	assert.equal(result.status, 0, result.stderr);
	return result.stdout.trim().split('\n').filter(Boolean).map(line => line.trim().split(' -> '));
}

test('scoped packages with the same archive basename stay distinct and deterministic', context => {
	const { lockfile } = fixture(context, {
		'node_modules/@two/shared': { version: '1.0.0', resolved: `${registry}/@two/shared/-/shared-1.0.0.tgz`, integrity: 'sha512-two' },
		'node_modules/@one/shared': { version: '1.0.0', resolved: `${registry}/@one/shared/-/shared-1.0.0.tgz`, integrity: 'sha512-one' },
		'node_modules/nested/node_modules/@one/shared': { version: '1.0.0', resolved: `${registry}/@one/shared/-/shared-1.0.0.tgz`, integrity: 'sha512-one' },
	});
	const entries = uris(lockfile);
	assert.equal(entries.length, 2);
	assert.match(entries[0][0], /@one/);
	assert.notEqual(entries[0][1], entries[1][1]);
	assert.match(entries[0][1], /^npm-[a-f0-9]{16}-shared-1\.0\.0\.tgz$/);
	assert.deepEqual(uris(lockfile), entries);
});

test('prepare preserves metadata and maps even skipped packages to local archives', context => {
	const packages = {
		'node_modules/sample': { version: '1.0.0', resolved: `${registry}/sample/-/sample-1.0.0.tgz`, integrity: 'sha512-sample', dependencies: { child: '^2.0.0' } },
		'node_modules/foreign': { version: '2.0.0', resolved: `${registry}/foreign/-/foreign-2.0.0.tgz`, integrity: 'sha512-foreign', optional: true, os: ['darwin'] },
	};
	const { source, distdir, lockfile, lock } = fixture(context, packages);
	const entries = uris(lockfile);
	assert.equal(entries.length, 1);
	writeFileSync(join(distdir, entries[0][1]), 'fixture');
	const result = run('prepare', source, distdir);
	assert.equal(result.status, 0, result.stderr);
	const prepared = JSON.parse(readFileSync(lockfile, 'utf8'));
	for (const [key, entry] of Object.entries(prepared.packages)) {
		if (!key) continue;
		assert.match(entry.resolved, /^file:\//);
		assert.deepEqual({ ...entry, resolved: lock.packages[key].resolved }, lock.packages[key]);
	}
	assert.equal(prepared.packages['node_modules/sample'].resolved, `file:${join(distdir, entries[0][1])}`);
	assert.deepEqual(prepared.packages[''], lock.packages['']);
});

test('URI generation respects optional os, cpu, libc and negated platform constraints', context => {
	const restrictions = [
		{}, { os: ['linux'] }, { os: ['!darwin'] }, { cpu: ['x64'] }, { libc: ['glibc'] },
		{ os: ['darwin'] }, { cpu: ['arm64'] }, { libc: ['musl'] }, { os: ['!linux'] },
	];
	const packages = Object.fromEntries(restrictions.map((restriction, index) => [
		`node_modules/pkg-${index}`,
		{ version: '1.0.0', resolved: `${registry}/pkg-${index}/-/pkg-${index}-1.0.0.tgz`, integrity: 'sha512-test', optional: true, ...restriction },
	]));
	const { lockfile } = fixture(context, packages);
	assert.equal(uris(lockfile).length, 5);
});

test('required foreign packages fail instead of silently disappearing', context => {
	const { lockfile } = fixture(context, {
		'node_modules/foreign': { version: '1.0.0', resolved: `${registry}/foreign/-/foreign-1.0.0.tgz`, integrity: 'sha512-test', cpu: ['arm64'] },
	});
	const result = run('uris', lockfile);
	assert.notEqual(result.status, 0);
	assert.match(result.stderr, /required package.*linux.*x64/);
});

test('unsupported archive URLs fail without changing the lockfile', context => {
	const { source, distdir, lockfile } = fixture(context, {
		'node_modules/sample': { version: '1.0.0', resolved: 'https://example.org/sample.tgz', integrity: 'sha512-test' },
	});
	const before = readFileSync(lockfile, 'utf8');
	const result = run('prepare', source, distdir);
	assert.notEqual(result.status, 0);
	assert.match(result.stderr, /unsupported npm archive URL/);
	assert.equal(readFileSync(lockfile, 'utf8'), before);
});

test('missing required distfiles fail before any lockfile rewrite', context => {
	const { source, distdir, lockfile } = fixture(context, {
		'node_modules/sample': { version: '1.0.0', resolved: `${registry}/sample/-/sample-1.0.0.tgz`, integrity: 'sha512-test' },
	});
	const before = readFileSync(lockfile, 'utf8');
	const result = run('prepare', source, distdir);
	assert.notEqual(result.status, 0);
	assert.match(result.stderr, /missing or unreadable distfile/);
	assert.equal(readFileSync(lockfile, 'utf8'), before);
});

test('missing archive integrity and unsupported lockfile versions are rejected', context => {
	const { lockfile, lock } = fixture(context, {
		'node_modules/sample': { version: '1.0.0', resolved: `${registry}/sample/-/sample-1.0.0.tgz` },
	});
	assert.match(run('uris', lockfile).stderr, /missing integrity/);
	lock.lockfileVersion = 2;
	writeFileSync(lockfile, JSON.stringify(lock));
	assert.match(run('uris', lockfile).stderr, /lockfileVersion 3/);
});

test('npm installs local archives with an empty cache, skips foreign packages and disables scripts', context => {
	const available = spawnSync('npm', ['--version'], { encoding: 'utf8' });
	if (available.status !== 0 || process.platform !== 'linux' || process.arch !== 'x64') {
		context.skip('requires npm and Linux x64');
		return;
	}
	const { directory, source, distdir, lock, lockfile } = fixture(context, {});
	const packageDirectory = join(directory, 'archive', 'package');
	mkdirSync(packageDirectory, { recursive: true });
	writeFileSync(join(packageDirectory, 'package.json'), JSON.stringify({
		name: 'sample', version: '1.0.0', scripts: { install: 'node -e "process.exit(99)"' },
	}));
	writeFileSync(join(packageDirectory, 'index.js'), 'module.exports = 42;\n');
	const archive = join(directory, 'sample.tgz');
	const tar = spawnSync('tar', ['-czf', archive, '-C', dirname(packageDirectory), 'package'], { encoding: 'utf8' });
	assert.equal(tar.status, 0, tar.stderr);
	const packageJson = { name: 'offline-fixture', version: '1.0.0', dependencies: { sample: '1.0.0' }, optionalDependencies: { foreign: '1.0.0' } };
	writeFileSync(join(source, 'package.json'), JSON.stringify(packageJson));
	lock.packages[''] = packageJson;
	lock.packages['node_modules/sample'] = {
		version: '1.0.0', resolved: `${registry}/sample/-/sample-1.0.0.tgz`,
		integrity: `sha512-${createHash('sha512').update(readFileSync(archive)).digest('base64')}`,
		hasInstallScript: true,
	};
	lock.packages['node_modules/foreign'] = {
		version: '1.0.0', resolved: `${registry}/foreign/-/foreign-1.0.0.tgz`,
		integrity: 'sha512-Zm9yZWlnbg==', optional: true, os: ['darwin'],
	};
	writeFileSync(lockfile, JSON.stringify(lock));
	const entries = uris(lockfile);
	assert.equal(entries.length, 1);
	writeFileSync(join(distdir, entries[0][1]), readFileSync(archive));
	const result = run('prepare', source, distdir);
	assert.equal(result.status, 0, result.stderr);
	const npm = spawnSync('npm', [
		'ci', '--offline', '--ignore-scripts', '--no-audit', '--no-fund',
		'--registry=http://127.0.0.1:9', `--cache=${join(directory, 'empty-cache')}`,
	], { cwd: source, encoding: 'utf8', timeout: 30000 });
	assert.equal(npm.status, 0, npm.stdout + npm.stderr);
	assert.equal(readFileSync(join(source, 'node_modules/sample/index.js'), 'utf8'), 'module.exports = 42;\n');
	assert.equal(existsSync(join(source, 'node_modules/foreign')), false);
});
