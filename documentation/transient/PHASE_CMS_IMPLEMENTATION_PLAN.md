# Phase CMS — Strapi 5 Headless CMS Integration

**Priority:** HIGH (parallel to Phase 6)
**Dependencies:** Phase 5.4 complete (current state)
**Estimated Duration:** 4–5 sessions
**Date Created:** 2026-02-20

---

## Context

The frontend currently has **300+ hardcoded static content items** across 28 components and 10 pages (headings, descriptions, CTAs, form labels, meta tags, navigation, error messages, etc.). Moving this content to a headless CMS enables:
- Non-developer content editing without code deployments
- A/B testing of copy, CTAs, and page layouts
- Content versioning and draft/publish workflows
- Centralized content governance
- Future i18n readiness (Phase 8.1)

The SRS already references Strapi CMS integration (Phase 3.2, Section 4.4). This plan implements it as a parallel phase using Strapi 5.

---

## Sub-Phase CMS.1 — Content Model Design

### Component Categories (organized in `src/api/` and `src/components/`)

#### `seo/` — SEO Metadata
| Component | Fields | Notes |
|-----------|--------|-------|
| `metadata` | title (string), description (text), keywords (text), ogImage (media), ogTitle (string), ogDescription (text), noIndex (boolean) | Reused on every page Single Type |

#### `layout/` — Global Layout Primitives
| Component | Fields | Notes |
|-----------|--------|-------|
| `nav-link` | label (string), href (string), icon (string), isExternal (boolean) | Used in navigation + footer |
| `cta-button` | label (string), href (string), variant (enum: primary\|secondary\|outline\|ghost), icon (string) | Universal CTA |
| `footer-config` | copyrightTemplate (string, e.g. "© {year} AI Enterprise Patterns. All rights reserved."), links (repeatable nav-link) | Single instance in Global |

#### `sections/` — Dynamic Zone Blocks (Page Builder)
| Component | Fields | Notes |
|-----------|--------|-------|
| `hero` | heading (string), subheading (richtext), primaryCTA (cta-button), secondaryCTA (cta-button), backgroundImage (media) | Home page hero |
| `cta-banner` | heading (string), description (richtext), primaryCTA (cta-button), secondaryCTA (cta-button), variant (enum: default\|highlighted) | Reusable call-to-action strip |
| `stats-bar` | stats (repeatable `stat-item`: value string, label string, icon string) | Home page stats |
| `featured-patterns` | heading (string), subheading (string), viewAllLabel (string), mobileViewAllLabel (string) | Dynamic — patterns fetched from API |
| `rich-text` | body (richtext) | Generic markdown/rich-text block |
| `feature-grid` | heading (string), columns (enum: 2\|3\|4), features (repeatable `feature-card`: icon string, title string, description string, items repeatable text-item) | About page "What We Offer" |
| `tech-stack` | heading (string), groups (repeatable `tech-group`: title string, items repeatable text-item) | About page tech stack |
| `mission-block` | title (string), content (richtext) | About page mission |
| `open-source-info` | title (string), description (richtext), links (repeatable cta-button) | About page open source CTA |
| `page-header` | badge (string), title (string), subtitle (richtext) | Reusable page header with badge |
| `doc-section` | anchorId (string), title (string), content (richtext) | Docs page sections |
| `api-reference` | title (string), description (text), baseUrl (string), endpoints (repeatable `api-endpoint`: method enum GET\|POST\|PUT\|DELETE, path string, description string, authRequired boolean, rateLimit string, queryParams repeatable key-value), exampleCode (richtext), swaggerNote (richtext) | Docs API reference |
| `quick-nav` | heading (string), items (repeatable `quick-nav-item`: title string, description string, href string, icon string) | Docs quick navigation |
| `contributing` | title (string), description (text), howToTitle (string), steps (richtext), guidelinesTitle (string), guidelines (repeatable text-item), ctaButton (cta-button) | Docs contributing section |
| `support-links` | title (string), description (text), items (repeatable `support-item`: title string, description string, href string, icon string) | Docs support section |

