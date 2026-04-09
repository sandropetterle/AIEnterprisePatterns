/**
 * generate-fallbacks.ts
 *
 * Reads content.json from the most recent backup (or the date specified via
 * BACKUP_DATE env) and rewrites the delimited fallback regions in
 * lib/cms/queries.ts.
 *
 * Usage:
 *   npx tsx scripts/cms/generate-fallbacks.ts
 *   BACKUP_DATE=2026-04-09 npx tsx scripts/cms/generate-fallbacks.ts
 *
 * The script rewrites only the content between matching marker pairs:
 *   // --- fallback:<name>:start ---
 *   // --- fallback:<name>:end ---
 *
 * It does NOT use an AST — it does template-based string replacement so the
 * diff stays readable and reviewable.
 */

import * as fs from 'fs';
import * as path from 'path';

// ─── Helpers ─────────────────────────────────────────────────────────────────

const ROOT = path.resolve(__dirname, '../..');
const BACKUPS_DIR = path.join(ROOT, 'backups/cms');
const QUERIES_FILE = path.join(ROOT, 'lib/cms/queries.ts');

function latestBackupDate(): string {
  const dirs = fs
    .readdirSync(BACKUPS_DIR)
    .filter((d) => /^\d{4}-\d{2}-\d{2}$/.test(d))
    .sort();
  if (dirs.length === 0) throw new Error(`No backup directories found in ${BACKUPS_DIR}`);
  return dirs[dirs.length - 1];
}

function loadContent(date: string): Record<string, unknown> {
  const file = path.join(BACKUPS_DIR, date, 'content.json');
  if (!fs.existsSync(file)) throw new Error(`content.json not found at ${file}`);
  return JSON.parse(fs.readFileSync(file, 'utf-8')) as Record<string, unknown>;
}

/**
 * Replace the content between start/end markers for the given name.
 * The replacement is indented to match the surrounding code.
 */
function replaceRegion(source: string, name: string, replacement: string): string {
  const startMarker = `// --- fallback:${name}:start ---`;
  const endMarker = `// --- fallback:${name}:end ---`;
  const startIdx = source.indexOf(startMarker);
  const endIdx = source.indexOf(endMarker);
  if (startIdx === -1 || endIdx === -1) {
    console.warn(`  [skip] Markers for "${name}" not found in queries.ts`);
    return source;
  }
  const before = source.slice(0, startIdx + startMarker.length);
  const after = source.slice(endIdx);
  return `${before}\n${replacement}\n  ${after}`;
}

// ─── Fallback generators ──────────────────────────────────────────────────────

