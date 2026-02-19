# Phase 5.3 & 5.4 — Detailed Implementation Plan

**Date:** 2026-02-19
**Status:** Ready for execution
**Depends on:** Phase 5.1 (Auth) ✅, Phase 5.2 (Pattern Management UI) ✅

---

## Phase 5.3 — Advanced Search & Discovery

### Scope Assessment

The current implementation already has:
- ✅ Keyword search on Title + ShortDescription (URL-driven, server-side)
- ✅ Multi-tag checkbox filtering (OR logic, comma-separated)
- ✅ Category single-select filtering
- ✅ Sort by recent / votes / alphabetical
- ✅ Pagination

What needs to be added:
1. **Full-text search** — extend backend to also search FullContent and Tags
2. **Tag search mode toggle** — AND vs OR logic option
3. **Date range filter** — filter by CreatedDate (backend + UI)
4. **Search suggestions/autocomplete** — debounced client-side suggestions from pattern titles + tags
5. **Recently Viewed** — localStorage tracking, sidebar widget
6. **Saved Searches** — localStorage persistence of search+filter state

---

### 5.3.1 — Full-Text Search on FullContent and Tags

**Why:** Current search only hits Title and ShortDescription. Users searching for specific technologies or patterns in the body content get no results.

#### Backend Changes

**File:** `backend/src/AIEnterprisePatterns.Data/Repositories/PatternRepository.cs`

In `GetPatternsAsync()`, extend the search predicate:

```csharp
// Current:
.Where(p => p.Title.Contains(search) || p.ShortDescription.Contains(search))

// New:
.Where(p =>
    p.Title.Contains(search) ||
    p.ShortDescription.Contains(search) ||
    p.FullContent.Contains(search) ||
    p.Tags.Any(t => t.Name.Contains(search)))
```

**File:** `backend/src/AIEnterprisePatterns.Core/Services/PatternService.cs`
No changes — search string is passed through as-is.

**File:** `backend/src/AIEnterprisePatterns.Api/DTOs/GetPatternsQuery.cs`
No changes — `Search` field already exists with correct MaxLength.

**Test:** `backend/tests/AIEnterprisePatterns.Data.Tests/Repositories/PatternRepositoryTests.cs`
- Add: `GetPatternsAsync_WithSearchTerm_SearchesFullContent()`
- Add: `GetPatternsAsync_WithSearchTerm_SearchesTags()`

---

### 5.3.2 — Date Range Filter

**Why:** Users want to find recently added patterns or patterns from a specific time period.

#### Backend Changes

**File:** `backend/src/AIEnterprisePatterns.Api/DTOs/GetPatternsQuery.cs`

```csharp
[DataType(DataType.Date)]
public DateTime? DateFrom { get; set; }

[DataType(DataType.Date)]
public DateTime? DateTo { get; set; }
```

**File:** `backend/src/AIEnterprisePatterns.Data/Repositories/PatternRepository.cs`

```csharp
if (query.DateFrom.HasValue)
    q = q.Where(p => p.CreatedDate >= query.DateFrom.Value);

if (query.DateTo.HasValue)
    q = q.Where(p => p.CreatedDate <= query.DateTo.Value.AddDays(1)); // inclusive end
```

**File:** `lib/api/patterns.ts` — add `dateFrom` and `dateTo` to `GetPatternsParams` type and URL builder.

**Tests:**
- Backend: `GetPatternsAsync_WithDateRange_FiltersCorrectly()`
- Backend: `GetPatternsAsync_WithDateFrom_OnlyReturnsNewerPatterns()`

#### Frontend Changes

**New file:** `components/patterns/DateRangeFilter.tsx` (client component)

- Two `<input type="date">` fields (From / To) with labels
- Uses router.push to update `dateFrom` / `dateTo` search params
- "Clear dates" button visible when either is set
- Renders inside FilterPanel after Category section
- Use shadcn `Label` and native date inputs (no new dependency)

**File:** `components/patterns/FilterPanel.tsx`
- Import and render `<DateRangeFilter />` between Category and Tags sections
- Pass `dateFrom` / `dateTo` props from searchParams

**File:** `app/patterns/page.tsx`
- Parse `dateFrom` and `dateTo` from searchParams
- Pass to `getPatterns()` call

**File:** `lib/api/patterns.ts`
- Add `dateFrom?: string` and `dateTo?: string` to `GetPatternsParams`
- Append to URLSearchParams when present

