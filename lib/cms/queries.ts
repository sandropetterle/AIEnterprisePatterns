/**
 * CMS query functions — one per Single Type.
 * Each wraps fetchStrapi with appropriate ISR revalidation and a fallback.
 * Falls back to empty/default values when Strapi is unavailable (build time safety).
 */

import { CmsUnavailableError, fetchStrapi } from './client';
import type {
  CmsAboutPage,
  CmsDocsPage,
  CmsErrorPage,
  CmsGlobal,
  CmsHomePage,
  CmsLoginPage,
  CmsNotFoundPage,
  CmsPatternDetailLabels,
  CmsPatternFormLabels,
  CmsPatternListingLabels,
} from './types';

/** Revalidation intervals in seconds */
const TTL = {
  GLOBAL: 600,       // 10 min — rarely changes (nav, footer)
  PAGE: 300,         // 5 min — marketing content
  LABELS: 3600,      // 1 hour — UI labels almost never change
  STATIC: 3600,      // 1 hour — login, error, 404
} as const;

/**
 * Strapi 5 populate presets.
 * Strapi 5 does NOT support `populate=deep` without a plugin.
 * - `*` populates 1 level (flat single types, labels)
 * - Bracket notation populates specific nested fields
 */
const POPULATE = {
  /** 1-level populate — flat content types & labels */
  FLAT: { populate: '*' } as Record<string, string>,
  /** Global: navigation (flat) + footer → links (2 levels) */
  GLOBAL: {
    'populate[navigation]': '*',
    'populate[footer][populate][links]': '*',
  } as Record<string, string>,
  /** Pages with Dynamic Zone `content` field — 2-level populate */
  DYNAMIC_ZONE: {
    'populate[content][populate]': '*',
    // Populate seo with explicit scalar fields only — wildcard (*) fails because
    // ogImage is a Media relation that requires separate populate syntax.
    'populate[seo][fields][0]': 'title',
    'populate[seo][fields][1]': 'description',
    'populate[seo][fields][2]': 'keywords',
    'populate[seo][fields][3]': 'ogTitle',
    'populate[seo][fields][4]': 'ogDescription',
  } as Record<string, string>,
  /** Pages with DZ `content` field + `header` component */
  DYNAMIC_ZONE_WITH_HEADER: {
    'populate[content][populate]': '*',
    'populate[header]': '*',
    // Populate seo with explicit scalar fields only — wildcard (*) fails because
    // ogImage is a Media relation that requires separate populate syntax.
    'populate[seo][fields][0]': 'title',
    'populate[seo][fields][1]': 'description',
    'populate[seo][fields][2]': 'keywords',
    'populate[seo][fields][3]': 'ogTitle',
    'populate[seo][fields][4]': 'ogDescription',
  } as Record<string, string>,
} as const;

async function safeFetch<T>(
  path: string,
  revalidate: number,
  fallback: T,
  params: Record<string, string> = POPULATE.FLAT,
): Promise<T> {
  try {
    return await fetchStrapi<T>(path, revalidate, params);
  } catch (err) {
    if (err instanceof CmsUnavailableError) {
      // Expected during build when CMS isn't running — use fallback
      return fallback;
    }
    throw err;
  }
}

// ─── Global ───────────────────────────────────────────────────────────────

const GLOBAL_FALLBACK: CmsGlobal = {
  siteName: 'AI Enterprise Patterns Library',
  navigation: [
    { label: 'Home', href: '/' },
    { label: 'Patterns', href: '/patterns' },
    { label: 'About', href: '/about' },
  ],
  mobileMenuTitle: 'Menu',
  skipToContentLabel: 'Skip to main content',
  signInLabel: 'Sign In',
  signOutLabel: 'Sign Out',
  userMenuLabel: 'User menu',
  newPatternButtonLabel: '+ New Pattern',
  footer: {
    copyrightTemplate: '© {year} AI Enterprise Patterns. All rights reserved.',
    links: [
      { label: 'GitHub', href: 'https://github.com/sandropetterle/AIEnterprisePatterns', isExternal: true },
      { label: 'Documentation', href: '/docs' },
    ],
  },
};

export async function getGlobal(): Promise<CmsGlobal> {
  return safeFetch<CmsGlobal>('/global', TTL.GLOBAL, GLOBAL_FALLBACK, POPULATE.GLOBAL);
}

// ─── Pages ────────────────────────────────────────────────────────────────

export async function getHomePage(): Promise<CmsHomePage> {
  return safeFetch<CmsHomePage>('/home-page', TTL.PAGE, {}, POPULATE.DYNAMIC_ZONE);
}

export async function getAboutPage(): Promise<CmsAboutPage> {
  return safeFetch<CmsAboutPage>('/about-page', TTL.PAGE, {}, POPULATE.DYNAMIC_ZONE_WITH_HEADER);
}

export async function getDocsPage(): Promise<CmsDocsPage> {
  return safeFetch<CmsDocsPage>('/docs-page', TTL.PAGE, {}, POPULATE.DYNAMIC_ZONE_WITH_HEADER);
}

export async function getLoginPage(): Promise<CmsLoginPage> {
  return safeFetch<CmsLoginPage>('/login-page', TTL.STATIC, {
    cardTitle: 'Sign in',
    cardDescription: 'Access the AI Enterprise Patterns Library',
    signInButtonLabel: 'Continue with Microsoft',
    signInLoadingLabel: 'Redirecting...',
    footerNotice: 'Sign-in is managed securely by Microsoft Entra. Only authorized users may access this application.',
    errorMessages: {
      OAuthSignin: 'Could not start the sign-in flow. Please try again.',
      OAuthCallback: 'Sign-in failed during callback. Please try again.',
      AccessDenied: 'Access denied. You may not have permission to access this application.',
      Default: 'An unexpected error occurred during sign-in. Please try again.',
    },
  });
}

