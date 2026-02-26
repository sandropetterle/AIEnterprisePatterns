import type { Schema, Struct } from '@strapi/strapi';

export interface LayoutCtaButton extends Struct.ComponentSchema {
  collectionName: 'components_layout_cta_buttons';
  info: {
    displayName: 'CTA Button';
    icon: 'cursor';
  };
  attributes: {
    href: Schema.Attribute.String & Schema.Attribute.Required;
    icon: Schema.Attribute.String;
    label: Schema.Attribute.String & Schema.Attribute.Required;
    variant: Schema.Attribute.Enumeration<
      ['primary', 'secondary', 'outline', 'ghost']
    > &
      Schema.Attribute.DefaultTo<'primary'>;
  };
}

export interface LayoutFooterConfig extends Struct.ComponentSchema {
  collectionName: 'components_layout_footer_configs';
  info: {
    displayName: 'Footer Config';
    icon: 'layout';
  };
  attributes: {
    copyrightTemplate: Schema.Attribute.String &
      Schema.Attribute.Required &
      Schema.Attribute.DefaultTo<'\u00A9 {year} AI Enterprise Patterns. All rights reserved.'>;
    links: Schema.Attribute.Component<'layout.nav-link', true>;
  };
}

export interface LayoutNavLink extends Struct.ComponentSchema {
  collectionName: 'components_layout_nav_links';
  info: {
    displayName: 'Nav Link';
    icon: 'link';
  };
  attributes: {
    href: Schema.Attribute.String & Schema.Attribute.Required;
    icon: Schema.Attribute.String;
    isExternal: Schema.Attribute.Boolean & Schema.Attribute.DefaultTo<false>;
    label: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SectionsApiReference extends Struct.ComponentSchema {
  collectionName: 'components_sections_api_references';
  info: {
    displayName: 'API Reference';
    icon: 'server';
  };
  attributes: {
    baseUrl: Schema.Attribute.String;
    description: Schema.Attribute.Text;
    endpoints: Schema.Attribute.Component<'shared.api-endpoint', true>;
    exampleCode: Schema.Attribute.RichText;
    swaggerNote: Schema.Attribute.RichText;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SectionsContributing extends Struct.ComponentSchema {
  collectionName: 'components_sections_contributings';
  info: {
    displayName: 'Contributing';
    icon: 'user';
  };
  attributes: {
    ctaButton: Schema.Attribute.Component<'layout.cta-button', false>;
    description: Schema.Attribute.Text;
    guidelines: Schema.Attribute.Component<'shared.text-item', true>;
    guidelinesTitle: Schema.Attribute.String;
    howToTitle: Schema.Attribute.String;
    steps: Schema.Attribute.RichText;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SectionsCtaBanner extends Struct.ComponentSchema {
  collectionName: 'components_sections_cta_banners';
  info: {
    displayName: 'CTA Banner';
    icon: 'megaphone';
  };
  attributes: {
    description: Schema.Attribute.RichText;
    heading: Schema.Attribute.String & Schema.Attribute.Required;
    primaryCTA: Schema.Attribute.Component<'layout.cta-button', false>;
    secondaryCTA: Schema.Attribute.Component<'layout.cta-button', false>;
    variant: Schema.Attribute.Enumeration<['default', 'highlighted']> &
      Schema.Attribute.DefaultTo<'default'>;
  };
}

export interface SectionsDocSection extends Struct.ComponentSchema {
  collectionName: 'components_sections_doc_sections';
  info: {
    displayName: 'Doc Section';
    icon: 'file';
  };
  attributes: {
    anchorId: Schema.Attribute.String & Schema.Attribute.Required;
    content: Schema.Attribute.RichText & Schema.Attribute.Required;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SectionsFeatureGrid extends Struct.ComponentSchema {
  collectionName: 'components_sections_feature_grids';
  info: {
    displayName: 'Feature Grid';
    icon: 'apps';
  };
  attributes: {
    columns: Schema.Attribute.Enumeration<['2', '3', '4']> &
      Schema.Attribute.DefaultTo<'3'>;
    features: Schema.Attribute.Component<'shared.feature-card', true>;
    heading: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SectionsFeaturedPatterns extends Struct.ComponentSchema {
  collectionName: 'components_sections_featured_patterns';
  info: {
    displayName: 'Featured Patterns';
    icon: 'star';
  };
  attributes: {
    heading: Schema.Attribute.String & Schema.Attribute.Required;
    mobileViewAllLabel: Schema.Attribute.String &
      Schema.Attribute.DefaultTo<'View all'>;
    subheading: Schema.Attribute.String;
    viewAllLabel: Schema.Attribute.String &
      Schema.Attribute.DefaultTo<'View all patterns'>;
  };
}

export interface SectionsHero extends Struct.ComponentSchema {
  collectionName: 'components_sections_heroes';
  info: {
    displayName: 'Hero';
    icon: 'landscape';
  };
  attributes: {
    backgroundImage: Schema.Attribute.Media<'images'>;
    heading: Schema.Attribute.String & Schema.Attribute.Required;
    primaryCTA: Schema.Attribute.Component<'layout.cta-button', false>;
    secondaryCTA: Schema.Attribute.Component<'layout.cta-button', false>;
    subheading: Schema.Attribute.RichText;
  };
}

export interface SectionsMissionBlock extends Struct.ComponentSchema {
  collectionName: 'components_sections_mission_blocks';
  info: {
    displayName: 'Mission Block';
    icon: 'rocket';
  };
  attributes: {
    content: Schema.Attribute.RichText & Schema.Attribute.Required;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SectionsOpenSourceInfo extends Struct.ComponentSchema {
  collectionName: 'components_sections_open_source_infos';
  info: {
    displayName: 'Open Source Info';
    icon: 'code';
  };
  attributes: {
    description: Schema.Attribute.RichText;
    links: Schema.Attribute.Component<'layout.cta-button', true>;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SectionsPageHeader extends Struct.ComponentSchema {
  collectionName: 'components_sections_page_headers';
  info: {
    displayName: 'Page Header';
    icon: 'bold';
  };
  attributes: {
    badge: Schema.Attribute.String;
    subtitle: Schema.Attribute.RichText;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SectionsQuickNav extends Struct.ComponentSchema {
  collectionName: 'components_sections_quick_navs';
  info: {
    displayName: 'Quick Nav';
    icon: 'arrowRight';
  };
  attributes: {
    heading: Schema.Attribute.String & Schema.Attribute.Required;
    items: Schema.Attribute.Component<'shared.quick-nav-item', true>;
  };
}

export interface SectionsRichText extends Struct.ComponentSchema {
  collectionName: 'components_sections_rich_texts';
  info: {
    displayName: 'Rich Text';
    icon: 'file';
  };
  attributes: {
    body: Schema.Attribute.RichText & Schema.Attribute.Required;
  };
}

export interface SectionsStatsBar extends Struct.ComponentSchema {
  collectionName: 'components_sections_stats_bars';
  info: {
    displayName: 'Stats Bar';
    icon: 'chartBubble';
  };
  attributes: {
    stats: Schema.Attribute.Component<'shared.stat-item', true>;
  };
}

export interface SectionsSupportLinks extends Struct.ComponentSchema {
  collectionName: 'components_sections_support_links';
  info: {
    displayName: 'Support Links';
    icon: 'question';
  };
  attributes: {
    description: Schema.Attribute.Text;
    items: Schema.Attribute.Component<'shared.support-item', true>;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SectionsTechStack extends Struct.ComponentSchema {
  collectionName: 'components_sections_tech_stacks';
  info: {
    displayName: 'Tech Stack';
    icon: 'code';
  };
  attributes: {
    groups: Schema.Attribute.Component<'shared.tech-group', true>;
    heading: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SeoMetadata extends Struct.ComponentSchema {
  collectionName: 'components_seo_metadata';
  info: {
    displayName: 'SEO Metadata';
    icon: 'search';
  };
  attributes: {
    description: Schema.Attribute.Text;
    keywords: Schema.Attribute.Text;
    noIndex: Schema.Attribute.Boolean & Schema.Attribute.DefaultTo<false>;
    ogDescription: Schema.Attribute.Text;
    ogImage: Schema.Attribute.Media<'images'>;
    ogTitle: Schema.Attribute.String;
    title: Schema.Attribute.String;
  };
}

export interface SharedApiEndpoint extends Struct.ComponentSchema {
  collectionName: 'components_shared_api_endpoints';
  info: {
    displayName: 'API Endpoint';
    icon: 'server';
  };
  attributes: {
    authRequired: Schema.Attribute.Boolean & Schema.Attribute.DefaultTo<false>;
    description: Schema.Attribute.String & Schema.Attribute.Required;
    method: Schema.Attribute.Enumeration<['GET', 'POST', 'PUT', 'DELETE']> &
      Schema.Attribute.Required &
      Schema.Attribute.DefaultTo<'GET'>;
    path: Schema.Attribute.String & Schema.Attribute.Required;
    queryParams: Schema.Attribute.Component<'shared.key-value', true>;
    rateLimit: Schema.Attribute.String;
  };
}

export interface SharedFeatureCard extends Struct.ComponentSchema {
  collectionName: 'components_shared_feature_card';
  info: {
    description: 'A feature card with icon, title, description, and list of items';
    displayName: 'Feature Card';
    icon: 'star';
  };
  attributes: {
    description: Schema.Attribute.String & Schema.Attribute.Required;
    icon: Schema.Attribute.String & Schema.Attribute.Required;
    items: Schema.Attribute.Component<'shared.text-item', true>;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SharedKeyValue extends Struct.ComponentSchema {
  collectionName: 'components_shared_key_value';
  info: {
    description: 'A key-value pair for metadata and configuration';
    displayName: 'Key Value';
    icon: 'code';
  };
  attributes: {
    key: Schema.Attribute.String & Schema.Attribute.Required;
    value: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SharedQuickNavItem extends Struct.ComponentSchema {
  collectionName: 'components_shared_quick_nav_items';
  info: {
    displayName: 'Quick Nav Item';
    icon: 'arrowRight';
  };
  attributes: {
    description: Schema.Attribute.String & Schema.Attribute.Required;
    href: Schema.Attribute.String & Schema.Attribute.Required;
    icon: Schema.Attribute.String;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SharedStatItem extends Struct.ComponentSchema {
  collectionName: 'components_shared_stat_item';
  info: {
    description: 'A statistic with value, label, and optional icon';
    displayName: 'Stat Item';
    icon: 'chartPie';
  };
  attributes: {
    icon: Schema.Attribute.String;
    label: Schema.Attribute.String & Schema.Attribute.Required;
    value: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SharedSupportItem extends Struct.ComponentSchema {
  collectionName: 'components_shared_support_items';
  info: {
    displayName: 'Support Item';
    icon: 'question';
  };
  attributes: {
    description: Schema.Attribute.String & Schema.Attribute.Required;
    href: Schema.Attribute.String & Schema.Attribute.Required;
    icon: Schema.Attribute.String;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SharedTechGroup extends Struct.ComponentSchema {
  collectionName: 'components_shared_tech_groups';
  info: {
    displayName: 'Tech Group';
    icon: 'code';
  };
  attributes: {
    items: Schema.Attribute.Component<'shared.text-item', true>;
    title: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

export interface SharedTextItem extends Struct.ComponentSchema {
  collectionName: 'components_shared_text_item';
  info: {
    description: 'A simple text item for use in repeatable lists';
    displayName: 'Text Item';
    icon: 'feather';
  };
  attributes: {
    text: Schema.Attribute.String & Schema.Attribute.Required;
  };
}

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'layout.cta-button': LayoutCtaButton;
      'layout.footer-config': LayoutFooterConfig;
      'layout.nav-link': LayoutNavLink;
      'sections.api-reference': SectionsApiReference;
      'sections.contributing': SectionsContributing;
      'sections.cta-banner': SectionsCtaBanner;
      'sections.doc-section': SectionsDocSection;
      'sections.feature-grid': SectionsFeatureGrid;
      'sections.featured-patterns': SectionsFeaturedPatterns;
      'sections.hero': SectionsHero;
      'sections.mission-block': SectionsMissionBlock;
      'sections.open-source-info': SectionsOpenSourceInfo;
      'sections.page-header': SectionsPageHeader;
      'sections.quick-nav': SectionsQuickNav;
      'sections.rich-text': SectionsRichText;
      'sections.stats-bar': SectionsStatsBar;
      'sections.support-links': SectionsSupportLinks;
      'sections.tech-stack': SectionsTechStack;
      'seo.metadata': SeoMetadata;
      'shared.api-endpoint': SharedApiEndpoint;
      'shared.feature-card': SharedFeatureCard;
      'shared.key-value': SharedKeyValue;
      'shared.quick-nav-item': SharedQuickNavItem;
      'shared.stat-item': SharedStatItem;
      'shared.support-item': SharedSupportItem;
      'shared.tech-group': SharedTechGroup;
      'shared.text-item': SharedTextItem;
    }
  }
}
