// Usage: node shot.cjs <url-or-path> <out.png> [--full] [--width N] [--height N] [--wait MS]
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const args = process.argv.slice(2);
const opt = (name, def) => {
  const i = args.indexOf(name);
  return i < 0 ? def : args.splice(i, 2)[1];
};
const full = args.includes('--full') && args.splice(args.indexOf('--full'), 1);
const width = Number(opt('--width', 1440));
const height = Number(opt('--height', 900));
const wait = Number(opt('--wait', 0));
const [target, out] = args;
if (!target || !out) {
  console.error('usage: node shot.cjs <url-or-path> <out.png> [--full] [--width N] [--height N] [--wait MS]');
  process.exit(1);
}

const sh = (cmd) => { try { return execSync(cmd, { stdio: ['ignore', 'pipe', 'ignore'] }).toString().trim(); } catch { return ''; } };

// deliberate: no shell-style escapes or variable expansion; only KEY=VALUE with optional quotes
function readEnvFile(file) {
  const env = {};
  for (const line of fs.readFileSync(file, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z_]+)\s*=\s*(.*?)\s*$/);
    if (!m || line.trim().startsWith('#')) continue;
    env[m[1]] = m[2].replace(/^(['"])(.*)\1$/, '$2');
  }
  return env;
}
const root = sh('git rev-parse --show-toplevel');
const file = [process.cwd(), root].filter(Boolean).map((d) => path.join(d, '.screenshot.env')).find(fs.existsSync);
const cfg = { ...(file ? readEnvFile(file) : {}) };
for (const k of ['SCREENSHOT_BASE_URL', 'SCREENSHOT_COOKIE', 'SCREENSHOT_CHROMIUM']) if (process.env[k]) cfg[k] = process.env[k];

let url = target;
if (target.startsWith('/')) {
  if (!cfg.SCREENSHOT_BASE_URL) { console.error('SCREENSHOT_BASE_URL is required for path targets'); process.exit(3); }
  url = cfg.SCREENSHOT_BASE_URL.replace(/\/$/, '') + target;
}
const host = new URL(url).hostname;

const chrome = cfg.SCREENSHOT_CHROMIUM || sh('which chromium') ||
  ['/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'].find(fs.existsSync);
if (!chrome) { console.error('chromium not found: set SCREENSHOT_CHROMIUM, put chromium on PATH, or install Google Chrome'); process.exit(3); }

let chromium;
try { ({ chromium } = require('playwright-core')); } catch {
  console.error(`playwright-core missing: run npm install in ${__dirname}`);
  process.exit(3);
}

(async () => {
  const browser = await chromium.launch({ executablePath: chrome, headless: true });
  const logs = [];
  try {
    const context = await browser.newContext({ viewport: { width, height } });
    const cookies = (cfg.SCREENSHOT_COOKIE || '').split(';').map((s) => s.trim()).filter(Boolean).map((c) => {
      const i = c.indexOf('=');
      return { name: c.slice(0, i), value: c.slice(i + 1), domain: host, path: '/' };
    }).filter((c) => c.name);
    if (cookies.length) await context.addCookies(cookies);
    const page = await context.newPage();
    page.on('pageerror', (e) => logs.push(`pageerror: ${e.message}`));
    page.on('console', (m) => m.type() === 'error' && logs.push(`console.error: ${m.text()}`));
    page.on('requestfailed', (r) => logs.push(`requestfailed: ${r.url()}`));
    const res = await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
    if (wait) await page.waitForTimeout(wait);
    fs.mkdirSync(path.dirname(path.resolve(out)), { recursive: true });
    await page.screenshot({ path: out, fullPage: Boolean(full) });
    const final = page.url();
    // deliberate: hide query/hash in the log; SSO redirects carry long tokens there
    const shown = new URL(final); shown.hash = ''; if (shown.search) shown.search = '?...';
    console.log(`status=${res ? res.status() : 'n/a'} final=${shown} title=${await page.title()} out=${out}`);
    logs.forEach((l) => console.log(l));
    if (new URL(final).hostname !== host) {
      console.log('WARN: redirected off-site (cookies missing or expired?)');
      process.exitCode = 2;
    }
  } finally {
    await browser.close();
  }
})().catch((e) => { console.error(e.message); process.exit(1); });
