# Patterns API Reference

**Last Updated:** 2026-03-02
**Audience:** Developers, API consumers
**Purpose:** Complete reference for all `/patterns` endpoints — request shapes, response shapes, validation rules, query parameters, and error codes.

See [API_REFERENCE_INDEX.md](API_REFERENCE_INDEX.md) for base URLs, auth, and rate limiting.

---

## Endpoint Summary

| Method | Endpoint | Auth | Rate Limit | Notes |
|--------|----------|------|------------|-------|
| GET | `/patterns` | None | `api` | Paginated list with filtering and sorting |
| GET | `/patterns/featured` | None | `api` | Featured patterns, cached 5 min |
| GET | `/patterns/trending` | None | `api` | Trending patterns, cached 5 min |
| GET | `/patterns/{slug}` | None | `api` | Single pattern by slug |
| GET | `/patterns/{slug}/related` | None | `api` | Related patterns, cached 5 min per slug |
| POST | `/patterns/{id}/vote` | None | `vote` (10/min) | Increment vote count |
| POST | `/patterns` | RequireEditor | `api` | Create new pattern |
| PUT | `/patterns/{id}` | RequireEditor | `api` | Update existing pattern |
| DELETE | `/patterns/{id}` | RequireAdmin | `api` | Delete pattern |

---

## DTOs

### PatternListDto

