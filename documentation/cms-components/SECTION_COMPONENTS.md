# Section Components

**Namespace:** `sections` · **Source:** [`cms/src/components/sections/`](../../cms/src/components/sections/)
**Frontend renderers:** [`lib/cms/components.tsx`](../../lib/cms/components.tsx)

Section components are the building blocks of the Dynamic Zone (`content` field) on page content types. Each section renders as a full-width page section. They are mapped to React renderer functions in `DynamicZone` via the `RENDERERS` registry.

← [Back to Component Index](COMPONENT_INDEX.md)

---

## hero

**Schema:** [`cms/src/components/sections/hero.json`](../../cms/src/components/sections/hero.json)
**Renderer:** `HeroRenderer` · **`__component`:** `sections.hero`

**Purpose:** Full-width page hero with gradient background, large heading, optional subheading, and up to two CTA buttons.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `heading` | string | Yes | — | Main hero heading (rendered as `<h1>`) |
| `subheading` | richtext | No | — | Supporting text below the heading |
| `primaryCTA` | `layout.cta-button` | No | — | Primary action button |
| `secondaryCTA` | `layout.cta-button` | No | — | Secondary action button |
| `backgroundImage` | media (image) | No | — | Optional background image (currently not rendered by `HeroRenderer`) |

**Used by:** `home-page` (content dynamic zone)

---

## featured-patterns

**Schema:** [`cms/src/components/sections/featured-patterns.json`](../../cms/src/components/sections/featured-patterns.json)
**Renderer:** `FeaturedPatternsRenderer` · **`__component`:** `sections.featured-patterns`

**Purpose:** Provides heading labels for the featured patterns section. Pattern data is **not** stored in the CMS — it is fetched from the REST API. The renderer emits a `<div data-cms-featured-patterns>` marker that the page server component uses to inject the heading into the `FeaturedPatterns` UI component.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `heading` | string | Yes | — | Section heading (e.g., "Featured Patterns") |
| `subheading` | string | No | — | Optional subtitle |
| `viewAllLabel` | string | No | `View all patterns` | Label for the "view all" link on desktop |
| `mobileViewAllLabel` | string | No | `View all` | Label for the "view all" link on mobile |

**Used by:** `home-page` (content dynamic zone)

---

## stats-bar

**Schema:** [`cms/src/components/sections/stats-bar.json`](../../cms/src/components/sections/stats-bar.json)
**Renderer:** `StatsBarRenderer` · **`__component`:** `sections.stats-bar`

**Purpose:** A responsive grid of statistic cards, each displaying a value and label. Renders nothing if `stats` is empty.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `stats` | repeatable `shared.stat-item` | No | — | List of statistics to display |