**Tests:**
- `DateRangeFilter.test.tsx`: renders correctly, calls router on change, shows/hides clear button

---

### 5.3.3 — Search Suggestions / Autocomplete

**Why:** Helps users discover patterns and tags without knowing exact names.

**Approach:** Client-side suggestions sourced from pattern titles + tags fetched once per page load. No new backend endpoint needed.

#### Frontend Changes

**New file:** `hooks/useSearchSuggestions.ts`

```typescript
// Returns filtered suggestions based on query string
// Sources: pattern titles from the current result set + all known tags
// Debounces by 200ms
// Returns: { suggestions: string[], isLoading: boolean }
```

Implementation notes:
- Takes `allPatterns: PatternListItem[]` (available from current page data)
- Takes `allTags: string[]` (from tags in patterns)
- Uses `useMemo` to build suggestion list
- Filters when query length >= 2 characters
- Deduplicates and limits to 8 suggestions
- Prioritises title matches over tag matches

**File:** `components/patterns/SearchBar.tsx`
- Add suggestion dropdown (absolute positioned `<ul>`)
- Show on focus when suggestions available and query >= 2 chars
- Hide on blur (with 150ms delay to allow click)
- Keyboard navigation: ArrowDown/ArrowUp/Enter/Escape
- Each suggestion item: clickable, triggers search
- Accessible: `role="listbox"`, `aria-expanded`, `aria-activedescendant` on input, `role="option"` on items

**File:** `app/patterns/page.tsx`
- Fetch all patterns once at page level to feed suggestions (or use the already-fetched paginated set + store tags client-side)

**Note:** Suggestions are drawn from the current full tag list (18 tags) + visible pattern titles. No extra API call.

**Tests:**
- `useSearchSuggestions.test.ts`: filters correctly, deduplicates, respects min length
- `SearchBar.test.tsx`: shows/hides dropdown, keyboard navigation, selects suggestion

---

### 5.3.4 — Recently Viewed Patterns

**Why:** Users often want to revisit patterns they viewed. Purely client-side, no backend needed.

#### Frontend Changes

**New file:** `hooks/useRecentlyViewed.ts`

```typescript
const MAX_RECENT = 5

type RecentPattern = {
  slug: string
  title: string
  category: PatternCategory
  visitedAt: string // ISO date
}

// Reads/writes to localStorage key 'recently-viewed-patterns'
// Returns: { recentPatterns, addRecentPattern, clearRecentPatterns }
```

Implementation:
- `addRecentPattern(pattern)` — prepend, deduplicate by slug, trim to 5
- Handles SSR: check `typeof window !== 'undefined'` before localStorage access

**File:** `app/patterns/[slug]/page.tsx`
- Import and use `useRecentlyViewed` hook
- Call `addRecentPattern()` on mount with pattern data
- But this is a server component — need a client wrapper

**New file:** `components/patterns/RecentlyViewedTracker.tsx` (client component)
- Takes `{ slug, title, category }` props
- On mount, calls `addRecentPattern()`
- Renders `null` (invisible tracker)

**New file:** `components/patterns/RecentlyViewedSidebar.tsx` (client component)
- Renders in FilterPanel sidebar (desktop) below Saved Searches
- Shows up to 5 recent patterns as links with category badge
- "Clear history" button
- Hidden when `recentPatterns.length === 0`

**File:** `app/patterns/[slug]/page.tsx`
- Add `<RecentlyViewedTracker slug={pattern.slug} title={pattern.title} category={pattern.category} />`

**File:** `components/patterns/FilterPanel.tsx`
- Add `<RecentlyViewedSidebar />` below the tag list

**Tests:**
- `useRecentlyViewed.test.ts`: add, deduplicate, max 5, clear, SSR guard
- `RecentlyViewedSidebar.test.tsx`: renders list, shows clear button, hides when empty
- `RecentlyViewedTracker.test.tsx`: calls addRecentPattern on mount

---

### 5.3.5 — Saved Searches

**Why:** Power users want to save and quickly recall complex filter combinations.

**Approach:** localStorage persistence. Linked to authenticated session where available (use username as part of key if session exists), but also works unauthenticated.

#### Frontend Changes

**New file:** `hooks/useSavedSearches.ts`