#### `shared/` — Atomic Helpers
| Component | Fields |
|-----------|--------|
| `text-item` | text (string) |
| `stat-item` | value (string), label (string), icon (string) |
| `feature-card` | icon (string), title (string), description (string), items (repeatable text-item) |
| `tech-group` | title (string), items (repeatable text-item) |
| `api-endpoint` | method (enum: GET\|POST\|PUT\|DELETE), path (string), description (string), authRequired (boolean), rateLimit (string), queryParams (repeatable key-value) |
| `key-value` | key (string), value (string) |
| `quick-nav-item` | title (string), description (string), href (string), icon (string) |
| `support-item` | title (string), description (string), href (string), icon (string) |

### Single Types (Pages)

#### 1. `global` — Site-Wide Settings
```
siteName: string
siteDescription: text
logo: media
navigation: repeatable(layout.nav-link)       -> Header nav: Home, Patterns, About
mobileMenuTitle: string                        -> "Menu"
skipToContentLabel: string                     -> "Skip to main content"
signInLabel: string                            -> "Sign In"
signOutLabel: string                           -> "Sign Out"
userMenuLabel: string                          -> "User menu"
newPatternButtonLabel: string                  -> "+ New Pattern"
footer: component(layout.footer-config)
defaultSeo: component(seo.metadata)
```

#### 2. `home-page`
```
seo: component(seo.metadata)
content: dynamiczone[
  sections.hero,
  sections.featured-patterns,
  sections.stats-bar,
  sections.cta-banner,
  sections.rich-text
]
```
Default composition: Hero -> Stats Bar -> Featured Patterns -> CTA Banner

#### 3. `about-page`
```
seo: component(seo.metadata)
header: component(sections.page-header)
content: dynamiczone[
  sections.mission-block,
  sections.feature-grid,
  sections.tech-stack,
  sections.open-source-info,
  sections.cta-banner,
  sections.rich-text
]
```

#### 4. `docs-page`
```
seo: component(seo.metadata)
header: component(sections.page-header)
content: dynamiczone[
  sections.quick-nav,
  sections.doc-section,
  sections.api-reference,
  sections.contributing,
  sections.support-links,
  sections.rich-text
]
```

#### 5. `login-page`
```
seo: component(seo.metadata)
cardTitle: string                              -> "Sign in"
cardDescription: string                        -> "Access the AI Enterprise Patterns Library"
signInButtonLabel: string                      -> "Continue with Microsoft"
signInLoadingLabel: string                     -> "Redirecting..."
footerNotice: richtext                         -> Security notice text
errorMessages: JSON                            -> { OAuthSignin: "...", ... }
```

#### 6. `not-found-page`
```
errorCode: string                              -> "404"
heading: string                                -> "Page Not Found"
message: text                                  -> "The page you are looking for..."
backButton: component(layout.cta-button)
```

#### 7. `error-page`
```
title: string                                  -> "Something went wrong"
description: text                              -> "We encountered an error..."
retryButtonLabel: string                       -> "Try again"
homeButtonLabel: string                        -> "Go home"
```

#### 8. `pattern-listing-labels` — All Browse Patterns UI Strings
```
pageTitle: string                              -> "Browse Patterns"
pageDescription: text                          -> "Discover {count} {pattern|patterns}..."
searchPlaceholder: string                      -> "Search patterns..."
clearSearchLabel: string                       -> "Clear search"
sortByLabel: string                            -> "Sort by:"
sortOptions: JSON                              -> [{ value: "newest", label: "Most Recent" }, ...]
filterSectionHeader: string                    -> "Filters"
clearAllLabel: string                          -> "Clear all"
categoryLabel: string                          -> "Category"
allCategoriesLabel: string                     -> "All Categories"
tagsLabel: string                              -> "Tags"
tagModeLabel: string                           -> "Match:"
anyLabel: string                               -> "Any"
allLabel: string                               -> "All"
dateRangeHeader: string                        -> "Date Range"
clearDatesLabel: string                        -> "Clear dates"
fromLabel: string                              -> "From"
toLabel: string                                -> "To"
activeFiltersLabel: string                     -> "Active Filters"
filtersButtonLabel: string                     -> "Filters"
filterSheetTitle: string                       -> "Filter Patterns"
filterSheetDescription: string                 -> "Refine your search by category and tags"
savedSearchesHeader: string                    -> "Saved Searches"
saveCurrentLabel: string                       -> "Save current"
saveDialogTitle: string                        -> "Save Search"
saveDialogDescription: string                  -> "Give this search a name..."
searchNameLabel: string                        -> "Search name"
searchNamePlaceholder: string                  -> "e.g. Architecture with CQRS"
cancelLabel: string                            -> "Cancel"
saveLabel: string                              -> "Save"
recentlyViewedHeader: string                   -> "Recently Viewed"
clearLabel: string                             -> "Clear"
previousLabel: string                          -> "Previous"
nextLabel: string                              -> "Next"
emptyFilteredHeading: string                   -> "No patterns found"
emptyUnfilteredHeading: string                 -> "No patterns available"
emptyFilteredDescription: string               -> "Try adjusting your filters..."
emptyUnfilteredDescription: string             -> "There are no patterns..."
clearFiltersLabel: string                      -> "Clear all filters"
```

