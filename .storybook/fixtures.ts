/**
 * Shared mock data fixtures for Storybook stories.
 * Import from this file to get consistent test data across stories.
 * Field names mirror the CMS types in lib/cms/types.ts exactly.
 */
import type { Pattern } from '../lib/types/pattern'
import type {
  CmsNavLink,
  CmsCtaButton,
  CmsStatItem,
  CmsFeatureCard,
  CmsTechGroup,
  CmsApiEndpoint,
  CmsQuickNavItem,
  CmsSupportItem,
  CmsFooterConfig,
  CmsHeroBlock,
  CmsStatsBarBlock,
  CmsFeaturedPatternsBlock,
  CmsRichTextBlock,
  CmsCtaBannerBlock,
  CmsFeatureGridBlock,
  CmsTechStackBlock,
  CmsMissionBlock,
  CmsOpenSourceInfoBlock,
  CmsPageHeaderBlock,
  CmsDocSectionBlock,
  CmsApiReferenceBlock,
  CmsQuickNavBlock,
  CmsContributingBlock,
  CmsSupportLinksBlock,
} from '../lib/cms/types'

// ---------- Pattern fixtures ----------

export const MOCK_PATTERN: Pattern = {
  id: 'b0000000-0000-0000-0000-000000000001',
  title: 'Chain of Thought Prompting',
  slug: 'chain-of-thought-prompting',
  shortDescription:
    'Guide LLMs to reason step-by-step before producing a final answer, significantly improving accuracy on complex reasoning tasks.',
  fullContent: `## Overview\n\nChain of Thought (CoT) prompting encourages the model to show its reasoning before giving a final answer.\n\n## When to use\n\nUse CoT when:\n- The task requires multi-step reasoning\n- Accuracy is more important than speed\n\n## Example\n\n\`\`\`\nQ: Roger has 5 tennis balls. He buys 2 more cans of 3 balls each. How many tennis balls does he have?\nA: Roger started with 5. 2 cans × 3 = 6. Total: 5 + 6 = 11.\n\`\`\``,
  category: 'AI Prompts',
  tags: ['prompting', 'reasoning', 'llm', 'accuracy'],
  author: 'Alice Chen',
  createdDate: '2024-01-15T10:00:00Z',
  updatedDate: '2024-02-20T14:30:00Z',
  voteCount: 142,
  status: 'published',
  isFeatured: true,
  isTrending: false,
}

export const MOCK_PATTERN_ARCHITECTURE: Pattern = {
  id: 'b0000000-0000-0000-0000-000000000002',
  title: 'Event-Driven Microservices',
  slug: 'event-driven-microservices',
  shortDescription:
    'Decouple services using asynchronous events to improve scalability and resilience in distributed systems.',
  category: 'Architecture',
  tags: ['microservices', 'events', 'kafka', 'async'],
  author: 'Bob Smith',
  createdDate: '2024-02-01T09:00:00Z',
  updatedDate: '2024-03-10T11:00:00Z',
  voteCount: 89,
  status: 'published',
  isFeatured: false,
  isTrending: true,
}

export const MOCK_PATTERN_SECURITY: Pattern = {
  id: 'b0000000-0000-0000-0000-000000000003',
  title: 'Zero Trust Security Model',
  slug: 'zero-trust-security',
  shortDescription:
    'Never trust, always verify. Apply strict identity verification for every person and device attempting to access resources.',
  category: 'Security',
  tags: ['security', 'identity', 'zero-trust', 'authentication'],
  author: 'Carol Davis',
  createdDate: '2024-03-05T08:00:00Z',
  updatedDate: '2024-03-15T16:00:00Z',
  voteCount: 67,
  status: 'published',
  isFeatured: false,
  isTrending: false,
}

export const MOCK_PATTERNS: Pattern[] = [
  MOCK_PATTERN,
  MOCK_PATTERN_ARCHITECTURE,
  MOCK_PATTERN_SECURITY,
]

