/**
 * Strapi 5 Seed Script
 * Populates all Single Types with current hardcoded content from the Next.js frontend.
 * Run via: npx ts-node data/seed.ts
 *
 * This script uses the Strapi REST API directly so it can be run against
 * a running instance (local or remote). Requires STRAPI_ADMIN_EMAIL and
 * STRAPI_ADMIN_PASSWORD env vars for auth, or a valid STRAPI_API_TOKEN.
 */

const STRAPI_URL = process.env.STRAPI_URL || 'http://localhost:1337';
const API_TOKEN = process.env.STRAPI_API_TOKEN;

async function apiRequest(
  method: string,
  path: string,
  body?: unknown
): Promise<unknown> {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };
  if (API_TOKEN) {
    headers['Authorization'] = `Bearer ${API_TOKEN}`;
  }

  const res = await fetch(`${STRAPI_URL}/api${path}`, {
    method,
    headers,
    body: body ? JSON.stringify({ data: body }) : undefined,
  });

  if (!res.ok) {
    const text = await res.text();
    throw new Error(`${method} ${path} → ${res.status}: ${text}`);
  }
  return res.json();
}

async function upsertSingleType(uid: string, data: unknown): Promise<void> {
  try {
    await apiRequest('PUT', `/${uid}`, data);
    console.log(`  ✓ ${uid}`);
  } catch (err) {
    console.error(`  ✗ ${uid}:`, (err as Error).message);
  }
}