```typescript
const MAX_SAVED = 10

type SavedSearch = {
  id: string // nanoid or crypto.randomUUID()
  name: string // user-provided label
  params: {
    q?: string
    category?: string
    tags?: string[]
    sort?: string
    dateFrom?: string
    dateTo?: string
  }
  savedAt: string // ISO date
}

// localStorage key: 'saved-searches'
// Returns: { savedSearches, saveSearch, deleteSearch, applySavedSearch }
```

**New file:** `components/patterns/SavedSearches.tsx` (client component)
- "Save current search" button (only active when q/filters are set)
- Dialog/modal to name the search (shadcn Dialog)
- List of saved searches as clickable chips with delete (X) button
- Clicking a saved search applies all its params via router.push
- Renders in FilterPanel sidebar above Recently Viewed
- Hidden when no saved searches and no active filters to save

**File:** `components/patterns/FilterPanel.tsx`
- Add `<SavedSearches currentParams={...} />` above Recently Viewed
- Pass current searchParams so Save button knows what to save

**File:** `app/patterns/page.tsx`
- Pass searchParams to FilterPanel for SavedSearches

**Tests:**
- `useSavedSearches.test.ts`: save, delete, max 10, apply, SSR guard
- `SavedSearches.test.tsx`: renders list, save dialog, delete, apply navigates

---

### 5.3.6 — Tag OR/AND Toggle

**Why:** Currently multi-tag filtering uses OR logic (patterns with any selected tag). AND logic (patterns with all selected tags) is more precise for power users.

**Approach:** Simple toggle in FilterPanel header with "Match any" / "Match all" label.

#### Backend Changes

**File:** `backend/src/AIEnterprisePatterns.Api/DTOs/GetPatternsQuery.cs`

```csharp
[MaxLength(3)]
public string TagMode { get; set; } = "any"; // "any" | "all"
```

**File:** `backend/src/AIEnterprisePatterns.Data/Repositories/PatternRepository.cs`

```csharp
// Replace current:
.Where(p => p.Tags.Any(t => filterTags.Contains(t.Name)))

// With:
if (query.TagMode == "all")
    q = filterTags.Aggregate(q, (current, tag) =>
        current.Where(p => p.Tags.Any(t => t.Name == tag)));
else
    q = q.Where(p => p.Tags.Any(t => filterTags.Contains(t.Name)));
```

**File:** `lib/api/patterns.ts`
- Add `tagMode?: 'any' | 'all'` to `GetPatternsParams`
- Append to URLSearchParams when present and != 'any'

#### Frontend Changes

**File:** `components/patterns/FilterPanel.tsx`
- Add toggle above tag list: `<ToggleGroup>` or two radio buttons "Match any" / "Match all"
- Only visible/active when >= 2 tags are selected
- Update URL param `tagMode` on toggle change

**File:** `app/patterns/page.tsx`
- Parse `tagMode` from searchParams, pass to `getPatterns()`

**Tests:**
- Backend: `GetPatternsAsync_WithTagModeAll_RequiresAllTags()`
- Frontend: FilterPanel shows toggle when 2+ tags selected

---

### 5.3 — Files Summary

| File | Change Type |
|------|-------------|
| `backend/.../DTOs/GetPatternsQuery.cs` | Modify: add DateFrom, DateTo, TagMode |
| `backend/.../Repositories/PatternRepository.cs` | Modify: extend search, add date filter, add tag AND mode |
| `backend/.../Data.Tests/Repositories/PatternRepositoryTests.cs` | Modify: add new test cases |
| `lib/api/patterns.ts` | Modify: add dateFrom, dateTo, tagMode to params |
| `lib/types/pattern.ts` | Modify: extend GetPatternsParams type |
| `hooks/useSearchSuggestions.ts` | **New** |
| `hooks/useRecentlyViewed.ts` | **New** |
| `hooks/useSavedSearches.ts` | **New** |
| `components/patterns/DateRangeFilter.tsx` | **New** |
| `components/patterns/RecentlyViewedTracker.tsx` | **New** |
| `components/patterns/RecentlyViewedSidebar.tsx` | **New** |
| `components/patterns/SavedSearches.tsx` | **New** |
| `components/patterns/FilterPanel.tsx` | Modify: add DateRange, SavedSearches, RecentlyViewed, TagMode toggle |
| `components/patterns/SearchBar.tsx` | Modify: add suggestions dropdown |
| `app/patterns/page.tsx` | Modify: parse new params, add RecentlyViewedTracker |
| `app/patterns/[slug]/page.tsx` | Modify: add RecentlyViewedTracker |
| `__tests__/hooks/useSearchSuggestions.test.ts` | **New** |
| `__tests__/hooks/useRecentlyViewed.test.ts` | **New** |
| `__tests__/hooks/useSavedSearches.test.ts` | **New** |
| `__tests__/components/patterns/DateRangeFilter.test.tsx` | **New** |
| `__tests__/components/patterns/RecentlyViewedSidebar.test.tsx` | **New** |
| `__tests__/components/patterns/RecentlyViewedTracker.test.tsx` | **New** |
| `__tests__/components/patterns/SavedSearches.test.tsx` | **New** |