export async function getNotFoundPage(): Promise<CmsNotFoundPage> {
  return safeFetch<CmsNotFoundPage>('/not-found-page', TTL.STATIC, {
    errorCode: '404',
    heading: 'Page Not Found',
    message: 'The page you are looking for does not exist or has been moved.',
    backButton: { label: 'Back to Home', href: '/', variant: 'primary' },
  });
}

export async function getErrorPage(): Promise<CmsErrorPage> {
  return safeFetch<CmsErrorPage>('/error-page', TTL.STATIC, {
    title: 'Something went wrong',
    description: 'We encountered an unexpected error. Please try again.',
    retryButtonLabel: 'Try again',
    homeButtonLabel: 'Go home',
  });
}

// ─── UI Labels ────────────────────────────────────────────────────────────

export async function getPatternListingLabels(): Promise<CmsPatternListingLabels> {
  return safeFetch<CmsPatternListingLabels>('/pattern-listing-labels', TTL.LABELS, {
    pageTitle: 'Browse Patterns',
    searchPlaceholder: 'Search patterns...',
    sortByLabel: 'Sort by:',
    sortOptions: [
      { value: 'newest', label: 'Most Recent' },
      { value: 'popular', label: 'Most Popular' },
      { value: 'title', label: 'Title A-Z' },
    ],
    filterSectionHeader: 'Filters',
    clearAllLabel: 'Clear all',
    categoryLabel: 'Category',
    allCategoriesLabel: 'All Categories',
    tagsLabel: 'Tags',
    tagModeLabel: 'Match:',
    anyLabel: 'Any',
    allLabel: 'All',
    dateRangeHeader: 'Date Range',
    clearDatesLabel: 'Clear dates',
    fromLabel: 'From',
    toLabel: 'To',
    activeFiltersLabel: 'Active Filters',
    filtersButtonLabel: 'Filters',
    filterSheetTitle: 'Filter Patterns',
    filterSheetDescription: 'Refine your search by category and tags',
    savedSearchesHeader: 'Saved Searches',
    saveCurrentLabel: 'Save current',
    saveDialogTitle: 'Save Search',
    saveDialogDescription: 'Give this search a name to quickly access it later.',
    searchNameLabel: 'Search name',
    searchNamePlaceholder: 'e.g. Architecture with CQRS',
    cancelLabel: 'Cancel',
    saveLabel: 'Save',
    recentlyViewedHeader: 'Recently Viewed',
    clearLabel: 'Clear',
    previousLabel: 'Previous',
    nextLabel: 'Next',
    emptyFilteredHeading: 'No patterns found',
    emptyUnfilteredHeading: 'No patterns available',
    emptyFilteredDescription: "Try adjusting your filters or search query to find what you're looking for.",
    emptyUnfilteredDescription: 'There are no patterns yet. Check back later.',
    clearFiltersLabel: 'Clear all filters',
  });
}

export async function getPatternDetailLabels(): Promise<CmsPatternDetailLabels> {
  return safeFetch<CmsPatternDetailLabels>('/pattern-detail-labels', TTL.LABELS, {
    breadcrumbAriaLabel: 'Breadcrumb',
    voteAriaTemplate: 'Vote for this pattern. {count} votes',
    votesLabel: 'votes',
    voteAnnouncementTemplate: 'Voted! {count} total votes',
    noContentMessage: 'No content available for this pattern.',
    relatedPatternsTitle: 'Related Patterns',
    noRelatedMessage: 'No related patterns found',
    editLabel: 'Edit',
    deleteLabel: 'Delete',
    deleteDialogTitle: 'Delete Pattern?',
    deleteDialogDescription: 'This action cannot be undone. The pattern will be permanently removed.',
    cancelLabel: 'Cancel',
    deleteConfirmLabel: 'Delete',
    deletingLabel: 'Deleting...',
  });
}

export async function getPatternFormLabels(): Promise<CmsPatternFormLabels> {
  return safeFetch<CmsPatternFormLabels>('/pattern-form-labels', TTL.LABELS, {
    createTitle: 'New Pattern',
    editTitle: 'Edit Pattern',
    titleLabel: 'Title *',
    titlePlaceholder: 'e.g. CQRS Pattern for Event-Driven Systems',
    slugPreviewTemplate: 'Slug preview: {slug}',
    shortDescLabel: 'Short Description *',
    shortDescPlaceholder: 'A brief summary of the pattern (shown in listings)',
    categoryLabel: 'Category *',
    categoryPlaceholder: 'Select a category',
    tagsLabel: 'Tags',
    tagPlaceholder: 'Add a tag and press Enter',
    addTagLabel: 'Add',
    tagCountTemplate: '{count}/{max} tags',
    contentLabel: 'Full Content (Markdown)',
    contentPlaceholder: 'Write the full pattern content in Markdown...',
    authorLabel: 'Author',
    authorPlaceholder: 'Your name (optional)',
    adminSettingsLabel: 'Admin Settings',
    featuredLabel: 'Featured pattern',
    trendingLabel: 'Trending pattern',
    cancelLabel: 'Cancel',
    createLabel: 'Create Pattern',
    creatingLabel: 'Creating...',
    saveLabel: 'Save Changes',
    savingLabel: 'Saving...',
  });
}
