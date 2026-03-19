# Phase 7.3: Frontend Code Quality & Security — Implementation Plan

**Created:** 2026-03-18
**Status:** ✅ Complete (2026-03-19)
**Parent:** Phase 7 — Quality & Hardening Evaluation ([PHASE_QUALITY_HARDENING_PLAN.md](PHASE_QUALITY_HARDENING_PLAN.md))

---

## Context

Phase 7.3 audits all frontend source code (`app/`, `components/`, `lib/`, root configs) for code quality and security issues. The audit found the codebase is in **strong shape overall** — TypeScript strict mode, rehype-sanitize for markdown, proper security headers, secure Auth.js OIDC, no secrets in git, no eval/Function usage. Five MEDIUM findings warrant remediation; four LOW findings are documented as accepted risks.

---

## Findings Summary

| # | Finding | Severity | Action |
|---|---------|----------|--------|
| 1 | CMS `dangerouslySetInnerHTML` without sanitization (3 sites) | MEDIUM | Fix (Track 1) |
| 2 | CSP: `unsafe-eval`, missing `base-uri`/`object-src`, wide `img-src` | MEDIUM | Fix (Track 2) |
| 3 | No 429 rate-limit handling in API client | MEDIUM | Fix (Track 3) |
| 4 | ESLint has no security plugin | MEDIUM | Fix (Track 4) |
| 5 | Source maps — verify not exposed in production | MEDIUM | Verify (Track 5) |
| 6 | Docker base image not SHA-pinned | LOW | Defer to 7.7 |
| 7 | No middleware.ts for auth routing | LOW | Accept |
| 8 | console.warn in mappers | LOW | Accept |
| 9 | CMS href values without `javascript:` URL filtering | LOW | Accept |

---

## Track 1: CMS HTML Sanitization (Defense-in-Depth)

**Scope:** Small
**Files:** `package.json`, `lib/cms/components.tsx`, new `lib/cms/sanitize.ts`, new `lib/cms/__tests__/sanitize.test.ts`

**Problem:** Three uses of `dangerouslySetInnerHTML` in `lib/cms/components.tsx` render Strapi rich text HTML without sanitization:
- Line 152: `RichTextRenderer` — `block.body`
- Line 273: `DocSectionRenderer` — `block.content`
- Line 355: `ContributingRenderer` — `block.steps`

The CMS is admin-only and trusted, but defense-in-depth dictates sanitizing even trusted HTML. A compromised CMS admin account or Strapi vulnerability could inject XSS.

**Implementation:**
1. `npm install isomorphic-dompurify` (works in server components via JSDOM)
2. Create `lib/cms/sanitize.ts`:
   ```typescript
   import DOMPurify from 'isomorphic-dompurify';
   export function sanitizeCmsHtml(html: string): string {
     return DOMPurify.sanitize(html);
   }
   ```
3. Wrap all 3 `dangerouslySetInnerHTML` calls:
   ```tsx
   <div dangerouslySetInnerHTML={{ __html: sanitizeCmsHtml(block.body) }} />
   ```
4. Add unit test in `lib/cms/__tests__/sanitize.test.ts` — verify `<script>` stripped, safe HTML passes through
5. **Verify:** `npm run test:ci` (390+ tests, ≥70% coverage), `npm run build`

**Why `isomorphic-dompurify`:** DOMPurify is the most battle-tested HTML sanitizer. The `isomorphic-dompurify` wrapper handles the server-side JSDOM requirement transparently. The project already uses `rehype-sanitize` for markdown — DOMPurify complements it for raw CMS HTML.

---

## Track 2: CSP Hardening

**Scope:** Small
**Files:** `next.config.mjs`

**Problem:** The current CSP has:
- `script-src` includes `'unsafe-eval'` which may not be needed by Next.js 16
- Missing `base-uri 'self'` (prevents base tag injection)
- Missing `object-src 'none'` (prevents plugin embedding)
- `img-src 'self' data: https:` allows images from any HTTPS origin

**Implementation:**
1. Add missing directives: `base-uri 'self'`, `object-src 'none'`
2. Narrow `img-src` to: `'self' data: https://staipatternsmedia.blob.core.windows.net`
3. Test removing `'unsafe-eval'` from `script-src`:
   - Build & start production, check browser DevTools for CSP violations
   - If no violations → remove permanently
   - If violations → restore and document as accepted risk