// ---------- CMS component fixtures ----------

export const MOCK_NAV_LINKS: CmsNavLink[] = [
  { label: 'Patterns', href: '/patterns' },
  { label: 'About', href: '/about' },
  { label: 'Docs', href: '/docs' },
]

export const MOCK_FOOTER_CONFIG: CmsFooterConfig = {
  copyrightTemplate: '© {year} AI Enterprise Patterns. All rights reserved.',
  links: [
    { label: 'GitHub', href: 'https://github.com', isExternal: true },
    { label: 'Privacy', href: '/privacy' },
  ],
}

export const MOCK_CTA_PRIMARY: CmsCtaButton = {
  label: 'Browse Patterns',
  href: '/patterns',
  variant: 'primary',
}

export const MOCK_CTA_SECONDARY: CmsCtaButton = {
  label: 'View on GitHub',
  href: 'https://github.com',
  variant: 'outline',
}

export const MOCK_STAT_ITEMS: CmsStatItem[] = [
  { label: 'Patterns', value: '42', icon: 'BookOpen' },
  { label: 'Categories', value: '8', icon: 'Folder' },
  { label: 'Contributors', value: '120+', icon: 'Users' },
]

export const MOCK_FEATURE_CARDS: CmsFeatureCard[] = [
  { title: 'Proven Patterns', description: 'Battle-tested solutions used by leading enterprises.', icon: 'Shield' },
  { title: 'AI-Powered', description: 'Optimized for AI-assisted development workflows.', icon: 'Sparkles' },
  { title: 'Open Source', description: 'Community-driven and freely available to everyone.', icon: 'Code' },
]

export const MOCK_TECH_GROUPS: CmsTechGroup[] = [
  {
    title: 'Frontend',
    items: [{ text: 'Next.js' }, { text: 'React 19' }, { text: 'TypeScript' }, { text: 'Tailwind CSS' }],
  },
  {
    title: 'Backend',
    items: [{ text: 'ASP.NET Core 8' }, { text: 'Entity Framework Core' }, { text: 'SQLite / Azure SQL' }],
  },
]

export const MOCK_API_ENDPOINTS: CmsApiEndpoint[] = [
  { method: 'GET', path: '/api/patterns', description: 'List patterns with filtering and pagination' },
  { method: 'GET', path: '/api/patterns/{slug}', description: 'Get a single pattern by slug' },
  { method: 'POST', path: '/api/patterns/{id}/vote', description: 'Vote on a pattern', rateLimit: '10/min' },
]

export const MOCK_QUICK_NAV_ITEMS: CmsQuickNavItem[] = [
  { title: 'Overview', description: 'Introduction and goals', href: '#overview' },
  { title: 'Getting Started', description: 'Quick start guide', href: '#getting-started' },
  { title: 'REST API', description: 'API reference', href: '#rest-api' },
]

export const MOCK_SUPPORT_ITEMS: CmsSupportItem[] = [
  { title: 'GitHub Issues', description: 'Report bugs or request features', href: 'https://github.com' },
  { title: 'Discussions', description: 'Ask questions and share ideas', href: 'https://github.com' },
]

// ---------- CMS Block fixtures ----------

export const MOCK_HERO_BLOCK: CmsHeroBlock = {
  __component: 'sections.hero',
  heading: 'AI Enterprise Patterns Library',
  subheading: 'Discover battle-tested AI patterns for building enterprise-grade AI systems.',
  primaryCTA: MOCK_CTA_PRIMARY,
  secondaryCTA: MOCK_CTA_SECONDARY,
}

export const MOCK_STATS_BAR_BLOCK: CmsStatsBarBlock = {
  __component: 'sections.stats-bar',
  stats: MOCK_STAT_ITEMS,
}

export const MOCK_FEATURED_PATTERNS_BLOCK: CmsFeaturedPatternsBlock = {
  __component: 'sections.featured-patterns',
  heading: 'Featured Patterns',
  subheading: 'Curated patterns from our community of enterprise architects.',
  viewAllLabel: 'View All Patterns',
  mobileViewAllLabel: 'View All',
}

