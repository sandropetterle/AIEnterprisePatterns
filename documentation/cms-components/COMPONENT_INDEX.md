# CMS Component Index

**Source:** `cms/src/components/` · **Frontend renderers:** [`lib/cms/components.tsx`](../../lib/cms/components.tsx)

> **Reuse-first decision guide — check this before creating a new component:**
> 1. Does an existing component already handle this? (see table below)
> 2. Can an existing component be extended with an optional field instead of creating a new one?
> 3. If neither works, create a new component in the appropriate namespace and update this index.

---

## Namespace pages

| Namespace | Count | File |
|-----------|-------|------|
| `layout` | 3 | [LAYOUT_COMPONENTS.md](LAYOUT_COMPONENTS.md) |
| `sections` | 15 | [SECTION_COMPONENTS.md](SECTION_COMPONENTS.md) |
| `shared` | 8 | [SHARED_COMPONENTS.md](SHARED_COMPONENTS.md) |
| `seo` | 1 | [SEO_COMPONENTS.md](SEO_COMPONENTS.md) |

---

## Full catalog

### Layout components

| Component | Purpose | Used By |
|-----------|---------|---------|
| [`cta-button`](LAYOUT_COMPONENTS.md#cta-button) | Call-to-action link with variant styling (primary/secondary/outline/ghost) | `sections.hero` (primaryCTA, secondaryCTA), `sections.cta-banner` (primaryCTA, secondaryCTA), `sections.open-source-info` (links), `sections.contributing` (ctaButton), `not-found-page` (backButton) |
| [`footer-config`](LAYOUT_COMPONENTS.md#footer-config) | Footer copyright text + nav links | `global` (footer) |
| [`nav-link`](LAYOUT_COMPONENTS.md#nav-link) | Navigation link with optional external-link flag | `global` (navigation), `layout.footer-config` (links) |

### Section components (Dynamic Zone blocks)

| Component | Purpose | Used By |
|-----------|---------|---------|
| [`hero`](SECTION_COMPONENTS.md#hero) | Full-width page hero with heading, subheading, and up to two CTAs | `home-page` (content) |
| [`featured-patterns`](SECTION_COMPONENTS.md#featured-patterns) | Labels/heading for the featured patterns section — pattern data comes from the API, not CMS | `home-page` (content) |
| [`stats-bar`](SECTION_COMPONENTS.md#stats-bar) | Grid of stat cards (value + label) | `home-page` (content) |
| [`cta-banner`](SECTION_COMPONENTS.md#cta-banner) | Full-width call-to-action banner with optional highlighted variant | `home-page` (content), `about-page` (content) |
| [`rich-text`](SECTION_COMPONENTS.md#rich-text) | Free-form HTML rich text section | `home-page` (content), `about-page` (content), `docs-page` (content) |
| [`page-header`](SECTION_COMPONENTS.md#page-header) | Centered page title/subtitle with optional badge; used as fixed header field (not in dynamic zone) | `about-page` (header), `docs-page` (header) |
| [`mission-block`](SECTION_COMPONENTS.md#mission-block) | Boxed mission statement with title and multi-paragraph content | `about-page` (content) |
| [`feature-grid`](SECTION_COMPONENTS.md#feature-grid) | Responsive grid of feature cards with configurable column count | `about-page` (content) |
| [`tech-stack`](SECTION_COMPONENTS.md#tech-stack) | Two-column grid of technology groups, each with a bulleted list | `about-page` (content) |
| [`open-source-info`](SECTION_COMPONENTS.md#open-source-info) | Open source section with title, description, and multiple CTA links | `about-page` (content) |
| [`quick-nav`](SECTION_COMPONENTS.md#quick-nav) | 3-column grid of navigation cards for docs page TOC | `docs-page` (content) |
| [`doc-section`](SECTION_COMPONENTS.md#doc-section) | Anchor-linked documentation section with title + HTML body | `docs-page` (content) |
| [`api-reference`](SECTION_COMPONENTS.md#api-reference) | Interactive API endpoint table with optional code example and Swagger note | `docs-page` (content) |
| [`contributing`](SECTION_COMPONENTS.md#contributing) | Contributing guide with steps (rich text), guidelines list, and a CTA button | `docs-page` (content) |
| [`support-links`](SECTION_COMPONENTS.md#support-links) | Grid of support/resource links (title + description) | `docs-page` (content) |

### Shared components (embedded within sections)

| Component | Purpose | Used By |
|-----------|---------|---------|
| [`stat-item`](SHARED_COMPONENTS.md#stat-item) | A single statistic: value + label + optional icon | `sections.stats-bar` (stats) |
| [`feature-card`](SHARED_COMPONENTS.md#feature-card) | Feature card with icon, title, description, and optional bullet list | `sections.feature-grid` (features) |
| [`tech-group`](SHARED_COMPONENTS.md#tech-group) | Titled group of technology names (text-item list) | `sections.tech-stack` (groups) |
| [`quick-nav-item`](SHARED_COMPONENTS.md#quick-nav-item) | A navigable card: title, description, href, optional icon | `sections.quick-nav` (items) |
| [`support-item`](SHARED_COMPONENTS.md#support-item) | A support resource link: title, description, href, optional icon | `sections.support-links` (items) |
| [`text-item`](SHARED_COMPONENTS.md#text-item) | A single text string for repeatable lists | `shared.feature-card` (items), `shared.tech-group` (items), `sections.contributing` (guidelines) |
| [`key-value`](SHARED_COMPONENTS.md#key-value) | A key-value pair for metadata and configuration | `shared.api-endpoint` (queryParams) |
| [`api-endpoint`](SHARED_COMPONENTS.md#api-endpoint) | API endpoint row: method, path, description, auth flag, rate limit, query params | `sections.api-reference` (endpoints) |

### SEO component

| Component | Purpose | Used By |
|-----------|---------|---------|
| [`metadata`](SEO_COMPONENTS.md#metadata) | Page SEO metadata: title, description, OG tags, noIndex | `home-page` (seo), `about-page` (seo), `docs-page` (seo), `login-page` (seo), `global` (defaultSeo) |