---

## Phase 5.4 — Accessibility Improvements

### Scope Assessment

Current accessibility baseline (already implemented):
- ✅ `<nav aria-label>`, `<main>`, `<aside>`, `<header>`, `<footer>` landmarks
- ✅ `aria-current="page"` on active pagination
- ✅ `aria-pressed` on category filter buttons
- ✅ `htmlFor` + matching `id` on sort and tag inputs
- ✅ `sr-only` labels on icon-only buttons
- ✅ `html lang="en"` in root layout
- ✅ Keyboard accessible form controls

Gaps to fix:
1. No skip-to-content link
2. No ARIA live regions for dynamic content (search results, filter changes)
3. Focus management when filters change (no announcement)
4. Missing focus-visible styles on some interactive elements
5. PatternCard links — card description needs better SR context
6. VotingButton — state change not announced
7. PatternActions delete confirmation — focus management in dialog
8. FilterSheet (mobile) — sheet close button lacks context
9. No axe-core automated accessibility tests
10. SearchBar autocomplete — needs ARIA combobox pattern
11. PatternForm — field error messages not linked with aria-describedby
12. Missing `aria-busy` during loading states

---

### 5.4.1 — Skip-to-Content Link

**Why:** Keyboard and screen reader users cannot skip repeated navigation on every page.

**File:** `app/layout.tsx`

Add as the very first element inside `<body>`:

```tsx
<a
  href="#main-content"
  className="sr-only focus:not-sr-only focus:fixed focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-primary focus:text-primary-foreground focus:rounded-md focus:ring-2 focus:ring-ring"
>
  Skip to main content
</a>
```

**File:** `app/layout.tsx` — add `id="main-content"` to `<main>` element.

**Tests:** `app/layout.test.tsx` — verify skip link renders and points to `#main-content`.

---

### 5.4.2 — ARIA Live Regions for Dynamic Content

**Why:** Screen readers don't announce URL-driven content changes automatically. Users filtering/searching get no feedback.

#### Search Results Announcement

**File:** `app/patterns/page.tsx`

Add an SR-only results count after data loads:

```tsx
<p role="status" aria-live="polite" className="sr-only">
  {totalCount === 0
    ? 'No patterns found'
    : `${totalCount} pattern${totalCount === 1 ? '' : 's'} found`}
</p>
```

Place this just before `<PatternsGrid>`. It must be rendered server-side with the real count.

#### Filter Change Announcement

**File:** `components/patterns/FilterPanel.tsx`

Add a visually hidden live region that announces filter changes:

```tsx
<div role="status" aria-live="polite" className="sr-only" aria-atomic="true">
  {activeFilterDescription} {/* e.g. "Filtered by Architecture, 2 tags" */}
</div>
```

Compute `activeFilterDescription` from active category + tag count.

#### Loading State Announcement

**New file:** `components/ui/LoadingAnnouncer.tsx` (client component)

```tsx
// Reads `isPending` from useTransition context or a prop
// Renders: <div role="status" aria-live="polite" aria-atomic="true" className="sr-only">
//   {isPending ? 'Loading patterns...' : ''}
// </div>
```

Used in `SearchBar` (already has `useTransition`) and `SortSelector`.

---

### 5.4.3 — Focus Visible Improvements

**Why:** Default focus indicators are insufficient for keyboard navigation. Some shadcn components suppress the browser default without providing a visible alternative.

**File:** `app/globals.css`

Add global focus-visible styles:

```css
/* Ensure focus-visible ring on all interactive elements */
*:focus-visible {
  outline: 2px solid hsl(var(--ring));
  outline-offset: 2px;
  border-radius: 4px;
}
```