#### 9. `pattern-detail-labels` — Pattern Detail Page UI Strings
```
breadcrumbAriaLabel: string                    -> "Breadcrumb"
voteAriaTemplate: string                       -> "Vote for this pattern. {count} votes"
votesLabel: string                             -> "votes"
voteAnnouncementTemplate: string               -> "Voted! {count} total votes"
noContentMessage: string                       -> "No content available for this pattern."
relatedPatternsTitle: string                   -> "Related Patterns"
noRelatedMessage: string                       -> "No related patterns found"
editLabel: string                              -> "Edit"
deleteLabel: string                            -> "Delete"
deleteDialogTitle: string                      -> "Delete Pattern?"
deleteDialogDescription: string                -> "This action cannot be undone..."
cancelLabel: string                            -> "Cancel"
deleteConfirmLabel: string                     -> "Delete"
deletingLabel: string                          -> "Deleting..."
```

#### 10. `pattern-form-labels` — Create/Edit Form UI Strings
```
createTitle: string                            -> "New Pattern"
editTitle: string                              -> "Edit Pattern"
titleLabel: string                             -> "Title *"
titlePlaceholder: string                       -> "e.g. CQRS Pattern for..."
slugPreviewTemplate: string                    -> "Slug preview: {slug}"
shortDescLabel: string                         -> "Short Description *"
shortDescPlaceholder: string                   -> "A brief summary..."
categoryLabel: string                          -> "Category *"
categoryPlaceholder: string                    -> "Select a category"
tagsLabel: string                              -> "Tags"
tagPlaceholder: string                         -> "Add a tag and press Enter"
addTagLabel: string                            -> "Add"
tagCountTemplate: string                       -> "{count}/{max} tags"
contentLabel: string                           -> "Full Content (Markdown)"
contentPlaceholder: string                     -> "Write the full pattern content..."
authorLabel: string                            -> "Author"
authorPlaceholder: string                      -> "Your name (optional)"
adminSettingsLabel: string                     -> "Admin Settings"
featuredLabel: string                          -> "Featured pattern"
trendingLabel: string                          -> "Trending pattern"
cancelLabel: string                            -> "Cancel"
createLabel: string                            -> "Create Pattern"
creatingLabel: string                          -> "Creating..."
saveLabel: string                              -> "Save Changes"
savingLabel: string                            -> "Saving..."
```

### Relationships Diagram

