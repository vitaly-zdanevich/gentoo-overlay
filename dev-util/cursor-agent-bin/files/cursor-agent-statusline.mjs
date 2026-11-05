#!/usr/bin/env node
// One-line Cursor CLI footer: session · model · MAX · context % · directory · branch* · Run Everything.
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";

const DIM = "\x1b[2m";
const UNDIM = "\x1b[22m";
const MAGENTA = "\x1b[35m";
const DEFAULT_FG = "\x1b[39m";

const data = JSON.parse(readFileSync(0, "utf8"));
const model = data.model ?? {};
const parts = [];

if (data.session_name) parts.push(data.session_name);

let name = model.display_name ?? "";
if (model.param_summary && !name.includes(model.param_summary)) name += ` ${model.param_summary}`;
if (model.max_mode) name += " · MAX";
parts.push(name);

const pct = data.context_window?.used_percentage;
if (pct != null) {
  const rounded = pct.toFixed(1);
  parts.push(rounded.endsWith(".0") ? `${Math.round(pct)}%` : `${rounded}%`);
}

const cwd = data.cwd || process.cwd();
const home = homedir();
parts.push(cwd === home || cwd.startsWith(`${home}/`) ? `~${cwd.slice(home.length)}` : cwd);

let status = [];
try {
  status = execFileSync("git", ["-C", cwd, "status", "--porcelain=v2", "--branch"], {
    encoding: "utf8",
    timeout: 1000,
    stdio: ["ignore", "pipe", "ignore"],
    // The agent runs git in the same repo; never hold .git/index.lock.
    env: { ...process.env, GIT_OPTIONAL_LOCKS: "0" },
  }).split("\n");
} catch {}
const branch = status.find((line) => line.startsWith("# branch.head "))?.slice("# branch.head ".length);
if (branch && branch !== "(detached)") {
  const dirty = status.some((line) => line && !line.startsWith("#"));
  parts.push(dirty ? `${branch}*` : branch);
}

let line = DIM + parts.join(" · ") + UNDIM;
if (data.autorun) line += `${DIM} · ${UNDIM}${MAGENTA}Run Everything${DEFAULT_FG}`;
const vimMode = data.vim?.mode;
if (vimMode && vimMode !== "NORMAL") line += `${DIM} · -- ${vimMode} --${UNDIM}`;
console.log(line);