**Files to audit for missing focus styles:**
- `components/patterns/FilterPanel.tsx` — category buttons use `variant="ghost"` which should have focus styles via shadcn
- `components/patterns/SearchBar.tsx` — suggestion dropdown items need explicit `tabIndex={-1}` + focus classes
- `components/patterns/Pagination.tsx` — page number buttons need focus ring when using keyboard
- `components/layout/UserMenu.tsx` — dropdown trigger should show focus ring

**Verification:** All interactive elements show a visible 2px ring on `:focus-visible`. Tested via keyboard Tab navigation through each page.

---

### 5.4.4 — PatternCard Accessibility

**Why:** Pattern cards have links with potentially ambiguous text for screen readers (multiple cards all saying "read more" or just showing a title link to the same page content).

**File:** `components/home/PatternCard.tsx` (or wherever PatternCard is defined)

1. Add `aria-label` to the card's main link:
   ```tsx
   <Link href={...} aria-label={`View pattern: ${pattern.title}`}>
   ```

2. Vote count: Wrap in `<span aria-label={`${pattern.voteCount} votes`}>`

3. Category badge: Add `aria-label={`Category: ${pattern.category}`}` to the badge wrapper

4. Tags: Add `aria-label="Tags:"` to the tag container

---

### 5.4.5 — VotingButton Accessibility

**Why:** The vote count changes after clicking but screen readers don't announce the change.

**File:** `components/patterns/VotingButton.tsx`

1. Add `aria-pressed` to reflect voted state:
   ```tsx
   <Button aria-pressed={hasVoted} aria-label={`Vote for this pattern. ${voteCount} votes`}>
   ```

2. Add a live region for vote confirmation:
   ```tsx
   <span role="status" aria-live="polite" aria-atomic="true" className="sr-only">
     {justVoted ? `Voted! ${voteCount} total votes` : ''}
   </span>
   ```

3. During vote submission: `aria-busy="true"` on the button.

---

### 5.4.6 — PatternForm Accessibility

**Why:** Form validation errors are displayed visually but not linked to their inputs via aria-describedby.

**File:** `components/patterns/PatternForm.tsx`

For each field with potential error:

```tsx
<Input
  id="title"
  aria-describedby={errors.title ? 'title-error' : undefined}
  aria-invalid={!!errors.title}
/>
{errors.title && (
  <p id="title-error" role="alert" className="text-sm text-destructive">
    {errors.title.message}
  </p>
)}
```

Apply to: title, shortDescription, content, category (Select), status, tags.

Also add `aria-required="true"` to required fields.

---

### 5.4.7 — FilterSheet (Mobile) Accessibility

**Why:** The mobile filter sheet's trigger button and close button need better SR context.

**File:** `components/patterns/FilterSheet.tsx`

1. Sheet trigger: Add `aria-label="Open filters"` if current label is just an icon
2. Sheet close: Verify `aria-label="Close filters"` is present
3. Sheet content: Add `aria-label="Filter options"` to SheetContent
4. When sheet closes: Return focus to trigger button (shadcn Sheet should handle this, verify)

---

### 5.4.8 — Delete Confirmation Dialog

**Why:** PatternActions uses browser `confirm()` which has poor accessibility. It should use a proper Dialog.

**File:** `components/patterns/PatternActions.tsx`

Replace `window.confirm()` with a shadcn `AlertDialog`:

```tsx
<AlertDialog open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
  <AlertDialogTrigger asChild>
    <Button variant="destructive" ...>Delete</Button>
  </AlertDialogTrigger>
  <AlertDialogContent>
    <AlertDialogHeader>
      <AlertDialogTitle>Delete Pattern</AlertDialogTitle>
      <AlertDialogDescription>
        Are you sure you want to delete "{patternTitle}"? This action cannot be undone.
      </AlertDialogDescription>
    </AlertDialogHeader>
    <AlertDialogFooter>
      <AlertDialogCancel>Cancel</AlertDialogCancel>
      <AlertDialogAction onClick={handleDelete} className="bg-destructive">
        {isDeleting ? 'Deleting...' : 'Delete'}
      </AlertDialogAction>
    </AlertDialogFooter>
  </AlertDialogContent>
</AlertDialog>
```

Requires: Add `AlertDialog` shadcn component if not already present: `npx shadcn@latest add alert-dialog`

