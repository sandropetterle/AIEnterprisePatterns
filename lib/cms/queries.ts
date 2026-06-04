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

// --- fallback:global:start ---
const GLOBAL_FALLBACK: CmsGlobal = {
    "siteName": "AI Enterprise Patterns Library",
    "siteDescription": "A centralized repository of AI-driven recipes, prompts, and blueprints for enterprise software architecture patterns.",
    "mobileMenuTitle": "Menu",
    "skipToContentLabel": "Skip to main content",
    "signInLabel": "Sign In",
    "signOutLabel": "Sign Out",
    "userMenuLabel": "User menu",
    "newPatternButtonLabel": "+ New Pattern",
    "navigation": [
      {
        "label": "Home",
        "href": "/",
        "isExternal": false
      },
      {
        "label": "Patterns",
        "href": "/patterns",
        "isExternal": false
      },
      {
        "label": "About",
        "href": "/about",
        "isExternal": false
      }
    ],
    "footer": {
      "copyrightTemplate": "© {year} AI Enterprise Patterns. All rights reserved.",
      "links": [
        {
          "label": "GitHub",
          "href": "https://github.com/sandropetterle/AIEnterprisePatterns",
          "isExternal": true
        },
        {
          "label": "Documentation",
          "href": "/docs",
          "isExternal": false
        }
      ]
    }
  };
// --- fallback:global:end ---

export async function getGlobal(): Promise<CmsGlobal> {
  return safeFetch<CmsGlobal>('/global', TTL.GLOBAL, GLOBAL_FALLBACK, POPULATE.GLOBAL);
}

// ─── Pages ────────────────────────────────────────────────────────────────

export async function getHomePage(): Promise<CmsHomePage> {
  // --- fallback:home-page:start ---
  return safeFetch<CmsHomePage>('/home-page', TTL.PAGE, {
      "content": [
        {
          "__component": "sections.hero",
          "heading": "AI Enterprise Patterns Library",
          "subheading": "Curated AI-driven recipes, prompts, and blueprints for enterprise software architecture. Discover proven patterns, best practices, and innovative solutions to accelerate your development.",
          "primaryCTA": {
            "label": "Browse Patterns",
            "href": "/patterns",
            "variant": "primary"
          },
          "secondaryCTA": {
            "label": "Learn More",
            "href": "#featured",
            "variant": "outline"
          }
        },
        {
          "__component": "sections.stats-bar",
          "stats": [
            {
              "value": "{totalPatterns}",
              "label": "Patterns Available",
              "icon": "BookOpen"
            },
            {
              "value": "{totalCategories}",
              "label": "Categories",
              "icon": "Folder"
            },
            {
              "value": "{totalContributors}",
              "label": "Contributors",
              "icon": "Users"
            }
          ]
        },
        {
          "__component": "sections.featured-patterns",
          "heading": "Featured Patterns",
          "subheading": "Explore our most popular and recently added enterprise patterns",
          "viewAllLabel": "View all patterns",
          "mobileViewAllLabel": "View all"
        },
        {
          "__component": "sections.cta-banner",
          "heading": "Ready to explore enterprise patterns?",
          "description": "Join our community and discover proven solutions for your next project. Contribute your own patterns and help others build better software.",
          "variant": "highlighted",
          "primaryCTA": {
            "label": "Get Started",
            "href": "/patterns",
            "variant": "secondary"
          },
          "secondaryCTA": {
            "label": "Star on GitHub",
            "href": "https://github.com/sandropetterle/AIEnterprisePatterns",
            "variant": "outline",
            "icon": "Github"
          }
        }
      ],
      "seo": {
        "title": "Home",
        "description": "Discover curated AI-driven enterprise patterns, prompts, and architectural blueprints. Browse featured patterns and join the community."
      }
    } satisfies CmsHomePage, POPULATE.DYNAMIC_ZONE);
  // --- fallback:home-page:end ---
}

