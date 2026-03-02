# Shared Components

**Namespace:** `shared` · **Source:** [`cms/src/components/shared/`](../../cms/src/components/shared/)

Shared components are reusable primitives embedded within section components. They are never used as top-level Dynamic Zone blocks — they always appear inside a repeatable field on a parent section or another shared component.

← [Back to Component Index](COMPONENT_INDEX.md)

---

## stat-item

**Schema:** [`cms/src/components/shared/stat-item.json`](../../cms/src/components/shared/stat-item.json)

**Purpose:** A single statistic displayed as a value + label pair inside a card. Used as a repeatable list in `sections.stats-bar`.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `value` | string | Yes | — | Statistic value (e.g., `"50+"`, `"99%"`) |
| `label` | string | Yes | — | Description of the statistic (e.g., `"Patterns"`) |
| `icon` | string | No | — | Optional icon identifier (not yet rendered by `StatsBarRenderer`) |

**Used by:** [`sections.stats-bar`](SECTION_COMPONENTS.md#stats-bar) (`stats` field)

---

## feature-card

**Schema:** [`cms/src/components/shared/feature-card.json`](../../cms/src/components/shared/feature-card.json)

**Purpose:** A feature card with an icon, title, description, and optional bulleted item list. Used as a repeatable list in `sections.feature-grid`. The `items` list renders as a `•`-prefixed bullet list below the description.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `icon` | string | Yes | — | Icon identifier (e.g., emoji or icon name) |
| `title` | string | Yes | — | Card title |
| `description` | string | Yes | — | Short description |
| `items` | repeatable `shared.text-item` | No | — | Optional bullet list of sub-items |

**Used by:** [`sections.feature-grid`](SECTION_COMPONENTS.md#feature-grid) (`features` field)
**Child components:** [`shared.text-item`](#text-item)

---

## tech-group

**Schema:** [`cms/src/components/shared/tech-group.json`](../../cms/src/components/shared/tech-group.json)

**Purpose:** A named group of technology names. Renders as a bordered card with a title and a bulleted list of `text-item` entries. Used as a repeatable list in `sections.tech-stack`.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `title` | string | Yes | — | Group title (e.g., `"Frontend"`, `"Backend"`) |
| `items` | repeatable `shared.text-item` | No | — | List of technology names |

**Used by:** [`sections.tech-stack`](SECTION_COMPONENTS.md#tech-stack) (`groups` field)
**Child components:** [`shared.text-item`](#text-item)

---

## quick-nav-item

**Schema:** [`cms/src/components/shared/quick-nav-item.json`](../../cms/src/components/shared/quick-nav-item.json)

**Purpose:** A single navigable card entry with title, description, and a link. Clicking the card navigates to `href`. Used as a repeatable list in `sections.quick-nav` to create a docs page table of contents.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `title` | string | Yes | — | Card title |
| `description` | string | Yes | — | Short description of the destination |
| `href` | string | Yes | — | Destination URL or anchor (e.g., `#getting-started`) |
| `icon` | string | No | — | Optional icon identifier (not yet rendered by `QuickNavRenderer`) |

**Used by:** [`sections.quick-nav`](SECTION_COMPONENTS.md#quick-nav) (`items` field)

---

## support-item

**Schema:** [`cms/src/components/shared/support-item.json`](../../cms/src/components/shared/support-item.json)

**Purpose:** A support resource link card with title, description, and href. External links automatically open in a new tab. Used as a repeatable list in `sections.support-links`.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `title` | string | Yes | — | Resource title |
| `description` | string | Yes | — | Short description of the resource |
| `href` | string | Yes | — | Link URL |
| `icon` | string | No | — | Optional icon identifier (not yet rendered by `SupportLinksRenderer`) |

**Used by:** [`sections.support-links`](SECTION_COMPONENTS.md#support-links) (`items` field)

---

## text-item

**Schema:** [`cms/src/components/shared/text-item.json`](../../cms/src/components/shared/text-item.json)

**Purpose:** The simplest shared component — a single text string for repeatable lists. Reused in three places: feature card sub-items, tech group entries, and contributing guidelines. Before creating a new single-field component, check if `text-item` already serves the purpose.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `text` | string | Yes | — | The text string |

**Used by:**
- [`shared.feature-card`](SHARED_COMPONENTS.md#feature-card) (`items` — bullet list in feature cards)
- [`shared.tech-group`](SHARED_COMPONENTS.md#tech-group) (`items` — technology names)
- [`sections.contributing`](SECTION_COMPONENTS.md#contributing) (`guidelines` — contributing guidelines)

---

## key-value

**Schema:** [`cms/src/components/shared/key-value.json`](../../cms/src/components/shared/key-value.json)

**Purpose:** A key-value pair for structured metadata. Currently used only for API endpoint query parameter documentation.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | string | Yes | — | Parameter name or metadata key |
| `value` | string | Yes | — | Parameter value or description |

**Used by:** [`shared.api-endpoint`](#api-endpoint) (`queryParams` field)

---

## api-endpoint

**Schema:** [`cms/src/components/shared/api-endpoint.json`](../../cms/src/components/shared/api-endpoint.json)

**Purpose:** A single API endpoint row for use in an `sections.api-reference` table. Captures the HTTP method, path, description, auth requirement, optional rate limit, and an optional list of query parameters.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `method` | enum | Yes | `GET` | HTTP method: `GET`, `POST`, `PUT`, `DELETE` |
| `path` | string | Yes | — | Endpoint path (e.g., `/api/patterns/{slug}`) |
| `description` | string | Yes | — | Short description of what the endpoint does |
| `authRequired` | boolean | No | `false` | Whether authentication is required |
| `rateLimit` | string | No | — | Rate limit description (e.g., `api (50/min)`) |
| `queryParams` | repeatable `shared.key-value` | No | — | Query parameter documentation |

**Used by:** [`sections.api-reference`](SECTION_COMPONENTS.md#api-reference) (`endpoints` field)
**Child components:** [`shared.key-value`](#key-value)