**Used by:** `home-page` (content dynamic zone)
**Child components:** [`shared.stat-item`](SHARED_COMPONENTS.md#stat-item)

---

## cta-banner

**Schema:** [`cms/src/components/sections/cta-banner.json`](../../cms/src/components/sections/cta-banner.json)
**Renderer:** `CtaBannerRenderer` · **`__component`:** `sections.cta-banner`

**Purpose:** Full-width call-to-action banner. The `highlighted` variant renders with a primary-color background and inverted text. External links are automatically opened in a new tab.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `heading` | string | Yes | — | Banner heading |
| `description` | richtext | No | — | Supporting description text |
| `primaryCTA` | `layout.cta-button` | No | — | Primary action button |
| `secondaryCTA` | `layout.cta-button` | No | — | Secondary action button |
| `variant` | enum | No | `default` | `default` (neutral background) or `highlighted` (primary-color background) |

**Used by:** `home-page` (content dynamic zone), `about-page` (content dynamic zone)
**Child components:** [`layout.cta-button`](LAYOUT_COMPONENTS.md#cta-button)

---

## rich-text

**Schema:** [`cms/src/components/sections/rich-text.json`](../../cms/src/components/sections/rich-text.json)
**Renderer:** `RichTextRenderer` · **`__component`:** `sections.rich-text`

**Purpose:** Free-form HTML rich text section with prose typography. Content is rendered via `dangerouslySetInnerHTML` — sanitization should be applied upstream in the CMS.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `body` | richtext | Yes | — | HTML content from the Strapi rich text editor |

**Used by:** `home-page`, `about-page`, `docs-page` (all content dynamic zones)

---

## page-header

**Schema:** [`cms/src/components/sections/page-header.json`](../../cms/src/components/sections/page-header.json)
**Renderer:** `PageHeaderRenderer` · **`__component`:** `sections.page-header`

**Purpose:** Centered page title with optional badge chip and subtitle. Used as a fixed `header` field on content types (not in the dynamic zone itself), so it always appears at the top of the page before the dynamic zone blocks.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `badge` | string | No | — | Small badge/chip above the title (e.g., "About Us") |
| `title` | string | Yes | — | Page title (rendered as `<h1>`) |
| `subtitle` | richtext | No | — | Supporting subtitle below the title |

**Used by:** `about-page` (header field), `docs-page` (header field)

---

## mission-block

**Schema:** [`cms/src/components/sections/mission-block.json`](../../cms/src/components/sections/mission-block.json)
**Renderer:** `MissionBlockRenderer` · **`__component`:** `sections.mission-block`

**Purpose:** A boxed card displaying a mission/vision statement. Paragraphs in `content` are split on `\n\n` and rendered as separate `<p>` elements.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `title` | string | Yes | — | Section title |
| `content` | richtext | Yes | — | Mission statement body (multi-paragraph) |

**Used by:** `about-page` (content dynamic zone)

---

## feature-grid

**Schema:** [`cms/src/components/sections/feature-grid.json`](../../cms/src/components/sections/feature-grid.json)
**Renderer:** `FeatureGridRenderer` · **`__component`:** `sections.feature-grid`

**Purpose:** Responsive grid of feature cards with configurable column count (2, 3, or 4). Each card can include an icon, title, description, and optional bullet list.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `heading` | string | Yes | — | Section heading |
| `columns` | enum | No | `3` | Grid columns: `2`, `3`, or `4` |
| `features` | repeatable `shared.feature-card` | No | — | List of feature cards |

**Used by:** `about-page` (content dynamic zone)
**Child components:** [`shared.feature-card`](SHARED_COMPONENTS.md#feature-card)

---

## tech-stack

**Schema:** [`cms/src/components/sections/tech-stack.json`](../../cms/src/components/sections/tech-stack.json)
**Renderer:** `TechStackRenderer` · **`__component`:** `sections.tech-stack`

**Purpose:** Two-column grid of technology groups. Each group has a title and a bulleted list of technology names.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `heading` | string | Yes | — | Section heading |
| `groups` | repeatable `shared.tech-group` | No | — | List of technology groups |

**Used by:** `about-page` (content dynamic zone)
**Child components:** [`shared.tech-group`](SHARED_COMPONENTS.md#tech-group)

---

## open-source-info

**Schema:** [`cms/src/components/sections/open-source-info.json`](../../cms/src/components/sections/open-source-info.json)
**Renderer:** `OpenSourceInfoRenderer` · **`__component`:** `sections.open-source-info`

**Purpose:** Centered card for open source project information, with a title, description, and a row of CTA link buttons. External links automatically open in a new tab.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `title` | string | Yes | — | Section title |
| `description` | richtext | No | — | Supporting description |
| `links` | repeatable `layout.cta-button` | No | — | CTA link buttons (e.g., GitHub, npm) |

**Used by:** `about-page` (content dynamic zone)
**Child components:** [`layout.cta-button`](LAYOUT_COMPONENTS.md#cta-button)

---

## quick-nav

**Schema:** [`cms/src/components/sections/quick-nav.json`](../../cms/src/components/sections/quick-nav.json)
**Renderer:** `QuickNavRenderer` · **`__component`:** `sections.quick-nav`

**Purpose:** A 3-column grid of navigable cards linking to different sections of a page. Typically used as a table of contents on the docs page.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `heading` | string | Yes | — | Section heading |
| `items` | repeatable `shared.quick-nav-item` | No | — | Navigation card entries |

**Used by:** `docs-page` (content dynamic zone)
**Child components:** [`shared.quick-nav-item`](SHARED_COMPONENTS.md#quick-nav-item)

---

## doc-section

**Schema:** [`cms/src/components/sections/doc-section.json`](../../cms/src/components/sections/doc-section.json)
**Renderer:** `DocSectionRenderer` · **`__component`:** `sections.doc-section`

**Purpose:** An anchor-linked documentation section with a heading and HTML body. `anchorId` is applied as the `id` attribute on the `<section>` element, enabling deep-linking from `quick-nav` items.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `anchorId` | string | Yes | — | HTML anchor ID for deep-linking (e.g., `getting-started`) |
| `title` | string | Yes | — | Section heading |
| `content` | richtext | Yes | — | Section body (HTML from rich text editor) |

**Used by:** `docs-page` (content dynamic zone)

---

## api-reference

**Schema:** [`cms/src/components/sections/api-reference.json`](../../cms/src/components/sections/api-reference.json)
**Renderer:** `ApiReferenceRenderer` · **`__component`:** `sections.api-reference`

**Purpose:** An API endpoint table rendered from CMS data. Includes title, description, base URL, and a list of `shared.api-endpoint` rows. Optional fields for a code example and a Swagger note.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `title` | string | Yes | — | Section heading |
| `description` | text | No | — | Section description |
| `baseUrl` | string | No | — | API base URL displayed above the table |
| `endpoints` | repeatable `shared.api-endpoint` | No | — | Endpoint rows |
| `exampleCode` | richtext | No | — | Code example block |
| `swaggerNote` | richtext | No | — | Note about Swagger availability |

**Used by:** `docs-page` (content dynamic zone)
**Child components:** [`shared.api-endpoint`](SHARED_COMPONENTS.md#api-endpoint)

---

## contributing

**Schema:** [`cms/src/components/sections/contributing.json`](../../cms/src/components/sections/contributing.json)
**Renderer:** `ContributingRenderer` · **`__component`:** `sections.contributing`

**Purpose:** Contributing guide section with an optional "how to contribute" steps block (rich text), a bulleted guidelines list, and a single CTA button.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `title` | string | Yes | — | Section heading |
| `description` | text | No | — | Section description |
| `howToTitle` | string | No | — | Sub-heading for the "how to contribute" steps |
| `steps` | richtext | No | — | Step-by-step instructions (HTML) |
| `guidelinesTitle` | string | No | — | Sub-heading for the guidelines list |
| `guidelines` | repeatable `shared.text-item` | No | — | List of guideline strings |
| `ctaButton` | `layout.cta-button` | No | — | CTA button at the bottom (e.g., "Open an issue") |

**Used by:** `docs-page` (content dynamic zone)
**Child components:** [`shared.text-item`](SHARED_COMPONENTS.md#text-item), [`layout.cta-button`](LAYOUT_COMPONENTS.md#cta-button)

---

## support-links

**Schema:** [`cms/src/components/sections/support-links.json`](../../cms/src/components/sections/support-links.json)
**Renderer:** `SupportLinksRenderer` · **`__component`:** `sections.support-links`

**Purpose:** A 2-column grid of support/resource links. Each item links to an external resource (GitHub Issues, Discussions, etc.). External links automatically open in a new tab.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `title` | string | Yes | — | Section heading |
| `description` | text | No | — | Section description |
| `items` | repeatable `shared.support-item` | No | — | Support link entries |

**Used by:** `docs-page` (content dynamic zone)
**Child components:** [`shared.support-item`](SHARED_COMPONENTS.md#support-item)