/**
 * Strip Strapi internal fields (id, documentId, createdAt, updatedAt,
 * publishedAt) from any object, recursively through arrays.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function stripInternal(obj: any): any {
  if (Array.isArray(obj)) return obj.map(stripInternal);
  if (obj !== null && typeof obj === 'object') {
    const SKIP = new Set(['id', 'documentId', 'createdAt', 'updatedAt', 'publishedAt']);
    return Object.fromEntries(
      Object.entries(obj)
        .filter(([k, v]) => !SKIP.has(k) && v !== null)
        .map(([k, v]) => [k, stripInternal(v)]),
    );
  }
  return obj;
}

/** Produce the TypeScript literal for a given fallback value, indented. */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function toLiteral(value: any, indent = 2): string {
  return JSON.stringify(value, null, 2)
    .replace(/^/gm, ' '.repeat(indent))   // indent every line
    .replace(/"/g, "'")                    // prefer single quotes
    .replace(/'([a-zA-Z_][a-zA-Z0-9_]*)': /g, '$1: '); // unquote simple keys
}

// ─── Main ─────────────────────────────────────────────────────────────────────

const backupDate = process.env.BACKUP_DATE ?? latestBackupDate();
console.log(`Using backup: ${backupDate}`);

const content = loadContent(backupDate);
let source = fs.readFileSync(QUERIES_FILE, 'utf-8');

// ── global ────────────────────────────────────────────────────────────────────
if (content['global']) {
  const g = stripInternal(content['global']);
  const lit = `const GLOBAL_FALLBACK: CmsGlobal = ${toLiteral(g).trimStart()};`;
  source = replaceRegion(source, 'global', lit);
  console.log('  [updated] global');
}

// ── home-page ─────────────────────────────────────────────────────────────────
if (content['home-page']) {
  const hp = stripInternal(content['home-page']);
  const lit =
    `  return safeFetch<CmsHomePage>('/home-page', TTL.PAGE, ${toLiteral(hp, 4).trimStart()} satisfies CmsHomePage, POPULATE.DYNAMIC_ZONE);`;
  source = replaceRegion(source, 'home-page', lit);
  console.log('  [updated] home-page');
} else {
  console.log('  [skip] home-page not in backup');
}

// ── about-page ────────────────────────────────────────────────────────────────
if (content['about-page']) {
  const ap = stripInternal(content['about-page']);
  const lit =
    `  return safeFetch<CmsAboutPage>('/about-page', TTL.PAGE, ${toLiteral(ap, 4).trimStart()} satisfies CmsAboutPage, POPULATE.DYNAMIC_ZONE_WITH_HEADER);`;
  source = replaceRegion(source, 'about-page', lit);
  console.log('  [updated] about-page');
} else {
  console.log('  [skip] about-page not in backup');
}

// ── docs-page ─────────────────────────────────────────────────────────────────
if (content['docs-page']) {
  const dp = stripInternal(content['docs-page']);
  const lit =
    `  return safeFetch<CmsDocsPage>('/docs-page', TTL.PAGE, ${toLiteral(dp, 4).trimStart()} satisfies CmsDocsPage, POPULATE.DYNAMIC_ZONE_WITH_HEADER);`;
  source = replaceRegion(source, 'docs-page', lit);
  console.log('  [updated] docs-page');
} else {
  console.log('  [skip] docs-page not in backup (keeping empty fallback)');
}

// ── login-page ────────────────────────────────────────────────────────────────
if (content['login-page']) {
  const lp = stripInternal(content['login-page']);
  const lit =
    `  return safeFetch<CmsLoginPage>('/login-page', TTL.STATIC, ${toLiteral(lp, 4).trimStart()} satisfies CmsLoginPage);`;
  source = replaceRegion(source, 'login-page', lit);
  console.log('  [updated] login-page');
} else {
  console.log('  [skip] login-page not in backup');
}

// ── not-found-page ────────────────────────────────────────────────────────────
if (content['not-found-page']) {
  const nf = stripInternal(content['not-found-page']);
  const lit =
    `  return safeFetch<CmsNotFoundPage>('/not-found-page', TTL.STATIC, ${toLiteral(nf, 4).trimStart()} satisfies CmsNotFoundPage);`;
  source = replaceRegion(source, 'not-found-page', lit);
  console.log('  [updated] not-found-page');
} else {
  console.log('  [skip] not-found-page not in backup');
}

// ── error-page ────────────────────────────────────────────────────────────────
if (content['error-page']) {
  const ep = stripInternal(content['error-page']);
  const lit =
    `  return safeFetch<CmsErrorPage>('/error-page', TTL.STATIC, ${toLiteral(ep, 4).trimStart()} satisfies CmsErrorPage);`;
  source = replaceRegion(source, 'error-page', lit);
  console.log('  [updated] error-page');
} else {
  console.log('  [skip] error-page not in backup');
}

// ── pattern-listing-labels ────────────────────────────────────────────────────
if (content['pattern-listing-labels']) {
  const pl = stripInternal(content['pattern-listing-labels']);
  const lit =
    `  return safeFetch<CmsPatternListingLabels>('/pattern-listing-labels', TTL.LABELS, ${toLiteral(pl, 4).trimStart()} satisfies CmsPatternListingLabels);`;
  source = replaceRegion(source, 'pattern-listing-labels', lit);
  console.log('  [updated] pattern-listing-labels');
} else {
  console.log('  [skip] pattern-listing-labels not in backup');
}

// ── pattern-detail-labels ─────────────────────────────────────────────────────
if (content['pattern-detail-labels']) {
  const pd = stripInternal(content['pattern-detail-labels']);
  const lit =
    `  return safeFetch<CmsPatternDetailLabels>('/pattern-detail-labels', TTL.LABELS, ${toLiteral(pd, 4).trimStart()} satisfies CmsPatternDetailLabels);`;
  source = replaceRegion(source, 'pattern-detail-labels', lit);
  console.log('  [updated] pattern-detail-labels');
} else {
  console.log('  [skip] pattern-detail-labels not in backup');
}

// ── pattern-form-labels ───────────────────────────────────────────────────────
if (content['pattern-form-labels']) {
  const pf = stripInternal(content['pattern-form-labels']);
  const lit =
    `  return safeFetch<CmsPatternFormLabels>('/pattern-form-labels', TTL.LABELS, ${toLiteral(pf, 4).trimStart()} satisfies CmsPatternFormLabels);`;
  source = replaceRegion(source, 'pattern-form-labels', lit);
  console.log('  [updated] pattern-form-labels');
} else {
  console.log('  [skip] pattern-form-labels not in backup');
}

fs.writeFileSync(QUERIES_FILE, source, 'utf-8');
console.log(`\nDone. Review the diff in lib/cms/queries.ts before committing.`);