After deletion: redirect to `/patterns` (already done in PatternActions).

**Note:** This changes the delete flow UI — update the 9 existing PatternActions tests to use the new Dialog pattern. The AlertDialog needs to be mocked in tests.

---

### 5.4.9 — axe-core Automated Accessibility Tests

**Why:** Automated detection of WCAG violations catches regressions early.

#### Setup

```bash
npm install --save-dev jest-axe @types/jest-axe
```

**File:** `jest.setup.ts` — add `import 'jest-axe/extend-expect'`

#### Test Files

**New file:** `__tests__/accessibility/patterns-listing.a11y.test.tsx`

Tests:
- Patterns listing page has no axe violations
- FilterPanel has no axe violations
- Pagination has no axe violations
- Empty state has no axe violations

**New file:** `__tests__/accessibility/pattern-detail.a11y.test.tsx`

Tests:
- Pattern detail page has no axe violations
- VotingButton has no axe violations
- PatternActions (when visible) has no axe violations

**New file:** `__tests__/accessibility/pattern-form.a11y.test.tsx`

Tests:
- PatternForm (create mode) has no axe violations
- PatternForm (edit mode) has no axe violations
- PatternForm validation errors: no axe violations after submission attempt

**New file:** `__tests__/accessibility/layout.a11y.test.tsx`

Tests:
- Layout has no axe violations
- Header/UserMenu have no axe violations

**Test Pattern:**

```typescript
import { axe, toHaveNoViolations } from 'jest-axe'
expect.extend(toHaveNoViolations)

it('should have no accessibility violations', async () => {
  const { container } = render(<ComponentUnderTest />)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})
```

---

### 5.4.10 — Keyboard Navigation Audit

**Verify each flow works keyboard-only:**

| Flow | Expected Behavior |
|------|-------------------|
| Skip to main content | Tab → skip link visible → Enter → focus jumps to `#main-content` |
| Search | Tab to SearchBar → Type → Suggestions appear → ArrowDown to navigate → Enter to select |
| Category filter | Tab to filter buttons → Space/Enter to select → Live region announces change |
| Tag filter | Tab to checkboxes → Space to toggle → Live region announces count |
| Date range | Tab to date inputs → Type or use picker → Filter applies |
| Saved search save | Tab to Save button → Enter → Dialog opens → Tab to name field → Type → Enter to save |
| Sort | Tab to SortSelector → Enter → Arrow to option → Enter to select |
| Pagination | Tab to page buttons → Enter to navigate |
| Pattern card | Tab to card link → Enter to navigate |
| Vote | Tab to vote button → Enter to vote → Status announced |
| Delete | Tab to Delete button → Enter → AlertDialog opens → Tab to Cancel/Confirm → Enter |
| Mobile filter | Tab to Filter button → Enter → Sheet opens → Tab within sheet → Esc to close → Focus returns to trigger |

---

### 5.4 — Files Summary

| File | Change Type |
|------|-------------|
| `app/layout.tsx` | Modify: skip link, `id="main-content"` on main |
| `app/globals.css` | Modify: global `*:focus-visible` styles |
| `app/patterns/page.tsx` | Modify: results count live region |
| `components/home/PatternCard.tsx` | Modify: aria-label on link, vote count, category, tags |
| `components/patterns/FilterPanel.tsx` | Modify: filter change live region |
| `components/patterns/FilterSheet.tsx` | Modify: aria-labels on trigger/close |
| `components/patterns/VotingButton.tsx` | Modify: aria-pressed, live region, aria-busy |
| `components/patterns/PatternForm.tsx` | Modify: aria-describedby, aria-invalid, aria-required |
| `components/patterns/PatternActions.tsx` | Modify: replace confirm() with AlertDialog |
| `components/patterns/SearchBar.tsx` | Modify: ARIA combobox pattern for suggestions |
| `components/ui/LoadingAnnouncer.tsx` | **New**: sr-only live region component |
| `jest.setup.ts` | Modify: add jest-axe/extend-expect |
| `__tests__/accessibility/patterns-listing.a11y.test.tsx` | **New** |
| `__tests__/accessibility/pattern-detail.a11y.test.tsx` | **New** |
| `__tests__/accessibility/pattern-form.a11y.test.tsx` | **New** |
| `__tests__/accessibility/layout.a11y.test.tsx` | **New** |
| `__tests__/components/patterns/PatternActions.test.tsx` | Modify: update 9 tests for AlertDialog |