```
                    +-------------------+
                    |   global          | (Single Type)
                    |                   |
                    | navigation ------>| repeatable layout.nav-link
                    | footer ---------->| layout.footer-config
                    |                   |   +-> repeatable layout.nav-link
                    | defaultSeo ------>| seo.metadata
                    +-------------------+

     +----------+  +----------+  +----------+
     |home-page |  |about-page|  |docs-page |  ... (all page Single Types)
     |          |  |          |  |          |
     | seo ---> |  | seo ---> |  | seo ---> |  component(seo.metadata)
     |          |  | header -> |  | header -> |  component(sections.page-header)
     | content  |  | content  |  | content  |
     | (DZ) --->|  | (DZ) --->|  | (DZ) --->|  Dynamic Zone (page builder)
     +----------+  +----------+  +----------+
          |              |              |
          v              v              v
    +-------------------------------------+
    |         Dynamic Zone Blocks         |
    |  (each page picks from its pool)    |
    +-------------------------------------+
    | hero, cta-banner, stats-bar,        |
    | featured-patterns, rich-text,       |
    | feature-grid, tech-stack,           |
    | mission-block, open-source-info,    |
    | doc-section, api-reference,         |
    | quick-nav, contributing,            |
    | support-links, page-header          |
    +-------------------------------------+
          |
          v  (nested components)
    +-------------------------------------+
    |         Shared Components           |
    +-------------------------------------+
    | layout.cta-button                   |
    | layout.nav-link                     |
    | text-item                           |
    | stat-item, feature-card, tech-group |
    | api-endpoint, quick-nav-item, etc.  |
    +-------------------------------------+

    +---------------------------------------------+
    |         UI Label Single Types               |
    |  (flat string fields, no Dynamic Zones)     |
    +---------------------------------------------+
    | pattern-listing-labels                      |
    | pattern-detail-labels                       |
    | pattern-form-labels                         |
    +---------------------------------------------+
```

---

## Sub-Phase CMS.2 — Azure Infrastructure

### Architecture

```
+---------------+     +--------------------+     +-------------------+
| Next.js App   |---->|  Strapi 5 CMS      |---->| Azure MySQL       |
| (existing)    | REST|  Container App     |     | Flexible Server   |
|               | API |  (port 1337)       |     | (Free Tier)       |
+---------------+     +--------------------+     +-------------------+
                             |
                             v
                      +--------------------+
                      | Azure Blob         |
                      | Storage (media)    |
                      +--------------------+
```

### Resources & Cost Estimate

| Resource | SKU / Tier | Monthly Cost |
|----------|-----------|-------------|
| Azure Database for MySQL Flexible Server | Burstable B1ms (1 vCore, 2 GiB RAM, 32 GB storage) | **$0** (free 12 months) |
| Azure Container App (Strapi) | 0.25 vCPU, 0.5 GiB RAM, scale-to-zero | **~$5-10** |
| Azure Blob Storage (media) | Hot tier, ~1 GB | **~$0.02** |
| Azure Container Registry | Basic tier (for Strapi image) | **~$5** |
| **Total** | | **~$10-15/month** |

After free-tier MySQL expires: Burstable B1ms = ~$13/month -> total ~$23-28/month.

### MySQL Free Tier Details
- **Compute:** Burstable B1ms (1 vCore, 2 GiB memory)
- **Storage:** 32 GiB included
- **Backup:** 32 GiB backup storage
- **Duration:** 12 months from creation
- **Limitations:** Single server, no high availability, no read replicas
- **Sufficient for:** Strapi CMS with low-medium traffic (content rarely changes)

### Provisioning Steps (IaC / CLI)

1. Create MySQL Flexible Server (free tier)
2. Create database `strapi_cms`
3. Create Azure Blob Storage account + container `strapi-media`
4. Create Container App for Strapi with env vars
5. Configure networking: Strapi Container App -> MySQL (private VNet or public with firewall rules)
6. Strapi admin panel accessible via Strapi Container App URL

### Environment Variables for Strapi Container App

```bash
DATABASE_CLIENT=mysql2
DATABASE_HOST=<mysql-server>.mysql.database.azure.com
DATABASE_PORT=3306
DATABASE_NAME=strapi_cms
DATABASE_USERNAME=strapi_admin
DATABASE_PASSWORD=<from-key-vault>
DATABASE_SSL=true
STRAPI_ADMIN_JWT_SECRET=<from-key-vault>
APP_KEYS=<from-key-vault>
API_TOKEN_SALT=<from-key-vault>
ADMIN_JWT_SECRET=<from-key-vault>
TRANSFER_TOKEN_SALT=<from-key-vault>
JWT_SECRET=<from-key-vault>
# Azure Blob Storage (media uploads)
STORAGE_ACCOUNT=<storage-account-name>
STORAGE_ACCOUNT_KEY=<from-key-vault>
STORAGE_CONTAINER_NAME=strapi-media
STORAGE_URL=https://<storage-account-name>.blob.core.windows.net
```

### Deployment Artifacts to Create

