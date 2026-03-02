# SEO Components

**Namespace:** `seo` · **Source:** [`cms/src/components/seo/`](../../cms/src/components/seo/)

← [Back to Component Index](COMPONENT_INDEX.md)

---

## metadata

**Schema:** [`cms/src/components/seo/metadata.json`](../../cms/src/components/seo/metadata.json)

**Purpose:** Page-level SEO metadata. Used as an embedded component on each page content type. `global` also has a `defaultSeo` field that provides fallback values when a page-level `seo` field is absent or empty.

> **Note on `ogImage`:** The `ogImage` field is a Strapi Media field. When populating this component via the REST API, use explicit field selection (`populate[seo][fields][0]=title` etc.) rather than wildcard `populate[seo]=*` — wildcard populate fails with HTTP 400 on components that contain Media relation fields.

**Fields:**

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `title` | string | No | — | Page `<title>` tag override. Falls back to `global.defaultSeo.title` |
| `description` | text | No | — | `<meta name="description">` content |
| `keywords` | text | No | — | `<meta name="keywords">` content |
| `ogImage` | media (image) | No | — | Open Graph image for social sharing previews |
| `ogTitle` | string | No | — | Open Graph title override (defaults to `title` if omitted) |
| `ogDescription` | text | No | — | Open Graph description override |
| `noIndex` | boolean | No | `false` | When `true`, adds `<meta name="robots" content="noindex">` |

**Used by:**

| Content Type | Field | Context |
|-------------|-------|---------|
| `home-page` | `seo` | Home page SEO |
| `about-page` | `seo` | About page SEO |
| `docs-page` | `seo` | Documentation page SEO |
| `login-page` | `seo` | Login page SEO |
| `global` | `defaultSeo` | Site-wide fallback SEO metadata |

**Frontend:** Consumed directly by page Server Components when building Next.js `generateMetadata()` exports — not part of the Dynamic Zone.