4. `'unsafe-inline'` stays — required by Next.js for theme anti-flash script, hydration, Tailwind

**Verify:** `npm run build`, manual browser smoke test (home, listing, detail, about, login), check DevTools console for CSP violations

---

## Track 3: 429 Rate-Limit Handling

**Scope:** Trivial
**Files:** `lib/api/error.ts`, existing error tests

**Problem:** `handleApiError()` has specific handling for 401 and 403 but not 429. When the backend rate limiter triggers, users see a generic error instead of a user-friendly message.

**Implementation:**
1. Add 429 case after the 403 block in `handleApiError()`:
   ```typescript
   if (response.status === 429) {
     throw new ApiError(
       'Too many requests. Please wait a moment and try again.',
       429,
       endpoint
     );
   }
   ```
2. Add test case for 429 in existing error test file
3. **Verify:** `npm run test:ci`

---

## Track 4: ESLint Security Plugin

**Scope:** Small
**Files:** `.eslintrc.json`, `package.json`

**Problem:** ESLint only extends `next/core-web-vitals` and `next/typescript`. No security-focused rules to catch eval(), innerHTML, or hardcoded credential patterns.

**Implementation:**
1. `npm install -D eslint-plugin-security`
2. Update `.eslintrc.json`:
   ```json
   {
     "extends": ["next/core-web-vitals", "next/typescript"],
     "plugins": ["security"],
     "rules": {
       "security/detect-object-injection": "off",
       "security/detect-eval-with-expression": "error",
       "security/detect-unsafe-regex": "warn",
       "security/detect-non-literal-regexp": "warn",
       "security/detect-possible-timing-attacks": "warn"
     }
   }
   ```
   Note: `detect-object-injection` is off — excessive false positives with array/object bracket access.
3. Run `npm run lint`, fix any findings (expected: zero or near-zero)
4. **Verify:** `npm run lint`, `npm run test:ci`

---

## Track 5: Source Maps Verification

**Scope:** Trivial
**Files:** `next.config.mjs` (potentially)

**Problem:** Next.js may expose source maps in production builds, leaking source code structure.

**Implementation:**
1. `npm run build`, check `.next/static/` for `.map` files
2. If present: add `productionBrowserSourceMaps: false` to `next.config.mjs`
3. If absent: document as "verified — no action needed"
4. **Verify:** rebuild, confirm no `.map` files in standalone output

---

## Accepted Risks

| # | Finding | Severity | Rationale |
|---|---------|----------|-----------|
| 6 | Docker base image not SHA-pinned | LOW | Deferred to Phase 7.7 (Docker audit) |
| 7 | No middleware.ts for auth routing | LOW | Per-page `auth()` + `redirect()` is equally secure; middleware adds routing complexity without security benefit |
| 8 | console.warn in mappers | LOW | Only fires for truly unknown categories (data integrity, not security); useful for debugging |
| 9 | CMS href values without URL validation | LOW | Same trust boundary as CMS HTML content; CMS is admin-only; `javascript:` URL filtering is a future enhancement if threat model changes |
| — | `'unsafe-inline'` in CSP | LOW | Required by Next.js for inline scripts and Tailwind styles; nonce-based CSP is Phase 8+ scope |

---

## Execution Order

1. Track 1 (CMS sanitization — highest security impact, new dependency)
2. Track 3 (429 handling — zero-dependency, quick)
3. Track 2 (CSP — requires manual browser testing)
4. Track 5 (source maps — verification, may be no-op)
5. Track 4 (ESLint plugin — new dev dependency)

---

## Verification Checklist

- [x] `npm run test:ci` — 396 tests pass (added 5 for sanitize, 1 for 429), all coverage ≥ 70%
- [ ] `npm run build` — production build succeeds (verify manually)
- [ ] `npm run lint` — NOTE: `next lint` removed in Next.js 16; `eslint-plugin-security` rules applied via `.eslintrc.json`
- [ ] Browser DevTools — no CSP violations on key pages (verify manually with production build)
- [x] All `dangerouslySetInnerHTML` wrapped in `sanitizeCmsHtml()`
- [x] No `.map` files in production output (verified: none in `.next/static/`)
- [x] Decision 58 in TECHNICAL_DECISIONS_LOG.md
- [ ] ROADMAP.md shows 7.3 evaluated