export async function getAboutPage(): Promise<CmsAboutPage> {
  // --- fallback:about-page:start ---
  return safeFetch<CmsAboutPage>('/about-page', TTL.PAGE, {
      "content": [
        {
          "__component": "sections.mission-block",
          "title": "Our Mission",
          "content": "In the rapidly evolving landscape of AI-assisted software development, developers need proven patterns and strategies to effectively leverage AI tools in enterprise contexts. Our mission is to bridge that gap.\n\nWe curate, document, and share battle-tested patterns that help teams integrate AI into their development workflows—from architectural decisions and design patterns to prompt engineering and best practices.\n\nWhether you're building microservices, implementing clean architecture, or exploring AI-assisted code generation, you'll find practical, production-ready patterns here."
        },
        {
          "__component": "sections.feature-grid",
          "heading": "What We Offer",
          "columns": "3",
          "features": [
            {
              "icon": "Code2",
              "title": "Design Patterns",
              "description": "Architectural blueprints and implementation guides for enterprise software development"
            },
            {
              "icon": "Sparkles",
              "title": "AI Prompts",
              "description": "Curated prompts for AI-assisted development, code review, and refactoring"
            },
            {
              "icon": "BookOpen",
              "title": "Best Practices",
              "description": "Industry-standard practices for security, performance, and code quality"
            },
            {
              "icon": "Zap",
              "title": "Architecture Guides",
              "description": "Comprehensive guides for building scalable, maintainable systems"
            },
            {
              "icon": "Users",
              "title": "Community Driven",
              "description": "Patterns contributed and validated by real enterprise developers"
            },
            {
              "icon": "Lightbulb",
              "title": "Continuous Learning",
              "description": "Stay updated with the latest AI-assisted development practices"
            }
          ]
        },
        {
          "__component": "sections.tech-stack",
          "heading": "Built With",
          "groups": [
            {
              "title": "Frontend"
            },
            {
              "title": "Backend"
            }
          ]
        },
        {
          "__component": "sections.open-source-info",
          "title": "Open Source",
          "description": "This project is open source and welcomes contributions from the community. Whether you want to add new patterns, improve documentation, or fix bugs — all contributions are appreciated.",
          "links": [
            {
              "label": "View on GitHub",
              "href": "https://github.com/sandropetterle/AIEnterprisePatterns",
              "variant": "primary",
              "icon": "Github"
            }
          ]
        }
      ],
      "header": {
        "badge": "About the Platform",
        "title": "AI Enterprise Patterns Library",
        "subtitle": "A centralized repository of AI-driven recipes, prompts, and blueprints for enterprise software architecture patterns. Curated by developers, for developers."
      },
      "seo": {
        "title": "About",
        "description": "Learn about AI Enterprise Patterns Library - a curated collection of AI-driven implementation patterns, prompts, and architectural blueprints for modern software development.",
        "keywords": "about, AI patterns, enterprise architecture, software patterns, AI-assisted development, pattern library",
        "ogTitle": "About | AI Enterprise Patterns",
        "ogDescription": "A curated collection of AI-driven implementation patterns for modern software development."
      }
    } satisfies CmsAboutPage, POPULATE.DYNAMIC_ZONE_WITH_HEADER);
  // --- fallback:about-page:end ---
}

export async function getDocsPage(): Promise<CmsDocsPage> {
  // --- fallback:docs-page:start ---
  return safeFetch<CmsDocsPage>('/docs-page', TTL.PAGE, {}, POPULATE.DYNAMIC_ZONE_WITH_HEADER);
  // --- fallback:docs-page:end ---
}

export async function getLoginPage(): Promise<CmsLoginPage> {
  // --- fallback:login-page:start ---
  return safeFetch<CmsLoginPage>('/login-page', TTL.STATIC, {
      "cardTitle": "Sign in",
      "cardDescription": "Access the AI Enterprise Patterns Library",
      "signInButtonLabel": "Continue with Microsoft",
      "signInLoadingLabel": "Redirecting...",
      "footerNotice": "Sign-in is managed securely by Microsoft Entra. Only authorized users may access this application.",
      "errorMessages": {
        "Default": "An unexpected error occurred during sign-in. Please try again.",
        "Callback": "Sign-in callback failed. Please try again.",
        "OAuthSignin": "Could not start the sign-in flow. Please try again.",
        "AccessDenied": "Access denied. You may not have permission to access this application.",
        "Verification": "The sign-in link has expired. Please request a new one.",
        "OAuthCallback": "Sign-in failed during callback. Please try again.",
        "OAuthCreateAccount": "Could not create your account. Please try again."
      },
      "seo": {
        "title": "Sign In | AI Enterprise Patterns",
        "noIndex": false
      }
    } satisfies CmsLoginPage);
  // --- fallback:login-page:end ---
}

export async function getNotFoundPage(): Promise<CmsNotFoundPage> {
  // --- fallback:not-found-page:start ---
  return safeFetch<CmsNotFoundPage>('/not-found-page', TTL.STATIC, {
      "errorCode": "404",
      "heading": "Page Not Found",
      "message": "The page you are looking for does not exist or has been moved.",
      "backButton": {
        "label": "Back to Home",
        "href": "/",
        "variant": "primary",
        "icon": "Home"
      }
    } satisfies CmsNotFoundPage);
  // --- fallback:not-found-page:end ---
}

export async function getErrorPage(): Promise<CmsErrorPage> {
  // --- fallback:error-page:start ---
  return safeFetch<CmsErrorPage>('/error-page', TTL.STATIC, {
      "title": "Something went wrong",
      "description": "We encountered an error while loading this page. This could be due to a temporary connection issue or a problem with our servers.",
      "retryButtonLabel": "Try again",
      "homeButtonLabel": "Go home"
    } satisfies CmsErrorPage);
  // --- fallback:error-page:end ---
}

// ─── UI Labels ────────────────────────────────────────────────────────────

