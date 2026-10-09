// Usage: node shot.cjs <url-or-path> <out.png> [--full] [--width N] [--height N] [--wait MS]
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const { parseArgs } = require('node:util');

const USAGE = 'usage: node shot.cjs <url-or-path> <out.png> [--full] [--width N] [--height N] [--wait MS]';
let parsed;
try {
  parsed = parseArgs({
    allowPositionals: true,
    options: {
      full: { type: 'boolean' },
      width: { type: 'string', default: '1440' },
      height: { type: 'string', default: '900' },
      wait: { type: 'string', default: '0' },
    },
  });
} catch (e) { console.error(`${e.message}\n${USAGE}`); process.exit(1); }
const num = (name, min) => {
  const v = parsed.values[name];
  const n = Number(v);
  if (v.trim() === '' || !Number.isInteger(n) || n < min) { console.error(`invalid --${name}`); process.exit(1); }
  return n;
};
const full = Boolean(parsed.values.full);
const width = num('width', 1);
const height = num('height', 1);
const wait = num('wait', 0);
const [target, out] = parsed.positionals;
if (!target || !out) { console.error(USAGE); process.exit(1); }

const sh = (cmd) => { try { return execSync(cmd, { stdio: ['ignore', 'pipe', 'ignore'] }).toString().trim(); } catch { return ''; } };

// deliberate: no shell-style escapes or variable expansion; only KEY=VALUE with optional quotes
function readEnvFile(file) {
  const env = {};
  for (const line of fs.readFileSync(file, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z_]+)\s*=\s*(.*?)\s*$/);
    if (!m) continue;
    env[m[1]] = m[2].replace(/^(['"])(.*)\1$/, '$2');
  }
  return env;
}
const root = sh('git rev-parse --show-toplevel');
const file = [process.cwd(), root].filter(Boolean).map((d) => path.join(d, '.screenshot.env')).find(fs.existsSync);
const cfg = file ? readEnvFile(file) : {};
for (const k of ['SCREENSHOT_BASE_URL', 'SCREENSHOT_COOKIE']) if (process.env[k]) cfg[k] = process.env[k];
// deliberate: executable path comes from the real environment only; an untrusted repo's .screenshot.env must not pick the executable
const chromiumEnv = process.env.SCREENSHOT_CHROMIUM;

let url = target;
if (target.startsWith('/')) {
  if (!cfg.SCREENSHOT_BASE_URL) { console.error('SCREENSHOT_BASE_URL is required for path targets'); process.exit(3); }
  url = cfg.SCREENSHOT_BASE_URL.replace(/\/$/, '') + target;
}
let host;
try { host = new URL(url).hostname; } catch { console.error(`invalid url: ${target}`); process.exit(1); }
let baseHost;
if (cfg.SCREENSHOT_BASE_URL) { try { baseHost = new URL(cfg.SCREENSHOT_BASE_URL).hostname; } catch { /* leave undefined: no cookies sent */ } }

const chrome = chromiumEnv || sh('command -v chromium') ||
  ['/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'].find(fs.existsSync);
if (!chrome) { console.error('chromium not found: set SCREENSHOT_CHROMIUM (env), put chromium on PATH, or install Google Chrome'); process.exit(3); }

let chromium;
try { ({ chromium } = require('playwright-core')); } catch {
  console.error(`playwright-core missing: run npm ci in ${__dirname}`);
  process.exit(3);
}

(async () => {
  const browser = await chromium.launch({ executablePath: chrome, headless: true });
  const logs = [];
  try {
    const context = await browser.newContext({ viewport: { width, height } });
    // deliberate: send the session cookie only to the SCREENSHOT_BASE_URL host so it cannot leak to arbitrary hosts
    let cookies = [];
    if (cfg.SCREENSHOT_COOKIE) {
      if (host === baseHost) {
        cookies = cfg.SCREENSHOT_COOKIE.split(';').map((s) => s.trim()).filter((c) => c.includes('=')).map((c) => {
          const i = c.indexOf('=');
          return { name: c.slice(0, i), value: c.slice(i + 1), domain: host, path: '/' };
        });
      } else {
        console.error('WARN: target host differs from SCREENSHOT_BASE_URL; cookies not sent');
      }
    }
    if (cookies.length) await context.addCookies(cookies);
    const page = await context.newPage();
    // deliberate: hide query/hash in the log; SSO redirects carry long tokens there
    const redact = (u) => {
      try { const x = new URL(u); x.username = ''; x.password = ''; x.hash = ''; if (x.search) x.search = '?...'; return x.toString(); } catch { return '<url>'; }
    };
    page.on('pageerror', (e) => logs.push(`pageerror: ${e.message}`));
    page.on('console', (m) => m.type() === 'error' && logs.push(`console.error: ${m.text()}`));
    page.on('requestfailed', (r) => logs.push(`requestfailed: ${redact(r.url())} ${r.failure()?.errorText ?? ''}`));
    const res = await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
    if (wait) await page.waitForTimeout(wait);
    fs.mkdirSync(path.dirname(path.resolve(out)), { recursive: true });
    await page.screenshot({ path: out, fullPage: full });
    const final = page.url();
    console.log(`status=${res ? res.status() : 'n/a'} final=${redact(final)} title=${await page.title()} out=${out}`);
    logs.forEach((l) => console.log(l));
    if (new URL(final).hostname !== host) {
      console.log('WARN: redirected off-site (cookies missing or expired?)');
      process.exitCode = 2;
    }
  } finally {
    await browser.close();
  }
})().catch((e) => { console.error(e.message); process.exit(1); });