- `cms/Dockerfile` — Strapi 5 production image (node:20-alpine, non-root user)
- `deployment/scripts/provision-cms.ps1` — Azure resource provisioning
- `.github/workflows/cms-container-deploy.yml` — CI/CD for Strapi
- Update `docker-compose.yml` — Add Strapi + MySQL services for local dev

---

## Sub-Phase CMS.3 — Strapi 5 Project Setup

### Directory Structure

```
cms/                              <-- NEW: Strapi 5 project root
|-- Dockerfile
|-- .dockerignore
|-- package.json
|-- tsconfig.json
|-- config/
|   |-- admin.ts
|   |-- api.ts
|   |-- database.ts               <-- MySQL config (dev: SQLite, prod: MySQL)
|   |-- middlewares.ts
|   |-- plugins.ts                <-- Azure Blob upload provider
|   +-- server.ts
|-- src/
|   |-- admin/
|   |   +-- app.tsx               <-- Admin panel customization
|   |-- api/                      <-- Single Types (auto-generated by Strapi)
|   |   |-- global/
|   |   |-- home-page/
|   |   |-- about-page/
|   |   |-- docs-page/
|   |   |-- login-page/
|   |   |-- not-found-page/
|   |   |-- error-page/
|   |   |-- pattern-listing-labels/
|   |   |-- pattern-detail-labels/
|   |   +-- pattern-form-labels/
|   +-- components/               <-- Reusable components
|       |-- seo/
|       |   +-- metadata.json
|       |-- layout/
|       |   |-- nav-link.json
|       |   |-- cta-button.json
|       |   +-- footer-config.json
|       |-- sections/
|       |   |-- hero.json
|       |   |-- cta-banner.json
|       |   |-- stats-bar.json
|       |   |-- featured-patterns.json
|       |   |-- rich-text.json
|       |   |-- feature-grid.json
|       |   |-- tech-stack.json
|       |   |-- mission-block.json
|       |   |-- open-source-info.json
|       |   |-- page-header.json
|       |   |-- doc-section.json
|       |   |-- api-reference.json
|       |   |-- quick-nav.json
|       |   |-- contributing.json
|       |   +-- support-links.json
|       +-- shared/
|           |-- text-item.json
|           |-- stat-item.json
|           |-- feature-card.json
|           |-- tech-group.json
|           |-- api-endpoint.json
|           |-- key-value.json
|           |-- quick-nav-item.json
|           +-- support-item.json
|-- data/
|   +-- seed.ts                   <-- Seed script with current hardcoded content
|-- types/
|   +-- generated/                <-- Auto-generated TypeScript types
+-- public/
    +-- uploads/                  <-- Local dev uploads (gitignored)
```

### Setup Steps

1. **Create Strapi 5 project:**
   ```bash
   npx create-strapi@latest cms --typescript --no-install
   cd cms && npm install
   ```

2. **Install plugins:**
   ```bash
   npm install @strapi/provider-upload-azure-storage mysql2
   ```

3. **Configure database** (`config/database.ts`):
   - Development: SQLite (zero-config local dev)
   - Production: MySQL via env vars

4. **Configure Azure Blob upload** (`config/plugins.ts`):
   ```ts
   export default ({ env }) => ({
     upload: {
       config: {
         provider: '@strapi/provider-upload-azure-storage',
         providerOptions: {
           account: env('STORAGE_ACCOUNT'),
           accountKey: env('STORAGE_ACCOUNT_KEY'),
           containerName: env('STORAGE_CONTAINER_NAME'),
           defaultPath: 'assets',
         },
       },
     },
   });
   ```

5. **Create all Single Types and Components** via Strapi Content-Type Builder UI or by writing schema JSON files directly (faster for bulk creation).

6. **Write seed script** (`data/seed.ts`):
   - Populate all Single Types with current hardcoded content values
   - This ensures zero content loss when switching from hardcoded to CMS

7. **Create Dockerfile** for production:
   ```dockerfile
   FROM node:20-alpine AS build
   WORKDIR /app
   COPY package*.json ./
   RUN npm ci
   COPY . .
   RUN npm run build

   FROM node:20-alpine
   WORKDIR /app
   RUN addgroup -S strapi && adduser -S strapi -G strapi
   COPY --from=build /app .
   USER strapi
   EXPOSE 1337
   CMD ["npm", "start"]
   ```

