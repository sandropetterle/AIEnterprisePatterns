# Layout Components

**Namespace:** `layout` · **Source:** [`cms/src/components/layout/`](../../cms/src/components/layout/)

Layout components are structural building blocks reused across content types and section components. They are not rendered directly by `DynamicZone` — they are embedded within section renderers or content type schema fields.

← [Back to Component Index](COMPONENT_INDEX.md)

---

## cta-button

**Schema:** [`cms/src/components/layout/cta-button.json`](../../cms/src/components/layout/cta-button.json)

**Purpose:** Call-to-action link with configurable styling variant. The most widely reused component in the system — used any time a button or link needs to appear in CMS-managed content.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `label` | string | Yes | — | Button/link display text |
| `href` | string | Yes | — | Destination URL (internal path or external URL) |
| `variant` | enum | No | `primary` | Visual style: `primary`, `secondary`, `outline`, `ghost` |
| `icon` | string | No | — | Optional icon identifier (name string, not a media asset) |

**Used by:**

| Parent | Field | Context |
|--------|-------|---------|
| `sections.hero` | `primaryCTA`, `secondaryCTA` | Two optional CTAs below the hero heading |
| `sections.cta-banner` | `primaryCTA`, `secondaryCTA` | Two optional CTAs in the banner |
| `sections.open-source-info` | `links` (repeatable) | Multiple project links (GitHub, docs, etc.) |
| `sections.contributing` | `ctaButton` | Single CTA at the end of the contributing section |
| `not-found-page` | `backButton` | Single "back" button on the 404 page |

**Frontend:** Rendered inline by the parent section's renderer in [`lib/cms/components.tsx`](../../lib/cms/components.tsx) — no standalone renderer.

---

## footer-config

**Schema:** [`cms/src/components/layout/footer-config.json`](../../cms/src/components/layout/footer-config.json)

**Purpose:** Global footer configuration — copyright text template and footer navigation links. Used as a single embedded component on the `global` content type.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `copyrightTemplate` | string | Yes | `© {year} AI Enterprise Patterns. All rights reserved.` | Copyright text; `{year}` is replaced at render time with the current year |
| `links` | repeatable `layout.nav-link` | No | — | Footer navigation links |

**Used by:**

| Parent | Field | Context |
|--------|-------|---------|
| `global` | `footer` | Single footer config for the entire site |

**Frontend:** Consumed directly by the `Footer` layout component — not part of the dynamic zone.

---

## nav-link

**Schema:** [`cms/src/components/layout/nav-link.json`](../../cms/src/components/layout/nav-link.json)

**Purpose:** A navigation link entry with an optional external-link flag. Used for both header navigation and footer links.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `label` | string | Yes | — | Link display text |
| `href` | string | Yes | — | Destination URL or path |
| `icon` | string | No | — | Optional icon identifier |
| `isExternal` | boolean | No | `false` | When `true`, renders with `target="_blank" rel="noopener noreferrer"` |

**Used by:**

| Parent | Field | Context |
|--------|-------|---------|
| `global` | `navigation` (repeatable) | Main site navigation links |
| `layout.footer-config` | `links` (repeatable) | Footer navigation links |

**Frontend:** Consumed directly by `Header` and `Footer` layout components.