export const MOCK_RICH_TEXT_BLOCK: CmsRichTextBlock = {
  __component: 'sections.rich-text',
  body: `## What is the AI Enterprise Patterns Library?\n\nA curated collection of proven patterns for building AI-powered enterprise applications.\n\n### Key benefits\n\n- **Reusable** — apply patterns across projects\n- **Documented** — clear rationale for each decision\n- **Community-driven** — contributed by practitioners`,
}

export const MOCK_CTA_BANNER_BLOCK: CmsCtaBannerBlock = {
  __component: 'sections.cta-banner',
  heading: 'Ready to build smarter?',
  description: 'Join hundreds of engineers using AI Enterprise Patterns.',
  primaryCTA: MOCK_CTA_PRIMARY,
  secondaryCTA: MOCK_CTA_SECONDARY,
}

export const MOCK_FEATURE_GRID_BLOCK: CmsFeatureGridBlock = {
  __component: 'sections.feature-grid',
  heading: 'Why use this library?',
  features: MOCK_FEATURE_CARDS,
}

export const MOCK_TECH_STACK_BLOCK: CmsTechStackBlock = {
  __component: 'sections.tech-stack',
  heading: 'Built with modern technologies',
  groups: MOCK_TECH_GROUPS,
}

export const MOCK_MISSION_BLOCK: CmsMissionBlock = {
  __component: 'sections.mission-block',
  title: 'Our Mission',
  content: 'Accelerate enterprise AI adoption through a shared language of proven architectural patterns.',
}

export const MOCK_OPEN_SOURCE_INFO_BLOCK: CmsOpenSourceInfoBlock = {
  __component: 'sections.open-source-info',
  title: 'Open Source & Community-Driven',
  description: 'All patterns are freely available. Contribute on GitHub to help the community grow.',
  links: [{ label: 'Star on GitHub', href: 'https://github.com', variant: 'outline' }],
}

export const MOCK_PAGE_HEADER_BLOCK: CmsPageHeaderBlock = {
  __component: 'sections.page-header',
  title: 'About',
  subtitle: 'Learn more about the AI Enterprise Patterns Library.',
}

export const MOCK_DOC_SECTION_BLOCK: CmsDocSectionBlock = {
  __component: 'sections.doc-section',
  anchorId: 'getting-started',
  title: 'Getting Started',
  content: 'Browse the pattern library and pick patterns relevant to your use case. Each pattern includes a rationale, example implementation, and trade-offs.',
}

export const MOCK_API_REFERENCE_BLOCK: CmsApiReferenceBlock = {
  __component: 'sections.api-reference',
  title: 'REST API',
  baseUrl: 'https://api.aipatterns.dev',
  endpoints: MOCK_API_ENDPOINTS,
}

export const MOCK_QUICK_NAV_BLOCK: CmsQuickNavBlock = {
  __component: 'sections.quick-nav',
  heading: 'On this page',
  items: MOCK_QUICK_NAV_ITEMS,
}

export const MOCK_CONTRIBUTING_BLOCK: CmsContributingBlock = {
  __component: 'sections.contributing',
  title: 'How to Contribute',
  description: 'We welcome contributions! Open a pull request on GitHub with your new pattern.',
  howToTitle: 'Steps',
  steps: '1. Fork the repository\n2. Add your pattern\n3. Submit a pull request',
  guidelines: [
    { text: 'Follow the pattern template' },
    { text: 'Include a clear rationale' },
    { text: 'Add usage examples' },
  ],
  ctaButton: { label: 'Open an Issue', href: 'https://github.com', variant: 'outline' },
}

export const MOCK_SUPPORT_LINKS_BLOCK: CmsSupportLinksBlock = {
  __component: 'sections.support-links',
  title: 'Get Help',
  description: 'Several ways to get support.',
  items: MOCK_SUPPORT_ITEMS,
}