---

## Execution Order

### Phase 5.3 — Recommended Order

1. **Backend first** (no frontend deps)
   - Extend `PatternRepository` (full-text search + date filter + tag mode)
   - Extend `GetPatternsQuery` (DateFrom, DateTo, TagMode)
   - Write backend tests

2. **API layer** (lib/api/patterns.ts + lib/types/pattern.ts)

3. **UI components** (each independently testable)
   - `DateRangeFilter.tsx` + tests
   - `SearchBar.tsx` suggestions + `useSearchSuggestions` hook + tests
   - FilterPanel tag mode toggle + tests
   - `useRecentlyViewed.ts` + `RecentlyViewedTracker` + `RecentlyViewedSidebar` + tests
   - `useSavedSearches.ts` + `SavedSearches.tsx` + tests

4. **Page integration** (app/patterns/page.tsx, app/patterns/[slug]/page.tsx)

### Phase 5.4 — Recommended Order

1. **Install jest-axe** (needed before writing accessibility tests)

2. **Quick wins** (each is one file, self-contained)
   - Skip link (`app/layout.tsx`)
   - `globals.css` focus-visible styles
   - PatternCard aria-label improvements
   - VotingButton aria-pressed + live region

3. **PatternForm** (aria-describedby on errors — update existing tests)

4. **AlertDialog for PatternActions** (breaking change — update 9 tests first)
   - Install alert-dialog: `npx shadcn@latest add alert-dialog`
   - Update tests to mock AlertDialog
   - Implement

5. **Live regions** (FilterPanel, SearchBar, results count)
   - `LoadingAnnouncer.tsx`
   - FilterPanel filter change announcer
   - Page results count region

6. **Accessibility tests** (jest-axe)
   - 4 new test files

7. **Keyboard navigation** (manual audit last — verify everything works)

---

## Test Count Expectations

| Phase | New Tests Estimate |
|-------|--------------------|
| 5.3 backend | ~8 new repository tests |
| 5.3 hooks | ~30 (3 hooks × ~10 each) |
| 5.3 components | ~40 (5 new components × ~8 each) |
| 5.4 a11y | ~20 (4 files × ~5 each) |
| 5.4 updates | ~5 net new (PatternActions rewrite) |
| **Total** | **~103 new tests** |

Current baseline: 323 tests. **Target: ~426 tests passing.**

---

## Technical Decisions to Record

After implementation, add to `TECHNICAL_DECISIONS_LOG.md`:

- **Decision 20:** Client-side search suggestions vs dedicated endpoint — chose client-side to avoid extra API round-trip; suggestions sourced from current page data
- **Decision 21:** localStorage for Recently Viewed and Saved Searches — no backend required; acceptable for non-critical UX features; user-agent scoped
- **Decision 22:** AlertDialog for delete confirmation — replaces `window.confirm()` for WCAG 2.1 AA compliance (keyboard trap, focus management, SR announcement)
- **Decision 23:** jest-axe for automated accessibility regression — lightweight, integrates with Jest, catches WCAG violations before PR merge
- **Decision 24:** Global `*:focus-visible` override in globals.css — ensures consistent visible focus across all interactive elements, not just shadcn components

---

## Definition of Done

### Phase 5.3
- [ ] Backend search hits FullContent and Tags
- [ ] Date range filter works end-to-end (backend + frontend)
- [ ] Tag AND/OR toggle works end-to-end
- [ ] Search suggestions appear and are keyboard navigable
- [ ] Recently Viewed shows last 5 patterns, persists across page loads
- [ ] Saved Searches: can save, name, recall, and delete
- [ ] All 5.3 tests passing
- [ ] No TypeScript errors

### Phase 5.4
- [ ] Skip-to-content link visible on Tab, focus lands on `#main-content`
- [ ] Screen reader announces result counts on filter/search
- [ ] All form errors linked with aria-describedby
- [ ] Delete uses AlertDialog (not `window.confirm()`)
- [ ] VotingButton announces vote confirmation
- [ ] `*:focus-visible` ring visible on all interactive elements
- [ ] All axe-core tests pass with no violations
- [ ] Keyboard-only audit passes all flows in table above
- [ ] All 5.4 tests passing (including updated PatternActions tests)
- [ ] No TypeScript errors