export async function getPatternListingLabels(): Promise<CmsPatternListingLabels> {
  // --- fallback:pattern-listing-labels:start ---
  return safeFetch<CmsPatternListingLabels>('/pattern-listing-labels', TTL.LABELS, {
      "pageTitle": "Browse Patterns",
      "pageDescription": "Discover {count} {pattern|patterns} across AI, architecture, and engineering disciplines.",
      "searchPlaceholder": "Search patterns...",
      "clearSearchLabel": "Clear search",
      "sortByLabel": "Sort by:",
      "sortOptions": [
        {
          "label": "Most Recent",
          "value": "newest"
        },
        {
          "label": "Most Popular",
          "value": "popular"
        },
        {
          "label": "Title A-Z",
          "value": "title"
        }
      ],
      "filterSectionHeader": "Filters",
      "clearAllLabel": "Clear all",
      "categoryLabel": "Category",
      "allCategoriesLabel": "All Categories",
      "tagsLabel": "Tags",
      "tagModeLabel": "Match:",
      "anyLabel": "Any",
      "allLabel": "All",
      "dateRangeHeader": "Date Range",
      "clearDatesLabel": "Clear dates",
      "fromLabel": "From",
      "toLabel": "To",
      "activeFiltersLabel": "Active Filters",
      "filtersButtonLabel": "Filters",
      "filterSheetTitle": "Filter Patterns",
      "filterSheetDescription": "Refine your search by category and tags",
      "savedSearchesHeader": "Saved Searches",
      "saveCurrentLabel": "Save current",
      "saveDialogTitle": "Save Search",
      "saveDialogDescription": "Give this search a name to quickly access it later.",
      "searchNameLabel": "Search name",
      "searchNamePlaceholder": "e.g. Architecture with CQRS",
      "cancelLabel": "Cancel",
      "saveLabel": "Save",
      "recentlyViewedHeader": "Recently Viewed",
      "clearLabel": "Clear",
      "previousLabel": "Previous",
      "nextLabel": "Next",
      "emptyFilteredHeading": "No patterns found",
      "emptyUnfilteredHeading": "No patterns available",
      "emptyFilteredDescription": "Try adjusting your filters or search query to find what you're looking for.",
      "emptyUnfilteredDescription": "There are no patterns yet. Check back later.",
      "clearFiltersLabel": "Clear all filters"
    } satisfies CmsPatternListingLabels);
  // --- fallback:pattern-listing-labels:end ---
}

export async function getPatternDetailLabels(): Promise<CmsPatternDetailLabels> {
  // --- fallback:pattern-detail-labels:start ---
  return safeFetch<CmsPatternDetailLabels>('/pattern-detail-labels', TTL.LABELS, {
      "breadcrumbAriaLabel": "Breadcrumb",
      "voteAriaTemplate": "Vote for this pattern. {count} votes",
      "votesLabel": "votes",
      "voteAnnouncementTemplate": "Voted! {count} total votes",
      "noContentMessage": "No content available for this pattern.",
      "relatedPatternsTitle": "Related Patterns",
      "noRelatedMessage": "No related patterns found",
      "editLabel": "Edit",
      "deleteLabel": "Delete",
      "deleteDialogTitle": "Delete Pattern?",
      "deleteDialogDescription": "This action cannot be undone. The pattern will be permanently removed.",
      "cancelLabel": "Cancel",
      "deleteConfirmLabel": "Delete",
      "deletingLabel": "Deleting..."
    } satisfies CmsPatternDetailLabels);
  // --- fallback:pattern-detail-labels:end ---
}

export async function getPatternFormLabels(): Promise<CmsPatternFormLabels> {
  // --- fallback:pattern-form-labels:start ---
  return safeFetch<CmsPatternFormLabels>('/pattern-form-labels', TTL.LABELS, {
      "createTitle": "New Pattern",
      "editTitle": "Edit Pattern",
      "titleLabel": "Title *",
      "titlePlaceholder": "e.g. CQRS Pattern for Event-Driven Systems",
      "slugPreviewTemplate": "Slug preview: {slug}",
      "shortDescLabel": "Short Description *",
      "shortDescPlaceholder": "A brief summary of the pattern (shown in listings)",
      "categoryLabel": "Category *",
      "categoryPlaceholder": "Select a category",
      "tagsLabel": "Tags",
      "tagPlaceholder": "Add a tag and press Enter",
      "addTagLabel": "Add",
      "tagCountTemplate": "{count}/{max} tags",
      "contentLabel": "Full Content (Markdown)",
      "contentPlaceholder": "Write the full pattern content in Markdown...",
      "authorLabel": "Author",
      "authorPlaceholder": "Your name (optional)",
      "adminSettingsLabel": "Admin Settings",
      "featuredLabel": "Featured pattern",
      "trendingLabel": "Trending pattern",
      "cancelLabel": "Cancel",
      "createLabel": "Create Pattern",
      "creatingLabel": "Creating...",
      "saveLabel": "Save Changes",
      "savingLabel": "Saving..."
    } satisfies CmsPatternFormLabels);
  // --- fallback:pattern-form-labels:end ---
}