8. **Update `docker-compose.yml`** for local development:
   ```yaml
   services:
     # ... existing sqlserver service ...

     mysql:
       image: mysql:8.0
       container_name: aipatterns-mysql
       environment:
         MYSQL_ROOT_PASSWORD: strapiPassword123
         MYSQL_DATABASE: strapi_cms
         MYSQL_USER: strapi
         MYSQL_PASSWORD: strapiPassword123
       ports:
         - "3306:3306"
       volumes:
         - mysql-data:/var/lib/mysql

     strapi:
       build: ./cms
       container_name: aipatterns-strapi
       environment:
         DATABASE_CLIENT: mysql2
         DATABASE_HOST: mysql
         DATABASE_PORT: 3306
         DATABASE_NAME: strapi_cms
         DATABASE_USERNAME: strapi
         DATABASE_PASSWORD: strapiPassword123
       ports:
         - "1337:1337"
       volumes:
         - ./cms:/app
         - /app/node_modules
       depends_on:
         - mysql
   ```

### API Tokens

- Create a read-only API token in Strapi admin for the Next.js frontend
- Store token in `STRAPI_API_TOKEN` env var (Next.js server-side only -- not `NEXT_PUBLIC_`)

---

## Sub-Phase CMS.4 — Frontend Integration

### New Files

```
lib/cms/
|-- client.ts                     <-- Strapi REST API client
|-- types.ts                      <-- TypeScript types for Strapi responses
|-- queries.ts                    <-- Functions per Single Type (getHomePage, getGlobal, etc.)
|-- components.tsx                <-- Dynamic Zone renderer (maps __component -> React component)
+-- cache.ts                      <-- ISR/caching strategy helpers
```

### Strapi Client (`lib/cms/client.ts`)

```ts
const STRAPI_URL = process.env.STRAPI_URL || 'http://localhost:1337';
const STRAPI_TOKEN = process.env.STRAPI_API_TOKEN;

export async function fetchStrapi<T>(
  path: string,
  params?: Record<string, string>
): Promise<T> {
  const url = new URL(`/api${path}`, STRAPI_URL);
  if (params) Object.entries(params).forEach(([k, v]) => url.searchParams.set(k, v));

  const res = await fetch(url.toString(), {
    headers: { Authorization: `Bearer ${STRAPI_TOKEN}` },
    next: { revalidate: 300 }, // 5 min ISR
  });

  if (!res.ok) throw new Error(`Strapi ${res.status}: ${path}`);
  const json = await res.json();
  return json.data;
}
```

### Query Functions (`lib/cms/queries.ts`)

```ts
export async function getGlobal() {
  return fetchStrapi('/global', { populate: 'deep' });
}
export async function getHomePage() {
  return fetchStrapi('/home-page', { populate: 'deep' });
}
export async function getPatternListingLabels() {
  return fetchStrapi('/pattern-listing-labels');
}
// ... one function per Single Type
```

### Dynamic Zone Renderer (`lib/cms/components.tsx`)

Maps `__component` field from Strapi response to React components:

```tsx
const componentMap: Record<string, React.ComponentType<any>> = {
  'sections.hero': HeroSection,
  'sections.cta-banner': CTABanner,
  'sections.stats-bar': StatsBar,
  'sections.featured-patterns': FeaturedPatterns,
  'sections.rich-text': RichTextBlock,
  'sections.feature-grid': FeatureGrid,
  'sections.tech-stack': TechStackSection,
  'sections.mission-block': MissionBlock,
  // ... all Dynamic Zone components
};

export function DynamicZone({ content }: { content: DynamicZoneBlock[] }) {
  return content.map((block, i) => {
    const Component = componentMap[block.__component];
    if (!Component) return null;
    return <Component key={`${block.__component}-${i}`} {...block} />;
  });
}
```

### Integration Strategy (Incremental, Non-Breaking)

**Phase 1 — Server-side fetch with fallbacks:**
- Each page fetches CMS content at build time / ISR
- If Strapi is unreachable, fall back to hardcoded defaults
- This ensures zero downtime during migration