async function seed() {
  console.log(`\nSeeding Strapi at ${STRAPI_URL}...\n`);

  // ─── 1. Global ──────────────────────────────────────────────────────────
  await upsertSingleType('global', {
    siteName: 'AI Enterprise Patterns Library',
    siteDescription:
      'A centralized repository of AI-driven recipes, prompts, and blueprints for enterprise software architecture patterns.',
    navigation: [
      { label: 'Home', href: '/', isExternal: false },
      { label: 'Patterns', href: '/patterns', isExternal: false },
      { label: 'About', href: '/about', isExternal: false },
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
        {
          label: 'GitHub',
          href: 'https://github.com/sandropetterle/AIEnterprisePatterns',
          isExternal: true,
        },
        { label: 'Documentation', href: '/docs', isExternal: false },
      ],
    },
    defaultSeo: {
      title: 'AI Enterprise Patterns Library',
      description:
        'A centralized repository of AI-driven recipes, prompts, and blueprints for enterprise software architecture patterns.',
      keywords:
        'AI patterns, enterprise architecture, software patterns, AI prompts, best practices, design patterns',
      ogTitle: 'AI Enterprise Patterns Library',
      ogDescription:
        'Curated AI-driven recipes, prompts, and blueprints for enterprise software architecture',
      noIndex: false,
    },
  });

  // ─── 2. Home Page ────────────────────────────────────────────────────────
  await upsertSingleType('home-page', {
    seo: {
      title: 'Home',
      description:
        'Discover curated AI-driven enterprise patterns, prompts, and architectural blueprints. Browse featured patterns and join the community.',
    },
    content: [
      {
        __component: 'sections.hero',
        heading: 'AI Enterprise Patterns Library',
        subheading:
          'Curated AI-driven recipes, prompts, and blueprints for enterprise software architecture. Discover proven patterns, best practices, and innovative solutions to accelerate your development.',
        primaryCTA: { label: 'Browse Patterns', href: '/patterns', variant: 'primary' },
        secondaryCTA: { label: 'Learn More', href: '#featured', variant: 'outline' },
      },
      {
        __component: 'sections.stats-bar',
        stats: [
          { value: '{totalPatterns}', label: 'Patterns Available', icon: 'BookOpen' },
          { value: '{totalCategories}', label: 'Categories', icon: 'Folder' },
          { value: '{totalContributors}', label: 'Contributors', icon: 'Users' },
        ],
      },
      {
        __component: 'sections.featured-patterns',
        heading: 'Featured Patterns',
        subheading: 'Explore our most popular and recently added enterprise patterns',
        viewAllLabel: 'View all patterns',
        mobileViewAllLabel: 'View all',
      },
      {
        __component: 'sections.cta-banner',
        heading: 'Ready to explore enterprise patterns?',
        description:
          'Join our community and discover proven solutions for your next project. Contribute your own patterns and help others build better software.',
        primaryCTA: { label: 'Get Started', href: '/patterns', variant: 'secondary' },
        secondaryCTA: {
          label: 'Star on GitHub',
          href: 'https://github.com/sandropetterle/AIEnterprisePatterns',
          variant: 'outline',
          icon: 'Github',
        },
        variant: 'highlighted',
      },
    ],
  });

  // ─── 3. About Page ───────────────────────────────────────────────────────
  await upsertSingleType('about-page', {
    seo: {
      title: 'About | AI Enterprise Patterns',
      description:
        'Learn about AI Enterprise Patterns Library - a curated collection of AI-driven implementation patterns, prompts, and architectural blueprints for modern software development.',
      keywords: 'about, AI patterns, enterprise architecture, software patterns, AI-assisted development, pattern library',
      ogTitle: 'About | AI Enterprise Patterns',
      ogDescription:
        'A curated collection of AI-driven implementation patterns for modern software development.',
    },
    header: {
      badge: 'About the Platform',
      title: 'AI Enterprise Patterns Library',
      subtitle:
        'A centralized repository of AI-driven recipes, prompts, and blueprints for enterprise software architecture patterns. Curated by developers, for developers.',
    },
    content: [
      {
        __component: 'sections.mission-block',
        title: 'Our Mission',
        content:
          "In the rapidly evolving landscape of AI-assisted software development, developers need proven patterns and strategies to effectively leverage AI tools in enterprise contexts. Our mission is to bridge that gap.\n\nWe curate, document, and share battle-tested patterns that help teams integrate AI into their development workflows—from architectural decisions and design patterns to prompt engineering and best practices.\n\nWhether you're building microservices, implementing clean architecture, or exploring AI-assisted code generation, you'll find practical, production-ready patterns here.",
      },
      {
        __component: 'sections.feature-grid',
        heading: 'What We Offer',
        columns: '3',
        features: [
          {
            icon: 'Code2',
            title: 'Design Patterns',
            description:
              'Architectural blueprints and implementation guides for enterprise software development',
            items: [
              { text: 'Repository Pattern with EF Core' },
              { text: 'CQRS and Event Sourcing' },
              { text: 'Clean Architecture strategies' },
              { text: 'Microservices patterns' },
            ],
          },
          {
            icon: 'Sparkles',
            title: 'AI Prompts',
            description: 'Curated prompts for AI-assisted development, code review, and refactoring',
            items: [
              { text: 'Code review prompts (SOLID, security)' },
              { text: 'Refactoring strategies' },
              { text: 'Documentation generation' },
              { text: 'Test case creation' },
            ],
          },
          {
            icon: 'BookOpen',
            title: 'Best Practices',
            description:
              'Industry-standard practices for security, performance, and code quality',
            items: [
              { text: 'OWASP security guidelines' },
              { text: 'Performance optimization' },
              { text: 'Testing strategies' },
              { text: 'Code quality metrics' },
            ],
          },
          {
            icon: 'Zap',
            title: 'Architecture Guides',
            description: 'Comprehensive guides for building scalable, maintainable systems',
            items: [
              { text: 'Cloud-native patterns' },
              { text: 'Event-driven architecture' },
              { text: 'API design principles' },
              { text: 'Database patterns' },
            ],
          },
          {
            icon: 'Users',
            title: 'Community Driven',
            description: 'Patterns contributed and validated by real enterprise developers',
            items: [
              { text: 'Peer-reviewed submissions' },
              { text: 'Real-world examples' },
              { text: 'Version control' },
              { text: 'Discussion and feedback' },
            ],
          },
          {
            icon: 'Lightbulb',
            title: 'Continuous Learning',
            description: 'Stay updated with the latest AI-assisted development practices',
            items: [
              { text: 'Regular content updates' },
              { text: 'Emerging AI patterns' },
              { text: 'Tool integrations' },
              { text: 'Case studies' },
            ],
          },
        ],
      },
      {
        __component: 'sections.tech-stack',
        heading: 'Built With',
        groups: [
          {
            title: 'Frontend',
            items: [
              { text: 'Next.js 16 (App Router)' },
              { text: 'React 19 + TypeScript' },
              { text: 'Tailwind CSS + shadcn/ui' },
            ],
          },
          {
            title: 'Backend',
            items: [
              { text: 'ASP.NET Core 8' },
              { text: 'Entity Framework Core 8' },
              { text: 'Azure Container Apps' },
            ],
          },
        ],
      },
      {
        __component: 'sections.open-source-info',
        title: 'Open Source',
        description:
          'This project is open source and welcomes contributions from the community. Whether you want to add new patterns, improve documentation, or fix bugs — all contributions are appreciated.',
        links: [
          {
            label: 'View on GitHub',
            href: 'https://github.com/sandropetterle/AIEnterprisePatterns',
            variant: 'primary',
            icon: 'Github',
          },
        ],
      },
    ],
  });

  // ─── 4. Login Page ───────────────────────────────────────────────────────
  await upsertSingleType('login-page', {
    seo: { title: 'Sign In | AI Enterprise Patterns' },
    cardTitle: 'Sign in',
    cardDescription: 'Access the AI Enterprise Patterns Library',
    signInButtonLabel: 'Continue with Microsoft',
    signInLoadingLabel: 'Redirecting...',
    footerNotice:
      'Sign-in is managed securely by Microsoft Entra. Only authorized users may access this application.',
    errorMessages: {
      OAuthSignin: 'Could not start the sign-in flow. Please try again.',
      OAuthCallback: 'Sign-in failed during callback. Please try again.',
      OAuthCreateAccount: 'Could not create your account. Please try again.',
      Callback: 'Sign-in callback failed. Please try again.',
      AccessDenied: 'Access denied. You may not have permission to access this application.',
      Verification: 'The sign-in link has expired. Please request a new one.',
      Default: 'An unexpected error occurred during sign-in. Please try again.',
    },
  });

  // ─── 5. Not Found Page ───────────────────────────────────────────────────
  await upsertSingleType('not-found-page', {
    errorCode: '404',
    heading: 'Page Not Found',
    message: 'The page you are looking for does not exist or has been moved.',
    backButton: { label: 'Back to Home', href: '/', variant: 'primary', icon: 'Home' },
  });

  // ─── 6. Error Page ───────────────────────────────────────────────────────
  await upsertSingleType('error-page', {
    title: 'Something went wrong',
    description:
      'We encountered an error while loading this page. This could be due to a temporary connection issue or a problem with our servers.',
    retryButtonLabel: 'Try again',
    homeButtonLabel: 'Go home',
  });

  // ─── 7. Pattern Listing Labels ───────────────────────────────────────────
  await upsertSingleType('pattern-listing-labels', {
    pageTitle: 'Browse Patterns',
    pageDescription:
      'Discover {count} {pattern|patterns} across AI, architecture, and engineering disciplines.',
    searchPlaceholder: 'Search patterns...',
    clearSearchLabel: 'Clear search',
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
    emptyFilteredDescription:
      "Try adjusting your filters or search query to find what you're looking for.",
    emptyUnfilteredDescription: 'There are no patterns yet. Check back later.',
    clearFiltersLabel: 'Clear all filters',
  });

  // ─── 8. Pattern Detail Labels ─────────────────────────────────────────────
  await upsertSingleType('pattern-detail-labels', {
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

  // ─── 9. Pattern Form Labels ───────────────────────────────────────────────
  await upsertSingleType('pattern-form-labels', {
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

  console.log('\nSeed complete!\n');
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