Returned by list endpoints (`GET /patterns`, `/featured`, `/trending`, `/related`). Excludes `fullContent` for performance.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string (uuid)` | Pattern unique identifier |
| `title` | `string` | Pattern title |
| `slug` | `string` | URL-safe identifier (e.g. `circuit-breaker-pattern`) |
| `shortDescription` | `string` | One-paragraph summary |
| `category` | `string` | PascalCase enum value — see [Category Values](#category-values) |
| `tags` | `string[]` | Tag names |
| `author` | `string \| null` | Author name |
| `createdDate` | `string (ISO 8601)` | Creation timestamp |
| `updatedDate` | `string (ISO 8601)` | Last update timestamp |
| `voteCount` | `number` | Total votes |
| `status` | `string` | `"draft"` or `"published"` |
| `isFeatured` | `boolean` | Appears on featured list |
| `isTrending` | `boolean` | Appears on trending list |

### PatternDetailDto

Returned by single-pattern endpoints (`GET /patterns/{slug}`, `POST /patterns`, `PUT /patterns/{id}`). Adds `fullContent`.

All fields from `PatternListDto` plus:

| Field | Type | Description |
|-------|------|-------------|
| `fullContent` | `string \| null` | Full Markdown content body |

### PaginatedResponse

Wrapper returned by `GET /patterns`.

| Field | Type | Description |
|-------|------|-------------|
| `patterns` | `PatternListDto[]` | Page of results |
| `totalCount` | `number` | Total matching records |
| `currentPage` | `number` | Current page number (1-based) |
| `pageSize` | `number` | Items per page |
| `totalPages` | `number` | Total page count |

### VoteResponse

Returned by `POST /patterns/{id}/vote`.

| Field | Type | Description |
|-------|------|-------------|
| `patternId` | `string (uuid)` | Pattern that was voted on |
| `voteCount` | `number` | New total vote count |

### CreatePatternDto

Request body for `POST /patterns`.

| Field | Type | Required | Validation |
|-------|------|----------|-----------|
| `title` | `string` | Yes | Max 255 chars |
| `shortDescription` | `string` | Yes | Max 500 chars |
| `fullContent` | `string` | No | Max 50,000 chars |
| `category` | `string` | Yes | Must be a valid [Category Value](#category-values) |
| `tags` | `string[]` | No | Max 10 tags; each tag max 50 chars |
| `author` | `string` | No | Max 100 chars |

### UpdatePatternDto

Request body for `PUT /patterns/{id}`. All fields required (full replacement).

All fields from `CreatePatternDto` plus:

| Field | Type | Required | Validation |
|-------|------|----------|-----------|
| `isFeatured` | `boolean` | Yes | Promotes to featured list |
| `isTrending` | `boolean` | Yes | Promotes to trending list |

---

## Category Values

Categories use PascalCase on the API. The frontend maps them to display strings.

| API Value | Display |
|-----------|---------|
| `DesignPatterns` | Design Patterns |
| `Architecture` | Architecture |
| `AIPrompts` | AI Prompts |
| `Security` | Security |
| `Performance` | Performance |

See [DATA_MODEL.md](../architecture/DATA_MODEL.md) for the full mapping and frontend mapper function.

---

## GET /patterns

Returns a paginated, filterable, sortable list of patterns.

### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | `integer` | `1` | Page number (1-based, min 1) |
| `pageSize` | `integer` | `9` | Items per page (min 1, max 100) |
| `sortBy` | `string` | `recent` | Sort order — `recent`, `votes`, `alphabetical` |
| `category` | `string` | — | Filter by PascalCase category value |
| `tags` | `string` | — | Comma-separated tag names — e.g. `resilience,cloud` |
| `tagMode` | `string` | `any` | Tag matching — `any` (OR) or `all` (AND) |
| `search` | `string` | — | Full-text search across title, description, tags, and content (max 200 chars) |
| `dateFrom` | `date` | — | Include only patterns created on or after this date (ISO 8601 date) |
| `dateTo` | `date` | — | Include only patterns created on or before this date (ISO 8601 date) |

### Example Request

```
GET /api/patterns?page=1&pageSize=9&sortBy=votes&category=Architecture&tags=resilience,cloud&tagMode=any
```

### Example Response

```json
{
  "patterns": [
    {
      "id": "b0000000-0000-0000-0000-000000000001",
      "title": "Circuit Breaker",
      "slug": "circuit-breaker-pattern",
      "shortDescription": "Prevents cascading failures in distributed systems.",
      "category": "DesignPatterns",
      "tags": ["resilience", "distributed-systems"],
      "author": "Martin Fowler",
      "createdDate": "2024-01-15T10:00:00Z",
      "updatedDate": "2024-06-01T08:30:00Z",
      "voteCount": 42,
      "status": "published",
      "isFeatured": true,
      "isTrending": false
    }
  ],
  "totalCount": 6,
  "currentPage": 1,
  "pageSize": 9,
  "totalPages": 1
}
```

### Error Responses

| Status | Condition |
|--------|-----------|
| `400` | Invalid query parameter (e.g. `pageSize` out of range) |
| `429` | Rate limit exceeded |

**Frontend client:** `getPatterns(params)` in [lib/api/patterns.ts](../../lib/api/patterns.ts)

---

## GET /patterns/featured

Returns all patterns with `isFeatured = true`. Cached for 5 minutes.

### Example Response

```json
[
  {
    "id": "b0000000-0000-0000-0000-000000000001",
    "title": "Circuit Breaker",
    "slug": "circuit-breaker-pattern",
    ...
  }
]
```

**Frontend client:** `getFeaturedPatterns()` in [lib/api/patterns.ts](../../lib/api/patterns.ts)

---

## GET /patterns/trending

Returns all patterns with `isTrending = true`. Cached for 5 minutes.

Same response shape as `/patterns/featured`.

**Frontend client:** `getTrendingPatterns()` in [lib/api/patterns.ts](../../lib/api/patterns.ts)

---

## GET /patterns/{slug}

Returns full details for a single pattern by its URL slug.

### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `slug` | `string` | Pattern slug (e.g. `circuit-breaker-pattern`) |

### Example Response

```json
{
  "id": "b0000000-0000-0000-0000-000000000001",
  "title": "Circuit Breaker",
  "slug": "circuit-breaker-pattern",
  "shortDescription": "Prevents cascading failures in distributed systems.",
  "fullContent": "## Overview\n\nThe Circuit Breaker pattern...",
  "category": "DesignPatterns",
  "tags": ["resilience", "distributed-systems"],
  "author": "Martin Fowler",
  "createdDate": "2024-01-15T10:00:00Z",
  "updatedDate": "2024-06-01T08:30:00Z",
  "voteCount": 42,
  "status": "published",
  "isFeatured": true,
  "isTrending": false
}
```

### Error Responses

| Status | Condition |
|--------|-----------|
| `404` | No pattern with that slug |
| `429` | Rate limit exceeded |

**Frontend client:** `getPatternBySlug(slug)` in [lib/api/patterns.ts](../../lib/api/patterns.ts) — returns `null` on 404.

---

## GET /patterns/{slug}/related

Returns up to 3 related patterns ordered by: same category first, then tag overlap, then vote count. Cached 5 minutes per slug.

### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `slug` | `string` | Slug of the source pattern |

Response is an array of `PatternListDto`. Returns an empty array if the slug is not found (graceful fallback).

**Frontend client:** `getRelatedPatterns(slug)` in [lib/api/patterns.ts](../../lib/api/patterns.ts) — returns `[]` on any error.

---

## POST /patterns/{id}/vote

Increments the vote count for a pattern by 1. **Requires** the pattern ID (UUID), not the slug.

Rate limited to **10 requests per minute per IP** (stricter than general `api` policy).

### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | `string (uuid)` | Pattern ID |

### Example Response

```json
{
  "patternId": "b0000000-0000-0000-0000-000000000001",
  "voteCount": 43
}
```

### Error Responses

| Status | Condition |
|--------|-----------|
| `404` | No pattern with that ID |
| `429` | Vote rate limit exceeded (10/min per IP) |

> **Known limitation:** Vote increment uses a basic `SaveAsync()` call rather than an atomic SQL `UPDATE … SET VoteCount = VoteCount + 1`, which creates a race condition under concurrent votes. Tracked for fix in a future phase.

**Frontend client:** `voteForPattern(id)` in [lib/api/patterns.ts](../../lib/api/patterns.ts)

---

## POST /patterns

Creates a new pattern. **Requires `Editor` role.**

### Request Body

`CreatePatternDto` — see [DTOs section](#createpatterndto).

### Example Request

```json
{
  "title": "Strangler Fig",
  "shortDescription": "Incrementally migrate a legacy system by replacing pieces with new services.",
  "fullContent": "## Overview\n\nThe Strangler Fig pattern...",
  "category": "Architecture",
  "tags": ["migration", "legacy", "incremental"],
  "author": "Martin Fowler"
}
```

### Example Response

`201 Created` with `Location: /api/patterns/{slug}` header and full `PatternDetailDto` body.

### Error Responses

| Status | Condition |
|--------|-----------|
| `400` | Validation error — see `errors` object |
| `401` | No token provided |
| `403` | Token present but role is not `Editor` or `Admin` |
| `429` | Rate limit exceeded |

**Frontend client:** `createPattern(data, token)` in [lib/api/patterns.ts](../../lib/api/patterns.ts)

---

## PUT /patterns/{id}

Replaces all fields of an existing pattern. **Requires `Editor` role.**

### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | `string (uuid)` | Pattern ID |

### Request Body

`UpdatePatternDto` — see [DTOs section](#updatepatterndto). All fields are required (full replacement, not partial update).

### Example Response

`200 OK` with updated `PatternDetailDto` body.

### Error Responses

| Status | Condition |
|--------|-----------|
| `400` | Validation error |
| `401` | No token |
| `403` | Insufficient role |
| `404` | No pattern with that ID |
| `429` | Rate limit exceeded |

**Frontend client:** `updatePattern(id, data, token)` in [lib/api/patterns.ts](../../lib/api/patterns.ts)

---

## DELETE /patterns/{id}

Deletes a pattern permanently. **Requires `Admin` role.**

> Note: The frontend does not yet wire up a delete UI — this endpoint exists at the API level only.

### Path Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | `string (uuid)` | Pattern ID |

### Response

`204 No Content` on success.

### Error Responses

| Status | Condition |
|--------|-----------|
| `401` | No token |
| `403` | Insufficient role (requires `Admin`) |
| `404` | No pattern with that ID |
| `429` | Rate limit exceeded |

**Controller source:** [PatternsController.cs](../../backend/src/AIEnterprisePatterns.Api/Controllers/PatternsController.cs)