**Phase 2 — Replace hardcoded content:**
- One page/component at a time, replace hardcoded strings with CMS values
- Pass CMS data as props to client components (keeps them pure)

**Phase 3 — Remove fallbacks:**
- Once CMS is stable and seeded, remove hardcoded fallback content
- Keep a minimal emergency fallback for critical strings only (site name, nav)

### Files to Modify (Incremental)

| Priority | File | Change |
|----------|------|--------|
| 1 | `app/layout.tsx` | Fetch `global` for nav, footer, site metadata, skip-link |
| 2 | `app/page.tsx` | Fetch `home-page`, render Dynamic Zone |
| 3 | `components/home/Hero.tsx` | Accept CMS props instead of hardcoded strings |
| 3 | `components/home/StatsSection.tsx` | Accept CMS props |
| 3 | `components/home/FeaturedPatterns.tsx` | Accept CMS props (headings/labels from CMS, patterns from API) |
| 3 | `components/home/CTASection.tsx` | Accept CMS props |
| 4 | `app/about/page.tsx` | Fetch `about-page`, render Dynamic Zone |
| 5 | `app/docs/page.tsx` | Fetch `docs-page`, render Dynamic Zone |
| 6 | `app/login/LoginForm.tsx` | Fetch `login-page` labels server-side, pass as props |
| 7 | `app/not-found.tsx` | Fetch `not-found-page` |
| 8 | `app/error.tsx` | Fetch `error-page` (with try/catch -- can't fail on error page) |
| 9 | `app/patterns/page.tsx` | Fetch `pattern-listing-labels`, pass to child components |
| 9 | `components/patterns/SearchBar.tsx` | Accept labels as props |
| 9 | `components/patterns/FilterPanel.tsx` | Accept labels as props |
| 9 | `components/patterns/SortSelector.tsx` | Accept labels as props |
| 9 | `components/patterns/EmptyState.tsx` | Accept labels as props |
| 9 | `components/patterns/Pagination.tsx` | Accept labels as props |
| 10 | `app/patterns/[slug]/page.tsx` | Fetch `pattern-detail-labels`, pass to child components |
| 10 | `components/patterns/details/*.tsx` | Accept labels as props |
| 11 | `components/patterns/PatternForm.tsx` | Fetch `pattern-form-labels`, pass as props |
| 12 | `components/layout/Header.tsx` | Use global nav from CMS |
| 12 | `components/layout/Footer.tsx` | Use global footer from CMS |
| 12 | `components/layout/Navigation.tsx` | Use global nav from CMS |
| 12 | `components/layout/UserMenu.tsx` | Use global signIn/signOut labels |
| 12 | `components/shared/Logo.tsx` | Use global siteName |

### Caching Strategy

| Content Type | Revalidation | Rationale |
|-------------|-------------|-----------|
| `global` | 600s (10 min) | Rarely changes; nav/footer |
| Page Single Types (home, about, docs) | 300s (5 min) | Marketing content, infrequent edits |
| Label Single Types (listing, detail, form) | 3600s (1 hour) | UI labels almost never change |
| `login-page`, `error-page`, `not-found-page` | 3600s (1 hour) | Very static content |

### Environment Variables (Frontend additions)

```bash
# .env.local (add to existing)
STRAPI_URL=http://localhost:1337
STRAPI_API_TOKEN=<read-only-api-token>
```

Note: These are server-only (no `NEXT_PUBLIC_` prefix) -- Strapi data fetched in Server Components only.

### Test Strategy

- **Unit tests:** Mock `fetchStrapi` in query function tests
- **Component tests:** Pass CMS data as props -- no change to existing test patterns
- **Integration tests:** Test fallback behavior when Strapi is unavailable
- **E2E tests:** Strapi running in docker-compose for full pipeline

---

## Implementation Order

| Step | Sub-Phase | What | Deliverables |
|------|-----------|------|-------------|
| 1 | CMS.3 | Create Strapi 5 project, define all schemas, write seed script | `cms/` directory, all content types, seed data |
| 2 | CMS.2 | Update docker-compose for local dev, create Dockerfile | `docker-compose.yml`, `cms/Dockerfile` |
| 3 | CMS.2 | Create Azure provisioning script | `deployment/scripts/provision-cms.ps1` |
| 4 | CMS.2 | Create CI/CD workflow | `.github/workflows/cms-container-deploy.yml` |
| 5 | CMS.4 | Build `lib/cms/` client, types, queries | `lib/cms/*` |
| 6 | CMS.4 | Build Dynamic Zone renderer | `lib/cms/components.tsx` |
| 7 | CMS.4 | Integrate layout (global -> nav, footer, metadata) | Modify `app/layout.tsx`, `components/layout/*` |
| 8 | CMS.4 | Integrate home page (Dynamic Zone) | Modify `app/page.tsx`, `components/home/*` |
| 9 | CMS.4 | Integrate about + docs pages | Modify `app/about/page.tsx`, `app/docs/page.tsx` |
| 10 | CMS.4 | Integrate login, error, 404 pages | Modify remaining pages |
| 11 | CMS.4 | Integrate pattern UI labels | Modify `app/patterns/`, `components/patterns/*` |
| 12 | CMS.4 | Update tests, add CMS-specific tests | New + modified test files |
| 13 | -- | Update documentation | `instructions.md`, `TECHNICAL_DECISIONS_LOG.md` |

---

## Static Content Inventory (Source Reference)

### Summary Statistics
- **Total Pages/Routes:** 10
- **Total Components with Static Content:** 28
- **Metadata Fields:** 30+
- **Headings:** 50+
- **Buttons/CTAs:** 70+
- **Labels/Form Fields:** 60+
- **Error/Empty States:** 8
- **Navigation Links:** 12
- **Descriptive Text Blocks:** 100+

### Content by Page

**Root Layout (`app/layout.tsx`):** Site title, description, keywords, OG tags, Twitter cards, skip-to-content link

**Home Page (`app/page.tsx` + `components/home/`):** Hero heading/subheading/CTAs, FeaturedPatterns heading/subheading/links, StatsSection 3 stat items, CTASection heading/description/CTAs

**About Page (`app/about/page.tsx`):** Badge, title, subtitle, mission section (3 paragraphs), 6 feature cards (each with title, description, 4 bullet points), tech stack (2 groups), open source section, CTA card

**Documentation Page (`app/docs/page.tsx`):** Badge, title, subtitle, quick navigation (3 items), Getting Started section, Pattern Categories (6 with descriptions), Search/Filtering/Sorting/Voting docs, API Reference (6 endpoints with params), Contributing section (4 steps, 6 guidelines), Support section (2 items)

**Login Page (`app/login/`):** Card title/description, sign-in button, loading state, footer notice, 8 error message codes

**Pattern Listing (`app/patterns/page.tsx` + `components/patterns/`):** Page heading, pattern count template, search placeholder, sort options (3), filter panel labels (15+), date range labels, saved searches dialog labels, recently viewed labels, pagination labels, empty state messages

**Pattern Detail (`app/patterns/[slug]/page.tsx` + `components/patterns/details/`):** Breadcrumb, vote button/announcement, related patterns heading, edit/delete labels, delete confirmation dialog

**Pattern Form (`components/patterns/PatternForm.tsx`):** 15+ form field labels/placeholders, validation error messages, admin settings, submit button states

**Error Pages (`app/error.tsx`, `app/not-found.tsx`):** Error titles, descriptions, button labels

**Layout Components (`components/layout/`, `components/shared/`):** Logo text, nav links (3), mobile menu, footer copyright/links, sign in/out buttons, user menu label

---

## Verification Checklist

1. **Local dev:** `docker-compose up` -> Strapi admin at `localhost:1337/admin`, seed data visible
2. **Frontend:** `npm run dev` -> all pages render CMS content identical to current hardcoded content
3. **Fallback:** Stop Strapi -> frontend still renders with fallback content
4. **CMS edit:** Change hero heading in Strapi admin -> refresh frontend -> new heading appears within revalidation window
5. **Tests:** `npm test` -> all 380+ frontend tests pass (components receive CMS data as props, same as before)
6. **Backend:** `dotnet test` -> all 93 backend tests pass (no backend changes)
7. **Build:** `npm run build` succeeds with `STRAPI_URL` env var set
8. **Docker:** `docker build -t aipatterns-cms ./cms` succeeds
