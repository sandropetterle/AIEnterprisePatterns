mysqldump: [Warning] Using a password on the command line interface can be insecure.
-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: mysql-aipatterns-cms.mysql.database.azure.com    Database: strapi_cms
-- ------------------------------------------------------
-- Server version	8.0.42-azure

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `about_page`
--

DROP TABLE IF EXISTS `about_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `about_page` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `about_page_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `about_page_created_by_id_fk` (`created_by_id`),
  KEY `about_page_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `about_page_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `about_page_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `about_page`
--

LOCK TABLES `about_page` WRITE;
/*!40000 ALTER TABLE `about_page` DISABLE KEYS */;
INSERT INTO `about_page` VALUES (1,'nwkn7luco01bbzpkhx43m4jy','2026-02-26 18:27:42.595000','2026-02-26 18:27:42.595000',NULL,NULL,NULL,NULL),(2,'nwkn7luco01bbzpkhx43m4jy','2026-02-26 18:27:42.595000','2026-02-26 18:27:42.595000','2026-02-26 18:27:45.021000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `about_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `about_page_cmps`
--

DROP TABLE IF EXISTS `about_page_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `about_page_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `about_page_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `about_page_field_idx` (`field`),
  KEY `about_page_component_type_idx` (`component_type`),
  KEY `about_page_entity_fk` (`entity_id`),
  CONSTRAINT `about_page_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `about_page` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `about_page_cmps`
--

LOCK TABLES `about_page_cmps` WRITE;
/*!40000 ALTER TABLE `about_page_cmps` DISABLE KEYS */;
INSERT INTO `about_page_cmps` VALUES (1,1,4,'seo.metadata','seo',NULL),(2,1,1,'sections.page-header','header',NULL),(3,1,1,'sections.mission-block','content',1),(4,1,1,'sections.feature-grid','content',2),(5,1,1,'sections.tech-stack','content',3),(6,1,1,'sections.open-source-info','content',4),(7,2,5,'seo.metadata','seo',NULL),(8,2,2,'sections.page-header','header',NULL),(9,2,2,'sections.mission-block','content',1),(10,2,2,'sections.feature-grid','content',2),(11,2,2,'sections.tech-stack','content',3),(12,2,2,'sections.open-source-info','content',4);
/*!40000 ALTER TABLE `about_page_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_permissions`
--

DROP TABLE IF EXISTS `admin_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_permissions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `action_parameters` json DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `properties` json DEFAULT NULL,
  `conditions` json DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `admin_permissions_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `admin_permissions_created_by_id_fk` (`created_by_id`),
  KEY `admin_permissions_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `admin_permissions_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `admin_permissions_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_permissions`
--

LOCK TABLES `admin_permissions` WRITE;
/*!40000 ALTER TABLE `admin_permissions` DISABLE KEYS */;
INSERT INTO `admin_permissions` VALUES (1,'ip9wtsm38jbij8rdoay1pq4x','plugin::content-manager.explorer.create','{}','api::about-page.about-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"header.badge\", \"header.title\", \"header.subtitle\", \"content\"]}','[]','2026-02-26 18:22:30.158000','2026-02-26 18:22:30.158000','2026-02-26 18:22:30.159000',NULL,NULL,NULL),(2,'kv1ys1kp7cf1qngu2s5nkiau','plugin::content-manager.explorer.create','{}','api::docs-page.docs-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"header.badge\", \"header.title\", \"header.subtitle\", \"content\"]}','[]','2026-02-26 18:22:30.897000','2026-02-26 18:22:30.897000','2026-02-26 18:22:30.897000',NULL,NULL,NULL),(3,'uwdzhb8yeb22su6czgskdhsg','plugin::content-manager.explorer.create','{}','api::error-page.error-page','{\"fields\": [\"title\", \"description\", \"retryButtonLabel\", \"homeButtonLabel\"]}','[]','2026-02-26 18:22:31.636000','2026-02-26 18:22:31.636000','2026-02-26 18:22:31.636000',NULL,NULL,NULL),(4,'ibrsqaibcf405y80ph7bdr9r','plugin::content-manager.explorer.create','{}','api::global.global','{\"fields\": [\"siteName\", \"siteDescription\", \"logo\", \"navigation.label\", \"navigation.href\", \"navigation.icon\", \"navigation.isExternal\", \"mobileMenuTitle\", \"skipToContentLabel\", \"signInLabel\", \"signOutLabel\", \"userMenuLabel\", \"newPatternButtonLabel\", \"footer.copyrightTemplate\", \"footer.links.label\", \"footer.links.href\", \"footer.links.icon\", \"footer.links.isExternal\", \"defaultSeo.title\", \"defaultSeo.description\", \"defaultSeo.keywords\", \"defaultSeo.ogImage\", \"defaultSeo.ogTitle\", \"defaultSeo.ogDescription\", \"defaultSeo.noIndex\"]}','[]','2026-02-26 18:22:32.373000','2026-02-26 18:22:32.373000','2026-02-26 18:22:32.374000',NULL,NULL,NULL),(5,'pa8rqfeekizs3gmjhazn71p9','plugin::content-manager.explorer.create','{}','api::home-page.home-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"content\"]}','[]','2026-02-26 18:22:33.112000','2026-02-26 18:22:33.112000','2026-02-26 18:22:33.112000',NULL,NULL,NULL),(6,'c84c27er9kqpnuchk13jrue0','plugin::content-manager.explorer.create','{}','api::login-page.login-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"cardTitle\", \"cardDescription\", \"signInButtonLabel\", \"signInLoadingLabel\", \"footerNotice\", \"errorMessages\"]}','[]','2026-02-26 18:22:33.849000','2026-02-26 18:22:33.849000','2026-02-26 18:22:33.849000',NULL,NULL,NULL),(7,'akq31b7cy9f7yq8toaz9je19','plugin::content-manager.explorer.create','{}','api::not-found-page.not-found-page','{\"fields\": [\"errorCode\", \"heading\", \"message\", \"backButton.label\", \"backButton.href\", \"backButton.variant\", \"backButton.icon\"]}','[]','2026-02-26 18:22:34.587000','2026-02-26 18:22:34.587000','2026-02-26 18:22:34.587000',NULL,NULL,NULL),(8,'tkg57wuyrl30kn1zgm2g7rfi','plugin::content-manager.explorer.create','{}','api::pattern-detail-labels.pattern-detail-labels','{\"fields\": [\"breadcrumbAriaLabel\", \"voteAriaTemplate\", \"votesLabel\", \"voteAnnouncementTemplate\", \"noContentMessage\", \"relatedPatternsTitle\", \"noRelatedMessage\", \"editLabel\", \"deleteLabel\", \"deleteDialogTitle\", \"deleteDialogDescription\", \"cancelLabel\", \"deleteConfirmLabel\", \"deletingLabel\"]}','[]','2026-02-26 18:22:35.325000','2026-02-26 18:22:35.325000','2026-02-26 18:22:35.326000',NULL,NULL,NULL),(9,'hxsk0n80l4trjqayo6alipfm','plugin::content-manager.explorer.create','{}','api::pattern-form-labels.pattern-form-labels','{\"fields\": [\"createTitle\", \"editTitle\", \"titleLabel\", \"titlePlaceholder\", \"slugPreviewTemplate\", \"shortDescLabel\", \"shortDescPlaceholder\", \"categoryLabel\", \"categoryPlaceholder\", \"tagsLabel\", \"tagPlaceholder\", \"addTagLabel\", \"tagCountTemplate\", \"contentLabel\", \"contentPlaceholder\", \"authorLabel\", \"authorPlaceholder\", \"adminSettingsLabel\", \"featuredLabel\", \"trendingLabel\", \"cancelLabel\", \"createLabel\", \"creatingLabel\", \"saveLabel\", \"savingLabel\"]}','[]','2026-02-26 18:22:36.066000','2026-02-26 18:22:36.066000','2026-02-26 18:22:36.066000',NULL,NULL,NULL),(10,'opjge4fdogv84417xt03o9mf','plugin::content-manager.explorer.create','{}','api::pattern-listing-labels.pattern-listing-labels','{\"fields\": [\"pageTitle\", \"pageDescription\", \"searchPlaceholder\", \"clearSearchLabel\", \"sortByLabel\", \"sortOptions\", \"filterSectionHeader\", \"clearAllLabel\", \"categoryLabel\", \"allCategoriesLabel\", \"tagsLabel\", \"tagModeLabel\", \"anyLabel\", \"allLabel\", \"dateRangeHeader\", \"clearDatesLabel\", \"fromLabel\", \"toLabel\", \"activeFiltersLabel\", \"filtersButtonLabel\", \"filterSheetTitle\", \"filterSheetDescription\", \"savedSearchesHeader\", \"saveCurrentLabel\", \"saveDialogTitle\", \"saveDialogDescription\", \"searchNameLabel\", \"searchNamePlaceholder\", \"cancelLabel\", \"saveLabel\", \"recentlyViewedHeader\", \"clearLabel\", \"previousLabel\", \"nextLabel\", \"emptyFilteredHeading\", \"emptyUnfilteredHeading\", \"emptyFilteredDescription\", \"emptyUnfilteredDescription\", \"clearFiltersLabel\"]}','[]','2026-02-26 18:22:36.803000','2026-02-26 18:22:36.803000','2026-02-26 18:22:36.803000',NULL,NULL,NULL),(11,'p1hrd3hdh35jgey37qu0xoto','plugin::content-manager.explorer.read','{}','api::about-page.about-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"header.badge\", \"header.title\", \"header.subtitle\", \"content\"]}','[]','2026-02-26 18:22:37.552000','2026-02-26 18:22:37.552000','2026-02-26 18:22:37.552000',NULL,NULL,NULL),(12,'czhsst13r1urfttqcccgnu49','plugin::content-manager.explorer.read','{}','api::docs-page.docs-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"header.badge\", \"header.title\", \"header.subtitle\", \"content\"]}','[]','2026-02-26 18:22:38.296000','2026-02-26 18:22:38.296000','2026-02-26 18:22:38.296000',NULL,NULL,NULL),(13,'eouq0t3ehwq2696pq4vrcfj1','plugin::content-manager.explorer.read','{}','api::error-page.error-page','{\"fields\": [\"title\", \"description\", \"retryButtonLabel\", \"homeButtonLabel\"]}','[]','2026-02-26 18:22:39.038000','2026-02-26 18:22:39.038000','2026-02-26 18:22:39.038000',NULL,NULL,NULL),(14,'ma0owe9fguo8py1d1r9c6qqu','plugin::content-manager.explorer.read','{}','api::global.global','{\"fields\": [\"siteName\", \"siteDescription\", \"logo\", \"navigation.label\", \"navigation.href\", \"navigation.icon\", \"navigation.isExternal\", \"mobileMenuTitle\", \"skipToContentLabel\", \"signInLabel\", \"signOutLabel\", \"userMenuLabel\", \"newPatternButtonLabel\", \"footer.copyrightTemplate\", \"footer.links.label\", \"footer.links.href\", \"footer.links.icon\", \"footer.links.isExternal\", \"defaultSeo.title\", \"defaultSeo.description\", \"defaultSeo.keywords\", \"defaultSeo.ogImage\", \"defaultSeo.ogTitle\", \"defaultSeo.ogDescription\", \"defaultSeo.noIndex\"]}','[]','2026-02-26 18:22:39.776000','2026-02-26 18:22:39.776000','2026-02-26 18:22:39.776000',NULL,NULL,NULL),(15,'sh6gfp0q0p1j6jd0p62uuojh','plugin::content-manager.explorer.read','{}','api::home-page.home-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"content\"]}','[]','2026-02-26 18:22:40.516000','2026-02-26 18:22:40.516000','2026-02-26 18:22:40.517000',NULL,NULL,NULL),(16,'ssq3z9yjmjqe1v3z3949459j','plugin::content-manager.explorer.read','{}','api::login-page.login-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"cardTitle\", \"cardDescription\", \"signInButtonLabel\", \"signInLoadingLabel\", \"footerNotice\", \"errorMessages\"]}','[]','2026-02-26 18:22:41.262000','2026-02-26 18:22:41.262000','2026-02-26 18:22:41.262000',NULL,NULL,NULL),(17,'bvlpolrgdordsn4axkz1tuxk','plugin::content-manager.explorer.read','{}','api::not-found-page.not-found-page','{\"fields\": [\"errorCode\", \"heading\", \"message\", \"backButton.label\", \"backButton.href\", \"backButton.variant\", \"backButton.icon\"]}','[]','2026-02-26 18:22:42.003000','2026-02-26 18:22:42.003000','2026-02-26 18:22:42.003000',NULL,NULL,NULL),(18,'a6rcd611fb1eutea7dlxhtoy','plugin::content-manager.explorer.read','{}','api::pattern-detail-labels.pattern-detail-labels','{\"fields\": [\"breadcrumbAriaLabel\", \"voteAriaTemplate\", \"votesLabel\", \"voteAnnouncementTemplate\", \"noContentMessage\", \"relatedPatternsTitle\", \"noRelatedMessage\", \"editLabel\", \"deleteLabel\", \"deleteDialogTitle\", \"deleteDialogDescription\", \"cancelLabel\", \"deleteConfirmLabel\", \"deletingLabel\"]}','[]','2026-02-26 18:22:42.741000','2026-02-26 18:22:42.741000','2026-02-26 18:22:42.741000',NULL,NULL,NULL),(19,'a2m9ya1moihae38n1ql82hnx','plugin::content-manager.explorer.read','{}','api::pattern-form-labels.pattern-form-labels','{\"fields\": [\"createTitle\", \"editTitle\", \"titleLabel\", \"titlePlaceholder\", \"slugPreviewTemplate\", \"shortDescLabel\", \"shortDescPlaceholder\", \"categoryLabel\", \"categoryPlaceholder\", \"tagsLabel\", \"tagPlaceholder\", \"addTagLabel\", \"tagCountTemplate\", \"contentLabel\", \"contentPlaceholder\", \"authorLabel\", \"authorPlaceholder\", \"adminSettingsLabel\", \"featuredLabel\", \"trendingLabel\", \"cancelLabel\", \"createLabel\", \"creatingLabel\", \"saveLabel\", \"savingLabel\"]}','[]','2026-02-26 18:22:43.484000','2026-02-26 18:22:43.484000','2026-02-26 18:22:43.484000',NULL,NULL,NULL),(20,'s7unta3yn9tgd70rhec22f8y','plugin::content-manager.explorer.read','{}','api::pattern-listing-labels.pattern-listing-labels','{\"fields\": [\"pageTitle\", \"pageDescription\", \"searchPlaceholder\", \"clearSearchLabel\", \"sortByLabel\", \"sortOptions\", \"filterSectionHeader\", \"clearAllLabel\", \"categoryLabel\", \"allCategoriesLabel\", \"tagsLabel\", \"tagModeLabel\", \"anyLabel\", \"allLabel\", \"dateRangeHeader\", \"clearDatesLabel\", \"fromLabel\", \"toLabel\", \"activeFiltersLabel\", \"filtersButtonLabel\", \"filterSheetTitle\", \"filterSheetDescription\", \"savedSearchesHeader\", \"saveCurrentLabel\", \"saveDialogTitle\", \"saveDialogDescription\", \"searchNameLabel\", \"searchNamePlaceholder\", \"cancelLabel\", \"saveLabel\", \"recentlyViewedHeader\", \"clearLabel\", \"previousLabel\", \"nextLabel\", \"emptyFilteredHeading\", \"emptyUnfilteredHeading\", \"emptyFilteredDescription\", \"emptyUnfilteredDescription\", \"clearFiltersLabel\"]}','[]','2026-02-26 18:22:44.222000','2026-02-26 18:22:44.222000','2026-02-26 18:22:44.222000',NULL,NULL,NULL),(21,'ao3464hfop0pt34iyw2em44q','plugin::content-manager.explorer.update','{}','api::about-page.about-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"header.badge\", \"header.title\", \"header.subtitle\", \"content\"]}','[]','2026-02-26 18:22:44.962000','2026-02-26 18:22:44.962000','2026-02-26 18:22:44.962000',NULL,NULL,NULL),(22,'i5gwm0tvvo0gqxb2b2xnqgmw','plugin::content-manager.explorer.update','{}','api::docs-page.docs-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"header.badge\", \"header.title\", \"header.subtitle\", \"content\"]}','[]','2026-02-26 18:22:45.702000','2026-02-26 18:22:45.702000','2026-02-26 18:22:45.702000',NULL,NULL,NULL),(23,'a5j06l2wlv35sixlgkm004sk','plugin::content-manager.explorer.update','{}','api::error-page.error-page','{\"fields\": [\"title\", \"description\", \"retryButtonLabel\", \"homeButtonLabel\"]}','[]','2026-02-26 18:22:46.451000','2026-02-26 18:22:46.451000','2026-02-26 18:22:46.451000',NULL,NULL,NULL),(24,'qcn8f9jjrs4kj38ieyfhf89a','plugin::content-manager.explorer.update','{}','api::global.global','{\"fields\": [\"siteName\", \"siteDescription\", \"logo\", \"navigation.label\", \"navigation.href\", \"navigation.icon\", \"navigation.isExternal\", \"mobileMenuTitle\", \"skipToContentLabel\", \"signInLabel\", \"signOutLabel\", \"userMenuLabel\", \"newPatternButtonLabel\", \"footer.copyrightTemplate\", \"footer.links.label\", \"footer.links.href\", \"footer.links.icon\", \"footer.links.isExternal\", \"defaultSeo.title\", \"defaultSeo.description\", \"defaultSeo.keywords\", \"defaultSeo.ogImage\", \"defaultSeo.ogTitle\", \"defaultSeo.ogDescription\", \"defaultSeo.noIndex\"]}','[]','2026-02-26 18:22:47.189000','2026-02-26 18:22:47.189000','2026-02-26 18:22:47.189000',NULL,NULL,NULL),(25,'xwg06edsv7uq5nivx56ci6a9','plugin::content-manager.explorer.update','{}','api::home-page.home-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"content\"]}','[]','2026-02-26 18:22:47.925000','2026-02-26 18:22:47.925000','2026-02-26 18:22:47.925000',NULL,NULL,NULL),(26,'bifmlx97ssop6ls1z2qkqjj3','plugin::content-manager.explorer.update','{}','api::login-page.login-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"cardTitle\", \"cardDescription\", \"signInButtonLabel\", \"signInLoadingLabel\", \"footerNotice\", \"errorMessages\"]}','[]','2026-02-26 18:22:48.666000','2026-02-26 18:22:48.666000','2026-02-26 18:22:48.666000',NULL,NULL,NULL),(27,'ix72k4q8i0qk5kkkzm1c7vl2','plugin::content-manager.explorer.update','{}','api::not-found-page.not-found-page','{\"fields\": [\"errorCode\", \"heading\", \"message\", \"backButton.label\", \"backButton.href\", \"backButton.variant\", \"backButton.icon\"]}','[]','2026-02-26 18:22:49.404000','2026-02-26 18:22:49.404000','2026-02-26 18:22:49.404000',NULL,NULL,NULL),(28,'fxfvtm66we33vuz8rtcyzr1b','plugin::content-manager.explorer.update','{}','api::pattern-detail-labels.pattern-detail-labels','{\"fields\": [\"breadcrumbAriaLabel\", \"voteAriaTemplate\", \"votesLabel\", \"voteAnnouncementTemplate\", \"noContentMessage\", \"relatedPatternsTitle\", \"noRelatedMessage\", \"editLabel\", \"deleteLabel\", \"deleteDialogTitle\", \"deleteDialogDescription\", \"cancelLabel\", \"deleteConfirmLabel\", \"deletingLabel\"]}','[]','2026-02-26 18:22:50.143000','2026-02-26 18:22:50.143000','2026-02-26 18:22:50.143000',NULL,NULL,NULL),(29,'g28td07fx6h4q51yksfuqcpv','plugin::content-manager.explorer.update','{}','api::pattern-form-labels.pattern-form-labels','{\"fields\": [\"createTitle\", \"editTitle\", \"titleLabel\", \"titlePlaceholder\", \"slugPreviewTemplate\", \"shortDescLabel\", \"shortDescPlaceholder\", \"categoryLabel\", \"categoryPlaceholder\", \"tagsLabel\", \"tagPlaceholder\", \"addTagLabel\", \"tagCountTemplate\", \"contentLabel\", \"contentPlaceholder\", \"authorLabel\", \"authorPlaceholder\", \"adminSettingsLabel\", \"featuredLabel\", \"trendingLabel\", \"cancelLabel\", \"createLabel\", \"creatingLabel\", \"saveLabel\", \"savingLabel\"]}','[]','2026-02-26 18:22:50.883000','2026-02-26 18:22:50.883000','2026-02-26 18:22:50.883000',NULL,NULL,NULL),(30,'u3ywcssvirvaf1pvdstchh8t','plugin::content-manager.explorer.update','{}','api::pattern-listing-labels.pattern-listing-labels','{\"fields\": [\"pageTitle\", \"pageDescription\", \"searchPlaceholder\", \"clearSearchLabel\", \"sortByLabel\", \"sortOptions\", \"filterSectionHeader\", \"clearAllLabel\", \"categoryLabel\", \"allCategoriesLabel\", \"tagsLabel\", \"tagModeLabel\", \"anyLabel\", \"allLabel\", \"dateRangeHeader\", \"clearDatesLabel\", \"fromLabel\", \"toLabel\", \"activeFiltersLabel\", \"filtersButtonLabel\", \"filterSheetTitle\", \"filterSheetDescription\", \"savedSearchesHeader\", \"saveCurrentLabel\", \"saveDialogTitle\", \"saveDialogDescription\", \"searchNameLabel\", \"searchNamePlaceholder\", \"cancelLabel\", \"saveLabel\", \"recentlyViewedHeader\", \"clearLabel\", \"previousLabel\", \"nextLabel\", \"emptyFilteredHeading\", \"emptyUnfilteredHeading\", \"emptyFilteredDescription\", \"emptyUnfilteredDescription\", \"clearFiltersLabel\"]}','[]','2026-02-26 18:22:51.619000','2026-02-26 18:22:51.619000','2026-02-26 18:22:51.619000',NULL,NULL,NULL),(31,'umhtf3naxeeysixv7jjnb8rg','plugin::content-manager.explorer.delete','{}','api::about-page.about-page','{}','[]','2026-02-26 18:22:52.358000','2026-02-26 18:22:52.358000','2026-02-26 18:22:52.358000',NULL,NULL,NULL),(32,'q1sh7ponr8x7m6urjs0nuzne','plugin::content-manager.explorer.delete','{}','api::docs-page.docs-page','{}','[]','2026-02-26 18:22:53.094000','2026-02-26 18:22:53.094000','2026-02-26 18:22:53.095000',NULL,NULL,NULL),(33,'t2kf24wu29iiu9hfvpabq700','plugin::content-manager.explorer.create','{}','plugin::users-permissions.user','{\"fields\": [\"username\", \"email\", \"provider\", \"password\", \"resetPasswordToken\", \"confirmationToken\", \"confirmed\", \"blocked\", \"role\"]}','[]','2026-02-26 18:23:27.145000','2026-02-26 18:23:27.145000','2026-02-26 18:23:27.152000',NULL,NULL,NULL),(34,'g0myf25d8sawqejnsgsy3blc','plugin::content-manager.explorer.create','{}','api::about-page.about-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"header.badge\", \"header.title\", \"header.subtitle\", \"content\"]}','[]','2026-02-26 18:23:27.874000','2026-02-26 18:23:27.874000','2026-02-26 18:23:27.874000',NULL,NULL,NULL),(35,'arpny1aisi7eui5lzsgof351','plugin::content-manager.explorer.create','{}','api::docs-page.docs-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"header.badge\", \"header.title\", \"header.subtitle\", \"content\"]}','[]','2026-02-26 18:23:28.596000','2026-02-26 18:23:28.596000','2026-02-26 18:23:28.597000',NULL,NULL,NULL),(36,'e9dtq1lpmnf2s1tq3iqelyty','plugin::content-manager.explorer.create','{}','api::error-page.error-page','{\"fields\": [\"title\", \"description\", \"retryButtonLabel\", \"homeButtonLabel\"]}','[]','2026-02-26 18:23:29.327000','2026-02-26 18:23:29.327000','2026-02-26 18:23:29.328000',NULL,NULL,NULL),(37,'igpjinfeba0s3pvyfo8t2tro','plugin::content-manager.explorer.create','{}','api::global.global','{\"fields\": [\"siteName\", \"siteDescription\", \"logo\", \"navigation.label\", \"navigation.href\", \"navigation.icon\", \"navigation.isExternal\", \"mobileMenuTitle\", \"skipToContentLabel\", \"signInLabel\", \"signOutLabel\", \"userMenuLabel\", \"newPatternButtonLabel\", \"footer.copyrightTemplate\", \"footer.links.label\", \"footer.links.href\", \"footer.links.icon\", \"footer.links.isExternal\", \"defaultSeo.title\", \"defaultSeo.description\", \"defaultSeo.keywords\", \"defaultSeo.ogImage\", \"defaultSeo.ogTitle\", \"defaultSeo.ogDescription\", \"defaultSeo.noIndex\"]}','[]','2026-02-26 18:23:30.045000','2026-02-26 18:23:30.045000','2026-02-26 18:23:30.045000',NULL,NULL,NULL),(38,'ovf6g5kfnmkbx4v4qo3yd3cp','plugin::content-manager.explorer.create','{}','api::home-page.home-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"content\"]}','[]','2026-02-26 18:23:30.766000','2026-02-26 18:23:30.766000','2026-02-26 18:23:30.766000',NULL,NULL,NULL),(39,'gjayz3djkqw62x3jah953t8v','plugin::content-manager.explorer.create','{}','api::login-page.login-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"cardTitle\", \"cardDescription\", \"signInButtonLabel\", \"signInLoadingLabel\", \"footerNotice\", \"errorMessages\"]}','[]','2026-02-26 18:23:31.488000','2026-02-26 18:23:31.488000','2026-02-26 18:23:31.489000',NULL,NULL,NULL),(40,'doiveiv710drzga48knariu0','plugin::content-manager.explorer.create','{}','api::not-found-page.not-found-page','{\"fields\": [\"errorCode\", \"heading\", \"message\", \"backButton.label\", \"backButton.href\", \"backButton.variant\", \"backButton.icon\"]}','[]','2026-02-26 18:23:32.207000','2026-02-26 18:23:32.207000','2026-02-26 18:23:32.207000',NULL,NULL,NULL),(41,'age1ju22rae784l05br5imfu','plugin::content-manager.explorer.create','{}','api::pattern-detail-labels.pattern-detail-labels','{\"fields\": [\"breadcrumbAriaLabel\", \"voteAriaTemplate\", \"votesLabel\", \"voteAnnouncementTemplate\", \"noContentMessage\", \"relatedPatternsTitle\", \"noRelatedMessage\", \"editLabel\", \"deleteLabel\", \"deleteDialogTitle\", \"deleteDialogDescription\", \"cancelLabel\", \"deleteConfirmLabel\", \"deletingLabel\"]}','[]','2026-02-26 18:23:32.927000','2026-02-26 18:23:32.927000','2026-02-26 18:23:32.927000',NULL,NULL,NULL),(42,'slhi88s0cqh41doc784fbrzt','plugin::content-manager.explorer.create','{}','api::pattern-form-labels.pattern-form-labels','{\"fields\": [\"createTitle\", \"editTitle\", \"titleLabel\", \"titlePlaceholder\", \"slugPreviewTemplate\", \"shortDescLabel\", \"shortDescPlaceholder\", \"categoryLabel\", \"categoryPlaceholder\", \"tagsLabel\", \"tagPlaceholder\", \"addTagLabel\", \"tagCountTemplate\", \"contentLabel\", \"contentPlaceholder\", \"authorLabel\", \"authorPlaceholder\", \"adminSettingsLabel\", \"featuredLabel\", \"trendingLabel\", \"cancelLabel\", \"createLabel\", \"creatingLabel\", \"saveLabel\", \"savingLabel\"]}','[]','2026-02-26 18:23:33.647000','2026-02-26 18:23:33.647000','2026-02-26 18:23:33.647000',NULL,NULL,NULL),(43,'enhem1sawg11tguifhpyml6n','plugin::content-manager.explorer.create','{}','api::pattern-listing-labels.pattern-listing-labels','{\"fields\": [\"pageTitle\", \"pageDescription\", \"searchPlaceholder\", \"clearSearchLabel\", \"sortByLabel\", \"sortOptions\", \"filterSectionHeader\", \"clearAllLabel\", \"categoryLabel\", \"allCategoriesLabel\", \"tagsLabel\", \"tagModeLabel\", \"anyLabel\", \"allLabel\", \"dateRangeHeader\", \"clearDatesLabel\", \"fromLabel\", \"toLabel\", \"activeFiltersLabel\", \"filtersButtonLabel\", \"filterSheetTitle\", \"filterSheetDescription\", \"savedSearchesHeader\", \"saveCurrentLabel\", \"saveDialogTitle\", \"saveDialogDescription\", \"searchNameLabel\", \"searchNamePlaceholder\", \"cancelLabel\", \"saveLabel\", \"recentlyViewedHeader\", \"clearLabel\", \"previousLabel\", \"nextLabel\", \"emptyFilteredHeading\", \"emptyUnfilteredHeading\", \"emptyFilteredDescription\", \"emptyUnfilteredDescription\", \"clearFiltersLabel\"]}','[]','2026-02-26 18:23:34.366000','2026-02-26 18:23:34.366000','2026-02-26 18:23:34.366000',NULL,NULL,NULL),(44,'hl8ccrwwbsgd3mfwfm3erzov','plugin::content-manager.explorer.read','{}','plugin::users-permissions.user','{\"fields\": [\"username\", \"email\", \"provider\", \"password\", \"resetPasswordToken\", \"confirmationToken\", \"confirmed\", \"blocked\", \"role\"]}','[]','2026-02-26 18:23:35.087000','2026-02-26 18:23:35.087000','2026-02-26 18:23:35.087000',NULL,NULL,NULL),(45,'u78u7mkh6md324bmxpc73eq7','plugin::content-manager.explorer.read','{}','api::about-page.about-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"header.badge\", \"header.title\", \"header.subtitle\", \"content\"]}','[]','2026-02-26 18:23:35.811000','2026-02-26 18:23:35.811000','2026-02-26 18:23:35.811000',NULL,NULL,NULL),(46,'rubqx4s9qwqwc6b6leu2xzzj','plugin::content-manager.explorer.read','{}','api::docs-page.docs-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"header.badge\", \"header.title\", \"header.subtitle\", \"content\"]}','[]','2026-02-26 18:23:36.531000','2026-02-26 18:23:36.531000','2026-02-26 18:23:36.531000',NULL,NULL,NULL),(47,'w5mop8fsdqw2ibu5518hb95c','plugin::content-manager.explorer.read','{}','api::error-page.error-page','{\"fields\": [\"title\", \"description\", \"retryButtonLabel\", \"homeButtonLabel\"]}','[]','2026-02-26 18:23:37.254000','2026-02-26 18:23:37.254000','2026-02-26 18:23:37.254000',NULL,NULL,NULL),(48,'edjni8c338n0no2ol3aki77t','plugin::content-manager.explorer.read','{}','api::global.global','{\"fields\": [\"siteName\", \"siteDescription\", \"logo\", \"navigation.label\", \"navigation.href\", \"navigation.icon\", \"navigation.isExternal\", \"mobileMenuTitle\", \"skipToContentLabel\", \"signInLabel\", \"signOutLabel\", \"userMenuLabel\", \"newPatternButtonLabel\", \"footer.copyrightTemplate\", \"footer.links.label\", \"footer.links.href\", \"footer.links.icon\", \"footer.links.isExternal\", \"defaultSeo.title\", \"defaultSeo.description\", \"defaultSeo.keywords\", \"defaultSeo.ogImage\", \"defaultSeo.ogTitle\", \"defaultSeo.ogDescription\", \"defaultSeo.noIndex\"]}','[]','2026-02-26 18:23:37.974000','2026-02-26 18:23:37.974000','2026-02-26 18:23:37.977000',NULL,NULL,NULL),(49,'h6cek416agn4w7htv17nwecp','plugin::content-manager.explorer.read','{}','api::home-page.home-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"content\"]}','[]','2026-02-26 18:23:38.703000','2026-02-26 18:23:38.703000','2026-02-26 18:23:38.703000',NULL,NULL,NULL),(50,'xeusedbrldq375rdrf5ug8yi','plugin::content-manager.explorer.read','{}','api::login-page.login-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"cardTitle\", \"cardDescription\", \"signInButtonLabel\", \"signInLoadingLabel\", \"footerNotice\", \"errorMessages\"]}','[]','2026-02-26 18:23:39.422000','2026-02-26 18:23:39.422000','2026-02-26 18:23:39.422000',NULL,NULL,NULL),(51,'liirkdewaoro57gchozqttg9','plugin::content-manager.explorer.read','{}','api::not-found-page.not-found-page','{\"fields\": [\"errorCode\", \"heading\", \"message\", \"backButton.label\", \"backButton.href\", \"backButton.variant\", \"backButton.icon\"]}','[]','2026-02-26 18:23:40.142000','2026-02-26 18:23:40.142000','2026-02-26 18:23:40.143000',NULL,NULL,NULL),(52,'czeuicu5mj57rq0xuyulugqo','plugin::content-manager.explorer.read','{}','api::pattern-detail-labels.pattern-detail-labels','{\"fields\": [\"breadcrumbAriaLabel\", \"voteAriaTemplate\", \"votesLabel\", \"voteAnnouncementTemplate\", \"noContentMessage\", \"relatedPatternsTitle\", \"noRelatedMessage\", \"editLabel\", \"deleteLabel\", \"deleteDialogTitle\", \"deleteDialogDescription\", \"cancelLabel\", \"deleteConfirmLabel\", \"deletingLabel\"]}','[]','2026-02-26 18:23:40.863000','2026-02-26 18:23:40.863000','2026-02-26 18:23:40.863000',NULL,NULL,NULL),(53,'bpatcolzw36lcvi3cblds6z8','plugin::content-manager.explorer.read','{}','api::pattern-form-labels.pattern-form-labels','{\"fields\": [\"createTitle\", \"editTitle\", \"titleLabel\", \"titlePlaceholder\", \"slugPreviewTemplate\", \"shortDescLabel\", \"shortDescPlaceholder\", \"categoryLabel\", \"categoryPlaceholder\", \"tagsLabel\", \"tagPlaceholder\", \"addTagLabel\", \"tagCountTemplate\", \"contentLabel\", \"contentPlaceholder\", \"authorLabel\", \"authorPlaceholder\", \"adminSettingsLabel\", \"featuredLabel\", \"trendingLabel\", \"cancelLabel\", \"createLabel\", \"creatingLabel\", \"saveLabel\", \"savingLabel\"]}','[]','2026-02-26 18:23:41.593000','2026-02-26 18:23:41.593000','2026-02-26 18:23:41.593000',NULL,NULL,NULL),(54,'kekzejr3bcdulp7vi49um85g','plugin::content-manager.explorer.read','{}','api::pattern-listing-labels.pattern-listing-labels','{\"fields\": [\"pageTitle\", \"pageDescription\", \"searchPlaceholder\", \"clearSearchLabel\", \"sortByLabel\", \"sortOptions\", \"filterSectionHeader\", \"clearAllLabel\", \"categoryLabel\", \"allCategoriesLabel\", \"tagsLabel\", \"tagModeLabel\", \"anyLabel\", \"allLabel\", \"dateRangeHeader\", \"clearDatesLabel\", \"fromLabel\", \"toLabel\", \"activeFiltersLabel\", \"filtersButtonLabel\", \"filterSheetTitle\", \"filterSheetDescription\", \"savedSearchesHeader\", \"saveCurrentLabel\", \"saveDialogTitle\", \"saveDialogDescription\", \"searchNameLabel\", \"searchNamePlaceholder\", \"cancelLabel\", \"saveLabel\", \"recentlyViewedHeader\", \"clearLabel\", \"previousLabel\", \"nextLabel\", \"emptyFilteredHeading\", \"emptyUnfilteredHeading\", \"emptyFilteredDescription\", \"emptyUnfilteredDescription\", \"clearFiltersLabel\"]}','[]','2026-02-26 18:23:42.311000','2026-02-26 18:23:42.311000','2026-02-26 18:23:42.311000',NULL,NULL,NULL),(55,'m4njnk0h7ybaethd30yhuf5a','plugin::content-manager.explorer.update','{}','plugin::users-permissions.user','{\"fields\": [\"username\", \"email\", \"provider\", \"password\", \"resetPasswordToken\", \"confirmationToken\", \"confirmed\", \"blocked\", \"role\"]}','[]','2026-02-26 18:23:43.030000','2026-02-26 18:23:43.030000','2026-02-26 18:23:43.030000',NULL,NULL,NULL),(56,'k7gnmdw7upymjw6urwntsooe','plugin::content-manager.explorer.update','{}','api::about-page.about-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"header.badge\", \"header.title\", \"header.subtitle\", \"content\"]}','[]','2026-02-26 18:23:43.748000','2026-02-26 18:23:43.748000','2026-02-26 18:23:43.748000',NULL,NULL,NULL),(57,'l8hcw16xrthcf0f6ml2y71x7','plugin::content-manager.explorer.update','{}','api::docs-page.docs-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"header.badge\", \"header.title\", \"header.subtitle\", \"content\"]}','[]','2026-02-26 18:23:44.469000','2026-02-26 18:23:44.469000','2026-02-26 18:23:44.469000',NULL,NULL,NULL),(58,'vgv8qo3krl2czxbhc3cqsrzu','plugin::content-manager.explorer.update','{}','api::error-page.error-page','{\"fields\": [\"title\", \"description\", \"retryButtonLabel\", \"homeButtonLabel\"]}','[]','2026-02-26 18:23:45.191000','2026-02-26 18:23:45.191000','2026-02-26 18:23:45.191000',NULL,NULL,NULL),(59,'xwnwlmxpgmbi32ppnoajts7l','plugin::content-manager.explorer.update','{}','api::global.global','{\"fields\": [\"siteName\", \"siteDescription\", \"logo\", \"navigation.label\", \"navigation.href\", \"navigation.icon\", \"navigation.isExternal\", \"mobileMenuTitle\", \"skipToContentLabel\", \"signInLabel\", \"signOutLabel\", \"userMenuLabel\", \"newPatternButtonLabel\", \"footer.copyrightTemplate\", \"footer.links.label\", \"footer.links.href\", \"footer.links.icon\", \"footer.links.isExternal\", \"defaultSeo.title\", \"defaultSeo.description\", \"defaultSeo.keywords\", \"defaultSeo.ogImage\", \"defaultSeo.ogTitle\", \"defaultSeo.ogDescription\", \"defaultSeo.noIndex\"]}','[]','2026-02-26 18:23:45.909000','2026-02-26 18:23:45.909000','2026-02-26 18:23:45.909000',NULL,NULL,NULL),(60,'yhg4dublq45734tm07h1na7f','plugin::content-manager.explorer.update','{}','api::home-page.home-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"content\"]}','[]','2026-02-26 18:23:46.630000','2026-02-26 18:23:46.630000','2026-02-26 18:23:46.631000',NULL,NULL,NULL),(61,'p948ayvpld7d1joovmjujt4y','plugin::content-manager.explorer.update','{}','api::login-page.login-page','{\"fields\": [\"seo.title\", \"seo.description\", \"seo.keywords\", \"seo.ogImage\", \"seo.ogTitle\", \"seo.ogDescription\", \"seo.noIndex\", \"cardTitle\", \"cardDescription\", \"signInButtonLabel\", \"signInLoadingLabel\", \"footerNotice\", \"errorMessages\"]}','[]','2026-02-26 18:23:47.354000','2026-02-26 18:23:47.354000','2026-02-26 18:23:47.355000',NULL,NULL,NULL),(62,'epoqiulpu14x141ffrfyt8gq','plugin::content-manager.explorer.update','{}','api::not-found-page.not-found-page','{\"fields\": [\"errorCode\", \"heading\", \"message\", \"backButton.label\", \"backButton.href\", \"backButton.variant\", \"backButton.icon\"]}','[]','2026-02-26 18:23:48.074000','2026-02-26 18:23:48.074000','2026-02-26 18:23:48.074000',NULL,NULL,NULL),(63,'ebemtc5qglmvr6lftf8rkckm','plugin::content-manager.explorer.update','{}','api::pattern-detail-labels.pattern-detail-labels','{\"fields\": [\"breadcrumbAriaLabel\", \"voteAriaTemplate\", \"votesLabel\", \"voteAnnouncementTemplate\", \"noContentMessage\", \"relatedPatternsTitle\", \"noRelatedMessage\", \"editLabel\", \"deleteLabel\", \"deleteDialogTitle\", \"deleteDialogDescription\", \"cancelLabel\", \"deleteConfirmLabel\", \"deletingLabel\"]}','[]','2026-02-26 18:23:48.793000','2026-02-26 18:23:48.793000','2026-02-26 18:23:48.793000',NULL,NULL,NULL),(64,'nogs893jhin0uphsxnrup5rd','plugin::content-manager.explorer.update','{}','api::pattern-form-labels.pattern-form-labels','{\"fields\": [\"createTitle\", \"editTitle\", \"titleLabel\", \"titlePlaceholder\", \"slugPreviewTemplate\", \"shortDescLabel\", \"shortDescPlaceholder\", \"categoryLabel\", \"categoryPlaceholder\", \"tagsLabel\", \"tagPlaceholder\", \"addTagLabel\", \"tagCountTemplate\", \"contentLabel\", \"contentPlaceholder\", \"authorLabel\", \"authorPlaceholder\", \"adminSettingsLabel\", \"featuredLabel\", \"trendingLabel\", \"cancelLabel\", \"createLabel\", \"creatingLabel\", \"saveLabel\", \"savingLabel\"]}','[]','2026-02-26 18:23:49.512000','2026-02-26 18:23:49.512000','2026-02-26 18:23:49.512000',NULL,NULL,NULL),(65,'r0lkpv4azuwlczyzhum2lez9','plugin::content-manager.explorer.update','{}','api::pattern-listing-labels.pattern-listing-labels','{\"fields\": [\"pageTitle\", \"pageDescription\", \"searchPlaceholder\", \"clearSearchLabel\", \"sortByLabel\", \"sortOptions\", \"filterSectionHeader\", \"clearAllLabel\", \"categoryLabel\", \"allCategoriesLabel\", \"tagsLabel\", \"tagModeLabel\", \"anyLabel\", \"allLabel\", \"dateRangeHeader\", \"clearDatesLabel\", \"fromLabel\", \"toLabel\", \"activeFiltersLabel\", \"filtersButtonLabel\", \"filterSheetTitle\", \"filterSheetDescription\", \"savedSearchesHeader\", \"saveCurrentLabel\", \"saveDialogTitle\", \"saveDialogDescription\", \"searchNameLabel\", \"searchNamePlaceholder\", \"cancelLabel\", \"saveLabel\", \"recentlyViewedHeader\", \"clearLabel\", \"previousLabel\", \"nextLabel\", \"emptyFilteredHeading\", \"emptyUnfilteredHeading\", \"emptyFilteredDescription\", \"emptyUnfilteredDescription\", \"clearFiltersLabel\"]}','[]','2026-02-26 18:23:50.233000','2026-02-26 18:23:50.233000','2026-02-26 18:23:50.233000',NULL,NULL,NULL),(66,'vu45r4hgplbgo3r8c3fy55e0','plugin::content-manager.explorer.delete','{}','plugin::users-permissions.user','{}','[]','2026-02-26 18:23:50.957000','2026-02-26 18:23:50.957000','2026-02-26 18:23:50.957000',NULL,NULL,NULL),(67,'cv42zlzuen8lii2v18gxn6qc','plugin::content-manager.explorer.delete','{}','api::about-page.about-page','{}','[]','2026-02-26 18:23:51.679000','2026-02-26 18:23:51.679000','2026-02-26 18:23:51.679000',NULL,NULL,NULL),(68,'dkqcmeod68nm1a6e29johit4','plugin::content-manager.explorer.delete','{}','api::docs-page.docs-page','{}','[]','2026-02-26 18:23:52.397000','2026-02-26 18:23:52.397000','2026-02-26 18:23:52.397000',NULL,NULL,NULL),(69,'upshdxdst6pvr232s98zmq5e','plugin::content-manager.explorer.delete','{}','api::error-page.error-page','{}','[]','2026-02-26 18:23:53.121000','2026-02-26 18:23:53.121000','2026-02-26 18:23:53.121000',NULL,NULL,NULL),(70,'ljjp7kgo0y4mcnrcogjjrkh4','plugin::content-manager.explorer.delete','{}','api::global.global','{}','[]','2026-02-26 18:23:53.846000','2026-02-26 18:23:53.846000','2026-02-26 18:23:53.846000',NULL,NULL,NULL),(71,'w88t82uiz0xac2ts8qnopbdg','plugin::content-manager.explorer.delete','{}','api::home-page.home-page','{}','[]','2026-02-26 18:23:54.565000','2026-02-26 18:23:54.565000','2026-02-26 18:23:54.565000',NULL,NULL,NULL),(72,'pqq20per376tdrm9jhdz0h9c','plugin::content-manager.explorer.delete','{}','api::login-page.login-page','{}','[]','2026-02-26 18:23:55.284000','2026-02-26 18:23:55.284000','2026-02-26 18:23:55.284000',NULL,NULL,NULL),(73,'hcr8ac4dvu1znz5fm07u47ap','plugin::content-manager.explorer.delete','{}','api::not-found-page.not-found-page','{}','[]','2026-02-26 18:23:56.001000','2026-02-26 18:23:56.001000','2026-02-26 18:23:56.002000',NULL,NULL,NULL),(74,'ul41r8n5a8u5o2isiex29zqa','plugin::content-manager.explorer.delete','{}','api::pattern-detail-labels.pattern-detail-labels','{}','[]','2026-02-26 18:23:56.727000','2026-02-26 18:23:56.727000','2026-02-26 18:23:56.727000',NULL,NULL,NULL),(75,'sxkxzg8a63xnl6urmas21sx4','plugin::content-manager.explorer.delete','{}','api::pattern-form-labels.pattern-form-labels','{}','[]','2026-02-26 18:23:57.444000','2026-02-26 18:23:57.444000','2026-02-26 18:23:57.444000',NULL,NULL,NULL),(76,'m7e3uyl78m5gowj557itawiu','plugin::content-manager.explorer.delete','{}','api::pattern-listing-labels.pattern-listing-labels','{}','[]','2026-02-26 18:23:58.161000','2026-02-26 18:23:58.161000','2026-02-26 18:23:58.161000',NULL,NULL,NULL),(77,'qrw22yf8s8h0hij243xx0wxz','plugin::content-manager.explorer.publish','{}','plugin::users-permissions.user','{}','[]','2026-02-26 18:23:58.881000','2026-02-26 18:23:58.881000','2026-02-26 18:23:58.881000',NULL,NULL,NULL),(78,'eibe2854t9zztdwdifpqx7ux','plugin::content-manager.explorer.publish','{}','api::about-page.about-page','{}','[]','2026-02-26 18:23:59.599000','2026-02-26 18:23:59.599000','2026-02-26 18:23:59.599000',NULL,NULL,NULL),(79,'xosdrut5lmvryrbuh65ne7x2','plugin::content-manager.explorer.publish','{}','api::docs-page.docs-page','{}','[]','2026-02-26 18:24:00.315000','2026-02-26 18:24:00.315000','2026-02-26 18:24:00.316000',NULL,NULL,NULL),(80,'hoj9u8j8z0jc5rgrklv4w7dd','plugin::content-manager.explorer.publish','{}','api::error-page.error-page','{}','[]','2026-02-26 18:24:01.033000','2026-02-26 18:24:01.033000','2026-02-26 18:24:01.033000',NULL,NULL,NULL),(81,'odt85kl9vtw3v62ujnat9cp4','plugin::content-manager.explorer.publish','{}','api::global.global','{}','[]','2026-02-26 18:24:01.750000','2026-02-26 18:24:01.750000','2026-02-26 18:24:01.750000',NULL,NULL,NULL),(82,'t4bzy50st7qi6vbs253qjczf','plugin::content-manager.explorer.publish','{}','api::home-page.home-page','{}','[]','2026-02-26 18:24:02.470000','2026-02-26 18:24:02.470000','2026-02-26 18:24:02.470000',NULL,NULL,NULL),(83,'h06hpherk3yqe3j8jikga77i','plugin::content-manager.explorer.publish','{}','api::login-page.login-page','{}','[]','2026-02-26 18:24:03.189000','2026-02-26 18:24:03.189000','2026-02-26 18:24:03.189000',NULL,NULL,NULL),(84,'ijrr1e162kv0gei6cuxqbfc1','plugin::content-manager.explorer.publish','{}','api::not-found-page.not-found-page','{}','[]','2026-02-26 18:24:03.905000','2026-02-26 18:24:03.905000','2026-02-26 18:24:03.905000',NULL,NULL,NULL),(85,'xgf2b6tmth3bj3lt9irnknnp','plugin::content-manager.explorer.publish','{}','api::pattern-detail-labels.pattern-detail-labels','{}','[]','2026-02-26 18:24:04.623000','2026-02-26 18:24:04.623000','2026-02-26 18:24:04.624000',NULL,NULL,NULL),(86,'abjj9rk1iemps74p4ffepfpz','plugin::content-manager.explorer.publish','{}','api::pattern-form-labels.pattern-form-labels','{}','[]','2026-02-26 18:24:05.342000','2026-02-26 18:24:05.342000','2026-02-26 18:24:05.342000',NULL,NULL,NULL),(87,'omwhnvg7039pds0b1r73utdc','plugin::content-manager.explorer.publish','{}','api::pattern-listing-labels.pattern-listing-labels','{}','[]','2026-02-26 18:24:06.060000','2026-02-26 18:24:06.060000','2026-02-26 18:24:06.060000',NULL,NULL,NULL),(88,'hmihwql3hqy2xy85c9tcmb7w','plugin::content-manager.single-types.configure-view','{}',NULL,'{}','[]','2026-02-26 18:24:06.780000','2026-02-26 18:24:06.780000','2026-02-26 18:24:06.780000',NULL,NULL,NULL),(89,'r7eyosopxovkrbsm003uwlf4','plugin::content-manager.collection-types.configure-view','{}',NULL,'{}','[]','2026-02-26 18:24:07.501000','2026-02-26 18:24:07.501000','2026-02-26 18:24:07.502000',NULL,NULL,NULL),(90,'urlvlz9pdi6k0uk49dj8hvh1','plugin::content-manager.components.configure-layout','{}',NULL,'{}','[]','2026-02-26 18:24:08.220000','2026-02-26 18:24:08.220000','2026-02-26 18:24:08.220000',NULL,NULL,NULL),(91,'eemhnmix8k2m5uf1ikcn3lwz','plugin::content-type-builder.read','{}',NULL,'{}','[]','2026-02-26 18:24:08.941000','2026-02-26 18:24:08.941000','2026-02-26 18:24:08.941000',NULL,NULL,NULL),(92,'nd2ufxa8oc1zzxttpjp1zmqb','plugin::email.settings.read','{}',NULL,'{}','[]','2026-02-26 18:24:09.660000','2026-02-26 18:24:09.660000','2026-02-26 18:24:09.661000',NULL,NULL,NULL),(93,'bnjmqoidfjvm9r1rssy3zteg','plugin::upload.read','{}',NULL,'{}','[]','2026-02-26 18:24:10.380000','2026-02-26 18:24:10.380000','2026-02-26 18:24:10.380000',NULL,NULL,NULL),(94,'ajryu15xe5g7erge6gj0rhq0','plugin::upload.assets.create','{}',NULL,'{}','[]','2026-02-26 18:24:11.100000','2026-02-26 18:24:11.100000','2026-02-26 18:24:11.100000',NULL,NULL,NULL),(95,'ezqgan79lb4ldhc5fmtgqxjr','plugin::upload.assets.update','{}',NULL,'{}','[]','2026-02-26 18:24:11.823000','2026-02-26 18:24:11.823000','2026-02-26 18:24:11.823000',NULL,NULL,NULL),(96,'z6ump3lelidv7dago20b4ywy','plugin::upload.assets.download','{}',NULL,'{}','[]','2026-02-26 18:24:19.140000','2026-02-26 18:24:19.140000','2026-02-26 18:24:19.143000',NULL,NULL,NULL),(97,'scpk8c9p83ijcmgdtfre36hm','plugin::upload.assets.copy-link','{}',NULL,'{}','[]','2026-02-26 18:24:19.864000','2026-02-26 18:24:19.864000','2026-02-26 18:24:19.865000',NULL,NULL,NULL),(98,'wwhq1es89i0ncn94gmfmc2u6','plugin::upload.configure-view','{}',NULL,'{}','[]','2026-02-26 18:24:20.584000','2026-02-26 18:24:20.584000','2026-02-26 18:24:20.584000',NULL,NULL,NULL),(99,'ijin9h9ejnfb5ygyrg57hrf1','plugin::upload.settings.read','{}',NULL,'{}','[]','2026-02-26 18:24:21.302000','2026-02-26 18:24:21.302000','2026-02-26 18:24:21.303000',NULL,NULL,NULL),(100,'vaqsof6czi2xvqtdp4l5mhxj','plugin::i18n.locale.create','{}',NULL,'{}','[]','2026-02-26 18:24:22.020000','2026-02-26 18:24:22.020000','2026-02-26 18:24:22.020000',NULL,NULL,NULL),(101,'jjgpwkvkwamb2vx12232i9xc','plugin::i18n.locale.read','{}',NULL,'{}','[]','2026-02-26 18:24:22.743000','2026-02-26 18:24:22.743000','2026-02-26 18:24:22.743000',NULL,NULL,NULL),(102,'i3xqv4axf3z154medtmxe045','plugin::i18n.locale.update','{}',NULL,'{}','[]','2026-02-26 18:24:23.464000','2026-02-26 18:24:23.464000','2026-02-26 18:24:23.464000',NULL,NULL,NULL),(103,'uqlu2nl74g0l6jmbtaknetz6','plugin::i18n.locale.delete','{}',NULL,'{}','[]','2026-02-26 18:24:24.182000','2026-02-26 18:24:24.182000','2026-02-26 18:24:24.183000',NULL,NULL,NULL),(104,'g1dhexfqy16o6z8j8wslvr5a','plugin::users-permissions.roles.create','{}',NULL,'{}','[]','2026-02-26 18:24:24.902000','2026-02-26 18:24:24.902000','2026-02-26 18:24:24.902000',NULL,NULL,NULL),(105,'c6fyta3y5yt1gwy4ikjyl8x7','plugin::users-permissions.roles.read','{}',NULL,'{}','[]','2026-02-26 18:24:25.622000','2026-02-26 18:24:25.622000','2026-02-26 18:24:25.622000',NULL,NULL,NULL),(106,'highsjjdu9hhuosqilzfp7u1','plugin::users-permissions.roles.update','{}',NULL,'{}','[]','2026-02-26 18:24:26.341000','2026-02-26 18:24:26.341000','2026-02-26 18:24:26.341000',NULL,NULL,NULL),(107,'cm57rl8toa16w4pky8m4w845','plugin::users-permissions.roles.delete','{}',NULL,'{}','[]','2026-02-26 18:24:27.061000','2026-02-26 18:24:27.061000','2026-02-26 18:24:27.061000',NULL,NULL,NULL),(108,'j6aablpjhcbaovq8nyodg0un','plugin::users-permissions.providers.read','{}',NULL,'{}','[]','2026-02-26 18:24:27.786000','2026-02-26 18:24:27.786000','2026-02-26 18:24:27.786000',NULL,NULL,NULL),(109,'x1q7btfmek6gf9xzdf9h7zyu','plugin::users-permissions.providers.update','{}',NULL,'{}','[]','2026-02-26 18:24:28.513000','2026-02-26 18:24:28.513000','2026-02-26 18:24:28.513000',NULL,NULL,NULL),(110,'gvfln0gh0a0904tk2ty4nlzg','plugin::users-permissions.email-templates.read','{}',NULL,'{}','[]','2026-02-26 18:24:29.233000','2026-02-26 18:24:29.233000','2026-02-26 18:24:29.233000',NULL,NULL,NULL),(111,'osjq30pud8rhvla3qhoztrrd','plugin::users-permissions.email-templates.update','{}',NULL,'{}','[]','2026-02-26 18:24:29.951000','2026-02-26 18:24:29.951000','2026-02-26 18:24:29.952000',NULL,NULL,NULL),(112,'wnn8nbx53dxlujy9k8lujqfy','plugin::users-permissions.advanced-settings.read','{}',NULL,'{}','[]','2026-02-26 18:24:30.673000','2026-02-26 18:24:30.673000','2026-02-26 18:24:30.673000',NULL,NULL,NULL),(113,'ebnk83mz7spknhgy8x28gtim','plugin::users-permissions.advanced-settings.update','{}',NULL,'{}','[]','2026-02-26 18:24:31.390000','2026-02-26 18:24:31.390000','2026-02-26 18:24:31.390000',NULL,NULL,NULL),(114,'flt7adlpqbpdr4xnnz96sbki','admin::marketplace.read','{}',NULL,'{}','[]','2026-02-26 18:24:32.109000','2026-02-26 18:24:32.109000','2026-02-26 18:24:32.110000',NULL,NULL,NULL),(115,'w7w3bl8zsmzrn6e2ml1s55sf','admin::webhooks.create','{}',NULL,'{}','[]','2026-02-26 18:24:32.830000','2026-02-26 18:24:32.830000','2026-02-26 18:24:32.830000',NULL,NULL,NULL),(116,'ttix3jlbqb9c1gerelzpf8cz','admin::webhooks.read','{}',NULL,'{}','[]','2026-02-26 18:24:33.548000','2026-02-26 18:24:33.548000','2026-02-26 18:24:33.549000',NULL,NULL,NULL),(117,'ivavmx4a3tgp719xkeaq10sj','admin::webhooks.update','{}',NULL,'{}','[]','2026-02-26 18:24:34.267000','2026-02-26 18:24:34.267000','2026-02-26 18:24:34.267000',NULL,NULL,NULL),(118,'bxa9hc5g318m4g9jnbro8mqv','admin::webhooks.delete','{}',NULL,'{}','[]','2026-02-26 18:24:34.986000','2026-02-26 18:24:34.986000','2026-02-26 18:24:34.986000',NULL,NULL,NULL),(119,'gyed1yrvsya0s8be5wi57x10','admin::users.create','{}',NULL,'{}','[]','2026-02-26 18:24:35.704000','2026-02-26 18:24:35.704000','2026-02-26 18:24:35.704000',NULL,NULL,NULL),(120,'qn0qscnmef4nxpkrwfv0vyj1','admin::users.read','{}',NULL,'{}','[]','2026-02-26 18:24:36.422000','2026-02-26 18:24:36.422000','2026-02-26 18:24:36.423000',NULL,NULL,NULL),(121,'p6u2rn59381x8kxqf00hpe9g','admin::users.update','{}',NULL,'{}','[]','2026-02-26 18:24:37.139000','2026-02-26 18:24:37.139000','2026-02-26 18:24:37.139000',NULL,NULL,NULL),(122,'hhviqvq7cn0fkhszzkzjrs6i','admin::users.delete','{}',NULL,'{}','[]','2026-02-26 18:24:37.857000','2026-02-26 18:24:37.857000','2026-02-26 18:24:37.857000',NULL,NULL,NULL),(123,'csjirnscv6b3c40d8o1r00o8','admin::roles.create','{}',NULL,'{}','[]','2026-02-26 18:24:38.575000','2026-02-26 18:24:38.575000','2026-02-26 18:24:38.575000',NULL,NULL,NULL),(124,'yjrtwwcadpsfqxwaqq6kgtaw','admin::roles.read','{}',NULL,'{}','[]','2026-02-26 18:24:39.295000','2026-02-26 18:24:39.295000','2026-02-26 18:24:39.296000',NULL,NULL,NULL),(125,'e11zshyaqecn88db0lf9o6xn','admin::roles.update','{}',NULL,'{}','[]','2026-02-26 18:24:40.025000','2026-02-26 18:24:40.025000','2026-02-26 18:24:40.026000',NULL,NULL,NULL),(126,'ksdt2kyhp02bbwdpobxz0kvu','admin::roles.delete','{}',NULL,'{}','[]','2026-02-26 18:24:40.748000','2026-02-26 18:24:40.748000','2026-02-26 18:24:40.749000',NULL,NULL,NULL),(127,'fpsryqcrkb29c3b3os5k7rtm','admin::api-tokens.access','{}',NULL,'{}','[]','2026-02-26 18:24:41.470000','2026-02-26 18:24:41.470000','2026-02-26 18:24:41.470000',NULL,NULL,NULL),(128,'lqmzj5301uf1l6elqkkb4so3','admin::api-tokens.create','{}',NULL,'{}','[]','2026-02-26 18:24:42.189000','2026-02-26 18:24:42.189000','2026-02-26 18:24:42.189000',NULL,NULL,NULL),(129,'yxyif50v6c625ouykyawq3ze','admin::api-tokens.read','{}',NULL,'{}','[]','2026-02-26 18:24:42.908000','2026-02-26 18:24:42.908000','2026-02-26 18:24:42.909000',NULL,NULL,NULL),(130,'hcwhpawuxqeamgx4q0wkd2d8','admin::api-tokens.update','{}',NULL,'{}','[]','2026-02-26 18:24:43.635000','2026-02-26 18:24:43.635000','2026-02-26 18:24:43.635000',NULL,NULL,NULL),(131,'azurmvfdu62d9cvt8nkv0gne','admin::api-tokens.regenerate','{}',NULL,'{}','[]','2026-02-26 18:24:44.355000','2026-02-26 18:24:44.355000','2026-02-26 18:24:44.355000',NULL,NULL,NULL),(132,'b7b50kph2tp6i4yoghgiu6kx','admin::api-tokens.delete','{}',NULL,'{}','[]','2026-02-26 18:24:45.075000','2026-02-26 18:24:45.075000','2026-02-26 18:24:45.076000',NULL,NULL,NULL),(133,'oeb7asyqz0qjch7fvt1gj5m6','admin::project-settings.update','{}',NULL,'{}','[]','2026-02-26 18:24:45.794000','2026-02-26 18:24:45.794000','2026-02-26 18:24:45.794000',NULL,NULL,NULL),(134,'ef3ghu1xsuksvyf96uy1nxr6','admin::project-settings.read','{}',NULL,'{}','[]','2026-02-26 18:24:46.513000','2026-02-26 18:24:46.513000','2026-02-26 18:24:46.513000',NULL,NULL,NULL),(135,'vn02wr34mu8lk9b4he8jdwnq','admin::transfer.tokens.access','{}',NULL,'{}','[]','2026-02-26 18:24:47.232000','2026-02-26 18:24:47.232000','2026-02-26 18:24:47.232000',NULL,NULL,NULL),(136,'j7cpotxymr4t2icj58wnbxmg','admin::transfer.tokens.create','{}',NULL,'{}','[]','2026-02-26 18:24:47.951000','2026-02-26 18:24:47.951000','2026-02-26 18:24:47.951000',NULL,NULL,NULL),(137,'lzymuodhifmshc4vbr532002','admin::transfer.tokens.read','{}',NULL,'{}','[]','2026-02-26 18:24:48.670000','2026-02-26 18:24:48.670000','2026-02-26 18:24:48.670000',NULL,NULL,NULL),(138,'eid7kucv5u9yepj78nwz0wus','admin::transfer.tokens.update','{}',NULL,'{}','[]','2026-02-26 18:24:49.388000','2026-02-26 18:24:49.388000','2026-02-26 18:24:49.388000',NULL,NULL,NULL),(139,'a9d0ih9vk6h40i2kym35d4w9','admin::transfer.tokens.regenerate','{}',NULL,'{}','[]','2026-02-26 18:24:50.110000','2026-02-26 18:24:50.110000','2026-02-26 18:24:50.110000',NULL,NULL,NULL),(140,'ppiqm0dkkltmjwsghqiwc7ft','admin::transfer.tokens.delete','{}',NULL,'{}','[]','2026-02-26 18:24:50.830000','2026-02-26 18:24:50.830000','2026-02-26 18:24:50.830000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `admin_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_permissions_role_lnk`
--

DROP TABLE IF EXISTS `admin_permissions_role_lnk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_permissions_role_lnk` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `permission_id` int unsigned DEFAULT NULL,
  `role_id` int unsigned DEFAULT NULL,
  `permission_ord` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admin_permissions_role_lnk_uq` (`permission_id`,`role_id`),
  KEY `admin_permissions_role_lnk_fk` (`permission_id`),
  KEY `admin_permissions_role_lnk_ifk` (`role_id`),
  KEY `admin_permissions_role_lnk_oifk` (`permission_ord`),
  CONSTRAINT `admin_permissions_role_lnk_fk` FOREIGN KEY (`permission_id`) REFERENCES `admin_permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `admin_permissions_role_lnk_ifk` FOREIGN KEY (`role_id`) REFERENCES `admin_roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_permissions_role_lnk`
--

LOCK TABLES `admin_permissions_role_lnk` WRITE;
/*!40000 ALTER TABLE `admin_permissions_role_lnk` DISABLE KEYS */;
INSERT INTO `admin_permissions_role_lnk` VALUES (1,1,2,1),(2,2,2,2),(3,3,2,3),(4,4,2,4),(5,5,2,5),(6,6,2,6),(7,7,2,7),(8,8,2,8),(9,9,2,9),(10,10,2,10),(11,11,2,11),(12,12,2,12),(13,13,2,13),(14,14,2,14),(15,15,2,15),(16,16,2,16),(17,17,2,17),(18,18,2,18),(19,19,2,19),(20,20,2,20),(21,21,2,21),(22,22,2,22),(23,23,2,23),(24,24,2,24),(25,25,2,25),(26,26,2,26),(27,27,2,27),(28,28,2,28),(29,29,2,29),(30,30,2,30),(31,31,2,31),(32,32,2,32),(33,33,1,1),(34,34,1,2),(35,35,1,3),(36,36,1,4),(37,37,1,5),(38,38,1,6),(39,39,1,7),(40,40,1,8),(41,41,1,9),(42,42,1,10),(43,43,1,11),(44,44,1,12),(45,45,1,13),(46,46,1,14),(47,47,1,15),(48,48,1,16),(49,49,1,17),(50,50,1,18),(51,51,1,19),(52,52,1,20),(53,53,1,21),(54,54,1,22),(55,55,1,23),(56,56,1,24),(57,57,1,25),(58,58,1,26),(59,59,1,27),(60,60,1,28),(61,61,1,29),(62,62,1,30),(63,63,1,31),(64,64,1,32),(65,65,1,33),(66,66,1,34),(67,67,1,35),(68,68,1,36),(69,69,1,37),(70,70,1,38),(71,71,1,39),(72,72,1,40),(73,73,1,41),(74,74,1,42),(75,75,1,43),(76,76,1,44),(77,77,1,45),(78,78,1,46),(79,79,1,47),(80,80,1,48),(81,81,1,49),(82,82,1,50),(83,83,1,51),(84,84,1,52),(85,85,1,53),(86,86,1,54),(87,87,1,55),(88,88,1,56),(89,89,1,57),(90,90,1,58),(91,91,1,59),(92,92,1,60),(93,93,1,61),(94,94,1,62),(95,95,1,63),(96,96,1,64),(97,97,1,65),(98,98,1,66),(99,99,1,67),(100,100,1,68),(101,101,1,69),(102,102,1,70),(103,103,1,71),(104,104,1,72),(105,105,1,73),(106,106,1,74),(107,107,1,75),(108,108,1,76),(109,109,1,77),(110,110,1,78),(111,111,1,79),(112,112,1,80),(113,113,1,81),(114,114,1,82),(115,115,1,83),(116,116,1,84),(117,117,1,85),(118,118,1,86),(119,119,1,87),(120,120,1,88),(121,121,1,89),(122,122,1,90),(123,123,1,91),(124,124,1,92),(125,125,1,93),(126,126,1,94),(127,127,1,95),(128,128,1,96),(129,129,1,97),(130,130,1,98),(131,131,1,99),(132,132,1,100),(133,133,1,101),(134,134,1,102),(135,135,1,103),(136,136,1,104),(137,137,1,105),(138,138,1,106),(139,139,1,107),(140,140,1,108);
/*!40000 ALTER TABLE `admin_permissions_role_lnk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_roles`
--

DROP TABLE IF EXISTS `admin_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_roles` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `admin_roles_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `admin_roles_created_by_id_fk` (`created_by_id`),
  KEY `admin_roles_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `admin_roles_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `admin_roles_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_roles`
--

LOCK TABLES `admin_roles` WRITE;
/*!40000 ALTER TABLE `admin_roles` DISABLE KEYS */;
INSERT INTO `admin_roles` VALUES (1,'ca9urk2vtirl6lu7zx0oxhml','Super Admin','strapi-super-admin','Super Admins can access and manage all features and settings.','2026-02-26 18:22:28.286000','2026-02-26 18:22:28.286000','2026-02-26 18:22:28.287000',NULL,NULL,NULL),(2,'dwe3yvnasa0frz34g8u7daqb','Editor','strapi-editor','Editors can manage and publish contents including those of other users.','2026-02-26 18:22:29.024000','2026-02-26 18:22:29.024000','2026-02-26 18:22:29.024000',NULL,NULL,NULL),(3,'il2mrj2dgebdv6wtc5us80fh','Author','strapi-author','Authors can manage the content they have created.','2026-02-26 18:22:29.637000','2026-02-26 18:22:29.637000','2026-02-26 18:22:29.637000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `admin_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_users`
--

DROP TABLE IF EXISTS `admin_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `firstname` varchar(255) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `reset_password_token` varchar(255) DEFAULT NULL,
  `registration_token` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `blocked` tinyint(1) DEFAULT NULL,
  `prefered_language` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `admin_users_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `admin_users_created_by_id_fk` (`created_by_id`),
  KEY `admin_users_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `admin_users_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `admin_users_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_users`
--

LOCK TABLES `admin_users` WRITE;
/*!40000 ALTER TABLE `admin_users` DISABLE KEYS */;
INSERT INTO `admin_users` VALUES (1,'ziulrd82il5uyqae573clu7j','Admin','User',NULL,'admin@aipatterns.dev','$2a$10$CtJQ2Q9kx9OAIPnWxNy58.ErFoHT/9VMZWDWf4oIJPCemd8pDUA7e',NULL,NULL,1,0,NULL,'2026-02-26 18:25:56.470000','2026-02-26 18:25:56.470000','2026-02-26 18:25:56.470000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `admin_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admin_users_roles_lnk`
--

DROP TABLE IF EXISTS `admin_users_roles_lnk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_users_roles_lnk` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned DEFAULT NULL,
  `role_id` int unsigned DEFAULT NULL,
  `role_ord` double unsigned DEFAULT NULL,
  `user_ord` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admin_users_roles_lnk_uq` (`user_id`,`role_id`),
  KEY `admin_users_roles_lnk_fk` (`user_id`),
  KEY `admin_users_roles_lnk_ifk` (`role_id`),
  KEY `admin_users_roles_lnk_ofk` (`role_ord`),
  KEY `admin_users_roles_lnk_oifk` (`user_ord`),
  CONSTRAINT `admin_users_roles_lnk_fk` FOREIGN KEY (`user_id`) REFERENCES `admin_users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `admin_users_roles_lnk_ifk` FOREIGN KEY (`role_id`) REFERENCES `admin_roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_users_roles_lnk`
--

LOCK TABLES `admin_users_roles_lnk` WRITE;
/*!40000 ALTER TABLE `admin_users_roles_lnk` DISABLE KEYS */;
INSERT INTO `admin_users_roles_lnk` VALUES (1,1,1,1,1);
/*!40000 ALTER TABLE `admin_users_roles_lnk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_layout_cta_buttons`
--

DROP TABLE IF EXISTS `components_layout_cta_buttons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_layout_cta_buttons` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `label` varchar(255) DEFAULT NULL,
  `href` varchar(255) DEFAULT NULL,
  `variant` varchar(255) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_layout_cta_buttons`
--

LOCK TABLES `components_layout_cta_buttons` WRITE;
/*!40000 ALTER TABLE `components_layout_cta_buttons` DISABLE KEYS */;
INSERT INTO `components_layout_cta_buttons` VALUES (1,'Browse Patterns','/patterns','primary',NULL),(2,'Get Started','/patterns','secondary',NULL),(3,'Learn More','#featured','outline',NULL),(4,'Star on GitHub','https://github.com/sandropetterle/AIEnterprisePatterns','outline','Github'),(9,'View on GitHub','https://github.com/sandropetterle/AIEnterprisePatterns','primary','Github'),(10,'View on GitHub','https://github.com/sandropetterle/AIEnterprisePatterns','primary','Github'),(11,'Back to Home','/','primary','Home'),(16,'Browse Patterns','/patterns','primary',NULL),(17,'Get Started','/patterns','secondary',NULL),(18,'Learn More','#featured','outline',NULL),(19,'Star on GitHub','https://github.com/sandropetterle/AIEnterprisePatterns','outline','Github');
/*!40000 ALTER TABLE `components_layout_cta_buttons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_layout_footer_configs`
--

DROP TABLE IF EXISTS `components_layout_footer_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_layout_footer_configs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `copyright_template` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_layout_footer_configs`
--

LOCK TABLES `components_layout_footer_configs` WRITE;
/*!40000 ALTER TABLE `components_layout_footer_configs` DISABLE KEYS */;
INSERT INTO `components_layout_footer_configs` VALUES (1,'© {year} AI Enterprise Patterns. All rights reserved.');
/*!40000 ALTER TABLE `components_layout_footer_configs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_layout_footer_configs_cmps`
--

DROP TABLE IF EXISTS `components_layout_footer_configs_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_layout_footer_configs_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_layout_footer_configs_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_layout_footer_configs_field_idx` (`field`),
  KEY `components_layout_footer_configs_component_type_idx` (`component_type`),
  KEY `components_layout_footer_configs_entity_fk` (`entity_id`),
  CONSTRAINT `components_layout_footer_configs_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_layout_footer_configs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_layout_footer_configs_cmps`
--

LOCK TABLES `components_layout_footer_configs_cmps` WRITE;
/*!40000 ALTER TABLE `components_layout_footer_configs_cmps` DISABLE KEYS */;
INSERT INTO `components_layout_footer_configs_cmps` VALUES (1,1,4,'layout.nav-link','links',1),(2,1,5,'layout.nav-link','links',2);
/*!40000 ALTER TABLE `components_layout_footer_configs_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_layout_nav_links`
--

DROP TABLE IF EXISTS `components_layout_nav_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_layout_nav_links` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `label` varchar(255) DEFAULT NULL,
  `href` varchar(255) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `is_external` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_layout_nav_links`
--

LOCK TABLES `components_layout_nav_links` WRITE;
/*!40000 ALTER TABLE `components_layout_nav_links` DISABLE KEYS */;
INSERT INTO `components_layout_nav_links` VALUES (1,'Home','/',NULL,0),(2,'Patterns','/patterns',NULL,0),(3,'About','/about',NULL,0),(4,'GitHub','https://github.com/sandropetterle/AIEnterprisePatterns',NULL,1),(5,'Documentation','/docs',NULL,0);
/*!40000 ALTER TABLE `components_layout_nav_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_api_references`
--

DROP TABLE IF EXISTS `components_sections_api_references`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_api_references` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `description` longtext,
  `base_url` varchar(255) DEFAULT NULL,
  `example_code` longtext,
  `swagger_note` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_api_references`
--

LOCK TABLES `components_sections_api_references` WRITE;
/*!40000 ALTER TABLE `components_sections_api_references` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_sections_api_references` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_api_references_cmps`
--

DROP TABLE IF EXISTS `components_sections_api_references_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_api_references_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_sections_api_references_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_sections_api_references_field_idx` (`field`),
  KEY `components_sections_api_references_component_type_idx` (`component_type`),
  KEY `components_sections_api_references_entity_fk` (`entity_id`),
  CONSTRAINT `components_sections_api_references_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_sections_api_references` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_api_references_cmps`
--

LOCK TABLES `components_sections_api_references_cmps` WRITE;
/*!40000 ALTER TABLE `components_sections_api_references_cmps` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_sections_api_references_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_contributings`
--

DROP TABLE IF EXISTS `components_sections_contributings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_contributings` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `description` longtext,
  `how_to_title` varchar(255) DEFAULT NULL,
  `steps` longtext,
  `guidelines_title` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_contributings`
--

LOCK TABLES `components_sections_contributings` WRITE;
/*!40000 ALTER TABLE `components_sections_contributings` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_sections_contributings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_contributings_cmps`
--

DROP TABLE IF EXISTS `components_sections_contributings_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_contributings_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_sections_contributings_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_sections_contributings_field_idx` (`field`),
  KEY `components_sections_contributings_component_type_idx` (`component_type`),
  KEY `components_sections_contributings_entity_fk` (`entity_id`),
  CONSTRAINT `components_sections_contributings_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_sections_contributings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_contributings_cmps`
--

LOCK TABLES `components_sections_contributings_cmps` WRITE;
/*!40000 ALTER TABLE `components_sections_contributings_cmps` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_sections_contributings_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_cta_banners`
--

DROP TABLE IF EXISTS `components_sections_cta_banners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_cta_banners` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `heading` varchar(255) DEFAULT NULL,
  `description` longtext,
  `variant` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_cta_banners`
--

LOCK TABLES `components_sections_cta_banners` WRITE;
/*!40000 ALTER TABLE `components_sections_cta_banners` DISABLE KEYS */;
INSERT INTO `components_sections_cta_banners` VALUES (1,'Ready to explore enterprise patterns?','Join our community and discover proven solutions for your next project. Contribute your own patterns and help others build better software.','highlighted'),(4,'Ready to explore enterprise patterns?','Join our community and discover proven solutions for your next project. Contribute your own patterns and help others build better software.','highlighted');
/*!40000 ALTER TABLE `components_sections_cta_banners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_cta_banners_cmps`
--

DROP TABLE IF EXISTS `components_sections_cta_banners_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_cta_banners_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_sections_cta_banners_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_sections_cta_banners_field_idx` (`field`),
  KEY `components_sections_cta_banners_component_type_idx` (`component_type`),
  KEY `components_sections_cta_banners_entity_fk` (`entity_id`),
  CONSTRAINT `components_sections_cta_banners_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_sections_cta_banners` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_cta_banners_cmps`
--

LOCK TABLES `components_sections_cta_banners_cmps` WRITE;
/*!40000 ALTER TABLE `components_sections_cta_banners_cmps` DISABLE KEYS */;
INSERT INTO `components_sections_cta_banners_cmps` VALUES (1,1,2,'layout.cta-button','primaryCTA',NULL),(2,1,4,'layout.cta-button','secondaryCTA',NULL),(15,4,17,'layout.cta-button','primaryCTA',NULL),(16,4,19,'layout.cta-button','secondaryCTA',NULL);
/*!40000 ALTER TABLE `components_sections_cta_banners_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_doc_sections`
--

DROP TABLE IF EXISTS `components_sections_doc_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_doc_sections` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `anchor_id` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_doc_sections`
--

LOCK TABLES `components_sections_doc_sections` WRITE;
/*!40000 ALTER TABLE `components_sections_doc_sections` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_sections_doc_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_feature_grids`
--

DROP TABLE IF EXISTS `components_sections_feature_grids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_feature_grids` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `heading` varchar(255) DEFAULT NULL,
  `columns` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_feature_grids`
--

LOCK TABLES `components_sections_feature_grids` WRITE;
/*!40000 ALTER TABLE `components_sections_feature_grids` DISABLE KEYS */;
INSERT INTO `components_sections_feature_grids` VALUES (1,'What We Offer','3'),(2,'What We Offer','3');
/*!40000 ALTER TABLE `components_sections_feature_grids` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_feature_grids_cmps`
--

DROP TABLE IF EXISTS `components_sections_feature_grids_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_feature_grids_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_sections_feature_grids_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_sections_feature_grids_field_idx` (`field`),
  KEY `components_sections_feature_grids_component_type_idx` (`component_type`),
  KEY `components_sections_feature_grids_entity_fk` (`entity_id`),
  CONSTRAINT `components_sections_feature_grids_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_sections_feature_grids` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_feature_grids_cmps`
--

LOCK TABLES `components_sections_feature_grids_cmps` WRITE;
/*!40000 ALTER TABLE `components_sections_feature_grids_cmps` DISABLE KEYS */;
INSERT INTO `components_sections_feature_grids_cmps` VALUES (1,1,1,'shared.feature-card','features',1),(2,1,2,'shared.feature-card','features',2),(3,1,3,'shared.feature-card','features',3),(4,1,4,'shared.feature-card','features',4),(5,1,5,'shared.feature-card','features',5),(6,1,6,'shared.feature-card','features',6),(7,2,7,'shared.feature-card','features',1),(8,2,8,'shared.feature-card','features',2),(9,2,9,'shared.feature-card','features',3),(10,2,10,'shared.feature-card','features',4),(11,2,11,'shared.feature-card','features',5),(12,2,12,'shared.feature-card','features',6);
/*!40000 ALTER TABLE `components_sections_feature_grids_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_featured_patterns`
--

DROP TABLE IF EXISTS `components_sections_featured_patterns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_featured_patterns` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `heading` varchar(255) DEFAULT NULL,
  `subheading` varchar(255) DEFAULT NULL,
  `view_all_label` varchar(255) DEFAULT NULL,
  `mobile_view_all_label` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_featured_patterns`
--

LOCK TABLES `components_sections_featured_patterns` WRITE;
/*!40000 ALTER TABLE `components_sections_featured_patterns` DISABLE KEYS */;
INSERT INTO `components_sections_featured_patterns` VALUES (1,'Featured Patterns','Explore our most popular and recently added enterprise patterns','View all patterns','View all'),(4,'Featured Patterns','Explore our most popular and recently added enterprise patterns','View all patterns','View all');
/*!40000 ALTER TABLE `components_sections_featured_patterns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_heroes`
--

DROP TABLE IF EXISTS `components_sections_heroes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_heroes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `heading` varchar(255) DEFAULT NULL,
  `subheading` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_heroes`
--

LOCK TABLES `components_sections_heroes` WRITE;
/*!40000 ALTER TABLE `components_sections_heroes` DISABLE KEYS */;
INSERT INTO `components_sections_heroes` VALUES (1,'AI Enterprise Patterns Library','Curated AI-driven recipes, prompts, and blueprints for enterprise software architecture. Discover proven patterns, best practices, and innovative solutions to accelerate your development.'),(4,'AI Enterprise Patterns Library','Curated AI-driven recipes, prompts, and blueprints for enterprise software architecture. Discover proven patterns, best practices, and innovative solutions to accelerate your development.');
/*!40000 ALTER TABLE `components_sections_heroes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_heroes_cmps`
--

DROP TABLE IF EXISTS `components_sections_heroes_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_heroes_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_sections_heroes_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_sections_heroes_field_idx` (`field`),
  KEY `components_sections_heroes_component_type_idx` (`component_type`),
  KEY `components_sections_heroes_entity_fk` (`entity_id`),
  CONSTRAINT `components_sections_heroes_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_sections_heroes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_heroes_cmps`
--

LOCK TABLES `components_sections_heroes_cmps` WRITE;
/*!40000 ALTER TABLE `components_sections_heroes_cmps` DISABLE KEYS */;
INSERT INTO `components_sections_heroes_cmps` VALUES (1,1,1,'layout.cta-button','primaryCTA',NULL),(2,1,3,'layout.cta-button','secondaryCTA',NULL),(15,4,16,'layout.cta-button','primaryCTA',NULL),(16,4,18,'layout.cta-button','secondaryCTA',NULL);
/*!40000 ALTER TABLE `components_sections_heroes_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_mission_blocks`
--

DROP TABLE IF EXISTS `components_sections_mission_blocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_mission_blocks` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `content` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_mission_blocks`
--

LOCK TABLES `components_sections_mission_blocks` WRITE;
/*!40000 ALTER TABLE `components_sections_mission_blocks` DISABLE KEYS */;
INSERT INTO `components_sections_mission_blocks` VALUES (1,'Our Mission','In the rapidly evolving landscape of AI-assisted software development, developers need proven patterns and strategies to effectively leverage AI tools in enterprise contexts. Our mission is to bridge that gap.\n\nWe curate, document, and share battle-tested patterns that help teams integrate AI into their development workflows—from architectural decisions and design patterns to prompt engineering and best practices.\n\nWhether you\'re building microservices, implementing clean architecture, or exploring AI-assisted code generation, you\'ll find practical, production-ready patterns here.'),(2,'Our Mission','In the rapidly evolving landscape of AI-assisted software development, developers need proven patterns and strategies to effectively leverage AI tools in enterprise contexts. Our mission is to bridge that gap.\n\nWe curate, document, and share battle-tested patterns that help teams integrate AI into their development workflows—from architectural decisions and design patterns to prompt engineering and best practices.\n\nWhether you\'re building microservices, implementing clean architecture, or exploring AI-assisted code generation, you\'ll find practical, production-ready patterns here.');
/*!40000 ALTER TABLE `components_sections_mission_blocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_open_source_infos`
--

DROP TABLE IF EXISTS `components_sections_open_source_infos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_open_source_infos` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `description` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_open_source_infos`
--

LOCK TABLES `components_sections_open_source_infos` WRITE;
/*!40000 ALTER TABLE `components_sections_open_source_infos` DISABLE KEYS */;
INSERT INTO `components_sections_open_source_infos` VALUES (1,'Open Source','This project is open source and welcomes contributions from the community. Whether you want to add new patterns, improve documentation, or fix bugs — all contributions are appreciated.'),(2,'Open Source','This project is open source and welcomes contributions from the community. Whether you want to add new patterns, improve documentation, or fix bugs — all contributions are appreciated.');
/*!40000 ALTER TABLE `components_sections_open_source_infos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_open_source_infos_cmps`
--

DROP TABLE IF EXISTS `components_sections_open_source_infos_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_open_source_infos_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_sections_open_source_infos_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_sections_open_source_infos_field_idx` (`field`),
  KEY `components_sections_open_sourcebd451_component_type_idx` (`component_type`),
  KEY `components_sections_open_source_infos_entity_fk` (`entity_id`),
  CONSTRAINT `components_sections_open_source_infos_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_sections_open_source_infos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_open_source_infos_cmps`
--

LOCK TABLES `components_sections_open_source_infos_cmps` WRITE;
/*!40000 ALTER TABLE `components_sections_open_source_infos_cmps` DISABLE KEYS */;
INSERT INTO `components_sections_open_source_infos_cmps` VALUES (1,1,9,'layout.cta-button','links',1),(2,2,10,'layout.cta-button','links',1);
/*!40000 ALTER TABLE `components_sections_open_source_infos_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_page_headers`
--

DROP TABLE IF EXISTS `components_sections_page_headers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_page_headers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `badge` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `subtitle` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_page_headers`
--

LOCK TABLES `components_sections_page_headers` WRITE;
/*!40000 ALTER TABLE `components_sections_page_headers` DISABLE KEYS */;
INSERT INTO `components_sections_page_headers` VALUES (1,'About the Platform','AI Enterprise Patterns Library','A centralized repository of AI-driven recipes, prompts, and blueprints for enterprise software architecture patterns. Curated by developers, for developers.'),(2,'About the Platform','AI Enterprise Patterns Library','A centralized repository of AI-driven recipes, prompts, and blueprints for enterprise software architecture patterns. Curated by developers, for developers.');
/*!40000 ALTER TABLE `components_sections_page_headers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_quick_navs`
--

DROP TABLE IF EXISTS `components_sections_quick_navs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_quick_navs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `heading` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_quick_navs`
--

LOCK TABLES `components_sections_quick_navs` WRITE;
/*!40000 ALTER TABLE `components_sections_quick_navs` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_sections_quick_navs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_quick_navs_cmps`
--

DROP TABLE IF EXISTS `components_sections_quick_navs_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_quick_navs_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_sections_quick_navs_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_sections_quick_navs_field_idx` (`field`),
  KEY `components_sections_quick_navs_component_type_idx` (`component_type`),
  KEY `components_sections_quick_navs_entity_fk` (`entity_id`),
  CONSTRAINT `components_sections_quick_navs_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_sections_quick_navs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_quick_navs_cmps`
--

LOCK TABLES `components_sections_quick_navs_cmps` WRITE;
/*!40000 ALTER TABLE `components_sections_quick_navs_cmps` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_sections_quick_navs_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_rich_texts`
--

DROP TABLE IF EXISTS `components_sections_rich_texts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_rich_texts` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `body` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_rich_texts`
--

LOCK TABLES `components_sections_rich_texts` WRITE;
/*!40000 ALTER TABLE `components_sections_rich_texts` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_sections_rich_texts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_stats_bars`
--

DROP TABLE IF EXISTS `components_sections_stats_bars`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_stats_bars` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_stats_bars`
--

LOCK TABLES `components_sections_stats_bars` WRITE;
/*!40000 ALTER TABLE `components_sections_stats_bars` DISABLE KEYS */;
INSERT INTO `components_sections_stats_bars` VALUES (1),(4);
/*!40000 ALTER TABLE `components_sections_stats_bars` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_stats_bars_cmps`
--

DROP TABLE IF EXISTS `components_sections_stats_bars_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_stats_bars_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_sections_stats_bars_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_sections_stats_bars_field_idx` (`field`),
  KEY `components_sections_stats_bars_component_type_idx` (`component_type`),
  KEY `components_sections_stats_bars_entity_fk` (`entity_id`),
  CONSTRAINT `components_sections_stats_bars_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_sections_stats_bars` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_stats_bars_cmps`
--

LOCK TABLES `components_sections_stats_bars_cmps` WRITE;
/*!40000 ALTER TABLE `components_sections_stats_bars_cmps` DISABLE KEYS */;
INSERT INTO `components_sections_stats_bars_cmps` VALUES (1,1,1,'shared.stat-item','stats',1),(2,1,2,'shared.stat-item','stats',2),(3,1,3,'shared.stat-item','stats',3),(22,4,10,'shared.stat-item','stats',1),(23,4,11,'shared.stat-item','stats',2),(24,4,12,'shared.stat-item','stats',3);
/*!40000 ALTER TABLE `components_sections_stats_bars_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_support_links`
--

DROP TABLE IF EXISTS `components_sections_support_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_support_links` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `description` longtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_support_links`
--

LOCK TABLES `components_sections_support_links` WRITE;
/*!40000 ALTER TABLE `components_sections_support_links` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_sections_support_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_support_links_cmps`
--

DROP TABLE IF EXISTS `components_sections_support_links_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_support_links_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_sections_support_links_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_sections_support_links_field_idx` (`field`),
  KEY `components_sections_support_links_component_type_idx` (`component_type`),
  KEY `components_sections_support_links_entity_fk` (`entity_id`),
  CONSTRAINT `components_sections_support_links_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_sections_support_links` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_support_links_cmps`
--

LOCK TABLES `components_sections_support_links_cmps` WRITE;
/*!40000 ALTER TABLE `components_sections_support_links_cmps` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_sections_support_links_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_tech_stacks`
--

DROP TABLE IF EXISTS `components_sections_tech_stacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_tech_stacks` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `heading` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_tech_stacks`
--

LOCK TABLES `components_sections_tech_stacks` WRITE;
/*!40000 ALTER TABLE `components_sections_tech_stacks` DISABLE KEYS */;
INSERT INTO `components_sections_tech_stacks` VALUES (1,'Built With'),(2,'Built With');
/*!40000 ALTER TABLE `components_sections_tech_stacks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_sections_tech_stacks_cmps`
--

DROP TABLE IF EXISTS `components_sections_tech_stacks_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_sections_tech_stacks_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_sections_tech_stacks_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_sections_tech_stacks_field_idx` (`field`),
  KEY `components_sections_tech_stacks_component_type_idx` (`component_type`),
  KEY `components_sections_tech_stacks_entity_fk` (`entity_id`),
  CONSTRAINT `components_sections_tech_stacks_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_sections_tech_stacks` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_sections_tech_stacks_cmps`
--

LOCK TABLES `components_sections_tech_stacks_cmps` WRITE;
/*!40000 ALTER TABLE `components_sections_tech_stacks_cmps` DISABLE KEYS */;
INSERT INTO `components_sections_tech_stacks_cmps` VALUES (1,1,1,'shared.tech-group','groups',1),(2,1,2,'shared.tech-group','groups',2),(3,2,3,'shared.tech-group','groups',1),(4,2,4,'shared.tech-group','groups',2);
/*!40000 ALTER TABLE `components_sections_tech_stacks_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_seo_metadata`
--

DROP TABLE IF EXISTS `components_seo_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_seo_metadata` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `description` longtext,
  `keywords` longtext,
  `og_title` varchar(255) DEFAULT NULL,
  `og_description` longtext,
  `no_index` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_seo_metadata`
--

LOCK TABLES `components_seo_metadata` WRITE;
/*!40000 ALTER TABLE `components_seo_metadata` DISABLE KEYS */;
INSERT INTO `components_seo_metadata` VALUES (1,'AI Enterprise Patterns Library','A centralized repository of AI-driven recipes, prompts, and blueprints for enterprise software architecture patterns.','AI patterns, enterprise architecture, software patterns, AI prompts, best practices, design patterns','AI Enterprise Patterns Library','Curated AI-driven recipes, prompts, and blueprints for enterprise software architecture',0),(2,'Home','Discover curated AI-driven enterprise patterns, prompts, and architectural blueprints. Browse featured patterns and join the community.',NULL,NULL,NULL,0),(4,'About | AI Enterprise Patterns','Learn about AI Enterprise Patterns Library - a curated collection of AI-driven implementation patterns, prompts, and architectural blueprints for modern software development.','about, AI patterns, enterprise architecture, software patterns, AI-assisted development, pattern library','About | AI Enterprise Patterns','A curated collection of AI-driven implementation patterns for modern software development.',0),(5,'About | AI Enterprise Patterns','Learn about AI Enterprise Patterns Library - a curated collection of AI-driven implementation patterns, prompts, and architectural blueprints for modern software development.','about, AI patterns, enterprise architecture, software patterns, AI-assisted development, pattern library','About | AI Enterprise Patterns','A curated collection of AI-driven implementation patterns for modern software development.',0),(6,'Sign In | AI Enterprise Patterns',NULL,NULL,NULL,NULL,0),(8,'Home','Discover curated AI-driven enterprise patterns, prompts, and architectural blueprints. Browse featured patterns and join the community.',NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `components_seo_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_shared_api_endpoints`
--

DROP TABLE IF EXISTS `components_shared_api_endpoints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_shared_api_endpoints` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `method` varchar(255) DEFAULT NULL,
  `path` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `auth_required` tinyint(1) DEFAULT NULL,
  `rate_limit` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_shared_api_endpoints`
--

LOCK TABLES `components_shared_api_endpoints` WRITE;
/*!40000 ALTER TABLE `components_shared_api_endpoints` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_shared_api_endpoints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_shared_api_endpoints_cmps`
--

DROP TABLE IF EXISTS `components_shared_api_endpoints_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_shared_api_endpoints_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_shared_api_endpoints_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_shared_api_endpoints_field_idx` (`field`),
  KEY `components_shared_api_endpoints_component_type_idx` (`component_type`),
  KEY `components_shared_api_endpoints_entity_fk` (`entity_id`),
  CONSTRAINT `components_shared_api_endpoints_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_shared_api_endpoints` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_shared_api_endpoints_cmps`
--

LOCK TABLES `components_shared_api_endpoints_cmps` WRITE;
/*!40000 ALTER TABLE `components_shared_api_endpoints_cmps` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_shared_api_endpoints_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_shared_feature_card`
--

DROP TABLE IF EXISTS `components_shared_feature_card`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_shared_feature_card` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `icon` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_shared_feature_card`
--

LOCK TABLES `components_shared_feature_card` WRITE;
/*!40000 ALTER TABLE `components_shared_feature_card` DISABLE KEYS */;
INSERT INTO `components_shared_feature_card` VALUES (1,'Code2','Design Patterns','Architectural blueprints and implementation guides for enterprise software development'),(2,'Sparkles','AI Prompts','Curated prompts for AI-assisted development, code review, and refactoring'),(3,'BookOpen','Best Practices','Industry-standard practices for security, performance, and code quality'),(4,'Zap','Architecture Guides','Comprehensive guides for building scalable, maintainable systems'),(5,'Users','Community Driven','Patterns contributed and validated by real enterprise developers'),(6,'Lightbulb','Continuous Learning','Stay updated with the latest AI-assisted development practices'),(7,'Code2','Design Patterns','Architectural blueprints and implementation guides for enterprise software development'),(8,'Sparkles','AI Prompts','Curated prompts for AI-assisted development, code review, and refactoring'),(9,'BookOpen','Best Practices','Industry-standard practices for security, performance, and code quality'),(10,'Zap','Architecture Guides','Comprehensive guides for building scalable, maintainable systems'),(11,'Users','Community Driven','Patterns contributed and validated by real enterprise developers'),(12,'Lightbulb','Continuous Learning','Stay updated with the latest AI-assisted development practices');
/*!40000 ALTER TABLE `components_shared_feature_card` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_shared_feature_card_cmps`
--

DROP TABLE IF EXISTS `components_shared_feature_card_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_shared_feature_card_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_shared_feature_card_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_shared_feature_card_field_idx` (`field`),
  KEY `components_shared_feature_card_component_type_idx` (`component_type`),
  KEY `components_shared_feature_card_entity_fk` (`entity_id`),
  CONSTRAINT `components_shared_feature_card_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_shared_feature_card` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_shared_feature_card_cmps`
--

LOCK TABLES `components_shared_feature_card_cmps` WRITE;
/*!40000 ALTER TABLE `components_shared_feature_card_cmps` DISABLE KEYS */;
INSERT INTO `components_shared_feature_card_cmps` VALUES (1,1,1,'shared.text-item','items',1),(2,1,2,'shared.text-item','items',2),(3,1,3,'shared.text-item','items',3),(4,1,4,'shared.text-item','items',4),(5,2,5,'shared.text-item','items',1),(6,2,6,'shared.text-item','items',2),(7,2,7,'shared.text-item','items',3),(8,2,8,'shared.text-item','items',4),(9,3,9,'shared.text-item','items',1),(10,3,10,'shared.text-item','items',2),(11,3,11,'shared.text-item','items',3),(12,3,12,'shared.text-item','items',4),(13,4,13,'shared.text-item','items',1),(14,4,14,'shared.text-item','items',2),(15,4,15,'shared.text-item','items',3),(16,4,16,'shared.text-item','items',4),(17,5,17,'shared.text-item','items',1),(18,5,18,'shared.text-item','items',2),(19,5,19,'shared.text-item','items',3),(20,5,20,'shared.text-item','items',4),(21,6,21,'shared.text-item','items',1),(22,6,22,'shared.text-item','items',2),(23,6,23,'shared.text-item','items',3),(24,6,24,'shared.text-item','items',4),(25,7,31,'shared.text-item','items',1),(26,7,32,'shared.text-item','items',2),(27,7,33,'shared.text-item','items',3),(28,7,34,'shared.text-item','items',4),(29,8,35,'shared.text-item','items',1),(30,8,36,'shared.text-item','items',2),(31,8,37,'shared.text-item','items',3),(32,8,38,'shared.text-item','items',4),(33,9,39,'shared.text-item','items',1),(34,9,40,'shared.text-item','items',2),(35,9,41,'shared.text-item','items',3),(36,9,42,'shared.text-item','items',4),(37,10,43,'shared.text-item','items',1),(38,10,44,'shared.text-item','items',2),(39,10,45,'shared.text-item','items',3),(40,10,46,'shared.text-item','items',4),(41,11,47,'shared.text-item','items',1),(42,11,48,'shared.text-item','items',2),(43,11,49,'shared.text-item','items',3),(44,11,50,'shared.text-item','items',4),(45,12,51,'shared.text-item','items',1),(46,12,52,'shared.text-item','items',2),(47,12,53,'shared.text-item','items',3),(48,12,54,'shared.text-item','items',4);
/*!40000 ALTER TABLE `components_shared_feature_card_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_shared_key_value`
--

DROP TABLE IF EXISTS `components_shared_key_value`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_shared_key_value` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) DEFAULT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_shared_key_value`
--

LOCK TABLES `components_shared_key_value` WRITE;
/*!40000 ALTER TABLE `components_shared_key_value` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_shared_key_value` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_shared_quick_nav_items`
--

DROP TABLE IF EXISTS `components_shared_quick_nav_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_shared_quick_nav_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `href` varchar(255) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_shared_quick_nav_items`
--

LOCK TABLES `components_shared_quick_nav_items` WRITE;
/*!40000 ALTER TABLE `components_shared_quick_nav_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_shared_quick_nav_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_shared_stat_item`
--

DROP TABLE IF EXISTS `components_shared_stat_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_shared_stat_item` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `value` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_shared_stat_item`
--

LOCK TABLES `components_shared_stat_item` WRITE;
/*!40000 ALTER TABLE `components_shared_stat_item` DISABLE KEYS */;
INSERT INTO `components_shared_stat_item` VALUES (1,'{totalPatterns}','Patterns Available','BookOpen'),(2,'{totalCategories}','Categories','Folder'),(3,'{totalContributors}','Contributors','Users'),(10,'{totalPatterns}','Patterns Available','BookOpen'),(11,'{totalCategories}','Categories','Folder'),(12,'{totalContributors}','Contributors','Users');
/*!40000 ALTER TABLE `components_shared_stat_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_shared_support_items`
--

DROP TABLE IF EXISTS `components_shared_support_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_shared_support_items` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `href` varchar(255) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_shared_support_items`
--

LOCK TABLES `components_shared_support_items` WRITE;
/*!40000 ALTER TABLE `components_shared_support_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `components_shared_support_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_shared_tech_groups`
--

DROP TABLE IF EXISTS `components_shared_tech_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_shared_tech_groups` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_shared_tech_groups`
--

LOCK TABLES `components_shared_tech_groups` WRITE;
/*!40000 ALTER TABLE `components_shared_tech_groups` DISABLE KEYS */;
INSERT INTO `components_shared_tech_groups` VALUES (1,'Frontend'),(2,'Backend'),(3,'Frontend'),(4,'Backend');
/*!40000 ALTER TABLE `components_shared_tech_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_shared_tech_groups_cmps`
--

DROP TABLE IF EXISTS `components_shared_tech_groups_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_shared_tech_groups_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `components_shared_tech_groups_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `components_shared_tech_groups_field_idx` (`field`),
  KEY `components_shared_tech_groups_component_type_idx` (`component_type`),
  KEY `components_shared_tech_groups_entity_fk` (`entity_id`),
  CONSTRAINT `components_shared_tech_groups_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `components_shared_tech_groups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_shared_tech_groups_cmps`
--

LOCK TABLES `components_shared_tech_groups_cmps` WRITE;
/*!40000 ALTER TABLE `components_shared_tech_groups_cmps` DISABLE KEYS */;
INSERT INTO `components_shared_tech_groups_cmps` VALUES (1,1,25,'shared.text-item','items',1),(2,1,26,'shared.text-item','items',2),(3,1,27,'shared.text-item','items',3),(4,2,28,'shared.text-item','items',1),(5,2,29,'shared.text-item','items',2),(6,2,30,'shared.text-item','items',3),(7,3,55,'shared.text-item','items',1),(8,3,56,'shared.text-item','items',2),(9,3,57,'shared.text-item','items',3),(10,4,58,'shared.text-item','items',1),(11,4,59,'shared.text-item','items',2),(12,4,60,'shared.text-item','items',3);
/*!40000 ALTER TABLE `components_shared_tech_groups_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `components_shared_text_item`
--

DROP TABLE IF EXISTS `components_shared_text_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `components_shared_text_item` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `text` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `components_shared_text_item`
--

LOCK TABLES `components_shared_text_item` WRITE;
/*!40000 ALTER TABLE `components_shared_text_item` DISABLE KEYS */;
INSERT INTO `components_shared_text_item` VALUES (1,'Repository Pattern with EF Core'),(2,'CQRS and Event Sourcing'),(3,'Clean Architecture strategies'),(4,'Microservices patterns'),(5,'Code review prompts (SOLID, security)'),(6,'Refactoring strategies'),(7,'Documentation generation'),(8,'Test case creation'),(9,'OWASP security guidelines'),(10,'Performance optimization'),(11,'Testing strategies'),(12,'Code quality metrics'),(13,'Cloud-native patterns'),(14,'Event-driven architecture'),(15,'API design principles'),(16,'Database patterns'),(17,'Peer-reviewed submissions'),(18,'Real-world examples'),(19,'Version control'),(20,'Discussion and feedback'),(21,'Regular content updates'),(22,'Emerging AI patterns'),(23,'Tool integrations'),(24,'Case studies'),(25,'Next.js 16 (App Router)'),(26,'React 19 + TypeScript'),(27,'Tailwind CSS + shadcn/ui'),(28,'ASP.NET Core 8'),(29,'Entity Framework Core 8'),(30,'Azure Container Apps'),(31,'Repository Pattern with EF Core'),(32,'CQRS and Event Sourcing'),(33,'Clean Architecture strategies'),(34,'Microservices patterns'),(35,'Code review prompts (SOLID, security)'),(36,'Refactoring strategies'),(37,'Documentation generation'),(38,'Test case creation'),(39,'OWASP security guidelines'),(40,'Performance optimization'),(41,'Testing strategies'),(42,'Code quality metrics'),(43,'Cloud-native patterns'),(44,'Event-driven architecture'),(45,'API design principles'),(46,'Database patterns'),(47,'Peer-reviewed submissions'),(48,'Real-world examples'),(49,'Version control'),(50,'Discussion and feedback'),(51,'Regular content updates'),(52,'Emerging AI patterns'),(53,'Tool integrations'),(54,'Case studies'),(55,'Next.js 16 (App Router)'),(56,'React 19 + TypeScript'),(57,'Tailwind CSS + shadcn/ui'),(58,'ASP.NET Core 8'),(59,'Entity Framework Core 8'),(60,'Azure Container Apps');
/*!40000 ALTER TABLE `components_shared_text_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `docs_page`
--

DROP TABLE IF EXISTS `docs_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `docs_page` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `docs_page_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `docs_page_created_by_id_fk` (`created_by_id`),
  KEY `docs_page_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `docs_page_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `docs_page_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `docs_page`
--

LOCK TABLES `docs_page` WRITE;
/*!40000 ALTER TABLE `docs_page` DISABLE KEYS */;
/*!40000 ALTER TABLE `docs_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `docs_page_cmps`
--

DROP TABLE IF EXISTS `docs_page_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `docs_page_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `docs_page_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `docs_page_field_idx` (`field`),
  KEY `docs_page_component_type_idx` (`component_type`),
  KEY `docs_page_entity_fk` (`entity_id`),
  CONSTRAINT `docs_page_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `docs_page` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `docs_page_cmps`
--

LOCK TABLES `docs_page_cmps` WRITE;
/*!40000 ALTER TABLE `docs_page_cmps` DISABLE KEYS */;
/*!40000 ALTER TABLE `docs_page_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `error_page`
--

DROP TABLE IF EXISTS `error_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `error_page` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` longtext,
  `retry_button_label` varchar(255) DEFAULT NULL,
  `home_button_label` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `error_page_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `error_page_created_by_id_fk` (`created_by_id`),
  KEY `error_page_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `error_page_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `error_page_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `error_page`
--

LOCK TABLES `error_page` WRITE;
/*!40000 ALTER TABLE `error_page` DISABLE KEYS */;
INSERT INTO `error_page` VALUES (1,'dl18siviv6t44qh4cwuw94sb','Something went wrong','We encountered an error while loading this page. This could be due to a temporary connection issue or a problem with our servers.','Try again','Go home','2026-02-26 18:28:02.533000','2026-02-26 18:28:02.533000','2026-02-26 18:28:02.531000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `error_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `files` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `alternative_text` longtext,
  `caption` longtext,
  `focal_point` json DEFAULT NULL,
  `width` int DEFAULT NULL,
  `height` int DEFAULT NULL,
  `formats` json DEFAULT NULL,
  `hash` varchar(255) DEFAULT NULL,
  `ext` varchar(255) DEFAULT NULL,
  `mime` varchar(255) DEFAULT NULL,
  `size` decimal(10,2) DEFAULT NULL,
  `url` longtext,
  `preview_url` longtext,
  `provider` varchar(255) DEFAULT NULL,
  `provider_metadata` json DEFAULT NULL,
  `folder_path` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `upload_files_folder_path_index` (`folder_path`),
  KEY `upload_files_created_at_index` (`created_at`),
  KEY `upload_files_updated_at_index` (`updated_at`),
  KEY `upload_files_name_index` (`name`),
  KEY `upload_files_size_index` (`size`),
  KEY `upload_files_ext_index` (`ext`),
  KEY `files_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `files_created_by_id_fk` (`created_by_id`),
  KEY `files_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `files_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `files_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `files`
--

LOCK TABLES `files` WRITE;
/*!40000 ALTER TABLE `files` DISABLE KEYS */;
/*!40000 ALTER TABLE `files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `files_folder_lnk`
--

DROP TABLE IF EXISTS `files_folder_lnk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `files_folder_lnk` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `file_id` int unsigned DEFAULT NULL,
  `folder_id` int unsigned DEFAULT NULL,
  `file_ord` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `files_folder_lnk_uq` (`file_id`,`folder_id`),
  KEY `files_folder_lnk_fk` (`file_id`),
  KEY `files_folder_lnk_ifk` (`folder_id`),
  KEY `files_folder_lnk_oifk` (`file_ord`),
  CONSTRAINT `files_folder_lnk_fk` FOREIGN KEY (`file_id`) REFERENCES `files` (`id`) ON DELETE CASCADE,
  CONSTRAINT `files_folder_lnk_ifk` FOREIGN KEY (`folder_id`) REFERENCES `upload_folders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `files_folder_lnk`
--

LOCK TABLES `files_folder_lnk` WRITE;
/*!40000 ALTER TABLE `files_folder_lnk` DISABLE KEYS */;
/*!40000 ALTER TABLE `files_folder_lnk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `files_related_mph`
--

DROP TABLE IF EXISTS `files_related_mph`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `files_related_mph` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `file_id` int unsigned DEFAULT NULL,
  `related_id` int unsigned DEFAULT NULL,
  `related_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `files_related_mph_fk` (`file_id`),
  KEY `files_related_mph_oidx` (`order`),
  KEY `files_related_mph_idix` (`related_id`),
  CONSTRAINT `files_related_mph_fk` FOREIGN KEY (`file_id`) REFERENCES `files` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `files_related_mph`
--

LOCK TABLES `files_related_mph` WRITE;
/*!40000 ALTER TABLE `files_related_mph` DISABLE KEYS */;
/*!40000 ALTER TABLE `files_related_mph` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global`
--

DROP TABLE IF EXISTS `global`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `global` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `site_name` varchar(255) DEFAULT NULL,
  `site_description` longtext,
  `mobile_menu_title` varchar(255) DEFAULT NULL,
  `skip_to_content_label` varchar(255) DEFAULT NULL,
  `sign_in_label` varchar(255) DEFAULT NULL,
  `sign_out_label` varchar(255) DEFAULT NULL,
  `user_menu_label` varchar(255) DEFAULT NULL,
  `new_pattern_button_label` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `global_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `global_created_by_id_fk` (`created_by_id`),
  KEY `global_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `global_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `global_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global`
--

LOCK TABLES `global` WRITE;
/*!40000 ALTER TABLE `global` DISABLE KEYS */;
INSERT INTO `global` VALUES (1,'nu19mf4g1njp50wb45umiyvf','AI Enterprise Patterns Library','A centralized repository of AI-driven recipes, prompts, and blueprints for enterprise software architecture patterns.','Menu','Skip to main content','Sign In','Sign Out','User menu','+ New Pattern','2026-02-26 18:27:17.635000','2026-02-26 18:27:17.635000','2026-02-26 18:27:15.810000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `global` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `global_cmps`
--

DROP TABLE IF EXISTS `global_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `global_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `global_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `global_field_idx` (`field`),
  KEY `global_component_type_idx` (`component_type`),
  KEY `global_entity_fk` (`entity_id`),
  CONSTRAINT `global_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `global` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `global_cmps`
--

LOCK TABLES `global_cmps` WRITE;
/*!40000 ALTER TABLE `global_cmps` DISABLE KEYS */;
INSERT INTO `global_cmps` VALUES (1,1,1,'layout.nav-link','navigation',1),(2,1,2,'layout.nav-link','navigation',2),(3,1,3,'layout.nav-link','navigation',3),(4,1,1,'layout.footer-config','footer',NULL),(5,1,1,'seo.metadata','defaultSeo',NULL);
/*!40000 ALTER TABLE `global_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `home_page`
--

DROP TABLE IF EXISTS `home_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `home_page` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `home_page_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `home_page_created_by_id_fk` (`created_by_id`),
  KEY `home_page_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `home_page_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `home_page_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `home_page`
--

LOCK TABLES `home_page` WRITE;
/*!40000 ALTER TABLE `home_page` DISABLE KEYS */;
INSERT INTO `home_page` VALUES (1,'im759x2ij64ux1cxjd56mc1b','2026-02-26 18:27:22.783000','2026-02-26 18:56:38.934000',NULL,NULL,1,NULL),(4,'im759x2ij64ux1cxjd56mc1b','2026-02-26 18:27:22.783000','2026-02-26 18:56:38.934000','2026-02-26 18:56:48.927000',NULL,1,NULL);
/*!40000 ALTER TABLE `home_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `home_page_cmps`
--

DROP TABLE IF EXISTS `home_page_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `home_page_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `home_page_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `home_page_field_idx` (`field`),
  KEY `home_page_component_type_idx` (`component_type`),
  KEY `home_page_entity_fk` (`entity_id`),
  CONSTRAINT `home_page_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `home_page` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `home_page_cmps`
--

LOCK TABLES `home_page_cmps` WRITE;
/*!40000 ALTER TABLE `home_page_cmps` DISABLE KEYS */;
INSERT INTO `home_page_cmps` VALUES (1,1,2,'seo.metadata','seo',NULL),(32,1,1,'sections.hero','content',1),(33,1,1,'sections.stats-bar','content',2),(34,1,1,'sections.featured-patterns','content',3),(35,1,1,'sections.cta-banner','content',4),(36,4,8,'seo.metadata','seo',NULL),(37,4,4,'sections.hero','content',1),(38,4,4,'sections.stats-bar','content',2),(39,4,4,'sections.featured-patterns','content',3),(40,4,4,'sections.cta-banner','content',4);
/*!40000 ALTER TABLE `home_page_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `i18n_locale`
--

DROP TABLE IF EXISTS `i18n_locale`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `i18n_locale` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `i18n_locale_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `i18n_locale_created_by_id_fk` (`created_by_id`),
  KEY `i18n_locale_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `i18n_locale_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `i18n_locale_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `i18n_locale`
--

LOCK TABLES `i18n_locale` WRITE;
/*!40000 ALTER TABLE `i18n_locale` DISABLE KEYS */;
INSERT INTO `i18n_locale` VALUES (1,'jo21a6gzwb8vpp20s027yyo2','English (en)','en','2026-02-26 18:22:21.861000','2026-02-26 18:22:21.861000','2026-02-26 18:22:21.862000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `i18n_locale` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_page`
--

DROP TABLE IF EXISTS `login_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_page` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `card_title` varchar(255) DEFAULT NULL,
  `card_description` varchar(255) DEFAULT NULL,
  `sign_in_button_label` varchar(255) DEFAULT NULL,
  `sign_in_loading_label` varchar(255) DEFAULT NULL,
  `footer_notice` longtext,
  `error_messages` json DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `login_page_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `login_page_created_by_id_fk` (`created_by_id`),
  KEY `login_page_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `login_page_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `login_page_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_page`
--

LOCK TABLES `login_page` WRITE;
/*!40000 ALTER TABLE `login_page` DISABLE KEYS */;
INSERT INTO `login_page` VALUES (1,'arikf4xzixgknjzik097c20j','Sign in','Access the AI Enterprise Patterns Library','Continue with Microsoft','Redirecting...','Sign-in is managed securely by Microsoft Entra. Only authorized users may access this application.','{\"Default\": \"An unexpected error occurred during sign-in. Please try again.\", \"Callback\": \"Sign-in callback failed. Please try again.\", \"OAuthSignin\": \"Could not start the sign-in flow. Please try again.\", \"AccessDenied\": \"Access denied. You may not have permission to access this application.\", \"Verification\": \"The sign-in link has expired. Please request a new one.\", \"OAuthCallback\": \"Sign-in failed during callback. Please try again.\", \"OAuthCreateAccount\": \"Could not create your account. Please try again.\"}','2026-02-26 18:27:59.447000','2026-02-26 18:27:59.447000','2026-02-26 18:27:59.221000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `login_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_page_cmps`
--

DROP TABLE IF EXISTS `login_page_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_page_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `login_page_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `login_page_field_idx` (`field`),
  KEY `login_page_component_type_idx` (`component_type`),
  KEY `login_page_entity_fk` (`entity_id`),
  CONSTRAINT `login_page_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `login_page` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_page_cmps`
--

LOCK TABLES `login_page_cmps` WRITE;
/*!40000 ALTER TABLE `login_page_cmps` DISABLE KEYS */;
INSERT INTO `login_page_cmps` VALUES (1,1,6,'seo.metadata','seo',NULL);
/*!40000 ALTER TABLE `login_page_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `not_found_page`
--

DROP TABLE IF EXISTS `not_found_page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `not_found_page` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `error_code` varchar(255) DEFAULT NULL,
  `heading` varchar(255) DEFAULT NULL,
  `message` longtext,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `not_found_page_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `not_found_page_created_by_id_fk` (`created_by_id`),
  KEY `not_found_page_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `not_found_page_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `not_found_page_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `not_found_page`
--

LOCK TABLES `not_found_page` WRITE;
/*!40000 ALTER TABLE `not_found_page` DISABLE KEYS */;
INSERT INTO `not_found_page` VALUES (1,'nxqb7fh3ddpjnqdlnqoj6e3e','404','Page Not Found','The page you are looking for does not exist or has been moved.','2026-02-26 18:28:01.413000','2026-02-26 18:28:01.413000','2026-02-26 18:28:01.101000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `not_found_page` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `not_found_page_cmps`
--

DROP TABLE IF EXISTS `not_found_page_cmps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `not_found_page_cmps` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `entity_id` int unsigned DEFAULT NULL,
  `cmp_id` int unsigned DEFAULT NULL,
  `component_type` varchar(255) DEFAULT NULL,
  `field` varchar(255) DEFAULT NULL,
  `order` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `not_found_page_uq` (`entity_id`,`cmp_id`,`field`,`component_type`),
  KEY `not_found_page_field_idx` (`field`),
  KEY `not_found_page_component_type_idx` (`component_type`),
  KEY `not_found_page_entity_fk` (`entity_id`),
  CONSTRAINT `not_found_page_entity_fk` FOREIGN KEY (`entity_id`) REFERENCES `not_found_page` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `not_found_page_cmps`
--

LOCK TABLES `not_found_page_cmps` WRITE;
/*!40000 ALTER TABLE `not_found_page_cmps` DISABLE KEYS */;
INSERT INTO `not_found_page_cmps` VALUES (1,1,11,'layout.cta-button','backButton',NULL);
/*!40000 ALTER TABLE `not_found_page_cmps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pattern_detail_labels`
--

DROP TABLE IF EXISTS `pattern_detail_labels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pattern_detail_labels` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `breadcrumb_aria_label` varchar(255) DEFAULT NULL,
  `vote_aria_template` varchar(255) DEFAULT NULL,
  `votes_label` varchar(255) DEFAULT NULL,
  `vote_announcement_template` varchar(255) DEFAULT NULL,
  `no_content_message` varchar(255) DEFAULT NULL,
  `related_patterns_title` varchar(255) DEFAULT NULL,
  `no_related_message` varchar(255) DEFAULT NULL,
  `edit_label` varchar(255) DEFAULT NULL,
  `delete_label` varchar(255) DEFAULT NULL,
  `delete_dialog_title` varchar(255) DEFAULT NULL,
  `delete_dialog_description` longtext,
  `cancel_label` varchar(255) DEFAULT NULL,
  `delete_confirm_label` varchar(255) DEFAULT NULL,
  `deleting_label` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pattern_detail_labels_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `pattern_detail_labels_created_by_id_fk` (`created_by_id`),
  KEY `pattern_detail_labels_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `pattern_detail_labels_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pattern_detail_labels_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pattern_detail_labels`
--

LOCK TABLES `pattern_detail_labels` WRITE;
/*!40000 ALTER TABLE `pattern_detail_labels` DISABLE KEYS */;
INSERT INTO `pattern_detail_labels` VALUES (1,'b85ja7wtlni0xpul59sx7rra','Breadcrumb','Vote for this pattern. {count} votes','votes','Voted! {count} total votes','No content available for this pattern.','Related Patterns','No related patterns found','Edit','Delete','Delete Pattern?','This action cannot be undone. The pattern will be permanently removed.','Cancel','Delete','Deleting...','2026-02-26 18:28:04.547000','2026-02-26 18:28:04.547000','2026-02-26 18:28:04.545000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `pattern_detail_labels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pattern_form_labels`
--

DROP TABLE IF EXISTS `pattern_form_labels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pattern_form_labels` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `create_title` varchar(255) DEFAULT NULL,
  `edit_title` varchar(255) DEFAULT NULL,
  `title_label` varchar(255) DEFAULT NULL,
  `title_placeholder` varchar(255) DEFAULT NULL,
  `slug_preview_template` varchar(255) DEFAULT NULL,
  `short_desc_label` varchar(255) DEFAULT NULL,
  `short_desc_placeholder` varchar(255) DEFAULT NULL,
  `category_label` varchar(255) DEFAULT NULL,
  `category_placeholder` varchar(255) DEFAULT NULL,
  `tags_label` varchar(255) DEFAULT NULL,
  `tag_placeholder` varchar(255) DEFAULT NULL,
  `add_tag_label` varchar(255) DEFAULT NULL,
  `tag_count_template` varchar(255) DEFAULT NULL,
  `content_label` varchar(255) DEFAULT NULL,
  `content_placeholder` varchar(255) DEFAULT NULL,
  `author_label` varchar(255) DEFAULT NULL,
  `author_placeholder` varchar(255) DEFAULT NULL,
  `admin_settings_label` varchar(255) DEFAULT NULL,
  `featured_label` varchar(255) DEFAULT NULL,
  `trending_label` varchar(255) DEFAULT NULL,
  `cancel_label` varchar(255) DEFAULT NULL,
  `create_label` varchar(255) DEFAULT NULL,
  `creating_label` varchar(255) DEFAULT NULL,
  `save_label` varchar(255) DEFAULT NULL,
  `saving_label` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pattern_form_labels_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `pattern_form_labels_created_by_id_fk` (`created_by_id`),
  KEY `pattern_form_labels_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `pattern_form_labels_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pattern_form_labels_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pattern_form_labels`
--

LOCK TABLES `pattern_form_labels` WRITE;
/*!40000 ALTER TABLE `pattern_form_labels` DISABLE KEYS */;
INSERT INTO `pattern_form_labels` VALUES (1,'z3389avcianxabs8gcfl588v','New Pattern','Edit Pattern','Title *','e.g. CQRS Pattern for Event-Driven Systems','Slug preview: {slug}','Short Description *','A brief summary of the pattern (shown in listings)','Category *','Select a category','Tags','Add a tag and press Enter','Add','{count}/{max} tags','Full Content (Markdown)','Write the full pattern content in Markdown...','Author','Your name (optional)','Admin Settings','Featured pattern','Trending pattern','Cancel','Create Pattern','Creating...','Save Changes','Saving...','2026-02-26 18:28:05.549000','2026-02-26 18:28:05.549000','2026-02-26 18:28:05.546000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `pattern_form_labels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pattern_listing_labels`
--

DROP TABLE IF EXISTS `pattern_listing_labels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pattern_listing_labels` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `page_title` varchar(255) DEFAULT NULL,
  `page_description` longtext,
  `search_placeholder` varchar(255) DEFAULT NULL,
  `clear_search_label` varchar(255) DEFAULT NULL,
  `sort_by_label` varchar(255) DEFAULT NULL,
  `sort_options` json DEFAULT NULL,
  `filter_section_header` varchar(255) DEFAULT NULL,
  `clear_all_label` varchar(255) DEFAULT NULL,
  `category_label` varchar(255) DEFAULT NULL,
  `all_categories_label` varchar(255) DEFAULT NULL,
  `tags_label` varchar(255) DEFAULT NULL,
  `tag_mode_label` varchar(255) DEFAULT NULL,
  `any_label` varchar(255) DEFAULT NULL,
  `all_label` varchar(255) DEFAULT NULL,
  `date_range_header` varchar(255) DEFAULT NULL,
  `clear_dates_label` varchar(255) DEFAULT NULL,
  `from_label` varchar(255) DEFAULT NULL,
  `to_label` varchar(255) DEFAULT NULL,
  `active_filters_label` varchar(255) DEFAULT NULL,
  `filters_button_label` varchar(255) DEFAULT NULL,
  `filter_sheet_title` varchar(255) DEFAULT NULL,
  `filter_sheet_description` varchar(255) DEFAULT NULL,
  `saved_searches_header` varchar(255) DEFAULT NULL,
  `save_current_label` varchar(255) DEFAULT NULL,
  `save_dialog_title` varchar(255) DEFAULT NULL,
  `save_dialog_description` varchar(255) DEFAULT NULL,
  `search_name_label` varchar(255) DEFAULT NULL,
  `search_name_placeholder` varchar(255) DEFAULT NULL,
  `cancel_label` varchar(255) DEFAULT NULL,
  `save_label` varchar(255) DEFAULT NULL,
  `recently_viewed_header` varchar(255) DEFAULT NULL,
  `clear_label` varchar(255) DEFAULT NULL,
  `previous_label` varchar(255) DEFAULT NULL,
  `next_label` varchar(255) DEFAULT NULL,
  `empty_filtered_heading` varchar(255) DEFAULT NULL,
  `empty_unfiltered_heading` varchar(255) DEFAULT NULL,
  `empty_filtered_description` longtext,
  `empty_unfiltered_description` longtext,
  `clear_filters_label` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pattern_listing_labels_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `pattern_listing_labels_created_by_id_fk` (`created_by_id`),
  KEY `pattern_listing_labels_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `pattern_listing_labels_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pattern_listing_labels_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pattern_listing_labels`
--

LOCK TABLES `pattern_listing_labels` WRITE;
/*!40000 ALTER TABLE `pattern_listing_labels` DISABLE KEYS */;
INSERT INTO `pattern_listing_labels` VALUES (1,'axzd5ce7g4a192y3pwv5z0uh','Browse Patterns','Discover {count} {pattern|patterns} across AI, architecture, and engineering disciplines.','Search patterns...','Clear search','Sort by:','[{\"label\": \"Most Recent\", \"value\": \"newest\"}, {\"label\": \"Most Popular\", \"value\": \"popular\"}, {\"label\": \"Title A-Z\", \"value\": \"title\"}]','Filters','Clear all','Category','All Categories','Tags','Match:','Any','All','Date Range','Clear dates','From','To','Active Filters','Filters','Filter Patterns','Refine your search by category and tags','Saved Searches','Save current','Save Search','Give this search a name to quickly access it later.','Search name','e.g. Architecture with CQRS','Cancel','Save','Recently Viewed','Clear','Previous','Next','No patterns found','No patterns available','Try adjusting your filters or search query to find what you\'re looking for.','There are no patterns yet. Check back later.','Clear all filters','2026-02-26 18:28:03.540000','2026-02-26 18:28:03.540000','2026-02-26 18:28:03.531000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `pattern_listing_labels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_ai_localization_jobs`
--

DROP TABLE IF EXISTS `strapi_ai_localization_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_ai_localization_jobs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `content_type` varchar(255) NOT NULL,
  `related_document_id` varchar(255) NOT NULL,
  `source_locale` varchar(255) NOT NULL,
  `target_locales` json NOT NULL,
  `status` varchar(255) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_ai_localization_jobs`
--

LOCK TABLES `strapi_ai_localization_jobs` WRITE;
/*!40000 ALTER TABLE `strapi_ai_localization_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_ai_localization_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_ai_metadata_jobs`
--

DROP TABLE IF EXISTS `strapi_ai_metadata_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_ai_metadata_jobs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `status` varchar(255) NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `completed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_ai_metadata_jobs`
--

LOCK TABLES `strapi_ai_metadata_jobs` WRITE;
/*!40000 ALTER TABLE `strapi_ai_metadata_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_ai_metadata_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_api_token_permissions`
--

DROP TABLE IF EXISTS `strapi_api_token_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_api_token_permissions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `strapi_api_token_permissions_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `strapi_api_token_permissions_created_by_id_fk` (`created_by_id`),
  KEY `strapi_api_token_permissions_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `strapi_api_token_permissions_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `strapi_api_token_permissions_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_api_token_permissions`
--

LOCK TABLES `strapi_api_token_permissions` WRITE;
/*!40000 ALTER TABLE `strapi_api_token_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_api_token_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_api_token_permissions_token_lnk`
--

DROP TABLE IF EXISTS `strapi_api_token_permissions_token_lnk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_api_token_permissions_token_lnk` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `api_token_permission_id` int unsigned DEFAULT NULL,
  `api_token_id` int unsigned DEFAULT NULL,
  `api_token_permission_ord` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `strapi_api_token_permissions_token_lnk_uq` (`api_token_permission_id`,`api_token_id`),
  KEY `strapi_api_token_permissions_token_lnk_fk` (`api_token_permission_id`),
  KEY `strapi_api_token_permissions_token_lnk_ifk` (`api_token_id`),
  KEY `strapi_api_token_permissions_token_lnk_oifk` (`api_token_permission_ord`),
  CONSTRAINT `strapi_api_token_permissions_token_lnk_fk` FOREIGN KEY (`api_token_permission_id`) REFERENCES `strapi_api_token_permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `strapi_api_token_permissions_token_lnk_ifk` FOREIGN KEY (`api_token_id`) REFERENCES `strapi_api_tokens` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_api_token_permissions_token_lnk`
--

LOCK TABLES `strapi_api_token_permissions_token_lnk` WRITE;
/*!40000 ALTER TABLE `strapi_api_token_permissions_token_lnk` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_api_token_permissions_token_lnk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_api_tokens`
--

DROP TABLE IF EXISTS `strapi_api_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_api_tokens` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `access_key` varchar(255) DEFAULT NULL,
  `encrypted_key` longtext,
  `last_used_at` datetime(6) DEFAULT NULL,
  `expires_at` datetime(6) DEFAULT NULL,
  `lifespan` bigint DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `strapi_api_tokens_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `strapi_api_tokens_created_by_id_fk` (`created_by_id`),
  KEY `strapi_api_tokens_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `strapi_api_tokens_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `strapi_api_tokens_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_api_tokens`
--

LOCK TABLES `strapi_api_tokens` WRITE;
/*!40000 ALTER TABLE `strapi_api_tokens` DISABLE KEYS */;
INSERT INTO `strapi_api_tokens` VALUES (1,'xgalfnlfrg27ksseyi71m8h0','Read Only','A default API token with read-only permissions, only used for accessing resources','read-only','5fa4643270d2828e963caad38ca85c0c37cfe632dbb7e31d7613608c80732bdf4efb84a36e42434781f634536e4d045ca1ace79ca00f09b83947c03b53246c32',NULL,NULL,NULL,NULL,'2026-02-26 18:24:53.763000','2026-02-26 18:24:53.763000','2026-02-26 18:24:53.763000',NULL,NULL,NULL),(3,'gzy8v3qoe587eomkjsaj3fuk','nextjs-readonly','Read-only token for Next.js frontend','read-only','afba1cfed8e4c3a60114372f20f751322f2e14f04586f7313cc19164ab4f1f09d863f5271239c6700e1e88af00c855d9d03e5a35219deb86dcf195ce9438b9df',NULL,'2026-03-03 15:43:09.916000',NULL,NULL,'2026-02-26 18:26:11.192000','2026-03-03 15:43:09.916000','2026-02-26 18:26:11.192000',NULL,NULL,NULL),(5,'ol7otycfkrs49e37l86o44m8','backup-2026-04-09','Temporary read-only token for cold storage backup','read-only','6f90817803f24dd9236614024e109be68fb3b34944a01b6791bf67f787c7d1c3f718e9540ed91a5be26bb8f41efceb414cc304414b10a828fe1a34ae301a9bfa',NULL,NULL,NULL,NULL,'2026-04-09 17:06:11.281000','2026-04-09 17:06:11.281000','2026-04-09 17:06:11.285000',NULL,NULL,NULL),(6,'o9tz2osvgnu3t9vc2n14bdl9','backup-2026-04-09-2','Temporary read-only token for cold storage backup','read-only','06c1d72758a2de8a8d3515ffaa0672541e1200041ae60a490256f7a3ca3b66c0133c92ee11fc7ad6ba79741f59d2fa593f2908c75c9dfd356eb439e0a8a583bd',NULL,'2026-04-09 17:06:56.871000',NULL,NULL,'2026-04-09 17:06:32.203000','2026-04-09 17:06:56.871000','2026-04-09 17:06:32.203000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `strapi_api_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_core_store_settings`
--

DROP TABLE IF EXISTS `strapi_core_store_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_core_store_settings` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) DEFAULT NULL,
  `value` longtext,
  `type` varchar(255) DEFAULT NULL,
  `environment` varchar(255) DEFAULT NULL,
  `tag` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_core_store_settings`
--

LOCK TABLES `strapi_core_store_settings` WRITE;
/*!40000 ALTER TABLE `strapi_core_store_settings` DISABLE KEYS */;
INSERT INTO `strapi_core_store_settings` VALUES (1,'strapi_unidirectional-join-table-repair-ran','true','boolean',NULL,NULL),(2,'strapi_content_types_schema','{\"plugin::upload.file\":{\"collectionName\":\"files\",\"info\":{\"singularName\":\"file\",\"pluralName\":\"files\",\"displayName\":\"File\",\"description\":\"\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"configurable\":false,\"required\":true},\"alternativeText\":{\"type\":\"text\",\"configurable\":false},\"caption\":{\"type\":\"text\",\"configurable\":false},\"focalPoint\":{\"type\":\"json\",\"configurable\":false},\"width\":{\"type\":\"integer\",\"configurable\":false},\"height\":{\"type\":\"integer\",\"configurable\":false},\"formats\":{\"type\":\"json\",\"configurable\":false},\"hash\":{\"type\":\"string\",\"configurable\":false,\"required\":true},\"ext\":{\"type\":\"string\",\"configurable\":false},\"mime\":{\"type\":\"string\",\"configurable\":false,\"required\":true},\"size\":{\"type\":\"decimal\",\"configurable\":false,\"required\":true},\"url\":{\"type\":\"text\",\"configurable\":false,\"required\":true},\"previewUrl\":{\"type\":\"text\",\"configurable\":false},\"provider\":{\"type\":\"string\",\"configurable\":false,\"required\":true},\"provider_metadata\":{\"type\":\"json\",\"configurable\":false},\"related\":{\"type\":\"relation\",\"relation\":\"morphToMany\",\"configurable\":false},\"folder\":{\"type\":\"relation\",\"relation\":\"manyToOne\",\"target\":\"plugin::upload.folder\",\"inversedBy\":\"files\",\"private\":true},\"folderPath\":{\"type\":\"string\",\"minLength\":1,\"required\":true,\"private\":true,\"searchable\":false},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::upload.file\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"files\"}}},\"indexes\":[{\"name\":\"upload_files_folder_path_index\",\"columns\":[\"folder_path\"],\"type\":null},{\"name\":\"upload_files_created_at_index\",\"columns\":[\"created_at\"],\"type\":null},{\"name\":\"upload_files_updated_at_index\",\"columns\":[\"updated_at\"],\"type\":null},{\"name\":\"upload_files_name_index\",\"columns\":[\"name\"],\"type\":null},{\"name\":\"upload_files_size_index\",\"columns\":[\"size\"],\"type\":null},{\"name\":\"upload_files_ext_index\",\"columns\":[\"ext\"],\"type\":null}],\"plugin\":\"upload\",\"globalId\":\"UploadFile\",\"uid\":\"plugin::upload.file\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"files\",\"info\":{\"singularName\":\"file\",\"pluralName\":\"files\",\"displayName\":\"File\",\"description\":\"\"},\"options\":{},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"configurable\":false,\"required\":true},\"alternativeText\":{\"type\":\"text\",\"configurable\":false},\"caption\":{\"type\":\"text\",\"configurable\":false},\"focalPoint\":{\"type\":\"json\",\"configurable\":false},\"width\":{\"type\":\"integer\",\"configurable\":false},\"height\":{\"type\":\"integer\",\"configurable\":false},\"formats\":{\"type\":\"json\",\"configurable\":false},\"hash\":{\"type\":\"string\",\"configurable\":false,\"required\":true},\"ext\":{\"type\":\"string\",\"configurable\":false},\"mime\":{\"type\":\"string\",\"configurable\":false,\"required\":true},\"size\":{\"type\":\"decimal\",\"configurable\":false,\"required\":true},\"url\":{\"type\":\"text\",\"configurable\":false,\"required\":true},\"previewUrl\":{\"type\":\"text\",\"configurable\":false},\"provider\":{\"type\":\"string\",\"configurable\":false,\"required\":true},\"provider_metadata\":{\"type\":\"json\",\"configurable\":false},\"related\":{\"type\":\"relation\",\"relation\":\"morphToMany\",\"configurable\":false},\"folder\":{\"type\":\"relation\",\"relation\":\"manyToOne\",\"target\":\"plugin::upload.folder\",\"inversedBy\":\"files\",\"private\":true},\"folderPath\":{\"type\":\"string\",\"minLength\":1,\"required\":true,\"private\":true,\"searchable\":false}},\"kind\":\"collectionType\"},\"modelName\":\"file\"},\"plugin::upload.folder\":{\"collectionName\":\"upload_folders\",\"info\":{\"singularName\":\"folder\",\"pluralName\":\"folders\",\"displayName\":\"Folder\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"minLength\":1,\"required\":true},\"pathId\":{\"type\":\"integer\",\"unique\":true,\"required\":true},\"parent\":{\"type\":\"relation\",\"relation\":\"manyToOne\",\"target\":\"plugin::upload.folder\",\"inversedBy\":\"children\"},\"children\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::upload.folder\",\"mappedBy\":\"parent\"},\"files\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::upload.file\",\"mappedBy\":\"folder\"},\"path\":{\"type\":\"string\",\"minLength\":1,\"required\":true},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::upload.folder\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"upload_folders\"}}},\"indexes\":[{\"name\":\"upload_folders_path_id_index\",\"columns\":[\"path_id\"],\"type\":\"unique\"},{\"name\":\"upload_folders_path_index\",\"columns\":[\"path\"],\"type\":\"unique\"}],\"plugin\":\"upload\",\"globalId\":\"UploadFolder\",\"uid\":\"plugin::upload.folder\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"upload_folders\",\"info\":{\"singularName\":\"folder\",\"pluralName\":\"folders\",\"displayName\":\"Folder\"},\"options\":{},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"minLength\":1,\"required\":true},\"pathId\":{\"type\":\"integer\",\"unique\":true,\"required\":true},\"parent\":{\"type\":\"relation\",\"relation\":\"manyToOne\",\"target\":\"plugin::upload.folder\",\"inversedBy\":\"children\"},\"children\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::upload.folder\",\"mappedBy\":\"parent\"},\"files\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::upload.file\",\"mappedBy\":\"folder\"},\"path\":{\"type\":\"string\",\"minLength\":1,\"required\":true}},\"kind\":\"collectionType\"},\"modelName\":\"folder\"},\"plugin::i18n.locale\":{\"info\":{\"singularName\":\"locale\",\"pluralName\":\"locales\",\"collectionName\":\"locales\",\"displayName\":\"Locale\",\"description\":\"\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"min\":1,\"max\":50,\"configurable\":false},\"code\":{\"type\":\"string\",\"unique\":true,\"configurable\":false},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::i18n.locale\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"i18n_locale\"}}},\"plugin\":\"i18n\",\"collectionName\":\"i18n_locale\",\"globalId\":\"I18NLocale\",\"uid\":\"plugin::i18n.locale\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"i18n_locale\",\"info\":{\"singularName\":\"locale\",\"pluralName\":\"locales\",\"collectionName\":\"locales\",\"displayName\":\"Locale\",\"description\":\"\"},\"options\":{},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"min\":1,\"max\":50,\"configurable\":false},\"code\":{\"type\":\"string\",\"unique\":true,\"configurable\":false}},\"kind\":\"collectionType\"},\"modelName\":\"locale\"},\"plugin::content-releases.release\":{\"collectionName\":\"strapi_releases\",\"info\":{\"singularName\":\"release\",\"pluralName\":\"releases\",\"displayName\":\"Release\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"required\":true},\"releasedAt\":{\"type\":\"datetime\"},\"scheduledAt\":{\"type\":\"datetime\"},\"timezone\":{\"type\":\"string\"},\"status\":{\"type\":\"enumeration\",\"enum\":[\"ready\",\"blocked\",\"failed\",\"done\",\"empty\"],\"required\":true},\"actions\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::content-releases.release-action\",\"mappedBy\":\"release\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::content-releases.release\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"strapi_releases\"}}},\"plugin\":\"content-releases\",\"globalId\":\"ContentReleasesRelease\",\"uid\":\"plugin::content-releases.release\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"strapi_releases\",\"info\":{\"singularName\":\"release\",\"pluralName\":\"releases\",\"displayName\":\"Release\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"required\":true},\"releasedAt\":{\"type\":\"datetime\"},\"scheduledAt\":{\"type\":\"datetime\"},\"timezone\":{\"type\":\"string\"},\"status\":{\"type\":\"enumeration\",\"enum\":[\"ready\",\"blocked\",\"failed\",\"done\",\"empty\"],\"required\":true},\"actions\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::content-releases.release-action\",\"mappedBy\":\"release\"}},\"kind\":\"collectionType\"},\"modelName\":\"release\"},\"plugin::content-releases.release-action\":{\"collectionName\":\"strapi_release_actions\",\"info\":{\"singularName\":\"release-action\",\"pluralName\":\"release-actions\",\"displayName\":\"Release Action\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"type\":{\"type\":\"enumeration\",\"enum\":[\"publish\",\"unpublish\"],\"required\":true},\"contentType\":{\"type\":\"string\",\"required\":true},\"entryDocumentId\":{\"type\":\"string\"},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"release\":{\"type\":\"relation\",\"relation\":\"manyToOne\",\"target\":\"plugin::content-releases.release\",\"inversedBy\":\"actions\"},\"isEntryValid\":{\"type\":\"boolean\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::content-releases.release-action\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"strapi_release_actions\"}}},\"plugin\":\"content-releases\",\"globalId\":\"ContentReleasesReleaseAction\",\"uid\":\"plugin::content-releases.release-action\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"strapi_release_actions\",\"info\":{\"singularName\":\"release-action\",\"pluralName\":\"release-actions\",\"displayName\":\"Release Action\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"type\":{\"type\":\"enumeration\",\"enum\":[\"publish\",\"unpublish\"],\"required\":true},\"contentType\":{\"type\":\"string\",\"required\":true},\"entryDocumentId\":{\"type\":\"string\"},\"locale\":{\"type\":\"string\"},\"release\":{\"type\":\"relation\",\"relation\":\"manyToOne\",\"target\":\"plugin::content-releases.release\",\"inversedBy\":\"actions\"},\"isEntryValid\":{\"type\":\"boolean\"}},\"kind\":\"collectionType\"},\"modelName\":\"release-action\"},\"plugin::review-workflows.workflow\":{\"collectionName\":\"strapi_workflows\",\"info\":{\"name\":\"Workflow\",\"description\":\"\",\"singularName\":\"workflow\",\"pluralName\":\"workflows\",\"displayName\":\"Workflow\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"required\":true,\"unique\":true},\"stages\":{\"type\":\"relation\",\"target\":\"plugin::review-workflows.workflow-stage\",\"relation\":\"oneToMany\",\"mappedBy\":\"workflow\"},\"stageRequiredToPublish\":{\"type\":\"relation\",\"target\":\"plugin::review-workflows.workflow-stage\",\"relation\":\"oneToOne\",\"required\":false},\"contentTypes\":{\"type\":\"json\",\"required\":true,\"default\":\"[]\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::review-workflows.workflow\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"strapi_workflows\"}}},\"plugin\":\"review-workflows\",\"globalId\":\"ReviewWorkflowsWorkflow\",\"uid\":\"plugin::review-workflows.workflow\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"strapi_workflows\",\"info\":{\"name\":\"Workflow\",\"description\":\"\",\"singularName\":\"workflow\",\"pluralName\":\"workflows\",\"displayName\":\"Workflow\"},\"options\":{},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"required\":true,\"unique\":true},\"stages\":{\"type\":\"relation\",\"target\":\"plugin::review-workflows.workflow-stage\",\"relation\":\"oneToMany\",\"mappedBy\":\"workflow\"},\"stageRequiredToPublish\":{\"type\":\"relation\",\"target\":\"plugin::review-workflows.workflow-stage\",\"relation\":\"oneToOne\",\"required\":false},\"contentTypes\":{\"type\":\"json\",\"required\":true,\"default\":\"[]\"}},\"kind\":\"collectionType\"},\"modelName\":\"workflow\"},\"plugin::review-workflows.workflow-stage\":{\"collectionName\":\"strapi_workflows_stages\",\"info\":{\"name\":\"Workflow Stage\",\"description\":\"\",\"singularName\":\"workflow-stage\",\"pluralName\":\"workflow-stages\",\"displayName\":\"Stages\"},\"options\":{\"version\":\"1.1.0\",\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"configurable\":false},\"color\":{\"type\":\"string\",\"configurable\":false,\"default\":\"#4945FF\"},\"workflow\":{\"type\":\"relation\",\"target\":\"plugin::review-workflows.workflow\",\"relation\":\"manyToOne\",\"inversedBy\":\"stages\",\"configurable\":false},\"permissions\":{\"type\":\"relation\",\"target\":\"admin::permission\",\"relation\":\"manyToMany\",\"configurable\":false},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::review-workflows.workflow-stage\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"strapi_workflows_stages\"}}},\"plugin\":\"review-workflows\",\"globalId\":\"ReviewWorkflowsWorkflowStage\",\"uid\":\"plugin::review-workflows.workflow-stage\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"strapi_workflows_stages\",\"info\":{\"name\":\"Workflow Stage\",\"description\":\"\",\"singularName\":\"workflow-stage\",\"pluralName\":\"workflow-stages\",\"displayName\":\"Stages\"},\"options\":{\"version\":\"1.1.0\"},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"configurable\":false},\"color\":{\"type\":\"string\",\"configurable\":false,\"default\":\"#4945FF\"},\"workflow\":{\"type\":\"relation\",\"target\":\"plugin::review-workflows.workflow\",\"relation\":\"manyToOne\",\"inversedBy\":\"stages\",\"configurable\":false},\"permissions\":{\"type\":\"relation\",\"target\":\"admin::permission\",\"relation\":\"manyToMany\",\"configurable\":false}},\"kind\":\"collectionType\"},\"modelName\":\"workflow-stage\"},\"plugin::users-permissions.permission\":{\"collectionName\":\"up_permissions\",\"info\":{\"name\":\"permission\",\"description\":\"\",\"singularName\":\"permission\",\"pluralName\":\"permissions\",\"displayName\":\"Permission\"},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"action\":{\"type\":\"string\",\"required\":true,\"configurable\":false},\"role\":{\"type\":\"relation\",\"relation\":\"manyToOne\",\"target\":\"plugin::users-permissions.role\",\"inversedBy\":\"permissions\",\"configurable\":false},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::users-permissions.permission\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"up_permissions\"}}},\"plugin\":\"users-permissions\",\"globalId\":\"UsersPermissionsPermission\",\"uid\":\"plugin::users-permissions.permission\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"up_permissions\",\"info\":{\"name\":\"permission\",\"description\":\"\",\"singularName\":\"permission\",\"pluralName\":\"permissions\",\"displayName\":\"Permission\"},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"action\":{\"type\":\"string\",\"required\":true,\"configurable\":false},\"role\":{\"type\":\"relation\",\"relation\":\"manyToOne\",\"target\":\"plugin::users-permissions.role\",\"inversedBy\":\"permissions\",\"configurable\":false}},\"kind\":\"collectionType\"},\"modelName\":\"permission\",\"options\":{\"draftAndPublish\":false}},\"plugin::users-permissions.role\":{\"collectionName\":\"up_roles\",\"info\":{\"name\":\"role\",\"description\":\"\",\"singularName\":\"role\",\"pluralName\":\"roles\",\"displayName\":\"Role\"},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"minLength\":3,\"required\":true,\"configurable\":false},\"description\":{\"type\":\"string\",\"configurable\":false},\"type\":{\"type\":\"string\",\"unique\":true,\"configurable\":false},\"permissions\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::users-permissions.permission\",\"mappedBy\":\"role\",\"configurable\":false},\"users\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::users-permissions.user\",\"mappedBy\":\"role\",\"configurable\":false},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::users-permissions.role\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"up_roles\"}}},\"plugin\":\"users-permissions\",\"globalId\":\"UsersPermissionsRole\",\"uid\":\"plugin::users-permissions.role\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"up_roles\",\"info\":{\"name\":\"role\",\"description\":\"\",\"singularName\":\"role\",\"pluralName\":\"roles\",\"displayName\":\"Role\"},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"minLength\":3,\"required\":true,\"configurable\":false},\"description\":{\"type\":\"string\",\"configurable\":false},\"type\":{\"type\":\"string\",\"unique\":true,\"configurable\":false},\"permissions\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::users-permissions.permission\",\"mappedBy\":\"role\",\"configurable\":false},\"users\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::users-permissions.user\",\"mappedBy\":\"role\",\"configurable\":false}},\"kind\":\"collectionType\"},\"modelName\":\"role\",\"options\":{\"draftAndPublish\":false}},\"plugin::users-permissions.user\":{\"collectionName\":\"up_users\",\"info\":{\"name\":\"user\",\"description\":\"\",\"singularName\":\"user\",\"pluralName\":\"users\",\"displayName\":\"User\"},\"options\":{\"timestamps\":true,\"draftAndPublish\":false},\"attributes\":{\"username\":{\"type\":\"string\",\"minLength\":3,\"unique\":true,\"configurable\":false,\"required\":true},\"email\":{\"type\":\"email\",\"minLength\":6,\"configurable\":false,\"required\":true},\"provider\":{\"type\":\"string\",\"configurable\":false},\"password\":{\"type\":\"password\",\"minLength\":6,\"configurable\":false,\"private\":true,\"searchable\":false},\"resetPasswordToken\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false},\"confirmationToken\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false},\"confirmed\":{\"type\":\"boolean\",\"default\":false,\"configurable\":false},\"blocked\":{\"type\":\"boolean\",\"default\":false,\"configurable\":false},\"role\":{\"type\":\"relation\",\"relation\":\"manyToOne\",\"target\":\"plugin::users-permissions.role\",\"inversedBy\":\"users\",\"configurable\":false},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"plugin::users-permissions.user\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"up_users\"}}},\"config\":{\"attributes\":{\"resetPasswordToken\":{\"hidden\":true},\"confirmationToken\":{\"hidden\":true},\"provider\":{\"hidden\":true}}},\"plugin\":\"users-permissions\",\"globalId\":\"UsersPermissionsUser\",\"uid\":\"plugin::users-permissions.user\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"up_users\",\"info\":{\"name\":\"user\",\"description\":\"\",\"singularName\":\"user\",\"pluralName\":\"users\",\"displayName\":\"User\"},\"options\":{\"timestamps\":true},\"attributes\":{\"username\":{\"type\":\"string\",\"minLength\":3,\"unique\":true,\"configurable\":false,\"required\":true},\"email\":{\"type\":\"email\",\"minLength\":6,\"configurable\":false,\"required\":true},\"provider\":{\"type\":\"string\",\"configurable\":false},\"password\":{\"type\":\"password\",\"minLength\":6,\"configurable\":false,\"private\":true,\"searchable\":false},\"resetPasswordToken\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false},\"confirmationToken\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false},\"confirmed\":{\"type\":\"boolean\",\"default\":false,\"configurable\":false},\"blocked\":{\"type\":\"boolean\",\"default\":false,\"configurable\":false},\"role\":{\"type\":\"relation\",\"relation\":\"manyToOne\",\"target\":\"plugin::users-permissions.role\",\"inversedBy\":\"users\",\"configurable\":false}},\"kind\":\"collectionType\"},\"modelName\":\"user\"},\"api::about-page.about-page\":{\"kind\":\"singleType\",\"collectionName\":\"about_page\",\"info\":{\"singularName\":\"about-page\",\"pluralName\":\"about-pages\",\"displayName\":\"About Page\"},\"options\":{\"draftAndPublish\":true},\"pluginOptions\":{},\"attributes\":{\"seo\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"seo.metadata\"},\"header\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"sections.page-header\"},\"content\":{\"type\":\"dynamiczone\",\"components\":[\"sections.mission-block\",\"sections.feature-grid\",\"sections.tech-stack\",\"sections.open-source-info\",\"sections.cta-banner\",\"sections.rich-text\"]},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"api::about-page.about-page\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"about_page\"}}},\"apiName\":\"about-page\",\"globalId\":\"AboutPage\",\"uid\":\"api::about-page.about-page\",\"modelType\":\"contentType\",\"__schema__\":{\"collectionName\":\"about_page\",\"info\":{\"singularName\":\"about-page\",\"pluralName\":\"about-pages\",\"displayName\":\"About Page\"},\"options\":{\"draftAndPublish\":true},\"pluginOptions\":{},\"attributes\":{\"seo\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"seo.metadata\"},\"header\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"sections.page-header\"},\"content\":{\"type\":\"dynamiczone\",\"components\":[\"sections.mission-block\",\"sections.feature-grid\",\"sections.tech-stack\",\"sections.open-source-info\",\"sections.cta-banner\",\"sections.rich-text\"]}},\"kind\":\"singleType\"},\"modelName\":\"about-page\",\"actions\":{},\"lifecycles\":{}},\"api::docs-page.docs-page\":{\"kind\":\"singleType\",\"collectionName\":\"docs_page\",\"info\":{\"singularName\":\"docs-page\",\"pluralName\":\"docs-pages\",\"displayName\":\"Documentation Page\"},\"options\":{\"draftAndPublish\":true},\"pluginOptions\":{},\"attributes\":{\"seo\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"seo.metadata\"},\"header\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"sections.page-header\"},\"content\":{\"type\":\"dynamiczone\",\"components\":[\"sections.quick-nav\",\"sections.doc-section\",\"sections.api-reference\",\"sections.contributing\",\"sections.support-links\",\"sections.rich-text\"]},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"api::docs-page.docs-page\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"docs_page\"}}},\"apiName\":\"docs-page\",\"globalId\":\"DocsPage\",\"uid\":\"api::docs-page.docs-page\",\"modelType\":\"contentType\",\"__schema__\":{\"collectionName\":\"docs_page\",\"info\":{\"singularName\":\"docs-page\",\"pluralName\":\"docs-pages\",\"displayName\":\"Documentation Page\"},\"options\":{\"draftAndPublish\":true},\"pluginOptions\":{},\"attributes\":{\"seo\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"seo.metadata\"},\"header\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"sections.page-header\"},\"content\":{\"type\":\"dynamiczone\",\"components\":[\"sections.quick-nav\",\"sections.doc-section\",\"sections.api-reference\",\"sections.contributing\",\"sections.support-links\",\"sections.rich-text\"]}},\"kind\":\"singleType\"},\"modelName\":\"docs-page\",\"actions\":{},\"lifecycles\":{}},\"api::error-page.error-page\":{\"kind\":\"singleType\",\"collectionName\":\"error_page\",\"info\":{\"singularName\":\"error-page\",\"pluralName\":\"error-pages\",\"displayName\":\"Error Page\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"title\":{\"type\":\"string\",\"default\":\"Something went wrong\"},\"description\":{\"type\":\"text\",\"default\":\"We encountered an unexpected error. Please try again.\"},\"retryButtonLabel\":{\"type\":\"string\",\"default\":\"Try again\"},\"homeButtonLabel\":{\"type\":\"string\",\"default\":\"Go home\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"api::error-page.error-page\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"error_page\"}}},\"apiName\":\"error-page\",\"globalId\":\"ErrorPage\",\"uid\":\"api::error-page.error-page\",\"modelType\":\"contentType\",\"__schema__\":{\"collectionName\":\"error_page\",\"info\":{\"singularName\":\"error-page\",\"pluralName\":\"error-pages\",\"displayName\":\"Error Page\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"title\":{\"type\":\"string\",\"default\":\"Something went wrong\"},\"description\":{\"type\":\"text\",\"default\":\"We encountered an unexpected error. Please try again.\"},\"retryButtonLabel\":{\"type\":\"string\",\"default\":\"Try again\"},\"homeButtonLabel\":{\"type\":\"string\",\"default\":\"Go home\"}},\"kind\":\"singleType\"},\"modelName\":\"error-page\",\"actions\":{},\"lifecycles\":{}},\"api::global.global\":{\"kind\":\"singleType\",\"collectionName\":\"global\",\"info\":{\"singularName\":\"global\",\"pluralName\":\"globals\",\"displayName\":\"Global Settings\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"siteName\":{\"type\":\"string\",\"required\":true,\"default\":\"AI Enterprise Patterns Library\"},\"siteDescription\":{\"type\":\"text\"},\"logo\":{\"type\":\"media\",\"multiple\":false,\"allowedTypes\":[\"images\"]},\"navigation\":{\"type\":\"component\",\"repeatable\":true,\"component\":\"layout.nav-link\"},\"mobileMenuTitle\":{\"type\":\"string\",\"default\":\"Menu\"},\"skipToContentLabel\":{\"type\":\"string\",\"default\":\"Skip to main content\"},\"signInLabel\":{\"type\":\"string\",\"default\":\"Sign In\"},\"signOutLabel\":{\"type\":\"string\",\"default\":\"Sign Out\"},\"userMenuLabel\":{\"type\":\"string\",\"default\":\"User menu\"},\"newPatternButtonLabel\":{\"type\":\"string\",\"default\":\"+ New Pattern\"},\"footer\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"layout.footer-config\"},\"defaultSeo\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"seo.metadata\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"api::global.global\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"global\"}}},\"apiName\":\"global\",\"globalId\":\"Global\",\"uid\":\"api::global.global\",\"modelType\":\"contentType\",\"__schema__\":{\"collectionName\":\"global\",\"info\":{\"singularName\":\"global\",\"pluralName\":\"globals\",\"displayName\":\"Global Settings\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"siteName\":{\"type\":\"string\",\"required\":true,\"default\":\"AI Enterprise Patterns Library\"},\"siteDescription\":{\"type\":\"text\"},\"logo\":{\"type\":\"media\",\"multiple\":false,\"allowedTypes\":[\"images\"]},\"navigation\":{\"type\":\"component\",\"repeatable\":true,\"component\":\"layout.nav-link\"},\"mobileMenuTitle\":{\"type\":\"string\",\"default\":\"Menu\"},\"skipToContentLabel\":{\"type\":\"string\",\"default\":\"Skip to main content\"},\"signInLabel\":{\"type\":\"string\",\"default\":\"Sign In\"},\"signOutLabel\":{\"type\":\"string\",\"default\":\"Sign Out\"},\"userMenuLabel\":{\"type\":\"string\",\"default\":\"User menu\"},\"newPatternButtonLabel\":{\"type\":\"string\",\"default\":\"+ New Pattern\"},\"footer\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"layout.footer-config\"},\"defaultSeo\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"seo.metadata\"}},\"kind\":\"singleType\"},\"modelName\":\"global\",\"actions\":{},\"lifecycles\":{}},\"api::home-page.home-page\":{\"kind\":\"singleType\",\"collectionName\":\"home_page\",\"info\":{\"singularName\":\"home-page\",\"pluralName\":\"home-pages\",\"displayName\":\"Home Page\"},\"options\":{\"draftAndPublish\":true},\"pluginOptions\":{},\"attributes\":{\"seo\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"seo.metadata\"},\"content\":{\"type\":\"dynamiczone\",\"components\":[\"sections.hero\",\"sections.featured-patterns\",\"sections.stats-bar\",\"sections.cta-banner\",\"sections.rich-text\"]},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"api::home-page.home-page\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"home_page\"}}},\"apiName\":\"home-page\",\"globalId\":\"HomePage\",\"uid\":\"api::home-page.home-page\",\"modelType\":\"contentType\",\"__schema__\":{\"collectionName\":\"home_page\",\"info\":{\"singularName\":\"home-page\",\"pluralName\":\"home-pages\",\"displayName\":\"Home Page\"},\"options\":{\"draftAndPublish\":true},\"pluginOptions\":{},\"attributes\":{\"seo\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"seo.metadata\"},\"content\":{\"type\":\"dynamiczone\",\"components\":[\"sections.hero\",\"sections.featured-patterns\",\"sections.stats-bar\",\"sections.cta-banner\",\"sections.rich-text\"]}},\"kind\":\"singleType\"},\"modelName\":\"home-page\",\"actions\":{},\"lifecycles\":{}},\"api::login-page.login-page\":{\"kind\":\"singleType\",\"collectionName\":\"login_page\",\"info\":{\"singularName\":\"login-page\",\"pluralName\":\"login-pages\",\"displayName\":\"Login Page\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"seo\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"seo.metadata\"},\"cardTitle\":{\"type\":\"string\",\"default\":\"Sign in\"},\"cardDescription\":{\"type\":\"string\",\"default\":\"Access the AI Enterprise Patterns Library\"},\"signInButtonLabel\":{\"type\":\"string\",\"default\":\"Continue with Microsoft\"},\"signInLoadingLabel\":{\"type\":\"string\",\"default\":\"Redirecting...\"},\"footerNotice\":{\"type\":\"richtext\"},\"errorMessages\":{\"type\":\"json\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"api::login-page.login-page\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"login_page\"}}},\"apiName\":\"login-page\",\"globalId\":\"LoginPage\",\"uid\":\"api::login-page.login-page\",\"modelType\":\"contentType\",\"__schema__\":{\"collectionName\":\"login_page\",\"info\":{\"singularName\":\"login-page\",\"pluralName\":\"login-pages\",\"displayName\":\"Login Page\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"seo\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"seo.metadata\"},\"cardTitle\":{\"type\":\"string\",\"default\":\"Sign in\"},\"cardDescription\":{\"type\":\"string\",\"default\":\"Access the AI Enterprise Patterns Library\"},\"signInButtonLabel\":{\"type\":\"string\",\"default\":\"Continue with Microsoft\"},\"signInLoadingLabel\":{\"type\":\"string\",\"default\":\"Redirecting...\"},\"footerNotice\":{\"type\":\"richtext\"},\"errorMessages\":{\"type\":\"json\"}},\"kind\":\"singleType\"},\"modelName\":\"login-page\",\"actions\":{},\"lifecycles\":{}},\"api::not-found-page.not-found-page\":{\"kind\":\"singleType\",\"collectionName\":\"not_found_page\",\"info\":{\"singularName\":\"not-found-page\",\"pluralName\":\"not-found-pages\",\"displayName\":\"404 Not Found Page\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"errorCode\":{\"type\":\"string\",\"default\":\"404\"},\"heading\":{\"type\":\"string\",\"default\":\"Page Not Found\"},\"message\":{\"type\":\"text\",\"default\":\"The page you are looking for doesn\'t exist or has been moved.\"},\"backButton\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"layout.cta-button\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"api::not-found-page.not-found-page\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"not_found_page\"}}},\"apiName\":\"not-found-page\",\"globalId\":\"NotFoundPage\",\"uid\":\"api::not-found-page.not-found-page\",\"modelType\":\"contentType\",\"__schema__\":{\"collectionName\":\"not_found_page\",\"info\":{\"singularName\":\"not-found-page\",\"pluralName\":\"not-found-pages\",\"displayName\":\"404 Not Found Page\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"errorCode\":{\"type\":\"string\",\"default\":\"404\"},\"heading\":{\"type\":\"string\",\"default\":\"Page Not Found\"},\"message\":{\"type\":\"text\",\"default\":\"The page you are looking for doesn\'t exist or has been moved.\"},\"backButton\":{\"type\":\"component\",\"repeatable\":false,\"component\":\"layout.cta-button\"}},\"kind\":\"singleType\"},\"modelName\":\"not-found-page\",\"actions\":{},\"lifecycles\":{}},\"api::pattern-detail-labels.pattern-detail-labels\":{\"kind\":\"singleType\",\"collectionName\":\"pattern_detail_labels\",\"info\":{\"singularName\":\"pattern-detail-labels\",\"pluralName\":\"pattern-detail-labels-list\",\"displayName\":\"Pattern Detail Labels\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"breadcrumbAriaLabel\":{\"type\":\"string\",\"default\":\"Breadcrumb\"},\"voteAriaTemplate\":{\"type\":\"string\",\"default\":\"Vote for this pattern. {count} votes\"},\"votesLabel\":{\"type\":\"string\",\"default\":\"votes\"},\"voteAnnouncementTemplate\":{\"type\":\"string\",\"default\":\"Voted! {count} total votes\"},\"noContentMessage\":{\"type\":\"string\",\"default\":\"No content available for this pattern.\"},\"relatedPatternsTitle\":{\"type\":\"string\",\"default\":\"Related Patterns\"},\"noRelatedMessage\":{\"type\":\"string\",\"default\":\"No related patterns found\"},\"editLabel\":{\"type\":\"string\",\"default\":\"Edit\"},\"deleteLabel\":{\"type\":\"string\",\"default\":\"Delete\"},\"deleteDialogTitle\":{\"type\":\"string\",\"default\":\"Delete Pattern?\"},\"deleteDialogDescription\":{\"type\":\"text\",\"default\":\"This action cannot be undone. The pattern will be permanently removed.\"},\"cancelLabel\":{\"type\":\"string\",\"default\":\"Cancel\"},\"deleteConfirmLabel\":{\"type\":\"string\",\"default\":\"Delete\"},\"deletingLabel\":{\"type\":\"string\",\"default\":\"Deleting...\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"api::pattern-detail-labels.pattern-detail-labels\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"pattern_detail_labels\"}}},\"apiName\":\"pattern-detail-labels\",\"globalId\":\"PatternDetailLabels\",\"uid\":\"api::pattern-detail-labels.pattern-detail-labels\",\"modelType\":\"contentType\",\"__schema__\":{\"collectionName\":\"pattern_detail_labels\",\"info\":{\"singularName\":\"pattern-detail-labels\",\"pluralName\":\"pattern-detail-labels-list\",\"displayName\":\"Pattern Detail Labels\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"breadcrumbAriaLabel\":{\"type\":\"string\",\"default\":\"Breadcrumb\"},\"voteAriaTemplate\":{\"type\":\"string\",\"default\":\"Vote for this pattern. {count} votes\"},\"votesLabel\":{\"type\":\"string\",\"default\":\"votes\"},\"voteAnnouncementTemplate\":{\"type\":\"string\",\"default\":\"Voted! {count} total votes\"},\"noContentMessage\":{\"type\":\"string\",\"default\":\"No content available for this pattern.\"},\"relatedPatternsTitle\":{\"type\":\"string\",\"default\":\"Related Patterns\"},\"noRelatedMessage\":{\"type\":\"string\",\"default\":\"No related patterns found\"},\"editLabel\":{\"type\":\"string\",\"default\":\"Edit\"},\"deleteLabel\":{\"type\":\"string\",\"default\":\"Delete\"},\"deleteDialogTitle\":{\"type\":\"string\",\"default\":\"Delete Pattern?\"},\"deleteDialogDescription\":{\"type\":\"text\",\"default\":\"This action cannot be undone. The pattern will be permanently removed.\"},\"cancelLabel\":{\"type\":\"string\",\"default\":\"Cancel\"},\"deleteConfirmLabel\":{\"type\":\"string\",\"default\":\"Delete\"},\"deletingLabel\":{\"type\":\"string\",\"default\":\"Deleting...\"}},\"kind\":\"singleType\"},\"modelName\":\"pattern-detail-labels\",\"actions\":{},\"lifecycles\":{}},\"api::pattern-form-labels.pattern-form-labels\":{\"kind\":\"singleType\",\"collectionName\":\"pattern_form_labels\",\"info\":{\"singularName\":\"pattern-form-labels\",\"pluralName\":\"pattern-form-labels-list\",\"displayName\":\"Pattern Form Labels\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"createTitle\":{\"type\":\"string\",\"default\":\"New Pattern\"},\"editTitle\":{\"type\":\"string\",\"default\":\"Edit Pattern\"},\"titleLabel\":{\"type\":\"string\",\"default\":\"Title *\"},\"titlePlaceholder\":{\"type\":\"string\",\"default\":\"e.g. CQRS Pattern for Event-Driven Systems\"},\"slugPreviewTemplate\":{\"type\":\"string\",\"default\":\"Slug preview: {slug}\"},\"shortDescLabel\":{\"type\":\"string\",\"default\":\"Short Description *\"},\"shortDescPlaceholder\":{\"type\":\"string\",\"default\":\"A brief summary of the pattern (shown in listings)\"},\"categoryLabel\":{\"type\":\"string\",\"default\":\"Category *\"},\"categoryPlaceholder\":{\"type\":\"string\",\"default\":\"Select a category\"},\"tagsLabel\":{\"type\":\"string\",\"default\":\"Tags\"},\"tagPlaceholder\":{\"type\":\"string\",\"default\":\"Add a tag and press Enter\"},\"addTagLabel\":{\"type\":\"string\",\"default\":\"Add\"},\"tagCountTemplate\":{\"type\":\"string\",\"default\":\"{count}/{max} tags\"},\"contentLabel\":{\"type\":\"string\",\"default\":\"Full Content (Markdown)\"},\"contentPlaceholder\":{\"type\":\"string\",\"default\":\"Write the full pattern content in Markdown...\"},\"authorLabel\":{\"type\":\"string\",\"default\":\"Author\"},\"authorPlaceholder\":{\"type\":\"string\",\"default\":\"Your name (optional)\"},\"adminSettingsLabel\":{\"type\":\"string\",\"default\":\"Admin Settings\"},\"featuredLabel\":{\"type\":\"string\",\"default\":\"Featured pattern\"},\"trendingLabel\":{\"type\":\"string\",\"default\":\"Trending pattern\"},\"cancelLabel\":{\"type\":\"string\",\"default\":\"Cancel\"},\"createLabel\":{\"type\":\"string\",\"default\":\"Create Pattern\"},\"creatingLabel\":{\"type\":\"string\",\"default\":\"Creating...\"},\"saveLabel\":{\"type\":\"string\",\"default\":\"Save Changes\"},\"savingLabel\":{\"type\":\"string\",\"default\":\"Saving...\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"api::pattern-form-labels.pattern-form-labels\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"pattern_form_labels\"}}},\"apiName\":\"pattern-form-labels\",\"globalId\":\"PatternFormLabels\",\"uid\":\"api::pattern-form-labels.pattern-form-labels\",\"modelType\":\"contentType\",\"__schema__\":{\"collectionName\":\"pattern_form_labels\",\"info\":{\"singularName\":\"pattern-form-labels\",\"pluralName\":\"pattern-form-labels-list\",\"displayName\":\"Pattern Form Labels\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"createTitle\":{\"type\":\"string\",\"default\":\"New Pattern\"},\"editTitle\":{\"type\":\"string\",\"default\":\"Edit Pattern\"},\"titleLabel\":{\"type\":\"string\",\"default\":\"Title *\"},\"titlePlaceholder\":{\"type\":\"string\",\"default\":\"e.g. CQRS Pattern for Event-Driven Systems\"},\"slugPreviewTemplate\":{\"type\":\"string\",\"default\":\"Slug preview: {slug}\"},\"shortDescLabel\":{\"type\":\"string\",\"default\":\"Short Description *\"},\"shortDescPlaceholder\":{\"type\":\"string\",\"default\":\"A brief summary of the pattern (shown in listings)\"},\"categoryLabel\":{\"type\":\"string\",\"default\":\"Category *\"},\"categoryPlaceholder\":{\"type\":\"string\",\"default\":\"Select a category\"},\"tagsLabel\":{\"type\":\"string\",\"default\":\"Tags\"},\"tagPlaceholder\":{\"type\":\"string\",\"default\":\"Add a tag and press Enter\"},\"addTagLabel\":{\"type\":\"string\",\"default\":\"Add\"},\"tagCountTemplate\":{\"type\":\"string\",\"default\":\"{count}/{max} tags\"},\"contentLabel\":{\"type\":\"string\",\"default\":\"Full Content (Markdown)\"},\"contentPlaceholder\":{\"type\":\"string\",\"default\":\"Write the full pattern content in Markdown...\"},\"authorLabel\":{\"type\":\"string\",\"default\":\"Author\"},\"authorPlaceholder\":{\"type\":\"string\",\"default\":\"Your name (optional)\"},\"adminSettingsLabel\":{\"type\":\"string\",\"default\":\"Admin Settings\"},\"featuredLabel\":{\"type\":\"string\",\"default\":\"Featured pattern\"},\"trendingLabel\":{\"type\":\"string\",\"default\":\"Trending pattern\"},\"cancelLabel\":{\"type\":\"string\",\"default\":\"Cancel\"},\"createLabel\":{\"type\":\"string\",\"default\":\"Create Pattern\"},\"creatingLabel\":{\"type\":\"string\",\"default\":\"Creating...\"},\"saveLabel\":{\"type\":\"string\",\"default\":\"Save Changes\"},\"savingLabel\":{\"type\":\"string\",\"default\":\"Saving...\"}},\"kind\":\"singleType\"},\"modelName\":\"pattern-form-labels\",\"actions\":{},\"lifecycles\":{}},\"api::pattern-listing-labels.pattern-listing-labels\":{\"kind\":\"singleType\",\"collectionName\":\"pattern_listing_labels\",\"info\":{\"singularName\":\"pattern-listing-labels\",\"pluralName\":\"pattern-listing-labels-list\",\"displayName\":\"Pattern Listing Labels\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"pageTitle\":{\"type\":\"string\",\"default\":\"Browse Patterns\"},\"pageDescription\":{\"type\":\"text\",\"default\":\"Discover {count} {pattern|patterns} across AI, architecture, and engineering disciplines.\"},\"searchPlaceholder\":{\"type\":\"string\",\"default\":\"Search patterns...\"},\"clearSearchLabel\":{\"type\":\"string\",\"default\":\"Clear search\"},\"sortByLabel\":{\"type\":\"string\",\"default\":\"Sort by:\"},\"sortOptions\":{\"type\":\"json\"},\"filterSectionHeader\":{\"type\":\"string\",\"default\":\"Filters\"},\"clearAllLabel\":{\"type\":\"string\",\"default\":\"Clear all\"},\"categoryLabel\":{\"type\":\"string\",\"default\":\"Category\"},\"allCategoriesLabel\":{\"type\":\"string\",\"default\":\"All Categories\"},\"tagsLabel\":{\"type\":\"string\",\"default\":\"Tags\"},\"tagModeLabel\":{\"type\":\"string\",\"default\":\"Match:\"},\"anyLabel\":{\"type\":\"string\",\"default\":\"Any\"},\"allLabel\":{\"type\":\"string\",\"default\":\"All\"},\"dateRangeHeader\":{\"type\":\"string\",\"default\":\"Date Range\"},\"clearDatesLabel\":{\"type\":\"string\",\"default\":\"Clear dates\"},\"fromLabel\":{\"type\":\"string\",\"default\":\"From\"},\"toLabel\":{\"type\":\"string\",\"default\":\"To\"},\"activeFiltersLabel\":{\"type\":\"string\",\"default\":\"Active Filters\"},\"filtersButtonLabel\":{\"type\":\"string\",\"default\":\"Filters\"},\"filterSheetTitle\":{\"type\":\"string\",\"default\":\"Filter Patterns\"},\"filterSheetDescription\":{\"type\":\"string\",\"default\":\"Refine your search by category and tags\"},\"savedSearchesHeader\":{\"type\":\"string\",\"default\":\"Saved Searches\"},\"saveCurrentLabel\":{\"type\":\"string\",\"default\":\"Save current\"},\"saveDialogTitle\":{\"type\":\"string\",\"default\":\"Save Search\"},\"saveDialogDescription\":{\"type\":\"string\",\"default\":\"Give this search a name to quickly access it later.\"},\"searchNameLabel\":{\"type\":\"string\",\"default\":\"Search name\"},\"searchNamePlaceholder\":{\"type\":\"string\",\"default\":\"e.g. Architecture with CQRS\"},\"cancelLabel\":{\"type\":\"string\",\"default\":\"Cancel\"},\"saveLabel\":{\"type\":\"string\",\"default\":\"Save\"},\"recentlyViewedHeader\":{\"type\":\"string\",\"default\":\"Recently Viewed\"},\"clearLabel\":{\"type\":\"string\",\"default\":\"Clear\"},\"previousLabel\":{\"type\":\"string\",\"default\":\"Previous\"},\"nextLabel\":{\"type\":\"string\",\"default\":\"Next\"},\"emptyFilteredHeading\":{\"type\":\"string\",\"default\":\"No patterns found\"},\"emptyUnfilteredHeading\":{\"type\":\"string\",\"default\":\"No patterns available\"},\"emptyFilteredDescription\":{\"type\":\"text\",\"default\":\"Try adjusting your filters or search query to find what you\'re looking for.\"},\"emptyUnfilteredDescription\":{\"type\":\"text\",\"default\":\"There are no patterns yet. Check back later.\"},\"clearFiltersLabel\":{\"type\":\"string\",\"default\":\"Clear all filters\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"api::pattern-listing-labels.pattern-listing-labels\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"pattern_listing_labels\"}}},\"apiName\":\"pattern-listing-labels\",\"globalId\":\"PatternListingLabels\",\"uid\":\"api::pattern-listing-labels.pattern-listing-labels\",\"modelType\":\"contentType\",\"__schema__\":{\"collectionName\":\"pattern_listing_labels\",\"info\":{\"singularName\":\"pattern-listing-labels\",\"pluralName\":\"pattern-listing-labels-list\",\"displayName\":\"Pattern Listing Labels\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{},\"attributes\":{\"pageTitle\":{\"type\":\"string\",\"default\":\"Browse Patterns\"},\"pageDescription\":{\"type\":\"text\",\"default\":\"Discover {count} {pattern|patterns} across AI, architecture, and engineering disciplines.\"},\"searchPlaceholder\":{\"type\":\"string\",\"default\":\"Search patterns...\"},\"clearSearchLabel\":{\"type\":\"string\",\"default\":\"Clear search\"},\"sortByLabel\":{\"type\":\"string\",\"default\":\"Sort by:\"},\"sortOptions\":{\"type\":\"json\"},\"filterSectionHeader\":{\"type\":\"string\",\"default\":\"Filters\"},\"clearAllLabel\":{\"type\":\"string\",\"default\":\"Clear all\"},\"categoryLabel\":{\"type\":\"string\",\"default\":\"Category\"},\"allCategoriesLabel\":{\"type\":\"string\",\"default\":\"All Categories\"},\"tagsLabel\":{\"type\":\"string\",\"default\":\"Tags\"},\"tagModeLabel\":{\"type\":\"string\",\"default\":\"Match:\"},\"anyLabel\":{\"type\":\"string\",\"default\":\"Any\"},\"allLabel\":{\"type\":\"string\",\"default\":\"All\"},\"dateRangeHeader\":{\"type\":\"string\",\"default\":\"Date Range\"},\"clearDatesLabel\":{\"type\":\"string\",\"default\":\"Clear dates\"},\"fromLabel\":{\"type\":\"string\",\"default\":\"From\"},\"toLabel\":{\"type\":\"string\",\"default\":\"To\"},\"activeFiltersLabel\":{\"type\":\"string\",\"default\":\"Active Filters\"},\"filtersButtonLabel\":{\"type\":\"string\",\"default\":\"Filters\"},\"filterSheetTitle\":{\"type\":\"string\",\"default\":\"Filter Patterns\"},\"filterSheetDescription\":{\"type\":\"string\",\"default\":\"Refine your search by category and tags\"},\"savedSearchesHeader\":{\"type\":\"string\",\"default\":\"Saved Searches\"},\"saveCurrentLabel\":{\"type\":\"string\",\"default\":\"Save current\"},\"saveDialogTitle\":{\"type\":\"string\",\"default\":\"Save Search\"},\"saveDialogDescription\":{\"type\":\"string\",\"default\":\"Give this search a name to quickly access it later.\"},\"searchNameLabel\":{\"type\":\"string\",\"default\":\"Search name\"},\"searchNamePlaceholder\":{\"type\":\"string\",\"default\":\"e.g. Architecture with CQRS\"},\"cancelLabel\":{\"type\":\"string\",\"default\":\"Cancel\"},\"saveLabel\":{\"type\":\"string\",\"default\":\"Save\"},\"recentlyViewedHeader\":{\"type\":\"string\",\"default\":\"Recently Viewed\"},\"clearLabel\":{\"type\":\"string\",\"default\":\"Clear\"},\"previousLabel\":{\"type\":\"string\",\"default\":\"Previous\"},\"nextLabel\":{\"type\":\"string\",\"default\":\"Next\"},\"emptyFilteredHeading\":{\"type\":\"string\",\"default\":\"No patterns found\"},\"emptyUnfilteredHeading\":{\"type\":\"string\",\"default\":\"No patterns available\"},\"emptyFilteredDescription\":{\"type\":\"text\",\"default\":\"Try adjusting your filters or search query to find what you\'re looking for.\"},\"emptyUnfilteredDescription\":{\"type\":\"text\",\"default\":\"There are no patterns yet. Check back later.\"},\"clearFiltersLabel\":{\"type\":\"string\",\"default\":\"Clear all filters\"}},\"kind\":\"singleType\"},\"modelName\":\"pattern-listing-labels\",\"actions\":{},\"lifecycles\":{}},\"admin::permission\":{\"collectionName\":\"admin_permissions\",\"info\":{\"name\":\"Permission\",\"description\":\"\",\"singularName\":\"permission\",\"pluralName\":\"permissions\",\"displayName\":\"Permission\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"action\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true},\"actionParameters\":{\"type\":\"json\",\"configurable\":false,\"required\":false,\"default\":{}},\"subject\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":false},\"properties\":{\"type\":\"json\",\"configurable\":false,\"required\":false,\"default\":{}},\"conditions\":{\"type\":\"json\",\"configurable\":false,\"required\":false,\"default\":[]},\"role\":{\"configurable\":false,\"type\":\"relation\",\"relation\":\"manyToOne\",\"inversedBy\":\"permissions\",\"target\":\"admin::role\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"admin::permission\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"admin_permissions\"}}},\"plugin\":\"admin\",\"globalId\":\"AdminPermission\",\"uid\":\"admin::permission\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"admin_permissions\",\"info\":{\"name\":\"Permission\",\"description\":\"\",\"singularName\":\"permission\",\"pluralName\":\"permissions\",\"displayName\":\"Permission\"},\"options\":{},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"action\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true},\"actionParameters\":{\"type\":\"json\",\"configurable\":false,\"required\":false,\"default\":{}},\"subject\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":false},\"properties\":{\"type\":\"json\",\"configurable\":false,\"required\":false,\"default\":{}},\"conditions\":{\"type\":\"json\",\"configurable\":false,\"required\":false,\"default\":[]},\"role\":{\"configurable\":false,\"type\":\"relation\",\"relation\":\"manyToOne\",\"inversedBy\":\"permissions\",\"target\":\"admin::role\"}},\"kind\":\"collectionType\"},\"modelName\":\"permission\"},\"admin::user\":{\"collectionName\":\"admin_users\",\"info\":{\"name\":\"User\",\"description\":\"\",\"singularName\":\"user\",\"pluralName\":\"users\",\"displayName\":\"User\"},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"firstname\":{\"type\":\"string\",\"unique\":false,\"minLength\":1,\"configurable\":false,\"required\":false},\"lastname\":{\"type\":\"string\",\"unique\":false,\"minLength\":1,\"configurable\":false,\"required\":false},\"username\":{\"type\":\"string\",\"unique\":false,\"configurable\":false,\"required\":false},\"email\":{\"type\":\"email\",\"minLength\":6,\"configurable\":false,\"required\":true,\"unique\":true,\"private\":true},\"password\":{\"type\":\"password\",\"minLength\":6,\"configurable\":false,\"required\":false,\"private\":true,\"searchable\":false},\"resetPasswordToken\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false},\"registrationToken\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false},\"isActive\":{\"type\":\"boolean\",\"default\":false,\"configurable\":false,\"private\":true},\"roles\":{\"configurable\":false,\"private\":true,\"type\":\"relation\",\"relation\":\"manyToMany\",\"inversedBy\":\"users\",\"target\":\"admin::role\",\"collectionName\":\"strapi_users_roles\"},\"blocked\":{\"type\":\"boolean\",\"default\":false,\"configurable\":false,\"private\":true},\"preferedLanguage\":{\"type\":\"string\",\"configurable\":false,\"required\":false,\"searchable\":false},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"admin::user\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"admin_users\"}}},\"config\":{\"attributes\":{\"resetPasswordToken\":{\"hidden\":true},\"registrationToken\":{\"hidden\":true}}},\"plugin\":\"admin\",\"globalId\":\"AdminUser\",\"uid\":\"admin::user\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"admin_users\",\"info\":{\"name\":\"User\",\"description\":\"\",\"singularName\":\"user\",\"pluralName\":\"users\",\"displayName\":\"User\"},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"firstname\":{\"type\":\"string\",\"unique\":false,\"minLength\":1,\"configurable\":false,\"required\":false},\"lastname\":{\"type\":\"string\",\"unique\":false,\"minLength\":1,\"configurable\":false,\"required\":false},\"username\":{\"type\":\"string\",\"unique\":false,\"configurable\":false,\"required\":false},\"email\":{\"type\":\"email\",\"minLength\":6,\"configurable\":false,\"required\":true,\"unique\":true,\"private\":true},\"password\":{\"type\":\"password\",\"minLength\":6,\"configurable\":false,\"required\":false,\"private\":true,\"searchable\":false},\"resetPasswordToken\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false},\"registrationToken\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false},\"isActive\":{\"type\":\"boolean\",\"default\":false,\"configurable\":false,\"private\":true},\"roles\":{\"configurable\":false,\"private\":true,\"type\":\"relation\",\"relation\":\"manyToMany\",\"inversedBy\":\"users\",\"target\":\"admin::role\",\"collectionName\":\"strapi_users_roles\"},\"blocked\":{\"type\":\"boolean\",\"default\":false,\"configurable\":false,\"private\":true},\"preferedLanguage\":{\"type\":\"string\",\"configurable\":false,\"required\":false,\"searchable\":false}},\"kind\":\"collectionType\"},\"modelName\":\"user\",\"options\":{\"draftAndPublish\":false}},\"admin::role\":{\"collectionName\":\"admin_roles\",\"info\":{\"name\":\"Role\",\"description\":\"\",\"singularName\":\"role\",\"pluralName\":\"roles\",\"displayName\":\"Role\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"minLength\":1,\"unique\":true,\"configurable\":false,\"required\":true},\"code\":{\"type\":\"string\",\"minLength\":1,\"unique\":true,\"configurable\":false,\"required\":true},\"description\":{\"type\":\"string\",\"configurable\":false},\"users\":{\"configurable\":false,\"type\":\"relation\",\"relation\":\"manyToMany\",\"mappedBy\":\"roles\",\"target\":\"admin::user\"},\"permissions\":{\"configurable\":false,\"type\":\"relation\",\"relation\":\"oneToMany\",\"mappedBy\":\"role\",\"target\":\"admin::permission\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"admin::role\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"admin_roles\"}}},\"plugin\":\"admin\",\"globalId\":\"AdminRole\",\"uid\":\"admin::role\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"admin_roles\",\"info\":{\"name\":\"Role\",\"description\":\"\",\"singularName\":\"role\",\"pluralName\":\"roles\",\"displayName\":\"Role\"},\"options\":{},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"minLength\":1,\"unique\":true,\"configurable\":false,\"required\":true},\"code\":{\"type\":\"string\",\"minLength\":1,\"unique\":true,\"configurable\":false,\"required\":true},\"description\":{\"type\":\"string\",\"configurable\":false},\"users\":{\"configurable\":false,\"type\":\"relation\",\"relation\":\"manyToMany\",\"mappedBy\":\"roles\",\"target\":\"admin::user\"},\"permissions\":{\"configurable\":false,\"type\":\"relation\",\"relation\":\"oneToMany\",\"mappedBy\":\"role\",\"target\":\"admin::permission\"}},\"kind\":\"collectionType\"},\"modelName\":\"role\"},\"admin::api-token\":{\"collectionName\":\"strapi_api_tokens\",\"info\":{\"name\":\"Api Token\",\"singularName\":\"api-token\",\"pluralName\":\"api-tokens\",\"displayName\":\"Api Token\",\"description\":\"\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true,\"unique\":true},\"description\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":false,\"default\":\"\"},\"type\":{\"type\":\"enumeration\",\"enum\":[\"read-only\",\"full-access\",\"custom\"],\"configurable\":false,\"required\":true,\"default\":\"read-only\"},\"accessKey\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true,\"searchable\":false},\"encryptedKey\":{\"type\":\"text\",\"minLength\":1,\"configurable\":false,\"required\":false,\"searchable\":false},\"lastUsedAt\":{\"type\":\"datetime\",\"configurable\":false,\"required\":false},\"permissions\":{\"type\":\"relation\",\"target\":\"admin::api-token-permission\",\"relation\":\"oneToMany\",\"mappedBy\":\"token\",\"configurable\":false,\"required\":false},\"expiresAt\":{\"type\":\"datetime\",\"configurable\":false,\"required\":false},\"lifespan\":{\"type\":\"biginteger\",\"configurable\":false,\"required\":false},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"admin::api-token\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"strapi_api_tokens\"}}},\"plugin\":\"admin\",\"globalId\":\"AdminApiToken\",\"uid\":\"admin::api-token\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"strapi_api_tokens\",\"info\":{\"name\":\"Api Token\",\"singularName\":\"api-token\",\"pluralName\":\"api-tokens\",\"displayName\":\"Api Token\",\"description\":\"\"},\"options\":{},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true,\"unique\":true},\"description\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":false,\"default\":\"\"},\"type\":{\"type\":\"enumeration\",\"enum\":[\"read-only\",\"full-access\",\"custom\"],\"configurable\":false,\"required\":true,\"default\":\"read-only\"},\"accessKey\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true,\"searchable\":false},\"encryptedKey\":{\"type\":\"text\",\"minLength\":1,\"configurable\":false,\"required\":false,\"searchable\":false},\"lastUsedAt\":{\"type\":\"datetime\",\"configurable\":false,\"required\":false},\"permissions\":{\"type\":\"relation\",\"target\":\"admin::api-token-permission\",\"relation\":\"oneToMany\",\"mappedBy\":\"token\",\"configurable\":false,\"required\":false},\"expiresAt\":{\"type\":\"datetime\",\"configurable\":false,\"required\":false},\"lifespan\":{\"type\":\"biginteger\",\"configurable\":false,\"required\":false}},\"kind\":\"collectionType\"},\"modelName\":\"api-token\"},\"admin::api-token-permission\":{\"collectionName\":\"strapi_api_token_permissions\",\"info\":{\"name\":\"API Token Permission\",\"description\":\"\",\"singularName\":\"api-token-permission\",\"pluralName\":\"api-token-permissions\",\"displayName\":\"API Token Permission\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"action\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true},\"token\":{\"configurable\":false,\"type\":\"relation\",\"relation\":\"manyToOne\",\"inversedBy\":\"permissions\",\"target\":\"admin::api-token\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"admin::api-token-permission\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"strapi_api_token_permissions\"}}},\"plugin\":\"admin\",\"globalId\":\"AdminApiTokenPermission\",\"uid\":\"admin::api-token-permission\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"strapi_api_token_permissions\",\"info\":{\"name\":\"API Token Permission\",\"description\":\"\",\"singularName\":\"api-token-permission\",\"pluralName\":\"api-token-permissions\",\"displayName\":\"API Token Permission\"},\"options\":{},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"action\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true},\"token\":{\"configurable\":false,\"type\":\"relation\",\"relation\":\"manyToOne\",\"inversedBy\":\"permissions\",\"target\":\"admin::api-token\"}},\"kind\":\"collectionType\"},\"modelName\":\"api-token-permission\"},\"admin::transfer-token\":{\"collectionName\":\"strapi_transfer_tokens\",\"info\":{\"name\":\"Transfer Token\",\"singularName\":\"transfer-token\",\"pluralName\":\"transfer-tokens\",\"displayName\":\"Transfer Token\",\"description\":\"\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true,\"unique\":true},\"description\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":false,\"default\":\"\"},\"accessKey\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true},\"lastUsedAt\":{\"type\":\"datetime\",\"configurable\":false,\"required\":false},\"permissions\":{\"type\":\"relation\",\"target\":\"admin::transfer-token-permission\",\"relation\":\"oneToMany\",\"mappedBy\":\"token\",\"configurable\":false,\"required\":false},\"expiresAt\":{\"type\":\"datetime\",\"configurable\":false,\"required\":false},\"lifespan\":{\"type\":\"biginteger\",\"configurable\":false,\"required\":false},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"admin::transfer-token\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"strapi_transfer_tokens\"}}},\"plugin\":\"admin\",\"globalId\":\"AdminTransferToken\",\"uid\":\"admin::transfer-token\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"strapi_transfer_tokens\",\"info\":{\"name\":\"Transfer Token\",\"singularName\":\"transfer-token\",\"pluralName\":\"transfer-tokens\",\"displayName\":\"Transfer Token\",\"description\":\"\"},\"options\":{},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"name\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true,\"unique\":true},\"description\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":false,\"default\":\"\"},\"accessKey\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true},\"lastUsedAt\":{\"type\":\"datetime\",\"configurable\":false,\"required\":false},\"permissions\":{\"type\":\"relation\",\"target\":\"admin::transfer-token-permission\",\"relation\":\"oneToMany\",\"mappedBy\":\"token\",\"configurable\":false,\"required\":false},\"expiresAt\":{\"type\":\"datetime\",\"configurable\":false,\"required\":false},\"lifespan\":{\"type\":\"biginteger\",\"configurable\":false,\"required\":false}},\"kind\":\"collectionType\"},\"modelName\":\"transfer-token\"},\"admin::transfer-token-permission\":{\"collectionName\":\"strapi_transfer_token_permissions\",\"info\":{\"name\":\"Transfer Token Permission\",\"description\":\"\",\"singularName\":\"transfer-token-permission\",\"pluralName\":\"transfer-token-permissions\",\"displayName\":\"Transfer Token Permission\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"action\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true},\"token\":{\"configurable\":false,\"type\":\"relation\",\"relation\":\"manyToOne\",\"inversedBy\":\"permissions\",\"target\":\"admin::transfer-token\"},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"admin::transfer-token-permission\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"strapi_transfer_token_permissions\"}}},\"plugin\":\"admin\",\"globalId\":\"AdminTransferTokenPermission\",\"uid\":\"admin::transfer-token-permission\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"strapi_transfer_token_permissions\",\"info\":{\"name\":\"Transfer Token Permission\",\"description\":\"\",\"singularName\":\"transfer-token-permission\",\"pluralName\":\"transfer-token-permissions\",\"displayName\":\"Transfer Token Permission\"},\"options\":{},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false}},\"attributes\":{\"action\":{\"type\":\"string\",\"minLength\":1,\"configurable\":false,\"required\":true},\"token\":{\"configurable\":false,\"type\":\"relation\",\"relation\":\"manyToOne\",\"inversedBy\":\"permissions\",\"target\":\"admin::transfer-token\"}},\"kind\":\"collectionType\"},\"modelName\":\"transfer-token-permission\"},\"admin::session\":{\"collectionName\":\"strapi_sessions\",\"info\":{\"name\":\"Session\",\"description\":\"Session Manager storage\",\"singularName\":\"session\",\"pluralName\":\"sessions\",\"displayName\":\"Session\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false},\"i18n\":{\"localized\":false}},\"attributes\":{\"userId\":{\"type\":\"string\",\"required\":true,\"configurable\":false,\"private\":true,\"searchable\":false},\"sessionId\":{\"type\":\"string\",\"unique\":true,\"required\":true,\"configurable\":false,\"private\":true,\"searchable\":false},\"childId\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false},\"deviceId\":{\"type\":\"string\",\"required\":true,\"configurable\":false,\"private\":true,\"searchable\":false},\"origin\":{\"type\":\"string\",\"required\":true,\"configurable\":false,\"private\":true,\"searchable\":false},\"expiresAt\":{\"type\":\"datetime\",\"required\":true,\"configurable\":false,\"private\":true,\"searchable\":false},\"absoluteExpiresAt\":{\"type\":\"datetime\",\"configurable\":false,\"private\":true,\"searchable\":false},\"status\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false},\"type\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false},\"createdAt\":{\"type\":\"datetime\"},\"updatedAt\":{\"type\":\"datetime\"},\"publishedAt\":{\"type\":\"datetime\",\"configurable\":false,\"writable\":true,\"visible\":true},\"createdBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"updatedBy\":{\"type\":\"relation\",\"relation\":\"oneToOne\",\"target\":\"admin::user\",\"configurable\":false,\"writable\":false,\"visible\":false,\"useJoinTable\":false,\"private\":true},\"locale\":{\"writable\":true,\"private\":true,\"configurable\":false,\"visible\":false,\"type\":\"string\"},\"localizations\":{\"type\":\"relation\",\"relation\":\"oneToMany\",\"target\":\"admin::session\",\"writable\":false,\"private\":true,\"configurable\":false,\"visible\":false,\"unstable_virtual\":true,\"joinColumn\":{\"name\":\"document_id\",\"referencedColumn\":\"document_id\",\"referencedTable\":\"strapi_sessions\"}}},\"plugin\":\"admin\",\"globalId\":\"AdminSession\",\"uid\":\"admin::session\",\"modelType\":\"contentType\",\"kind\":\"collectionType\",\"__schema__\":{\"collectionName\":\"strapi_sessions\",\"info\":{\"name\":\"Session\",\"description\":\"Session Manager storage\",\"singularName\":\"session\",\"pluralName\":\"sessions\",\"displayName\":\"Session\"},\"options\":{\"draftAndPublish\":false},\"pluginOptions\":{\"content-manager\":{\"visible\":false},\"content-type-builder\":{\"visible\":false},\"i18n\":{\"localized\":false}},\"attributes\":{\"userId\":{\"type\":\"string\",\"required\":true,\"configurable\":false,\"private\":true,\"searchable\":false},\"sessionId\":{\"type\":\"string\",\"unique\":true,\"required\":true,\"configurable\":false,\"private\":true,\"searchable\":false},\"childId\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false},\"deviceId\":{\"type\":\"string\",\"required\":true,\"configurable\":false,\"private\":true,\"searchable\":false},\"origin\":{\"type\":\"string\",\"required\":true,\"configurable\":false,\"private\":true,\"searchable\":false},\"expiresAt\":{\"type\":\"datetime\",\"required\":true,\"configurable\":false,\"private\":true,\"searchable\":false},\"absoluteExpiresAt\":{\"type\":\"datetime\",\"configurable\":false,\"private\":true,\"searchable\":false},\"status\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false},\"type\":{\"type\":\"string\",\"configurable\":false,\"private\":true,\"searchable\":false}},\"kind\":\"collectionType\"},\"modelName\":\"session\"}}','object',NULL,NULL),(3,'plugin_content_manager_configuration_components::shared.text-item','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"text\",\"defaultSortBy\":\"text\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"text\":{\"edit\":{\"label\":\"text\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"text\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"text\"],\"edit\":[[{\"name\":\"text\",\"size\":6}]]},\"uid\":\"shared.text-item\",\"isComponent\":true}','object',NULL,NULL),(4,'plugin_content_manager_configuration_components::seo.metadata','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"title\",\"defaultSortBy\":\"title\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"title\":{\"edit\":{\"label\":\"title\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"title\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":true,\"sortable\":true}},\"keywords\":{\"edit\":{\"label\":\"keywords\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"keywords\",\"searchable\":true,\"sortable\":true}},\"ogImage\":{\"edit\":{\"label\":\"ogImage\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"ogImage\",\"searchable\":false,\"sortable\":false}},\"ogTitle\":{\"edit\":{\"label\":\"ogTitle\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"ogTitle\",\"searchable\":true,\"sortable\":true}},\"ogDescription\":{\"edit\":{\"label\":\"ogDescription\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"ogDescription\",\"searchable\":true,\"sortable\":true}},\"noIndex\":{\"edit\":{\"label\":\"noIndex\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"noIndex\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"title\",\"description\",\"keywords\"],\"edit\":[[{\"name\":\"title\",\"size\":6},{\"name\":\"description\",\"size\":6}],[{\"name\":\"keywords\",\"size\":6},{\"name\":\"ogImage\",\"size\":6}],[{\"name\":\"ogTitle\",\"size\":6},{\"name\":\"ogDescription\",\"size\":6}],[{\"name\":\"noIndex\",\"size\":4}]]},\"uid\":\"seo.metadata\",\"isComponent\":true}','object',NULL,NULL),(5,'plugin_content_manager_configuration_components::shared.tech-group','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"title\",\"defaultSortBy\":\"title\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"title\":{\"edit\":{\"label\":\"title\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"title\",\"searchable\":true,\"sortable\":true}},\"items\":{\"edit\":{\"label\":\"items\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"items\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"title\",\"items\"],\"edit\":[[{\"name\":\"title\",\"size\":6}],[{\"name\":\"items\",\"size\":12}]]},\"uid\":\"shared.tech-group\",\"isComponent\":true}','object',NULL,NULL),(6,'plugin_content_manager_configuration_components::shared.quick-nav-item','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"title\",\"defaultSortBy\":\"title\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"title\":{\"edit\":{\"label\":\"title\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"title\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":true,\"sortable\":true}},\"href\":{\"edit\":{\"label\":\"href\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"href\",\"searchable\":true,\"sortable\":true}},\"icon\":{\"edit\":{\"label\":\"icon\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"icon\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"title\",\"description\",\"href\"],\"edit\":[[{\"name\":\"title\",\"size\":6},{\"name\":\"description\",\"size\":6}],[{\"name\":\"href\",\"size\":6},{\"name\":\"icon\",\"size\":6}]]},\"uid\":\"shared.quick-nav-item\",\"isComponent\":true}','object',NULL,NULL),(7,'plugin_content_manager_configuration_components::shared.support-item','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"title\",\"defaultSortBy\":\"title\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"title\":{\"edit\":{\"label\":\"title\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"title\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":true,\"sortable\":true}},\"href\":{\"edit\":{\"label\":\"href\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"href\",\"searchable\":true,\"sortable\":true}},\"icon\":{\"edit\":{\"label\":\"icon\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"icon\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"title\",\"description\",\"href\"],\"edit\":[[{\"name\":\"title\",\"size\":6},{\"name\":\"description\",\"size\":6}],[{\"name\":\"href\",\"size\":6},{\"name\":\"icon\",\"size\":6}]]},\"uid\":\"shared.support-item\",\"isComponent\":true}','object',NULL,NULL),(8,'plugin_content_manager_configuration_components::shared.stat-item','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"value\",\"defaultSortBy\":\"value\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"value\":{\"edit\":{\"label\":\"value\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"value\",\"searchable\":true,\"sortable\":true}},\"label\":{\"edit\":{\"label\":\"label\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"label\",\"searchable\":true,\"sortable\":true}},\"icon\":{\"edit\":{\"label\":\"icon\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"icon\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"value\",\"label\",\"icon\"],\"edit\":[[{\"name\":\"value\",\"size\":6},{\"name\":\"label\",\"size\":6}],[{\"name\":\"icon\",\"size\":6}]]},\"uid\":\"shared.stat-item\",\"isComponent\":true}','object',NULL,NULL),(9,'plugin_content_manager_configuration_components::shared.key-value','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"key\",\"defaultSortBy\":\"key\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"key\":{\"edit\":{\"label\":\"key\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"key\",\"searchable\":true,\"sortable\":true}},\"value\":{\"edit\":{\"label\":\"value\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"value\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"key\",\"value\"],\"edit\":[[{\"name\":\"key\",\"size\":6},{\"name\":\"value\",\"size\":6}]]},\"uid\":\"shared.key-value\",\"isComponent\":true}','object',NULL,NULL),(10,'plugin_content_manager_configuration_components::shared.feature-card','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"icon\",\"defaultSortBy\":\"icon\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"icon\":{\"edit\":{\"label\":\"icon\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"icon\",\"searchable\":true,\"sortable\":true}},\"title\":{\"edit\":{\"label\":\"title\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"title\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":true,\"sortable\":true}},\"items\":{\"edit\":{\"label\":\"items\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"items\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"icon\",\"title\",\"description\"],\"edit\":[[{\"name\":\"icon\",\"size\":6},{\"name\":\"title\",\"size\":6}],[{\"name\":\"description\",\"size\":6}],[{\"name\":\"items\",\"size\":12}]]},\"uid\":\"shared.feature-card\",\"isComponent\":true}','object',NULL,NULL),(11,'plugin_content_manager_configuration_components::shared.api-endpoint','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"path\",\"defaultSortBy\":\"path\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"method\":{\"edit\":{\"label\":\"method\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"method\",\"searchable\":true,\"sortable\":true}},\"path\":{\"edit\":{\"label\":\"path\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"path\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":true,\"sortable\":true}},\"authRequired\":{\"edit\":{\"label\":\"authRequired\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"authRequired\",\"searchable\":true,\"sortable\":true}},\"rateLimit\":{\"edit\":{\"label\":\"rateLimit\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"rateLimit\",\"searchable\":true,\"sortable\":true}},\"queryParams\":{\"edit\":{\"label\":\"queryParams\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"queryParams\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"method\",\"path\",\"description\"],\"edit\":[[{\"name\":\"method\",\"size\":6},{\"name\":\"path\",\"size\":6}],[{\"name\":\"description\",\"size\":6},{\"name\":\"authRequired\",\"size\":4}],[{\"name\":\"rateLimit\",\"size\":6}],[{\"name\":\"queryParams\",\"size\":12}]]},\"uid\":\"shared.api-endpoint\",\"isComponent\":true}','object',NULL,NULL),(12,'plugin_content_manager_configuration_components::sections.tech-stack','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"heading\",\"defaultSortBy\":\"heading\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"heading\":{\"edit\":{\"label\":\"heading\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"heading\",\"searchable\":true,\"sortable\":true}},\"groups\":{\"edit\":{\"label\":\"groups\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"groups\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"heading\",\"groups\"],\"edit\":[[{\"name\":\"heading\",\"size\":6}],[{\"name\":\"groups\",\"size\":12}]]},\"uid\":\"sections.tech-stack\",\"isComponent\":true}','object',NULL,NULL),(13,'plugin_content_manager_configuration_components::sections.support-links','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"title\",\"defaultSortBy\":\"title\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"title\":{\"edit\":{\"label\":\"title\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"title\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":true,\"sortable\":true}},\"items\":{\"edit\":{\"label\":\"items\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"items\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"title\",\"description\",\"items\"],\"edit\":[[{\"name\":\"title\",\"size\":6},{\"name\":\"description\",\"size\":6}],[{\"name\":\"items\",\"size\":12}]]},\"uid\":\"sections.support-links\",\"isComponent\":true}','object',NULL,NULL),(14,'plugin_content_manager_configuration_components::sections.stats-bar','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"documentId\",\"defaultSortBy\":\"documentId\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"stats\":{\"edit\":{\"label\":\"stats\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"stats\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"stats\"],\"edit\":[[{\"name\":\"stats\",\"size\":12}]]},\"uid\":\"sections.stats-bar\",\"isComponent\":true}','object',NULL,NULL),(15,'plugin_content_manager_configuration_components::sections.rich-text','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"documentId\",\"defaultSortBy\":\"documentId\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"body\":{\"edit\":{\"label\":\"body\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"body\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\"],\"edit\":[[{\"name\":\"body\",\"size\":12}]]},\"uid\":\"sections.rich-text\",\"isComponent\":true}','object',NULL,NULL),(16,'plugin_content_manager_configuration_components::sections.quick-nav','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"heading\",\"defaultSortBy\":\"heading\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"heading\":{\"edit\":{\"label\":\"heading\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"heading\",\"searchable\":true,\"sortable\":true}},\"items\":{\"edit\":{\"label\":\"items\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"items\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"heading\",\"items\"],\"edit\":[[{\"name\":\"heading\",\"size\":6}],[{\"name\":\"items\",\"size\":12}]]},\"uid\":\"sections.quick-nav\",\"isComponent\":true}','object',NULL,NULL),(17,'plugin_content_manager_configuration_components::sections.open-source-info','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"title\",\"defaultSortBy\":\"title\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"title\":{\"edit\":{\"label\":\"title\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"title\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":false,\"sortable\":false}},\"links\":{\"edit\":{\"label\":\"links\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"links\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"title\",\"links\"],\"edit\":[[{\"name\":\"title\",\"size\":6}],[{\"name\":\"description\",\"size\":12}],[{\"name\":\"links\",\"size\":12}]]},\"uid\":\"sections.open-source-info\",\"isComponent\":true}','object',NULL,NULL),(18,'plugin_content_manager_configuration_components::sections.page-header','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"badge\",\"defaultSortBy\":\"badge\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"badge\":{\"edit\":{\"label\":\"badge\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"badge\",\"searchable\":true,\"sortable\":true}},\"title\":{\"edit\":{\"label\":\"title\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"title\",\"searchable\":true,\"sortable\":true}},\"subtitle\":{\"edit\":{\"label\":\"subtitle\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"subtitle\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"badge\",\"title\"],\"edit\":[[{\"name\":\"badge\",\"size\":6},{\"name\":\"title\",\"size\":6}],[{\"name\":\"subtitle\",\"size\":12}]]},\"uid\":\"sections.page-header\",\"isComponent\":true}','object',NULL,NULL),(19,'plugin_content_manager_configuration_components::sections.mission-block','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"title\",\"defaultSortBy\":\"title\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"title\":{\"edit\":{\"label\":\"title\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"title\",\"searchable\":true,\"sortable\":true}},\"content\":{\"edit\":{\"label\":\"content\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"content\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"title\"],\"edit\":[[{\"name\":\"title\",\"size\":6}],[{\"name\":\"content\",\"size\":12}]]},\"uid\":\"sections.mission-block\",\"isComponent\":true}','object',NULL,NULL),(20,'plugin_content_manager_configuration_components::sections.hero','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"heading\",\"defaultSortBy\":\"heading\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"heading\":{\"edit\":{\"label\":\"heading\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"heading\",\"searchable\":true,\"sortable\":true}},\"subheading\":{\"edit\":{\"label\":\"subheading\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"subheading\",\"searchable\":false,\"sortable\":false}},\"primaryCTA\":{\"edit\":{\"label\":\"primaryCTA\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"primaryCTA\",\"searchable\":false,\"sortable\":false}},\"secondaryCTA\":{\"edit\":{\"label\":\"secondaryCTA\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"secondaryCTA\",\"searchable\":false,\"sortable\":false}},\"backgroundImage\":{\"edit\":{\"label\":\"backgroundImage\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"backgroundImage\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"heading\",\"primaryCTA\",\"secondaryCTA\"],\"edit\":[[{\"name\":\"heading\",\"size\":6}],[{\"name\":\"subheading\",\"size\":12}],[{\"name\":\"primaryCTA\",\"size\":12}],[{\"name\":\"secondaryCTA\",\"size\":12}],[{\"name\":\"backgroundImage\",\"size\":6}]]},\"uid\":\"sections.hero\",\"isComponent\":true}','object',NULL,NULL),(21,'plugin_content_manager_configuration_components::sections.feature-grid','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"heading\",\"defaultSortBy\":\"heading\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"heading\":{\"edit\":{\"label\":\"heading\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"heading\",\"searchable\":true,\"sortable\":true}},\"columns\":{\"edit\":{\"label\":\"columns\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"columns\",\"searchable\":true,\"sortable\":true}},\"features\":{\"edit\":{\"label\":\"features\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"features\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"heading\",\"columns\",\"features\"],\"edit\":[[{\"name\":\"heading\",\"size\":6},{\"name\":\"columns\",\"size\":6}],[{\"name\":\"features\",\"size\":12}]]},\"uid\":\"sections.feature-grid\",\"isComponent\":true}','object',NULL,NULL),(22,'plugin_content_manager_configuration_components::sections.featured-patterns','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"heading\",\"defaultSortBy\":\"heading\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"heading\":{\"edit\":{\"label\":\"heading\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"heading\",\"searchable\":true,\"sortable\":true}},\"subheading\":{\"edit\":{\"label\":\"subheading\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"subheading\",\"searchable\":true,\"sortable\":true}},\"viewAllLabel\":{\"edit\":{\"label\":\"viewAllLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"viewAllLabel\",\"searchable\":true,\"sortable\":true}},\"mobileViewAllLabel\":{\"edit\":{\"label\":\"mobileViewAllLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"mobileViewAllLabel\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"heading\",\"subheading\",\"viewAllLabel\"],\"edit\":[[{\"name\":\"heading\",\"size\":6},{\"name\":\"subheading\",\"size\":6}],[{\"name\":\"viewAllLabel\",\"size\":6},{\"name\":\"mobileViewAllLabel\",\"size\":6}]]},\"uid\":\"sections.featured-patterns\",\"isComponent\":true}','object',NULL,NULL),(23,'plugin_content_manager_configuration_components::sections.doc-section','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"anchorId\",\"defaultSortBy\":\"anchorId\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"anchorId\":{\"edit\":{\"label\":\"anchorId\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"anchorId\",\"searchable\":true,\"sortable\":true}},\"title\":{\"edit\":{\"label\":\"title\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"title\",\"searchable\":true,\"sortable\":true}},\"content\":{\"edit\":{\"label\":\"content\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"content\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"anchorId\",\"title\"],\"edit\":[[{\"name\":\"anchorId\",\"size\":6},{\"name\":\"title\",\"size\":6}],[{\"name\":\"content\",\"size\":12}]]},\"uid\":\"sections.doc-section\",\"isComponent\":true}','object',NULL,NULL),(24,'plugin_content_manager_configuration_components::sections.cta-banner','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"heading\",\"defaultSortBy\":\"heading\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"heading\":{\"edit\":{\"label\":\"heading\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"heading\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":false,\"sortable\":false}},\"primaryCTA\":{\"edit\":{\"label\":\"primaryCTA\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"primaryCTA\",\"searchable\":false,\"sortable\":false}},\"secondaryCTA\":{\"edit\":{\"label\":\"secondaryCTA\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"secondaryCTA\",\"searchable\":false,\"sortable\":false}},\"variant\":{\"edit\":{\"label\":\"variant\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"variant\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"heading\",\"primaryCTA\",\"secondaryCTA\"],\"edit\":[[{\"name\":\"heading\",\"size\":6}],[{\"name\":\"description\",\"size\":12}],[{\"name\":\"primaryCTA\",\"size\":12}],[{\"name\":\"secondaryCTA\",\"size\":12}],[{\"name\":\"variant\",\"size\":6}]]},\"uid\":\"sections.cta-banner\",\"isComponent\":true}','object',NULL,NULL),(25,'plugin_content_manager_configuration_components::sections.contributing','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"title\",\"defaultSortBy\":\"title\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"title\":{\"edit\":{\"label\":\"title\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"title\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":true,\"sortable\":true}},\"howToTitle\":{\"edit\":{\"label\":\"howToTitle\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"howToTitle\",\"searchable\":true,\"sortable\":true}},\"steps\":{\"edit\":{\"label\":\"steps\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"steps\",\"searchable\":false,\"sortable\":false}},\"guidelinesTitle\":{\"edit\":{\"label\":\"guidelinesTitle\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"guidelinesTitle\",\"searchable\":true,\"sortable\":true}},\"guidelines\":{\"edit\":{\"label\":\"guidelines\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"guidelines\",\"searchable\":false,\"sortable\":false}},\"ctaButton\":{\"edit\":{\"label\":\"ctaButton\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"ctaButton\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"title\",\"description\",\"howToTitle\"],\"edit\":[[{\"name\":\"title\",\"size\":6},{\"name\":\"description\",\"size\":6}],[{\"name\":\"howToTitle\",\"size\":6}],[{\"name\":\"steps\",\"size\":12}],[{\"name\":\"guidelinesTitle\",\"size\":6}],[{\"name\":\"guidelines\",\"size\":12}],[{\"name\":\"ctaButton\",\"size\":12}]]},\"uid\":\"sections.contributing\",\"isComponent\":true}','object',NULL,NULL),(26,'plugin_content_manager_configuration_components::sections.api-reference','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"title\",\"defaultSortBy\":\"title\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"title\":{\"edit\":{\"label\":\"title\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"title\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":true,\"sortable\":true}},\"baseUrl\":{\"edit\":{\"label\":\"baseUrl\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"baseUrl\",\"searchable\":true,\"sortable\":true}},\"endpoints\":{\"edit\":{\"label\":\"endpoints\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"endpoints\",\"searchable\":false,\"sortable\":false}},\"exampleCode\":{\"edit\":{\"label\":\"exampleCode\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"exampleCode\",\"searchable\":false,\"sortable\":false}},\"swaggerNote\":{\"edit\":{\"label\":\"swaggerNote\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"swaggerNote\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"title\",\"description\",\"baseUrl\"],\"edit\":[[{\"name\":\"title\",\"size\":6},{\"name\":\"description\",\"size\":6}],[{\"name\":\"baseUrl\",\"size\":6}],[{\"name\":\"endpoints\",\"size\":12}],[{\"name\":\"exampleCode\",\"size\":12}],[{\"name\":\"swaggerNote\",\"size\":12}]]},\"uid\":\"sections.api-reference\",\"isComponent\":true}','object',NULL,NULL),(27,'plugin_content_manager_configuration_components::layout.cta-button','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"label\",\"defaultSortBy\":\"label\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"label\":{\"edit\":{\"label\":\"label\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"label\",\"searchable\":true,\"sortable\":true}},\"href\":{\"edit\":{\"label\":\"href\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"href\",\"searchable\":true,\"sortable\":true}},\"variant\":{\"edit\":{\"label\":\"variant\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"variant\",\"searchable\":true,\"sortable\":true}},\"icon\":{\"edit\":{\"label\":\"icon\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"icon\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"label\",\"href\",\"variant\"],\"edit\":[[{\"name\":\"label\",\"size\":6},{\"name\":\"href\",\"size\":6}],[{\"name\":\"variant\",\"size\":6},{\"name\":\"icon\",\"size\":6}]]},\"uid\":\"layout.cta-button\",\"isComponent\":true}','object',NULL,NULL),(28,'plugin_content_manager_configuration_components::layout.nav-link','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"label\",\"defaultSortBy\":\"label\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"label\":{\"edit\":{\"label\":\"label\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"label\",\"searchable\":true,\"sortable\":true}},\"href\":{\"edit\":{\"label\":\"href\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"href\",\"searchable\":true,\"sortable\":true}},\"icon\":{\"edit\":{\"label\":\"icon\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"icon\",\"searchable\":true,\"sortable\":true}},\"isExternal\":{\"edit\":{\"label\":\"isExternal\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"isExternal\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"label\",\"href\",\"icon\"],\"edit\":[[{\"name\":\"label\",\"size\":6},{\"name\":\"href\",\"size\":6}],[{\"name\":\"icon\",\"size\":6},{\"name\":\"isExternal\",\"size\":4}]]},\"uid\":\"layout.nav-link\",\"isComponent\":true}','object',NULL,NULL),(29,'plugin_content_manager_configuration_components::layout.footer-config','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"copyrightTemplate\",\"defaultSortBy\":\"copyrightTemplate\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":false,\"sortable\":false}},\"copyrightTemplate\":{\"edit\":{\"label\":\"copyrightTemplate\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"copyrightTemplate\",\"searchable\":true,\"sortable\":true}},\"links\":{\"edit\":{\"label\":\"links\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"links\",\"searchable\":false,\"sortable\":false}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"copyrightTemplate\",\"links\"],\"edit\":[[{\"name\":\"copyrightTemplate\",\"size\":6}],[{\"name\":\"links\",\"size\":12}]]},\"uid\":\"layout.footer-config\",\"isComponent\":true}','object',NULL,NULL),(30,'plugin_content_manager_configuration_content_types::plugin::content-releases.release-action','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"contentType\",\"defaultSortBy\":\"contentType\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"type\":{\"edit\":{\"label\":\"type\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"type\",\"searchable\":true,\"sortable\":true}},\"contentType\":{\"edit\":{\"label\":\"contentType\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"contentType\",\"searchable\":true,\"sortable\":true}},\"entryDocumentId\":{\"edit\":{\"label\":\"entryDocumentId\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"entryDocumentId\",\"searchable\":true,\"sortable\":true}},\"release\":{\"edit\":{\"label\":\"release\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"release\",\"searchable\":true,\"sortable\":true}},\"isEntryValid\":{\"edit\":{\"label\":\"isEntryValid\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"isEntryValid\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"type\",\"contentType\",\"entryDocumentId\"],\"edit\":[[{\"name\":\"type\",\"size\":6},{\"name\":\"contentType\",\"size\":6}],[{\"name\":\"entryDocumentId\",\"size\":6},{\"name\":\"release\",\"size\":6}],[{\"name\":\"isEntryValid\",\"size\":4}]]},\"uid\":\"plugin::content-releases.release-action\"}','object',NULL,NULL),(31,'plugin_content_manager_configuration_content_types::plugin::upload.folder','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"name\",\"defaultSortBy\":\"name\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"name\":{\"edit\":{\"label\":\"name\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"name\",\"searchable\":true,\"sortable\":true}},\"pathId\":{\"edit\":{\"label\":\"pathId\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"pathId\",\"searchable\":true,\"sortable\":true}},\"parent\":{\"edit\":{\"label\":\"parent\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"parent\",\"searchable\":true,\"sortable\":true}},\"children\":{\"edit\":{\"label\":\"children\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"children\",\"searchable\":false,\"sortable\":false}},\"files\":{\"edit\":{\"label\":\"files\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"files\",\"searchable\":false,\"sortable\":false}},\"path\":{\"edit\":{\"label\":\"path\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"path\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"name\",\"pathId\",\"parent\"],\"edit\":[[{\"name\":\"name\",\"size\":6},{\"name\":\"pathId\",\"size\":4}],[{\"name\":\"parent\",\"size\":6},{\"name\":\"children\",\"size\":6}],[{\"name\":\"files\",\"size\":6},{\"name\":\"path\",\"size\":6}]]},\"uid\":\"plugin::upload.folder\"}','object',NULL,NULL),(32,'plugin_content_manager_configuration_content_types::plugin::content-releases.release','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"name\",\"defaultSortBy\":\"name\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"name\":{\"edit\":{\"label\":\"name\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"name\",\"searchable\":true,\"sortable\":true}},\"releasedAt\":{\"edit\":{\"label\":\"releasedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"releasedAt\",\"searchable\":true,\"sortable\":true}},\"scheduledAt\":{\"edit\":{\"label\":\"scheduledAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"scheduledAt\",\"searchable\":true,\"sortable\":true}},\"timezone\":{\"edit\":{\"label\":\"timezone\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"timezone\",\"searchable\":true,\"sortable\":true}},\"status\":{\"edit\":{\"label\":\"status\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"status\",\"searchable\":true,\"sortable\":true}},\"actions\":{\"edit\":{\"label\":\"actions\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"contentType\"},\"list\":{\"label\":\"actions\",\"searchable\":false,\"sortable\":false}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"name\",\"releasedAt\",\"scheduledAt\"],\"edit\":[[{\"name\":\"name\",\"size\":6},{\"name\":\"releasedAt\",\"size\":6}],[{\"name\":\"scheduledAt\",\"size\":6},{\"name\":\"timezone\",\"size\":6}],[{\"name\":\"status\",\"size\":6},{\"name\":\"actions\",\"size\":6}]]},\"uid\":\"plugin::content-releases.release\"}','object',NULL,NULL),(33,'plugin_content_manager_configuration_content_types::plugin::upload.file','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"name\",\"defaultSortBy\":\"name\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"name\":{\"edit\":{\"label\":\"name\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"name\",\"searchable\":true,\"sortable\":true}},\"alternativeText\":{\"edit\":{\"label\":\"alternativeText\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"alternativeText\",\"searchable\":true,\"sortable\":true}},\"caption\":{\"edit\":{\"label\":\"caption\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"caption\",\"searchable\":true,\"sortable\":true}},\"focalPoint\":{\"edit\":{\"label\":\"focalPoint\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"focalPoint\",\"searchable\":false,\"sortable\":false}},\"width\":{\"edit\":{\"label\":\"width\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"width\",\"searchable\":true,\"sortable\":true}},\"height\":{\"edit\":{\"label\":\"height\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"height\",\"searchable\":true,\"sortable\":true}},\"formats\":{\"edit\":{\"label\":\"formats\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"formats\",\"searchable\":false,\"sortable\":false}},\"hash\":{\"edit\":{\"label\":\"hash\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"hash\",\"searchable\":true,\"sortable\":true}},\"ext\":{\"edit\":{\"label\":\"ext\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"ext\",\"searchable\":true,\"sortable\":true}},\"mime\":{\"edit\":{\"label\":\"mime\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"mime\",\"searchable\":true,\"sortable\":true}},\"size\":{\"edit\":{\"label\":\"size\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"size\",\"searchable\":true,\"sortable\":true}},\"url\":{\"edit\":{\"label\":\"url\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"url\",\"searchable\":true,\"sortable\":true}},\"previewUrl\":{\"edit\":{\"label\":\"previewUrl\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"previewUrl\",\"searchable\":true,\"sortable\":true}},\"provider\":{\"edit\":{\"label\":\"provider\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"provider\",\"searchable\":true,\"sortable\":true}},\"provider_metadata\":{\"edit\":{\"label\":\"provider_metadata\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"provider_metadata\",\"searchable\":false,\"sortable\":false}},\"folder\":{\"edit\":{\"label\":\"folder\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"folder\",\"searchable\":true,\"sortable\":true}},\"folderPath\":{\"edit\":{\"label\":\"folderPath\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"folderPath\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"name\",\"alternativeText\",\"caption\"],\"edit\":[[{\"name\":\"name\",\"size\":6},{\"name\":\"alternativeText\",\"size\":6}],[{\"name\":\"caption\",\"size\":6}],[{\"name\":\"focalPoint\",\"size\":12}],[{\"name\":\"width\",\"size\":4},{\"name\":\"height\",\"size\":4}],[{\"name\":\"formats\",\"size\":12}],[{\"name\":\"hash\",\"size\":6},{\"name\":\"ext\",\"size\":6}],[{\"name\":\"mime\",\"size\":6},{\"name\":\"size\",\"size\":4}],[{\"name\":\"url\",\"size\":6},{\"name\":\"previewUrl\",\"size\":6}],[{\"name\":\"provider\",\"size\":6}],[{\"name\":\"provider_metadata\",\"size\":12}],[{\"name\":\"folder\",\"size\":6},{\"name\":\"folderPath\",\"size\":6}]]},\"uid\":\"plugin::upload.file\"}','object',NULL,NULL),(34,'plugin_content_manager_configuration_content_types::plugin::users-permissions.user','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"username\",\"defaultSortBy\":\"username\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"username\":{\"edit\":{\"label\":\"username\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"username\",\"searchable\":true,\"sortable\":true}},\"email\":{\"edit\":{\"label\":\"email\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"email\",\"searchable\":true,\"sortable\":true}},\"provider\":{\"edit\":{\"label\":\"provider\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"provider\",\"searchable\":true,\"sortable\":true}},\"password\":{\"edit\":{\"label\":\"password\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"password\",\"searchable\":true,\"sortable\":true}},\"resetPasswordToken\":{\"edit\":{\"label\":\"resetPasswordToken\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"resetPasswordToken\",\"searchable\":true,\"sortable\":true}},\"confirmationToken\":{\"edit\":{\"label\":\"confirmationToken\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"confirmationToken\",\"searchable\":true,\"sortable\":true}},\"confirmed\":{\"edit\":{\"label\":\"confirmed\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"confirmed\",\"searchable\":true,\"sortable\":true}},\"blocked\":{\"edit\":{\"label\":\"blocked\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"blocked\",\"searchable\":true,\"sortable\":true}},\"role\":{\"edit\":{\"label\":\"role\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"role\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"username\",\"email\",\"confirmed\"],\"edit\":[[{\"name\":\"username\",\"size\":6},{\"name\":\"email\",\"size\":6}],[{\"name\":\"password\",\"size\":6},{\"name\":\"confirmed\",\"size\":4}],[{\"name\":\"blocked\",\"size\":4},{\"name\":\"role\",\"size\":6}]]},\"uid\":\"plugin::users-permissions.user\"}','object',NULL,NULL),(35,'plugin_content_manager_configuration_content_types::plugin::i18n.locale','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"name\",\"defaultSortBy\":\"name\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"name\":{\"edit\":{\"label\":\"name\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"name\",\"searchable\":true,\"sortable\":true}},\"code\":{\"edit\":{\"label\":\"code\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"code\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"name\",\"code\",\"createdAt\"],\"edit\":[[{\"name\":\"name\",\"size\":6},{\"name\":\"code\",\"size\":6}]]},\"uid\":\"plugin::i18n.locale\"}','object',NULL,NULL),(36,'plugin_content_manager_configuration_content_types::plugin::users-permissions.permission','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"action\",\"defaultSortBy\":\"action\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"action\":{\"edit\":{\"label\":\"action\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"action\",\"searchable\":true,\"sortable\":true}},\"role\":{\"edit\":{\"label\":\"role\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"role\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"action\",\"role\",\"createdAt\"],\"edit\":[[{\"name\":\"action\",\"size\":6},{\"name\":\"role\",\"size\":6}]]},\"uid\":\"plugin::users-permissions.permission\"}','object',NULL,NULL),(37,'plugin_content_manager_configuration_content_types::plugin::review-workflows.workflow','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"name\",\"defaultSortBy\":\"name\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"name\":{\"edit\":{\"label\":\"name\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"name\",\"searchable\":true,\"sortable\":true}},\"stages\":{\"edit\":{\"label\":\"stages\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"stages\",\"searchable\":false,\"sortable\":false}},\"stageRequiredToPublish\":{\"edit\":{\"label\":\"stageRequiredToPublish\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"stageRequiredToPublish\",\"searchable\":true,\"sortable\":true}},\"contentTypes\":{\"edit\":{\"label\":\"contentTypes\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"contentTypes\",\"searchable\":false,\"sortable\":false}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"name\",\"stages\",\"stageRequiredToPublish\"],\"edit\":[[{\"name\":\"name\",\"size\":6},{\"name\":\"stages\",\"size\":6}],[{\"name\":\"stageRequiredToPublish\",\"size\":6}],[{\"name\":\"contentTypes\",\"size\":12}]]},\"uid\":\"plugin::review-workflows.workflow\"}','object',NULL,NULL),(38,'plugin_content_manager_configuration_content_types::plugin::users-permissions.role','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"name\",\"defaultSortBy\":\"name\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"name\":{\"edit\":{\"label\":\"name\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"name\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":true,\"sortable\":true}},\"type\":{\"edit\":{\"label\":\"type\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"type\",\"searchable\":true,\"sortable\":true}},\"permissions\":{\"edit\":{\"label\":\"permissions\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"action\"},\"list\":{\"label\":\"permissions\",\"searchable\":false,\"sortable\":false}},\"users\":{\"edit\":{\"label\":\"users\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"username\"},\"list\":{\"label\":\"users\",\"searchable\":false,\"sortable\":false}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"name\",\"description\",\"type\"],\"edit\":[[{\"name\":\"name\",\"size\":6},{\"name\":\"description\",\"size\":6}],[{\"name\":\"type\",\"size\":6},{\"name\":\"permissions\",\"size\":6}],[{\"name\":\"users\",\"size\":6}]]},\"uid\":\"plugin::users-permissions.role\"}','object',NULL,NULL),(39,'plugin_content_manager_configuration_content_types::plugin::review-workflows.workflow-stage','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"name\",\"defaultSortBy\":\"name\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"name\":{\"edit\":{\"label\":\"name\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"name\",\"searchable\":true,\"sortable\":true}},\"color\":{\"edit\":{\"label\":\"color\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"color\",\"searchable\":true,\"sortable\":true}},\"workflow\":{\"edit\":{\"label\":\"workflow\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"workflow\",\"searchable\":true,\"sortable\":true}},\"permissions\":{\"edit\":{\"label\":\"permissions\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"action\"},\"list\":{\"label\":\"permissions\",\"searchable\":false,\"sortable\":false}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"name\",\"color\",\"workflow\"],\"edit\":[[{\"name\":\"name\",\"size\":6},{\"name\":\"color\",\"size\":6}],[{\"name\":\"workflow\",\"size\":6},{\"name\":\"permissions\",\"size\":6}]]},\"uid\":\"plugin::review-workflows.workflow-stage\"}','object',NULL,NULL),(40,'plugin_content_manager_configuration_content_types::api::about-page.about-page','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"documentId\",\"defaultSortBy\":\"documentId\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"seo\":{\"edit\":{\"label\":\"seo\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"seo\",\"searchable\":false,\"sortable\":false}},\"header\":{\"edit\":{\"label\":\"header\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"header\",\"searchable\":false,\"sortable\":false}},\"content\":{\"edit\":{\"label\":\"content\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"content\",\"searchable\":false,\"sortable\":false}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"seo\",\"header\",\"createdAt\"],\"edit\":[[{\"name\":\"seo\",\"size\":12}],[{\"name\":\"header\",\"size\":12}],[{\"name\":\"content\",\"size\":12}]]},\"uid\":\"api::about-page.about-page\"}','object',NULL,NULL),(41,'plugin_content_manager_configuration_content_types::api::docs-page.docs-page','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"documentId\",\"defaultSortBy\":\"documentId\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"seo\":{\"edit\":{\"label\":\"seo\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"seo\",\"searchable\":false,\"sortable\":false}},\"header\":{\"edit\":{\"label\":\"header\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"header\",\"searchable\":false,\"sortable\":false}},\"content\":{\"edit\":{\"label\":\"content\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"content\",\"searchable\":false,\"sortable\":false}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"seo\",\"header\",\"createdAt\"],\"edit\":[[{\"name\":\"seo\",\"size\":12}],[{\"name\":\"header\",\"size\":12}],[{\"name\":\"content\",\"size\":12}]]},\"uid\":\"api::docs-page.docs-page\"}','object',NULL,NULL),(42,'plugin_content_manager_configuration_content_types::api::error-page.error-page','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"title\",\"defaultSortBy\":\"title\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"title\":{\"edit\":{\"label\":\"title\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"title\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":true,\"sortable\":true}},\"retryButtonLabel\":{\"edit\":{\"label\":\"retryButtonLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"retryButtonLabel\",\"searchable\":true,\"sortable\":true}},\"homeButtonLabel\":{\"edit\":{\"label\":\"homeButtonLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"homeButtonLabel\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"title\",\"description\",\"retryButtonLabel\"],\"edit\":[[{\"name\":\"title\",\"size\":6},{\"name\":\"description\",\"size\":6}],[{\"name\":\"retryButtonLabel\",\"size\":6},{\"name\":\"homeButtonLabel\",\"size\":6}]]},\"uid\":\"api::error-page.error-page\"}','object',NULL,NULL),(43,'plugin_content_manager_configuration_content_types::api::home-page.home-page','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"documentId\",\"defaultSortBy\":\"documentId\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"seo\":{\"edit\":{\"label\":\"seo\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"seo\",\"searchable\":false,\"sortable\":false}},\"content\":{\"edit\":{\"label\":\"content\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"content\",\"searchable\":false,\"sortable\":false}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"seo\",\"createdAt\",\"updatedAt\"],\"edit\":[[{\"name\":\"seo\",\"size\":12}],[{\"name\":\"content\",\"size\":12}]]},\"uid\":\"api::home-page.home-page\"}','object',NULL,NULL),(44,'plugin_content_manager_configuration_content_types::api::global.global','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"siteName\",\"defaultSortBy\":\"siteName\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"siteName\":{\"edit\":{\"label\":\"siteName\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"siteName\",\"searchable\":true,\"sortable\":true}},\"siteDescription\":{\"edit\":{\"label\":\"siteDescription\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"siteDescription\",\"searchable\":true,\"sortable\":true}},\"logo\":{\"edit\":{\"label\":\"logo\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"logo\",\"searchable\":false,\"sortable\":false}},\"navigation\":{\"edit\":{\"label\":\"navigation\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"navigation\",\"searchable\":false,\"sortable\":false}},\"mobileMenuTitle\":{\"edit\":{\"label\":\"mobileMenuTitle\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"mobileMenuTitle\",\"searchable\":true,\"sortable\":true}},\"skipToContentLabel\":{\"edit\":{\"label\":\"skipToContentLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"skipToContentLabel\",\"searchable\":true,\"sortable\":true}},\"signInLabel\":{\"edit\":{\"label\":\"signInLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"signInLabel\",\"searchable\":true,\"sortable\":true}},\"signOutLabel\":{\"edit\":{\"label\":\"signOutLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"signOutLabel\",\"searchable\":true,\"sortable\":true}},\"userMenuLabel\":{\"edit\":{\"label\":\"userMenuLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"userMenuLabel\",\"searchable\":true,\"sortable\":true}},\"newPatternButtonLabel\":{\"edit\":{\"label\":\"newPatternButtonLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"newPatternButtonLabel\",\"searchable\":true,\"sortable\":true}},\"footer\":{\"edit\":{\"label\":\"footer\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"footer\",\"searchable\":false,\"sortable\":false}},\"defaultSeo\":{\"edit\":{\"label\":\"defaultSeo\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"defaultSeo\",\"searchable\":false,\"sortable\":false}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"siteName\",\"siteDescription\",\"logo\"],\"edit\":[[{\"name\":\"siteName\",\"size\":6},{\"name\":\"siteDescription\",\"size\":6}],[{\"name\":\"logo\",\"size\":6}],[{\"name\":\"navigation\",\"size\":12}],[{\"name\":\"mobileMenuTitle\",\"size\":6},{\"name\":\"skipToContentLabel\",\"size\":6}],[{\"name\":\"signInLabel\",\"size\":6},{\"name\":\"signOutLabel\",\"size\":6}],[{\"name\":\"userMenuLabel\",\"size\":6},{\"name\":\"newPatternButtonLabel\",\"size\":6}],[{\"name\":\"footer\",\"size\":12}],[{\"name\":\"defaultSeo\",\"size\":12}]]},\"uid\":\"api::global.global\"}','object',NULL,NULL),(45,'plugin_content_manager_configuration_content_types::api::login-page.login-page','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"cardTitle\",\"defaultSortBy\":\"cardTitle\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"seo\":{\"edit\":{\"label\":\"seo\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"seo\",\"searchable\":false,\"sortable\":false}},\"cardTitle\":{\"edit\":{\"label\":\"cardTitle\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"cardTitle\",\"searchable\":true,\"sortable\":true}},\"cardDescription\":{\"edit\":{\"label\":\"cardDescription\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"cardDescription\",\"searchable\":true,\"sortable\":true}},\"signInButtonLabel\":{\"edit\":{\"label\":\"signInButtonLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"signInButtonLabel\",\"searchable\":true,\"sortable\":true}},\"signInLoadingLabel\":{\"edit\":{\"label\":\"signInLoadingLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"signInLoadingLabel\",\"searchable\":true,\"sortable\":true}},\"footerNotice\":{\"edit\":{\"label\":\"footerNotice\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"footerNotice\",\"searchable\":false,\"sortable\":false}},\"errorMessages\":{\"edit\":{\"label\":\"errorMessages\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"errorMessages\",\"searchable\":false,\"sortable\":false}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"seo\",\"cardTitle\",\"cardDescription\"],\"edit\":[[{\"name\":\"seo\",\"size\":12}],[{\"name\":\"cardTitle\",\"size\":6},{\"name\":\"cardDescription\",\"size\":6}],[{\"name\":\"signInButtonLabel\",\"size\":6},{\"name\":\"signInLoadingLabel\",\"size\":6}],[{\"name\":\"footerNotice\",\"size\":12}],[{\"name\":\"errorMessages\",\"size\":12}]]},\"uid\":\"api::login-page.login-page\"}','object',NULL,NULL),(46,'plugin_content_manager_configuration_content_types::api::not-found-page.not-found-page','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"errorCode\",\"defaultSortBy\":\"errorCode\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"errorCode\":{\"edit\":{\"label\":\"errorCode\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"errorCode\",\"searchable\":true,\"sortable\":true}},\"heading\":{\"edit\":{\"label\":\"heading\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"heading\",\"searchable\":true,\"sortable\":true}},\"message\":{\"edit\":{\"label\":\"message\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"message\",\"searchable\":true,\"sortable\":true}},\"backButton\":{\"edit\":{\"label\":\"backButton\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"backButton\",\"searchable\":false,\"sortable\":false}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"errorCode\",\"heading\",\"message\"],\"edit\":[[{\"name\":\"errorCode\",\"size\":6},{\"name\":\"heading\",\"size\":6}],[{\"name\":\"message\",\"size\":6}],[{\"name\":\"backButton\",\"size\":12}]]},\"uid\":\"api::not-found-page.not-found-page\"}','object',NULL,NULL),(47,'plugin_content_manager_configuration_content_types::api::pattern-detail-labels.pattern-detail-labels','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"breadcrumbAriaLabel\",\"defaultSortBy\":\"breadcrumbAriaLabel\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"breadcrumbAriaLabel\":{\"edit\":{\"label\":\"breadcrumbAriaLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"breadcrumbAriaLabel\",\"searchable\":true,\"sortable\":true}},\"voteAriaTemplate\":{\"edit\":{\"label\":\"voteAriaTemplate\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"voteAriaTemplate\",\"searchable\":true,\"sortable\":true}},\"votesLabel\":{\"edit\":{\"label\":\"votesLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"votesLabel\",\"searchable\":true,\"sortable\":true}},\"voteAnnouncementTemplate\":{\"edit\":{\"label\":\"voteAnnouncementTemplate\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"voteAnnouncementTemplate\",\"searchable\":true,\"sortable\":true}},\"noContentMessage\":{\"edit\":{\"label\":\"noContentMessage\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"noContentMessage\",\"searchable\":true,\"sortable\":true}},\"relatedPatternsTitle\":{\"edit\":{\"label\":\"relatedPatternsTitle\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"relatedPatternsTitle\",\"searchable\":true,\"sortable\":true}},\"noRelatedMessage\":{\"edit\":{\"label\":\"noRelatedMessage\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"noRelatedMessage\",\"searchable\":true,\"sortable\":true}},\"editLabel\":{\"edit\":{\"label\":\"editLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"editLabel\",\"searchable\":true,\"sortable\":true}},\"deleteLabel\":{\"edit\":{\"label\":\"deleteLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"deleteLabel\",\"searchable\":true,\"sortable\":true}},\"deleteDialogTitle\":{\"edit\":{\"label\":\"deleteDialogTitle\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"deleteDialogTitle\",\"searchable\":true,\"sortable\":true}},\"deleteDialogDescription\":{\"edit\":{\"label\":\"deleteDialogDescription\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"deleteDialogDescription\",\"searchable\":true,\"sortable\":true}},\"cancelLabel\":{\"edit\":{\"label\":\"cancelLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"cancelLabel\",\"searchable\":true,\"sortable\":true}},\"deleteConfirmLabel\":{\"edit\":{\"label\":\"deleteConfirmLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"deleteConfirmLabel\",\"searchable\":true,\"sortable\":true}},\"deletingLabel\":{\"edit\":{\"label\":\"deletingLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"deletingLabel\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"breadcrumbAriaLabel\",\"voteAriaTemplate\",\"votesLabel\"],\"edit\":[[{\"name\":\"breadcrumbAriaLabel\",\"size\":6},{\"name\":\"voteAriaTemplate\",\"size\":6}],[{\"name\":\"votesLabel\",\"size\":6},{\"name\":\"voteAnnouncementTemplate\",\"size\":6}],[{\"name\":\"noContentMessage\",\"size\":6},{\"name\":\"relatedPatternsTitle\",\"size\":6}],[{\"name\":\"noRelatedMessage\",\"size\":6},{\"name\":\"editLabel\",\"size\":6}],[{\"name\":\"deleteLabel\",\"size\":6},{\"name\":\"deleteDialogTitle\",\"size\":6}],[{\"name\":\"deleteDialogDescription\",\"size\":6},{\"name\":\"cancelLabel\",\"size\":6}],[{\"name\":\"deleteConfirmLabel\",\"size\":6},{\"name\":\"deletingLabel\",\"size\":6}]]},\"uid\":\"api::pattern-detail-labels.pattern-detail-labels\"}','object',NULL,NULL),(48,'plugin_content_manager_configuration_content_types::api::pattern-form-labels.pattern-form-labels','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"createTitle\",\"defaultSortBy\":\"createTitle\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"createTitle\":{\"edit\":{\"label\":\"createTitle\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"createTitle\",\"searchable\":true,\"sortable\":true}},\"editTitle\":{\"edit\":{\"label\":\"editTitle\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"editTitle\",\"searchable\":true,\"sortable\":true}},\"titleLabel\":{\"edit\":{\"label\":\"titleLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"titleLabel\",\"searchable\":true,\"sortable\":true}},\"titlePlaceholder\":{\"edit\":{\"label\":\"titlePlaceholder\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"titlePlaceholder\",\"searchable\":true,\"sortable\":true}},\"slugPreviewTemplate\":{\"edit\":{\"label\":\"slugPreviewTemplate\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"slugPreviewTemplate\",\"searchable\":true,\"sortable\":true}},\"shortDescLabel\":{\"edit\":{\"label\":\"shortDescLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"shortDescLabel\",\"searchable\":true,\"sortable\":true}},\"shortDescPlaceholder\":{\"edit\":{\"label\":\"shortDescPlaceholder\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"shortDescPlaceholder\",\"searchable\":true,\"sortable\":true}},\"categoryLabel\":{\"edit\":{\"label\":\"categoryLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"categoryLabel\",\"searchable\":true,\"sortable\":true}},\"categoryPlaceholder\":{\"edit\":{\"label\":\"categoryPlaceholder\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"categoryPlaceholder\",\"searchable\":true,\"sortable\":true}},\"tagsLabel\":{\"edit\":{\"label\":\"tagsLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"tagsLabel\",\"searchable\":true,\"sortable\":true}},\"tagPlaceholder\":{\"edit\":{\"label\":\"tagPlaceholder\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"tagPlaceholder\",\"searchable\":true,\"sortable\":true}},\"addTagLabel\":{\"edit\":{\"label\":\"addTagLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"addTagLabel\",\"searchable\":true,\"sortable\":true}},\"tagCountTemplate\":{\"edit\":{\"label\":\"tagCountTemplate\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"tagCountTemplate\",\"searchable\":true,\"sortable\":true}},\"contentLabel\":{\"edit\":{\"label\":\"contentLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"contentLabel\",\"searchable\":true,\"sortable\":true}},\"contentPlaceholder\":{\"edit\":{\"label\":\"contentPlaceholder\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"contentPlaceholder\",\"searchable\":true,\"sortable\":true}},\"authorLabel\":{\"edit\":{\"label\":\"authorLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"authorLabel\",\"searchable\":true,\"sortable\":true}},\"authorPlaceholder\":{\"edit\":{\"label\":\"authorPlaceholder\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"authorPlaceholder\",\"searchable\":true,\"sortable\":true}},\"adminSettingsLabel\":{\"edit\":{\"label\":\"adminSettingsLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"adminSettingsLabel\",\"searchable\":true,\"sortable\":true}},\"featuredLabel\":{\"edit\":{\"label\":\"featuredLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"featuredLabel\",\"searchable\":true,\"sortable\":true}},\"trendingLabel\":{\"edit\":{\"label\":\"trendingLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"trendingLabel\",\"searchable\":true,\"sortable\":true}},\"cancelLabel\":{\"edit\":{\"label\":\"cancelLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"cancelLabel\",\"searchable\":true,\"sortable\":true}},\"createLabel\":{\"edit\":{\"label\":\"createLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"createLabel\",\"searchable\":true,\"sortable\":true}},\"creatingLabel\":{\"edit\":{\"label\":\"creatingLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"creatingLabel\",\"searchable\":true,\"sortable\":true}},\"saveLabel\":{\"edit\":{\"label\":\"saveLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"saveLabel\",\"searchable\":true,\"sortable\":true}},\"savingLabel\":{\"edit\":{\"label\":\"savingLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"savingLabel\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"createTitle\",\"editTitle\",\"titleLabel\"],\"edit\":[[{\"name\":\"createTitle\",\"size\":6},{\"name\":\"editTitle\",\"size\":6}],[{\"name\":\"titleLabel\",\"size\":6},{\"name\":\"titlePlaceholder\",\"size\":6}],[{\"name\":\"slugPreviewTemplate\",\"size\":6},{\"name\":\"shortDescLabel\",\"size\":6}],[{\"name\":\"shortDescPlaceholder\",\"size\":6},{\"name\":\"categoryLabel\",\"size\":6}],[{\"name\":\"categoryPlaceholder\",\"size\":6},{\"name\":\"tagsLabel\",\"size\":6}],[{\"name\":\"tagPlaceholder\",\"size\":6},{\"name\":\"addTagLabel\",\"size\":6}],[{\"name\":\"tagCountTemplate\",\"size\":6},{\"name\":\"contentLabel\",\"size\":6}],[{\"name\":\"contentPlaceholder\",\"size\":6},{\"name\":\"authorLabel\",\"size\":6}],[{\"name\":\"authorPlaceholder\",\"size\":6},{\"name\":\"adminSettingsLabel\",\"size\":6}],[{\"name\":\"featuredLabel\",\"size\":6},{\"name\":\"trendingLabel\",\"size\":6}],[{\"name\":\"cancelLabel\",\"size\":6},{\"name\":\"createLabel\",\"size\":6}],[{\"name\":\"creatingLabel\",\"size\":6},{\"name\":\"saveLabel\",\"size\":6}],[{\"name\":\"savingLabel\",\"size\":6}]]},\"uid\":\"api::pattern-form-labels.pattern-form-labels\"}','object',NULL,NULL),(49,'plugin_content_manager_configuration_content_types::api::pattern-listing-labels.pattern-listing-labels','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"pageTitle\",\"defaultSortBy\":\"pageTitle\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"pageTitle\":{\"edit\":{\"label\":\"pageTitle\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"pageTitle\",\"searchable\":true,\"sortable\":true}},\"pageDescription\":{\"edit\":{\"label\":\"pageDescription\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"pageDescription\",\"searchable\":true,\"sortable\":true}},\"searchPlaceholder\":{\"edit\":{\"label\":\"searchPlaceholder\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"searchPlaceholder\",\"searchable\":true,\"sortable\":true}},\"clearSearchLabel\":{\"edit\":{\"label\":\"clearSearchLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"clearSearchLabel\",\"searchable\":true,\"sortable\":true}},\"sortByLabel\":{\"edit\":{\"label\":\"sortByLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"sortByLabel\",\"searchable\":true,\"sortable\":true}},\"sortOptions\":{\"edit\":{\"label\":\"sortOptions\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"sortOptions\",\"searchable\":false,\"sortable\":false}},\"filterSectionHeader\":{\"edit\":{\"label\":\"filterSectionHeader\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"filterSectionHeader\",\"searchable\":true,\"sortable\":true}},\"clearAllLabel\":{\"edit\":{\"label\":\"clearAllLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"clearAllLabel\",\"searchable\":true,\"sortable\":true}},\"categoryLabel\":{\"edit\":{\"label\":\"categoryLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"categoryLabel\",\"searchable\":true,\"sortable\":true}},\"allCategoriesLabel\":{\"edit\":{\"label\":\"allCategoriesLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"allCategoriesLabel\",\"searchable\":true,\"sortable\":true}},\"tagsLabel\":{\"edit\":{\"label\":\"tagsLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"tagsLabel\",\"searchable\":true,\"sortable\":true}},\"tagModeLabel\":{\"edit\":{\"label\":\"tagModeLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"tagModeLabel\",\"searchable\":true,\"sortable\":true}},\"anyLabel\":{\"edit\":{\"label\":\"anyLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"anyLabel\",\"searchable\":true,\"sortable\":true}},\"allLabel\":{\"edit\":{\"label\":\"allLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"allLabel\",\"searchable\":true,\"sortable\":true}},\"dateRangeHeader\":{\"edit\":{\"label\":\"dateRangeHeader\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"dateRangeHeader\",\"searchable\":true,\"sortable\":true}},\"clearDatesLabel\":{\"edit\":{\"label\":\"clearDatesLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"clearDatesLabel\",\"searchable\":true,\"sortable\":true}},\"fromLabel\":{\"edit\":{\"label\":\"fromLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"fromLabel\",\"searchable\":true,\"sortable\":true}},\"toLabel\":{\"edit\":{\"label\":\"toLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"toLabel\",\"searchable\":true,\"sortable\":true}},\"activeFiltersLabel\":{\"edit\":{\"label\":\"activeFiltersLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"activeFiltersLabel\",\"searchable\":true,\"sortable\":true}},\"filtersButtonLabel\":{\"edit\":{\"label\":\"filtersButtonLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"filtersButtonLabel\",\"searchable\":true,\"sortable\":true}},\"filterSheetTitle\":{\"edit\":{\"label\":\"filterSheetTitle\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"filterSheetTitle\",\"searchable\":true,\"sortable\":true}},\"filterSheetDescription\":{\"edit\":{\"label\":\"filterSheetDescription\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"filterSheetDescription\",\"searchable\":true,\"sortable\":true}},\"savedSearchesHeader\":{\"edit\":{\"label\":\"savedSearchesHeader\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"savedSearchesHeader\",\"searchable\":true,\"sortable\":true}},\"saveCurrentLabel\":{\"edit\":{\"label\":\"saveCurrentLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"saveCurrentLabel\",\"searchable\":true,\"sortable\":true}},\"saveDialogTitle\":{\"edit\":{\"label\":\"saveDialogTitle\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"saveDialogTitle\",\"searchable\":true,\"sortable\":true}},\"saveDialogDescription\":{\"edit\":{\"label\":\"saveDialogDescription\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"saveDialogDescription\",\"searchable\":true,\"sortable\":true}},\"searchNameLabel\":{\"edit\":{\"label\":\"searchNameLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"searchNameLabel\",\"searchable\":true,\"sortable\":true}},\"searchNamePlaceholder\":{\"edit\":{\"label\":\"searchNamePlaceholder\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"searchNamePlaceholder\",\"searchable\":true,\"sortable\":true}},\"cancelLabel\":{\"edit\":{\"label\":\"cancelLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"cancelLabel\",\"searchable\":true,\"sortable\":true}},\"saveLabel\":{\"edit\":{\"label\":\"saveLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"saveLabel\",\"searchable\":true,\"sortable\":true}},\"recentlyViewedHeader\":{\"edit\":{\"label\":\"recentlyViewedHeader\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"recentlyViewedHeader\",\"searchable\":true,\"sortable\":true}},\"clearLabel\":{\"edit\":{\"label\":\"clearLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"clearLabel\",\"searchable\":true,\"sortable\":true}},\"previousLabel\":{\"edit\":{\"label\":\"previousLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"previousLabel\",\"searchable\":true,\"sortable\":true}},\"nextLabel\":{\"edit\":{\"label\":\"nextLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"nextLabel\",\"searchable\":true,\"sortable\":true}},\"emptyFilteredHeading\":{\"edit\":{\"label\":\"emptyFilteredHeading\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"emptyFilteredHeading\",\"searchable\":true,\"sortable\":true}},\"emptyUnfilteredHeading\":{\"edit\":{\"label\":\"emptyUnfilteredHeading\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"emptyUnfilteredHeading\",\"searchable\":true,\"sortable\":true}},\"emptyFilteredDescription\":{\"edit\":{\"label\":\"emptyFilteredDescription\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"emptyFilteredDescription\",\"searchable\":true,\"sortable\":true}},\"emptyUnfilteredDescription\":{\"edit\":{\"label\":\"emptyUnfilteredDescription\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"emptyUnfilteredDescription\",\"searchable\":true,\"sortable\":true}},\"clearFiltersLabel\":{\"edit\":{\"label\":\"clearFiltersLabel\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"clearFiltersLabel\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"pageTitle\",\"pageDescription\",\"searchPlaceholder\"],\"edit\":[[{\"name\":\"pageTitle\",\"size\":6},{\"name\":\"pageDescription\",\"size\":6}],[{\"name\":\"searchPlaceholder\",\"size\":6},{\"name\":\"clearSearchLabel\",\"size\":6}],[{\"name\":\"sortByLabel\",\"size\":6}],[{\"name\":\"sortOptions\",\"size\":12}],[{\"name\":\"filterSectionHeader\",\"size\":6},{\"name\":\"clearAllLabel\",\"size\":6}],[{\"name\":\"categoryLabel\",\"size\":6},{\"name\":\"allCategoriesLabel\",\"size\":6}],[{\"name\":\"tagsLabel\",\"size\":6},{\"name\":\"tagModeLabel\",\"size\":6}],[{\"name\":\"anyLabel\",\"size\":6},{\"name\":\"allLabel\",\"size\":6}],[{\"name\":\"dateRangeHeader\",\"size\":6},{\"name\":\"clearDatesLabel\",\"size\":6}],[{\"name\":\"fromLabel\",\"size\":6},{\"name\":\"toLabel\",\"size\":6}],[{\"name\":\"activeFiltersLabel\",\"size\":6},{\"name\":\"filtersButtonLabel\",\"size\":6}],[{\"name\":\"filterSheetTitle\",\"size\":6},{\"name\":\"filterSheetDescription\",\"size\":6}],[{\"name\":\"savedSearchesHeader\",\"size\":6},{\"name\":\"saveCurrentLabel\",\"size\":6}],[{\"name\":\"saveDialogTitle\",\"size\":6},{\"name\":\"saveDialogDescription\",\"size\":6}],[{\"name\":\"searchNameLabel\",\"size\":6},{\"name\":\"searchNamePlaceholder\",\"size\":6}],[{\"name\":\"cancelLabel\",\"size\":6},{\"name\":\"saveLabel\",\"size\":6}],[{\"name\":\"recentlyViewedHeader\",\"size\":6},{\"name\":\"clearLabel\",\"size\":6}],[{\"name\":\"previousLabel\",\"size\":6},{\"name\":\"nextLabel\",\"size\":6}],[{\"name\":\"emptyFilteredHeading\",\"size\":6},{\"name\":\"emptyUnfilteredHeading\",\"size\":6}],[{\"name\":\"emptyFilteredDescription\",\"size\":6},{\"name\":\"emptyUnfilteredDescription\",\"size\":6}],[{\"name\":\"clearFiltersLabel\",\"size\":6}]]},\"uid\":\"api::pattern-listing-labels.pattern-listing-labels\"}','object',NULL,NULL),(50,'plugin_content_manager_configuration_content_types::admin::permission','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"action\",\"defaultSortBy\":\"action\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"action\":{\"edit\":{\"label\":\"action\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"action\",\"searchable\":true,\"sortable\":true}},\"actionParameters\":{\"edit\":{\"label\":\"actionParameters\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"actionParameters\",\"searchable\":false,\"sortable\":false}},\"subject\":{\"edit\":{\"label\":\"subject\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"subject\",\"searchable\":true,\"sortable\":true}},\"properties\":{\"edit\":{\"label\":\"properties\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"properties\",\"searchable\":false,\"sortable\":false}},\"conditions\":{\"edit\":{\"label\":\"conditions\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"conditions\",\"searchable\":false,\"sortable\":false}},\"role\":{\"edit\":{\"label\":\"role\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"role\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"action\",\"subject\",\"role\"],\"edit\":[[{\"name\":\"action\",\"size\":6}],[{\"name\":\"actionParameters\",\"size\":12}],[{\"name\":\"subject\",\"size\":6}],[{\"name\":\"properties\",\"size\":12}],[{\"name\":\"conditions\",\"size\":12}],[{\"name\":\"role\",\"size\":6}]]},\"uid\":\"admin::permission\"}','object',NULL,NULL),(51,'plugin_content_manager_configuration_content_types::admin::user','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"firstname\",\"defaultSortBy\":\"firstname\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"firstname\":{\"edit\":{\"label\":\"firstname\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"firstname\",\"searchable\":true,\"sortable\":true}},\"lastname\":{\"edit\":{\"label\":\"lastname\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"lastname\",\"searchable\":true,\"sortable\":true}},\"username\":{\"edit\":{\"label\":\"username\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"username\",\"searchable\":true,\"sortable\":true}},\"email\":{\"edit\":{\"label\":\"email\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"email\",\"searchable\":true,\"sortable\":true}},\"password\":{\"edit\":{\"label\":\"password\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"password\",\"searchable\":true,\"sortable\":true}},\"resetPasswordToken\":{\"edit\":{\"label\":\"resetPasswordToken\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"resetPasswordToken\",\"searchable\":true,\"sortable\":true}},\"registrationToken\":{\"edit\":{\"label\":\"registrationToken\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"registrationToken\",\"searchable\":true,\"sortable\":true}},\"isActive\":{\"edit\":{\"label\":\"isActive\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"isActive\",\"searchable\":true,\"sortable\":true}},\"roles\":{\"edit\":{\"label\":\"roles\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"roles\",\"searchable\":false,\"sortable\":false}},\"blocked\":{\"edit\":{\"label\":\"blocked\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"blocked\",\"searchable\":true,\"sortable\":true}},\"preferedLanguage\":{\"edit\":{\"label\":\"preferedLanguage\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"preferedLanguage\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"firstname\",\"lastname\",\"username\"],\"edit\":[[{\"name\":\"firstname\",\"size\":6},{\"name\":\"lastname\",\"size\":6}],[{\"name\":\"username\",\"size\":6},{\"name\":\"email\",\"size\":6}],[{\"name\":\"password\",\"size\":6},{\"name\":\"isActive\",\"size\":4}],[{\"name\":\"roles\",\"size\":6},{\"name\":\"blocked\",\"size\":4}],[{\"name\":\"preferedLanguage\",\"size\":6}]]},\"uid\":\"admin::user\"}','object',NULL,NULL),(52,'plugin_content_manager_configuration_content_types::admin::role','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"name\",\"defaultSortBy\":\"name\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"name\":{\"edit\":{\"label\":\"name\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"name\",\"searchable\":true,\"sortable\":true}},\"code\":{\"edit\":{\"label\":\"code\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"code\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":true,\"sortable\":true}},\"users\":{\"edit\":{\"label\":\"users\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"users\",\"searchable\":false,\"sortable\":false}},\"permissions\":{\"edit\":{\"label\":\"permissions\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"action\"},\"list\":{\"label\":\"permissions\",\"searchable\":false,\"sortable\":false}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"name\",\"code\",\"description\"],\"edit\":[[{\"name\":\"name\",\"size\":6},{\"name\":\"code\",\"size\":6}],[{\"name\":\"description\",\"size\":6},{\"name\":\"users\",\"size\":6}],[{\"name\":\"permissions\",\"size\":6}]]},\"uid\":\"admin::role\"}','object',NULL,NULL),(53,'plugin_content_manager_configuration_content_types::admin::api-token','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"name\",\"defaultSortBy\":\"name\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"name\":{\"edit\":{\"label\":\"name\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"name\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":true,\"sortable\":true}},\"type\":{\"edit\":{\"label\":\"type\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"type\",\"searchable\":true,\"sortable\":true}},\"accessKey\":{\"edit\":{\"label\":\"accessKey\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"accessKey\",\"searchable\":true,\"sortable\":true}},\"encryptedKey\":{\"edit\":{\"label\":\"encryptedKey\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"encryptedKey\",\"searchable\":true,\"sortable\":true}},\"lastUsedAt\":{\"edit\":{\"label\":\"lastUsedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"lastUsedAt\",\"searchable\":true,\"sortable\":true}},\"permissions\":{\"edit\":{\"label\":\"permissions\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"action\"},\"list\":{\"label\":\"permissions\",\"searchable\":false,\"sortable\":false}},\"expiresAt\":{\"edit\":{\"label\":\"expiresAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"expiresAt\",\"searchable\":true,\"sortable\":true}},\"lifespan\":{\"edit\":{\"label\":\"lifespan\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"lifespan\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"name\",\"description\",\"type\"],\"edit\":[[{\"name\":\"name\",\"size\":6},{\"name\":\"description\",\"size\":6}],[{\"name\":\"type\",\"size\":6},{\"name\":\"accessKey\",\"size\":6}],[{\"name\":\"encryptedKey\",\"size\":6},{\"name\":\"lastUsedAt\",\"size\":6}],[{\"name\":\"permissions\",\"size\":6},{\"name\":\"expiresAt\",\"size\":6}],[{\"name\":\"lifespan\",\"size\":4}]]},\"uid\":\"admin::api-token\"}','object',NULL,NULL),(54,'plugin_content_manager_configuration_content_types::admin::api-token-permission','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"action\",\"defaultSortBy\":\"action\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"action\":{\"edit\":{\"label\":\"action\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"action\",\"searchable\":true,\"sortable\":true}},\"token\":{\"edit\":{\"label\":\"token\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"token\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"action\",\"token\",\"createdAt\"],\"edit\":[[{\"name\":\"action\",\"size\":6},{\"name\":\"token\",\"size\":6}]]},\"uid\":\"admin::api-token-permission\"}','object',NULL,NULL),(55,'plugin_content_manager_configuration_content_types::admin::transfer-token-permission','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"action\",\"defaultSortBy\":\"action\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"action\":{\"edit\":{\"label\":\"action\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"action\",\"searchable\":true,\"sortable\":true}},\"token\":{\"edit\":{\"label\":\"token\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"name\"},\"list\":{\"label\":\"token\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"action\",\"token\",\"createdAt\"],\"edit\":[[{\"name\":\"action\",\"size\":6},{\"name\":\"token\",\"size\":6}]]},\"uid\":\"admin::transfer-token-permission\"}','object',NULL,NULL),(56,'plugin_content_manager_configuration_content_types::admin::session','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"userId\",\"defaultSortBy\":\"userId\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"userId\":{\"edit\":{\"label\":\"userId\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"userId\",\"searchable\":true,\"sortable\":true}},\"sessionId\":{\"edit\":{\"label\":\"sessionId\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"sessionId\",\"searchable\":true,\"sortable\":true}},\"childId\":{\"edit\":{\"label\":\"childId\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"childId\",\"searchable\":true,\"sortable\":true}},\"deviceId\":{\"edit\":{\"label\":\"deviceId\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"deviceId\",\"searchable\":true,\"sortable\":true}},\"origin\":{\"edit\":{\"label\":\"origin\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"origin\",\"searchable\":true,\"sortable\":true}},\"expiresAt\":{\"edit\":{\"label\":\"expiresAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"expiresAt\",\"searchable\":true,\"sortable\":true}},\"absoluteExpiresAt\":{\"edit\":{\"label\":\"absoluteExpiresAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"absoluteExpiresAt\",\"searchable\":true,\"sortable\":true}},\"status\":{\"edit\":{\"label\":\"status\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"status\",\"searchable\":true,\"sortable\":true}},\"type\":{\"edit\":{\"label\":\"type\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"type\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"userId\",\"sessionId\",\"childId\"],\"edit\":[[{\"name\":\"userId\",\"size\":6},{\"name\":\"sessionId\",\"size\":6}],[{\"name\":\"childId\",\"size\":6},{\"name\":\"deviceId\",\"size\":6}],[{\"name\":\"origin\",\"size\":6},{\"name\":\"expiresAt\",\"size\":6}],[{\"name\":\"absoluteExpiresAt\",\"size\":6},{\"name\":\"status\",\"size\":6}],[{\"name\":\"type\",\"size\":6}]]},\"uid\":\"admin::session\"}','object',NULL,NULL),(57,'plugin_content_manager_configuration_content_types::admin::transfer-token','{\"settings\":{\"bulkable\":true,\"filterable\":true,\"searchable\":true,\"pageSize\":10,\"mainField\":\"name\",\"defaultSortBy\":\"name\",\"defaultSortOrder\":\"ASC\"},\"metadatas\":{\"id\":{\"edit\":{},\"list\":{\"label\":\"id\",\"searchable\":true,\"sortable\":true}},\"name\":{\"edit\":{\"label\":\"name\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"name\",\"searchable\":true,\"sortable\":true}},\"description\":{\"edit\":{\"label\":\"description\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"description\",\"searchable\":true,\"sortable\":true}},\"accessKey\":{\"edit\":{\"label\":\"accessKey\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"accessKey\",\"searchable\":true,\"sortable\":true}},\"lastUsedAt\":{\"edit\":{\"label\":\"lastUsedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"lastUsedAt\",\"searchable\":true,\"sortable\":true}},\"permissions\":{\"edit\":{\"label\":\"permissions\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true,\"mainField\":\"action\"},\"list\":{\"label\":\"permissions\",\"searchable\":false,\"sortable\":false}},\"expiresAt\":{\"edit\":{\"label\":\"expiresAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"expiresAt\",\"searchable\":true,\"sortable\":true}},\"lifespan\":{\"edit\":{\"label\":\"lifespan\",\"description\":\"\",\"placeholder\":\"\",\"visible\":true,\"editable\":true},\"list\":{\"label\":\"lifespan\",\"searchable\":true,\"sortable\":true}},\"createdAt\":{\"edit\":{\"label\":\"createdAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"createdAt\",\"searchable\":true,\"sortable\":true}},\"updatedAt\":{\"edit\":{\"label\":\"updatedAt\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true},\"list\":{\"label\":\"updatedAt\",\"searchable\":true,\"sortable\":true}},\"createdBy\":{\"edit\":{\"label\":\"createdBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"createdBy\",\"searchable\":true,\"sortable\":true}},\"updatedBy\":{\"edit\":{\"label\":\"updatedBy\",\"description\":\"\",\"placeholder\":\"\",\"visible\":false,\"editable\":true,\"mainField\":\"firstname\"},\"list\":{\"label\":\"updatedBy\",\"searchable\":true,\"sortable\":true}},\"documentId\":{\"edit\":{},\"list\":{\"label\":\"documentId\",\"searchable\":true,\"sortable\":true}}},\"layouts\":{\"list\":[\"id\",\"name\",\"description\",\"accessKey\"],\"edit\":[[{\"name\":\"name\",\"size\":6},{\"name\":\"description\",\"size\":6}],[{\"name\":\"accessKey\",\"size\":6},{\"name\":\"lastUsedAt\",\"size\":6}],[{\"name\":\"permissions\",\"size\":6},{\"name\":\"expiresAt\",\"size\":6}],[{\"name\":\"lifespan\",\"size\":4}]]},\"uid\":\"admin::transfer-token\"}','object',NULL,NULL),(58,'plugin_upload_settings','{\"sizeOptimization\":true,\"responsiveDimensions\":true,\"autoOrientation\":false,\"aiMetadata\":true}','object',NULL,NULL),(59,'plugin_upload_view_configuration','{\"pageSize\":10,\"sort\":\"createdAt:DESC\"}','object',NULL,NULL),(60,'plugin_upload_metrics','{\"weeklySchedule\":\"18 30 14 * * 4\",\"lastWeeklyUpdate\":1775745019486}','object',NULL,NULL),(61,'plugin_i18n_default_locale','\"en\"','string',NULL,NULL),(62,'plugin_users-permissions_grant','{\"email\":{\"icon\":\"envelope\",\"enabled\":true},\"discord\":{\"icon\":\"discord\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"callbackUrl\":\"api/auth/discord/callback\",\"scope\":[\"identify\",\"email\"]},\"facebook\":{\"icon\":\"facebook-square\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"callbackUrl\":\"api/auth/facebook/callback\",\"scope\":[\"email\"]},\"google\":{\"icon\":\"google\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"callbackUrl\":\"api/auth/google/callback\",\"scope\":[\"email\"]},\"github\":{\"icon\":\"github\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"callbackUrl\":\"api/auth/github/callback\",\"scope\":[\"user\",\"user:email\"]},\"microsoft\":{\"icon\":\"windows\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"callbackUrl\":\"api/auth/microsoft/callback\",\"scope\":[\"user.read\"]},\"twitter\":{\"icon\":\"twitter\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"callbackUrl\":\"api/auth/twitter/callback\"},\"instagram\":{\"icon\":\"instagram\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"callbackUrl\":\"api/auth/instagram/callback\",\"scope\":[\"user_profile\"]},\"vk\":{\"icon\":\"vk\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"callbackUrl\":\"api/auth/vk/callback\",\"scope\":[\"email\"]},\"twitch\":{\"icon\":\"twitch\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"callbackUrl\":\"api/auth/twitch/callback\",\"scope\":[\"user:read:email\"]},\"linkedin\":{\"icon\":\"linkedin\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"callbackUrl\":\"api/auth/linkedin/callback\",\"scope\":[\"r_liteprofile\",\"r_emailaddress\"]},\"cognito\":{\"icon\":\"aws\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"subdomain\":\"my.subdomain.com\",\"callback\":\"api/auth/cognito/callback\",\"scope\":[\"email\",\"openid\",\"profile\"]},\"reddit\":{\"icon\":\"reddit\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"callback\":\"api/auth/reddit/callback\",\"scope\":[\"identity\"]},\"auth0\":{\"icon\":\"\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"subdomain\":\"my-tenant.eu\",\"callback\":\"api/auth/auth0/callback\",\"scope\":[\"openid\",\"email\",\"profile\"]},\"cas\":{\"icon\":\"book\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"callback\":\"api/auth/cas/callback\",\"scope\":[\"openid email\"],\"subdomain\":\"my.subdomain.com/cas\"},\"patreon\":{\"icon\":\"\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"callback\":\"api/auth/patreon/callback\",\"scope\":[\"identity\",\"identity[email]\"]},\"keycloak\":{\"icon\":\"\",\"enabled\":false,\"key\":\"\",\"secret\":\"\",\"subdomain\":\"myKeycloakProvider.com/realms/myrealm\",\"callback\":\"api/auth/keycloak/callback\",\"scope\":[\"openid\",\"email\",\"profile\"]}}','object',NULL,NULL),(63,'plugin_users-permissions_email','{\"reset_password\":{\"display\":\"Email.template.reset_password\",\"icon\":\"sync\",\"options\":{\"from\":{\"name\":\"Administration Panel\",\"email\":\"no-reply@strapi.io\"},\"response_email\":\"\",\"object\":\"Reset password\",\"message\":\"<p>We heard that you lost your password. Sorry about that!</p>\\n\\n<p>But don’t worry! You can use the following link to reset your password:</p>\\n<p><%= URL %>?code=<%= TOKEN %></p>\\n\\n<p>Thanks.</p>\"}},\"email_confirmation\":{\"display\":\"Email.template.email_confirmation\",\"icon\":\"check-square\",\"options\":{\"from\":{\"name\":\"Administration Panel\",\"email\":\"no-reply@strapi.io\"},\"response_email\":\"\",\"object\":\"Account confirmation\",\"message\":\"<p>Thank you for registering!</p>\\n\\n<p>You have to confirm your email address. Please click on the link below.</p>\\n\\n<p><%= URL %>?confirmation=<%= CODE %></p>\\n\\n<p>Thanks.</p>\"}}}','object',NULL,NULL),(64,'plugin_users-permissions_advanced','{\"unique_email\":true,\"allow_register\":true,\"email_confirmation\":false,\"email_reset_password\":null,\"email_confirmation_redirection\":null,\"default_role\":\"authenticated\"}','object',NULL,NULL),(65,'core_admin_auth','{\"providers\":{\"autoRegister\":false,\"defaultRole\":null,\"ssoLockedRoles\":null}}','object',NULL,NULL);
/*!40000 ALTER TABLE `strapi_core_store_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_database_schema`
--

DROP TABLE IF EXISTS `strapi_database_schema`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_database_schema` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `schema` json DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  `hash` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_database_schema`
--

LOCK TABLES `strapi_database_schema` WRITE;
/*!40000 ALTER TABLE `strapi_database_schema` DISABLE KEYS */;
INSERT INTO `strapi_database_schema` VALUES (15,'{\"tables\": [{\"name\": \"files\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"name\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"alternative_text\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"caption\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"focal_point\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"width\", \"type\": \"integer\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"height\", \"type\": \"integer\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"formats\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"hash\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"ext\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"mime\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [10, 2], \"name\": \"size\", \"type\": \"decimal\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"url\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"preview_url\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"provider\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"provider_metadata\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"folder_path\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"upload_files_folder_path_index\", \"type\": null, \"columns\": [\"folder_path\"]}, {\"name\": \"upload_files_created_at_index\", \"type\": null, \"columns\": [\"created_at\"]}, {\"name\": \"upload_files_updated_at_index\", \"type\": null, \"columns\": [\"updated_at\"]}, {\"name\": \"upload_files_name_index\", \"type\": null, \"columns\": [\"name\"]}, {\"name\": \"upload_files_size_index\", \"type\": null, \"columns\": [\"size\"]}, {\"name\": \"upload_files_ext_index\", \"type\": null, \"columns\": [\"ext\"]}, {\"name\": \"files_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"files_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"files_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"files_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"files_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"upload_folders\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"name\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"path_id\", \"type\": \"integer\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"path\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"upload_folders_path_id_index\", \"type\": \"unique\", \"columns\": [\"path_id\"]}, {\"name\": \"upload_folders_path_index\", \"type\": \"unique\", \"columns\": [\"path\"]}, {\"name\": \"upload_folders_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"upload_folders_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"upload_folders_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"upload_folders_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"upload_folders_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"i18n_locale\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"name\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"code\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"i18n_locale_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"i18n_locale_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"i18n_locale_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"i18n_locale_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"i18n_locale_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_releases\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"name\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"released_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"scheduled_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"timezone\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"status\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_releases_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"strapi_releases_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"strapi_releases_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"strapi_releases_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_releases_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_release_actions\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"content_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"entry_document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"is_entry_valid\", \"type\": \"boolean\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_release_actions_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"strapi_release_actions_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"strapi_release_actions_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"strapi_release_actions_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_release_actions_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_workflows\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"name\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"content_types\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_workflows_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"strapi_workflows_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"strapi_workflows_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"strapi_workflows_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_workflows_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_workflows_stages\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"name\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"color\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_workflows_stages_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"strapi_workflows_stages_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"strapi_workflows_stages_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"strapi_workflows_stages_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_workflows_stages_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"up_permissions\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"action\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"up_permissions_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"up_permissions_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"up_permissions_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"up_permissions_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"up_permissions_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"up_roles\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"name\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"description\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"up_roles_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"up_roles_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"up_roles_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"up_roles_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"up_roles_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"up_users\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"username\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"email\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"provider\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"password\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"reset_password_token\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"confirmation_token\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"confirmed\", \"type\": \"boolean\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"blocked\", \"type\": \"boolean\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"up_users_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"up_users_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"up_users_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"up_users_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"up_users_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"about_page_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"about_page_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"about_page_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"about_page_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"about_page_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"about_page_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"about_page\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"about_page\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"about_page_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"about_page_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"about_page_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"about_page_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"about_page_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"docs_page_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"docs_page_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"docs_page_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"docs_page_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"docs_page_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"docs_page_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"docs_page\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"docs_page\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"docs_page_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"docs_page_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"docs_page_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"docs_page_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"docs_page_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"error_page\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"description\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"retry_button_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"home_button_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"error_page_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"error_page_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"error_page_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"error_page_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"error_page_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"global_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"global_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"global_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"global_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"global_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"global_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"global\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"global\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"site_name\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"site_description\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"mobile_menu_title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"skip_to_content_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"sign_in_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"sign_out_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"user_menu_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"new_pattern_button_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"global_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"global_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"global_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"global_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"global_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"home_page_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"home_page_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"home_page_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"home_page_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"home_page_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"home_page_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"home_page\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"home_page\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"home_page_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"home_page_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"home_page_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"home_page_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"home_page_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"login_page_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"login_page_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"login_page_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"login_page_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"login_page_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"login_page_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"login_page\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"login_page\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"card_title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"card_description\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"sign_in_button_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"sign_in_loading_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"footer_notice\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"error_messages\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"login_page_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"login_page_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"login_page_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"login_page_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"login_page_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"not_found_page_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"not_found_page_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"not_found_page_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"not_found_page_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"not_found_page_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"not_found_page_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"not_found_page\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"not_found_page\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"error_code\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"heading\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"message\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"not_found_page_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"not_found_page_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"not_found_page_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"not_found_page_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"not_found_page_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"pattern_detail_labels\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"breadcrumb_aria_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"vote_aria_template\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"votes_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"vote_announcement_template\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"no_content_message\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"related_patterns_title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"no_related_message\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"edit_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"delete_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"delete_dialog_title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"delete_dialog_description\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cancel_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"delete_confirm_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"deleting_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"pattern_detail_labels_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"pattern_detail_labels_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"pattern_detail_labels_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"pattern_detail_labels_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"pattern_detail_labels_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"pattern_form_labels\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"create_title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"edit_title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"title_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"title_placeholder\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"slug_preview_template\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"short_desc_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"short_desc_placeholder\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"category_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"category_placeholder\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"tags_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"tag_placeholder\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"add_tag_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"tag_count_template\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"content_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"content_placeholder\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"author_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"author_placeholder\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"admin_settings_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"featured_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"trending_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cancel_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"create_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"creating_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"save_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"saving_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"pattern_form_labels_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"pattern_form_labels_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"pattern_form_labels_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"pattern_form_labels_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"pattern_form_labels_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"pattern_listing_labels\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"page_title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"page_description\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"search_placeholder\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"clear_search_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"sort_by_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"sort_options\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"filter_section_header\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"clear_all_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"category_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"all_categories_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"tags_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"tag_mode_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"any_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"all_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"date_range_header\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"clear_dates_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"from_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"to_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"active_filters_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"filters_button_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"filter_sheet_title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"filter_sheet_description\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"saved_searches_header\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"save_current_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"save_dialog_title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"save_dialog_description\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"search_name_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"search_name_placeholder\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cancel_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"save_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"recently_viewed_header\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"clear_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"previous_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"next_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"empty_filtered_heading\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"empty_unfiltered_heading\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"empty_filtered_description\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"empty_unfiltered_description\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"clear_filters_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"pattern_listing_labels_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"pattern_listing_labels_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"pattern_listing_labels_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"pattern_listing_labels_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"pattern_listing_labels_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"admin_permissions\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"action\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"action_parameters\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"subject\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"properties\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"conditions\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"admin_permissions_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"admin_permissions_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"admin_permissions_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"admin_permissions_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"admin_permissions_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"admin_users\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"firstname\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"lastname\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"username\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"email\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"password\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"reset_password_token\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"registration_token\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"is_active\", \"type\": \"boolean\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"blocked\", \"type\": \"boolean\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"prefered_language\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"admin_users_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"admin_users_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"admin_users_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"admin_users_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"admin_users_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"admin_roles\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"name\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"code\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"description\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"admin_roles_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"admin_roles_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"admin_roles_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"admin_roles_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"admin_roles_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_api_tokens\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"name\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"description\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"access_key\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"encrypted_key\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"last_used_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"expires_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"lifespan\", \"type\": \"bigInteger\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_api_tokens_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"strapi_api_tokens_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"strapi_api_tokens_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"strapi_api_tokens_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_api_tokens_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_api_token_permissions\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"action\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_api_token_permissions_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"strapi_api_token_permissions_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"strapi_api_token_permissions_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"strapi_api_token_permissions_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_api_token_permissions_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_transfer_tokens\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"name\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"description\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"access_key\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"last_used_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"expires_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"lifespan\", \"type\": \"bigInteger\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_transfer_tokens_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"strapi_transfer_tokens_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"strapi_transfer_tokens_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"strapi_transfer_tokens_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_transfer_tokens_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_transfer_token_permissions\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"action\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_transfer_token_permissions_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"strapi_transfer_token_permissions_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"strapi_transfer_token_permissions_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"strapi_transfer_token_permissions_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_transfer_token_permissions_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_sessions\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"user_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"session_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"child_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"device_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"origin\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"expires_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"absolute_expires_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"status\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"published_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"updated_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_sessions_documents_idx\", \"columns\": [\"document_id\", \"locale\", \"published_at\"]}, {\"name\": \"strapi_sessions_created_by_id_fk\", \"columns\": [\"created_by_id\"]}, {\"name\": \"strapi_sessions_updated_by_id_fk\", \"columns\": [\"updated_by_id\"]}], \"foreignKeys\": [{\"name\": \"strapi_sessions_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_sessions_updated_by_id_fk\", \"columns\": [\"updated_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_shared_text_item\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"text\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_shared_tech_groups_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_shared_tech_groups_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_shared_tech_groups_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_shared_tech_groups_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_shared_tech_groups_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_shared_tech_groups_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_shared_tech_groups\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_shared_tech_groups\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_shared_support_items\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"description\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"href\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"icon\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_shared_stat_item\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"value\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"icon\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_shared_quick_nav_items\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"description\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"href\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"icon\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_shared_key_value\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"key\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"value\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_shared_feature_card_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_shared_feature_card_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_shared_feature_card_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_shared_feature_card_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_shared_feature_card_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_shared_feature_card_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_shared_feature_card\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_shared_feature_card\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"icon\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"description\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_shared_api_endpoints_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_shared_api_endpoints_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_shared_api_endpoints_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_shared_api_endpoints_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_shared_api_endpoints_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_shared_api_endpoints_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_shared_api_endpoints\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_shared_api_endpoints\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"method\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"path\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"description\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"auth_required\", \"type\": \"boolean\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"rate_limit\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_seo_metadata\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"description\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"keywords\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"og_title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"og_description\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"no_index\", \"type\": \"boolean\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_tech_stacks_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_sections_tech_stacks_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_sections_tech_stacks_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_sections_tech_stacks_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_sections_tech_stacks_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_sections_tech_stacks_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_sections_tech_stacks\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_sections_tech_stacks\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"heading\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_support_links_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_sections_support_links_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_sections_support_links_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_sections_support_links_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_sections_support_links_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_sections_support_links_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_sections_support_links\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_sections_support_links\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"description\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_stats_bars_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_sections_stats_bars_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_sections_stats_bars_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_sections_stats_bars_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_sections_stats_bars_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_sections_stats_bars_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_sections_stats_bars\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_sections_stats_bars\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_rich_texts\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [\"longtext\"], \"name\": \"body\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_quick_navs_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_sections_quick_navs_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_sections_quick_navs_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_sections_quick_navs_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_sections_quick_navs_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_sections_quick_navs_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_sections_quick_navs\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_sections_quick_navs\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"heading\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_page_headers\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"badge\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"subtitle\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_open_source_infos_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_sections_open_source_infos_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_sections_open_sourcebd451_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_sections_open_source_infos_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_sections_open_source_infos_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_sections_open_source_infos_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_sections_open_source_infos\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_sections_open_source_infos\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"description\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_mission_blocks\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"content\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_heroes_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_sections_heroes_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_sections_heroes_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_sections_heroes_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_sections_heroes_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_sections_heroes_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_sections_heroes\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_sections_heroes\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"heading\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"subheading\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_featured_patterns\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"heading\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"subheading\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"view_all_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"mobile_view_all_label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_feature_grids_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_sections_feature_grids_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_sections_feature_grids_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_sections_feature_grids_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_sections_feature_grids_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_sections_feature_grids_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_sections_feature_grids\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_sections_feature_grids\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"heading\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"columns\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_doc_sections\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"anchor_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"content\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_cta_banners_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_sections_cta_banners_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_sections_cta_banners_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_sections_cta_banners_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_sections_cta_banners_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_sections_cta_banners_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_sections_cta_banners\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_sections_cta_banners\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"heading\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"description\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"variant\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_contributings_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_sections_contributings_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_sections_contributings_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_sections_contributings_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_sections_contributings_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_sections_contributings_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_sections_contributings\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_sections_contributings\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"description\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"how_to_title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"steps\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"guidelines_title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_sections_api_references_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_sections_api_references_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_sections_api_references_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_sections_api_references_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_sections_api_references_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_sections_api_references_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_sections_api_references\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_sections_api_references\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"title\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"description\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"base_url\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"example_code\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"swagger_note\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_layout_nav_links\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"href\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"icon\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"is_external\", \"type\": \"boolean\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_layout_footer_configs_cmps\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"entity_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"cmp_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"component_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"components_layout_footer_configs_field_idx\", \"columns\": [\"field\"]}, {\"name\": \"components_layout_footer_configs_component_type_idx\", \"columns\": [\"component_type\"]}, {\"name\": \"components_layout_footer_configs_entity_fk\", \"columns\": [\"entity_id\"]}, {\"name\": \"components_layout_footer_configs_uq\", \"type\": \"unique\", \"columns\": [\"entity_id\", \"cmp_id\", \"field\", \"component_type\"]}], \"foreignKeys\": [{\"name\": \"components_layout_footer_configs_entity_fk\", \"columns\": [\"entity_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"components_layout_footer_configs\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"components_layout_footer_configs\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"copyright_template\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"components_layout_cta_buttons\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"label\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"href\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"variant\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"icon\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"strapi_core_store_settings\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"key\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"value\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"environment\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"tag\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"strapi_webhooks\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"name\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [\"longtext\"], \"name\": \"url\", \"type\": \"text\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"headers\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"events\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"enabled\", \"type\": \"boolean\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"strapi_history_versions\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"content_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"related_document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"status\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"data\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"schema\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"created_by_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_history_versions_created_by_id_fk\", \"columns\": [\"created_by_id\"]}], \"foreignKeys\": [{\"name\": \"strapi_history_versions_created_by_id_fk\", \"columns\": [\"created_by_id\"], \"onDelete\": \"SET NULL\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_ai_metadata_jobs\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"status\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"completed_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"strapi_ai_localization_jobs\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"content_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"related_document_id\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"source_locale\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"target_locales\", \"type\": \"jsonb\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"status\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"created_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [{\"useTz\": false, \"precision\": 6}], \"name\": \"updated_at\", \"type\": \"datetime\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [], \"foreignKeys\": []}, {\"name\": \"files_related_mph\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"file_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"related_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"related_type\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"field\", \"type\": \"string\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"order\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"files_related_mph_fk\", \"columns\": [\"file_id\"]}, {\"name\": \"files_related_mph_oidx\", \"columns\": [\"order\"]}, {\"name\": \"files_related_mph_idix\", \"columns\": [\"related_id\"]}], \"foreignKeys\": [{\"name\": \"files_related_mph_fk\", \"columns\": [\"file_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"files\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"files_folder_lnk\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"file_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"folder_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"file_ord\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"files_folder_lnk_fk\", \"columns\": [\"file_id\"]}, {\"name\": \"files_folder_lnk_ifk\", \"columns\": [\"folder_id\"]}, {\"name\": \"files_folder_lnk_uq\", \"type\": \"unique\", \"columns\": [\"file_id\", \"folder_id\"]}, {\"name\": \"files_folder_lnk_oifk\", \"columns\": [\"file_ord\"]}], \"foreignKeys\": [{\"name\": \"files_folder_lnk_fk\", \"columns\": [\"file_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"files\", \"referencedColumns\": [\"id\"]}, {\"name\": \"files_folder_lnk_ifk\", \"columns\": [\"folder_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"upload_folders\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"upload_folders_parent_lnk\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"folder_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"inv_folder_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"folder_ord\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"upload_folders_parent_lnk_fk\", \"columns\": [\"folder_id\"]}, {\"name\": \"upload_folders_parent_lnk_ifk\", \"columns\": [\"inv_folder_id\"]}, {\"name\": \"upload_folders_parent_lnk_uq\", \"type\": \"unique\", \"columns\": [\"folder_id\", \"inv_folder_id\"]}, {\"name\": \"upload_folders_parent_lnk_oifk\", \"columns\": [\"folder_ord\"]}], \"foreignKeys\": [{\"name\": \"upload_folders_parent_lnk_fk\", \"columns\": [\"folder_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"upload_folders\", \"referencedColumns\": [\"id\"]}, {\"name\": \"upload_folders_parent_lnk_ifk\", \"columns\": [\"inv_folder_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"upload_folders\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_release_actions_release_lnk\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"release_action_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"release_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"release_action_ord\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_release_actions_release_lnk_fk\", \"columns\": [\"release_action_id\"]}, {\"name\": \"strapi_release_actions_release_lnk_ifk\", \"columns\": [\"release_id\"]}, {\"name\": \"strapi_release_actions_release_lnk_uq\", \"type\": \"unique\", \"columns\": [\"release_action_id\", \"release_id\"]}, {\"name\": \"strapi_release_actions_release_lnk_oifk\", \"columns\": [\"release_action_ord\"]}], \"foreignKeys\": [{\"name\": \"strapi_release_actions_release_lnk_fk\", \"columns\": [\"release_action_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"strapi_release_actions\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_release_actions_release_lnk_ifk\", \"columns\": [\"release_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"strapi_releases\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_workflows_stage_required_to_publish_lnk\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"workflow_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"workflow_stage_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_workflows_stage_required_to_publish_lnk_fk\", \"columns\": [\"workflow_id\"]}, {\"name\": \"strapi_workflows_stage_required_to_publish_lnk_ifk\", \"columns\": [\"workflow_stage_id\"]}, {\"name\": \"strapi_workflows_stage_required_to_publish_lnk_uq\", \"type\": \"unique\", \"columns\": [\"workflow_id\", \"workflow_stage_id\"]}], \"foreignKeys\": [{\"name\": \"strapi_workflows_stage_required_to_publish_lnk_fk\", \"columns\": [\"workflow_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"strapi_workflows\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_workflows_stage_required_to_publish_lnk_ifk\", \"columns\": [\"workflow_stage_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"strapi_workflows_stages\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_workflows_stages_workflow_lnk\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"workflow_stage_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"workflow_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"workflow_stage_ord\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_workflows_stages_workflow_lnk_fk\", \"columns\": [\"workflow_stage_id\"]}, {\"name\": \"strapi_workflows_stages_workflow_lnk_ifk\", \"columns\": [\"workflow_id\"]}, {\"name\": \"strapi_workflows_stages_workflow_lnk_uq\", \"type\": \"unique\", \"columns\": [\"workflow_stage_id\", \"workflow_id\"]}, {\"name\": \"strapi_workflows_stages_workflow_lnk_oifk\", \"columns\": [\"workflow_stage_ord\"]}], \"foreignKeys\": [{\"name\": \"strapi_workflows_stages_workflow_lnk_fk\", \"columns\": [\"workflow_stage_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"strapi_workflows_stages\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_workflows_stages_workflow_lnk_ifk\", \"columns\": [\"workflow_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"strapi_workflows\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_workflows_stages_permissions_lnk\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"workflow_stage_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"permission_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"permission_ord\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_workflows_stages_permissions_lnk_fk\", \"columns\": [\"workflow_stage_id\"]}, {\"name\": \"strapi_workflows_stages_permissions_lnk_ifk\", \"columns\": [\"permission_id\"]}, {\"name\": \"strapi_workflows_stages_permissions_lnk_uq\", \"type\": \"unique\", \"columns\": [\"workflow_stage_id\", \"permission_id\"]}, {\"name\": \"strapi_workflows_stages_permissions_lnk_ofk\", \"columns\": [\"permission_ord\"]}], \"foreignKeys\": [{\"name\": \"strapi_workflows_stages_permissions_lnk_fk\", \"columns\": [\"workflow_stage_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"strapi_workflows_stages\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_workflows_stages_permissions_lnk_ifk\", \"columns\": [\"permission_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"admin_permissions\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"up_permissions_role_lnk\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"permission_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"role_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"permission_ord\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"up_permissions_role_lnk_fk\", \"columns\": [\"permission_id\"]}, {\"name\": \"up_permissions_role_lnk_ifk\", \"columns\": [\"role_id\"]}, {\"name\": \"up_permissions_role_lnk_uq\", \"type\": \"unique\", \"columns\": [\"permission_id\", \"role_id\"]}, {\"name\": \"up_permissions_role_lnk_oifk\", \"columns\": [\"permission_ord\"]}], \"foreignKeys\": [{\"name\": \"up_permissions_role_lnk_fk\", \"columns\": [\"permission_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"up_permissions\", \"referencedColumns\": [\"id\"]}, {\"name\": \"up_permissions_role_lnk_ifk\", \"columns\": [\"role_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"up_roles\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"up_users_role_lnk\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"user_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"role_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"user_ord\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"up_users_role_lnk_fk\", \"columns\": [\"user_id\"]}, {\"name\": \"up_users_role_lnk_ifk\", \"columns\": [\"role_id\"]}, {\"name\": \"up_users_role_lnk_uq\", \"type\": \"unique\", \"columns\": [\"user_id\", \"role_id\"]}, {\"name\": \"up_users_role_lnk_oifk\", \"columns\": [\"user_ord\"]}], \"foreignKeys\": [{\"name\": \"up_users_role_lnk_fk\", \"columns\": [\"user_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"up_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"up_users_role_lnk_ifk\", \"columns\": [\"role_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"up_roles\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"admin_permissions_role_lnk\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"permission_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"role_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"permission_ord\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"admin_permissions_role_lnk_fk\", \"columns\": [\"permission_id\"]}, {\"name\": \"admin_permissions_role_lnk_ifk\", \"columns\": [\"role_id\"]}, {\"name\": \"admin_permissions_role_lnk_uq\", \"type\": \"unique\", \"columns\": [\"permission_id\", \"role_id\"]}, {\"name\": \"admin_permissions_role_lnk_oifk\", \"columns\": [\"permission_ord\"]}], \"foreignKeys\": [{\"name\": \"admin_permissions_role_lnk_fk\", \"columns\": [\"permission_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"admin_permissions\", \"referencedColumns\": [\"id\"]}, {\"name\": \"admin_permissions_role_lnk_ifk\", \"columns\": [\"role_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"admin_roles\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"admin_users_roles_lnk\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"user_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"role_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"role_ord\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"user_ord\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"admin_users_roles_lnk_fk\", \"columns\": [\"user_id\"]}, {\"name\": \"admin_users_roles_lnk_ifk\", \"columns\": [\"role_id\"]}, {\"name\": \"admin_users_roles_lnk_uq\", \"type\": \"unique\", \"columns\": [\"user_id\", \"role_id\"]}, {\"name\": \"admin_users_roles_lnk_ofk\", \"columns\": [\"role_ord\"]}, {\"name\": \"admin_users_roles_lnk_oifk\", \"columns\": [\"user_ord\"]}], \"foreignKeys\": [{\"name\": \"admin_users_roles_lnk_fk\", \"columns\": [\"user_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"admin_users\", \"referencedColumns\": [\"id\"]}, {\"name\": \"admin_users_roles_lnk_ifk\", \"columns\": [\"role_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"admin_roles\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_api_token_permissions_token_lnk\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"api_token_permission_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"api_token_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"api_token_permission_ord\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_api_token_permissions_token_lnk_fk\", \"columns\": [\"api_token_permission_id\"]}, {\"name\": \"strapi_api_token_permissions_token_lnk_ifk\", \"columns\": [\"api_token_id\"]}, {\"name\": \"strapi_api_token_permissions_token_lnk_uq\", \"type\": \"unique\", \"columns\": [\"api_token_permission_id\", \"api_token_id\"]}, {\"name\": \"strapi_api_token_permissions_token_lnk_oifk\", \"columns\": [\"api_token_permission_ord\"]}], \"foreignKeys\": [{\"name\": \"strapi_api_token_permissions_token_lnk_fk\", \"columns\": [\"api_token_permission_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"strapi_api_token_permissions\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_api_token_permissions_token_lnk_ifk\", \"columns\": [\"api_token_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"strapi_api_tokens\", \"referencedColumns\": [\"id\"]}]}, {\"name\": \"strapi_transfer_token_permissions_token_lnk\", \"columns\": [{\"args\": [{\"primary\": true, \"primaryKey\": true}], \"name\": \"id\", \"type\": \"increments\", \"unsigned\": false, \"defaultTo\": null, \"notNullable\": true}, {\"args\": [], \"name\": \"transfer_token_permission_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"transfer_token_id\", \"type\": \"integer\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}, {\"args\": [], \"name\": \"transfer_token_permission_ord\", \"type\": \"double\", \"unsigned\": true, \"defaultTo\": null, \"notNullable\": false}], \"indexes\": [{\"name\": \"strapi_transfer_token_permissions_token_lnk_fk\", \"columns\": [\"transfer_token_permission_id\"]}, {\"name\": \"strapi_transfer_token_permissions_token_lnk_ifk\", \"columns\": [\"transfer_token_id\"]}, {\"name\": \"strapi_transfer_token_permissions_token_lnk_uq\", \"type\": \"unique\", \"columns\": [\"transfer_token_permission_id\", \"transfer_token_id\"]}, {\"name\": \"strapi_transfer_token_permissions_token_lnk_oifk\", \"columns\": [\"transfer_token_permission_ord\"]}], \"foreignKeys\": [{\"name\": \"strapi_transfer_token_permissions_token_lnk_fk\", \"columns\": [\"transfer_token_permission_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"strapi_transfer_token_permissions\", \"referencedColumns\": [\"id\"]}, {\"name\": \"strapi_transfer_token_permissions_token_lnk_ifk\", \"columns\": [\"transfer_token_id\"], \"onDelete\": \"CASCADE\", \"referencedTable\": \"strapi_transfer_tokens\", \"referencedColumns\": [\"id\"]}]}]}','2026-04-09 16:59:35','c671cae02f4702b4466c0134902c7416fd8634feeea3753b22d486b9c013873c');
/*!40000 ALTER TABLE `strapi_database_schema` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_history_versions`
--

DROP TABLE IF EXISTS `strapi_history_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_history_versions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `content_type` varchar(255) NOT NULL,
  `related_document_id` varchar(255) DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `data` json DEFAULT NULL,
  `schema` json DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `strapi_history_versions_created_by_id_fk` (`created_by_id`),
  CONSTRAINT `strapi_history_versions_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_history_versions`
--

LOCK TABLES `strapi_history_versions` WRITE;
/*!40000 ALTER TABLE `strapi_history_versions` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_history_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_migrations`
--

DROP TABLE IF EXISTS `strapi_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_migrations`
--

LOCK TABLES `strapi_migrations` WRITE;
/*!40000 ALTER TABLE `strapi_migrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_migrations_internal`
--

DROP TABLE IF EXISTS `strapi_migrations_internal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_migrations_internal` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_migrations_internal`
--

LOCK TABLES `strapi_migrations_internal` WRITE;
/*!40000 ALTER TABLE `strapi_migrations_internal` DISABLE KEYS */;
INSERT INTO `strapi_migrations_internal` VALUES (1,'5.0.0-rename-identifiers-longer-than-max-length','2026-02-26 18:19:47'),(2,'5.0.0-02-created-document-id','2026-02-26 18:19:59'),(3,'5.0.0-03-created-locale','2026-02-26 18:20:10'),(4,'5.0.0-04-created-published-at','2026-02-26 18:20:22'),(5,'5.0.0-05-drop-slug-fields-index','2026-02-26 18:20:33'),(6,'5.0.0-06-add-document-id-indexes','2026-02-26 18:20:44'),(7,'core::5.0.0-discard-drafts','2026-02-26 18:20:56');
/*!40000 ALTER TABLE `strapi_migrations_internal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_release_actions`
--

DROP TABLE IF EXISTS `strapi_release_actions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_release_actions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `entry_document_id` varchar(255) DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  `is_entry_valid` tinyint(1) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `strapi_release_actions_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `strapi_release_actions_created_by_id_fk` (`created_by_id`),
  KEY `strapi_release_actions_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `strapi_release_actions_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `strapi_release_actions_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_release_actions`
--

LOCK TABLES `strapi_release_actions` WRITE;
/*!40000 ALTER TABLE `strapi_release_actions` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_release_actions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_release_actions_release_lnk`
--

DROP TABLE IF EXISTS `strapi_release_actions_release_lnk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_release_actions_release_lnk` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `release_action_id` int unsigned DEFAULT NULL,
  `release_id` int unsigned DEFAULT NULL,
  `release_action_ord` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `strapi_release_actions_release_lnk_uq` (`release_action_id`,`release_id`),
  KEY `strapi_release_actions_release_lnk_fk` (`release_action_id`),
  KEY `strapi_release_actions_release_lnk_ifk` (`release_id`),
  KEY `strapi_release_actions_release_lnk_oifk` (`release_action_ord`),
  CONSTRAINT `strapi_release_actions_release_lnk_fk` FOREIGN KEY (`release_action_id`) REFERENCES `strapi_release_actions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `strapi_release_actions_release_lnk_ifk` FOREIGN KEY (`release_id`) REFERENCES `strapi_releases` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_release_actions_release_lnk`
--

LOCK TABLES `strapi_release_actions_release_lnk` WRITE;
/*!40000 ALTER TABLE `strapi_release_actions_release_lnk` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_release_actions_release_lnk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_releases`
--

DROP TABLE IF EXISTS `strapi_releases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_releases` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `released_at` datetime(6) DEFAULT NULL,
  `scheduled_at` datetime(6) DEFAULT NULL,
  `timezone` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `strapi_releases_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `strapi_releases_created_by_id_fk` (`created_by_id`),
  KEY `strapi_releases_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `strapi_releases_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `strapi_releases_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_releases`
--

LOCK TABLES `strapi_releases` WRITE;
/*!40000 ALTER TABLE `strapi_releases` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_releases` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_sessions`
--

DROP TABLE IF EXISTS `strapi_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_sessions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `session_id` varchar(255) DEFAULT NULL,
  `child_id` varchar(255) DEFAULT NULL,
  `device_id` varchar(255) DEFAULT NULL,
  `origin` varchar(255) DEFAULT NULL,
  `expires_at` datetime(6) DEFAULT NULL,
  `absolute_expires_at` datetime(6) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `strapi_sessions_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `strapi_sessions_created_by_id_fk` (`created_by_id`),
  KEY `strapi_sessions_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `strapi_sessions_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `strapi_sessions_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_sessions`
--

LOCK TABLES `strapi_sessions` WRITE;
/*!40000 ALTER TABLE `strapi_sessions` DISABLE KEYS */;
INSERT INTO `strapi_sessions` VALUES (1,'zxxw4sr5j8ytj4sashd290vc','1','7bcf2dfa5e4b5971ceeef86432d6b517',NULL,'cadb77b9-4f9c-4d72-b0e8-78b9555e1303','admin','2026-02-26 20:25:57.432000','2026-03-28 18:25:57.432000','active','session','2026-02-26 18:25:57.432000','2026-02-26 18:25:57.432000','2026-02-26 18:25:57.433000',NULL,NULL,NULL),(2,'qt0vy4h32kga6cs29j3pi5i3','1','34507761c84fb1f8fd66fc749efb6fd0',NULL,'59453df7-c15f-4054-bb9c-55ea0170cc55','admin','2026-02-26 20:30:00.799000','2026-03-28 18:30:00.799000','active','session','2026-02-26 18:30:00.799000','2026-02-26 18:30:00.799000','2026-02-26 18:30:00.800000',NULL,NULL,NULL),(3,'xrihnx1ilxltg6euyhlkimel','1','8d26ad2ae96c58f5b12796492007699a',NULL,'4f764748-7cb0-4ca7-bae8-e4cfa400b8f8','admin','2026-02-26 20:30:10.809000','2026-03-28 18:30:10.809000','active','session','2026-02-26 18:30:10.809000','2026-02-26 18:30:10.809000','2026-02-26 18:30:10.809000',NULL,NULL,NULL),(4,'x92nsurtq9v2krz5a59sd0m9','1','a3a548c049111ef125672f89cab53e6d',NULL,'2b574574-8638-4f01-aa7f-79a336ee35c9','admin','2026-02-26 20:30:20.102000','2026-03-28 18:30:20.102000','active','session','2026-02-26 18:30:20.102000','2026-02-26 18:30:20.102000','2026-02-26 18:30:20.102000',NULL,NULL,NULL),(5,'gejh3f8wrtdomf57fcswpbs7','1','163c2a7cc3bd18e21a4119e251041d80',NULL,'91cfb21f-9863-49ce-afa2-7fc43e810de4','admin','2026-02-26 20:35:27.411000','2026-03-28 18:35:27.411000','active','session','2026-02-26 18:35:27.411000','2026-02-26 18:35:27.411000','2026-02-26 18:35:27.411000',NULL,NULL,NULL),(6,'ap4qmyva947qqapfztu06jt0','1','ce9528bc03e8d4141409be2a6b4c8803',NULL,'c7a30ee7-3ed7-48b0-895b-1db9c4b656a0','admin','2026-04-09 18:59:46.017000','2026-05-09 16:59:46.017000','active','session','2026-04-09 16:59:46.017000','2026-04-09 16:59:46.017000','2026-04-09 16:59:46.019000',NULL,NULL,NULL),(7,'j6346eb87b39k9jelncyizld','1','55e395edaf47405117c447452ea4abf5',NULL,'5e962161-ca58-40d3-b978-a8f357079801','admin','2026-04-09 19:05:03.030000','2026-05-09 17:05:03.030000','active','session','2026-04-09 17:05:03.030000','2026-04-09 17:05:03.030000','2026-04-09 17:05:03.031000',NULL,NULL,NULL),(8,'ugg21u9mte5915aigeo2ndpy','1','a70124008576acc55445800baf9de47d',NULL,'2b9da823-4594-4ab8-b625-8c2afb541d36','admin','2026-04-09 19:05:03.117000','2026-05-09 17:05:03.117000','active','session','2026-04-09 17:05:03.117000','2026-04-09 17:05:03.117000','2026-04-09 17:05:03.118000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `strapi_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_transfer_token_permissions`
--

DROP TABLE IF EXISTS `strapi_transfer_token_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_transfer_token_permissions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `strapi_transfer_token_permissions_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `strapi_transfer_token_permissions_created_by_id_fk` (`created_by_id`),
  KEY `strapi_transfer_token_permissions_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `strapi_transfer_token_permissions_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `strapi_transfer_token_permissions_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_transfer_token_permissions`
--

LOCK TABLES `strapi_transfer_token_permissions` WRITE;
/*!40000 ALTER TABLE `strapi_transfer_token_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_transfer_token_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_transfer_token_permissions_token_lnk`
--

DROP TABLE IF EXISTS `strapi_transfer_token_permissions_token_lnk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_transfer_token_permissions_token_lnk` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `transfer_token_permission_id` int unsigned DEFAULT NULL,
  `transfer_token_id` int unsigned DEFAULT NULL,
  `transfer_token_permission_ord` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `strapi_transfer_token_permissions_token_lnk_uq` (`transfer_token_permission_id`,`transfer_token_id`),
  KEY `strapi_transfer_token_permissions_token_lnk_fk` (`transfer_token_permission_id`),
  KEY `strapi_transfer_token_permissions_token_lnk_ifk` (`transfer_token_id`),
  KEY `strapi_transfer_token_permissions_token_lnk_oifk` (`transfer_token_permission_ord`),
  CONSTRAINT `strapi_transfer_token_permissions_token_lnk_fk` FOREIGN KEY (`transfer_token_permission_id`) REFERENCES `strapi_transfer_token_permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `strapi_transfer_token_permissions_token_lnk_ifk` FOREIGN KEY (`transfer_token_id`) REFERENCES `strapi_transfer_tokens` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_transfer_token_permissions_token_lnk`
--

LOCK TABLES `strapi_transfer_token_permissions_token_lnk` WRITE;
/*!40000 ALTER TABLE `strapi_transfer_token_permissions_token_lnk` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_transfer_token_permissions_token_lnk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_transfer_tokens`
--

DROP TABLE IF EXISTS `strapi_transfer_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_transfer_tokens` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `access_key` varchar(255) DEFAULT NULL,
  `last_used_at` datetime(6) DEFAULT NULL,
  `expires_at` datetime(6) DEFAULT NULL,
  `lifespan` bigint DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `strapi_transfer_tokens_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `strapi_transfer_tokens_created_by_id_fk` (`created_by_id`),
  KEY `strapi_transfer_tokens_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `strapi_transfer_tokens_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `strapi_transfer_tokens_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_transfer_tokens`
--

LOCK TABLES `strapi_transfer_tokens` WRITE;
/*!40000 ALTER TABLE `strapi_transfer_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_transfer_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_webhooks`
--

DROP TABLE IF EXISTS `strapi_webhooks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_webhooks` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `url` longtext,
  `headers` json DEFAULT NULL,
  `events` json DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_webhooks`
--

LOCK TABLES `strapi_webhooks` WRITE;
/*!40000 ALTER TABLE `strapi_webhooks` DISABLE KEYS */;
INSERT INTO `strapi_webhooks` VALUES (1,'ISR Revalidation','https://ca-aipatterns-web-prod.mangotree-f65a3b02.centralus.azurecontainerapps.io/api/revalidate?secret=PClOqDYfBc9Kn0cVbuh56jEvSit69AsYn6R5gX1dZO0=','{}','[\"entry.create\", \"entry.update\", \"entry.delete\", \"entry.publish\", \"entry.unpublish\"]',1);
/*!40000 ALTER TABLE `strapi_webhooks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_workflows`
--

DROP TABLE IF EXISTS `strapi_workflows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_workflows` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `content_types` json DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `strapi_workflows_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `strapi_workflows_created_by_id_fk` (`created_by_id`),
  KEY `strapi_workflows_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `strapi_workflows_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `strapi_workflows_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_workflows`
--

LOCK TABLES `strapi_workflows` WRITE;
/*!40000 ALTER TABLE `strapi_workflows` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_workflows` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_workflows_stage_required_to_publish_lnk`
--

DROP TABLE IF EXISTS `strapi_workflows_stage_required_to_publish_lnk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_workflows_stage_required_to_publish_lnk` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `workflow_id` int unsigned DEFAULT NULL,
  `workflow_stage_id` int unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `strapi_workflows_stage_required_to_publish_lnk_uq` (`workflow_id`,`workflow_stage_id`),
  KEY `strapi_workflows_stage_required_to_publish_lnk_fk` (`workflow_id`),
  KEY `strapi_workflows_stage_required_to_publish_lnk_ifk` (`workflow_stage_id`),
  CONSTRAINT `strapi_workflows_stage_required_to_publish_lnk_fk` FOREIGN KEY (`workflow_id`) REFERENCES `strapi_workflows` (`id`) ON DELETE CASCADE,
  CONSTRAINT `strapi_workflows_stage_required_to_publish_lnk_ifk` FOREIGN KEY (`workflow_stage_id`) REFERENCES `strapi_workflows_stages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_workflows_stage_required_to_publish_lnk`
--

LOCK TABLES `strapi_workflows_stage_required_to_publish_lnk` WRITE;
/*!40000 ALTER TABLE `strapi_workflows_stage_required_to_publish_lnk` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_workflows_stage_required_to_publish_lnk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_workflows_stages`
--

DROP TABLE IF EXISTS `strapi_workflows_stages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_workflows_stages` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `strapi_workflows_stages_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `strapi_workflows_stages_created_by_id_fk` (`created_by_id`),
  KEY `strapi_workflows_stages_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `strapi_workflows_stages_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `strapi_workflows_stages_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_workflows_stages`
--

LOCK TABLES `strapi_workflows_stages` WRITE;
/*!40000 ALTER TABLE `strapi_workflows_stages` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_workflows_stages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_workflows_stages_permissions_lnk`
--

DROP TABLE IF EXISTS `strapi_workflows_stages_permissions_lnk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_workflows_stages_permissions_lnk` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `workflow_stage_id` int unsigned DEFAULT NULL,
  `permission_id` int unsigned DEFAULT NULL,
  `permission_ord` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `strapi_workflows_stages_permissions_lnk_uq` (`workflow_stage_id`,`permission_id`),
  KEY `strapi_workflows_stages_permissions_lnk_fk` (`workflow_stage_id`),
  KEY `strapi_workflows_stages_permissions_lnk_ifk` (`permission_id`),
  KEY `strapi_workflows_stages_permissions_lnk_ofk` (`permission_ord`),
  CONSTRAINT `strapi_workflows_stages_permissions_lnk_fk` FOREIGN KEY (`workflow_stage_id`) REFERENCES `strapi_workflows_stages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `strapi_workflows_stages_permissions_lnk_ifk` FOREIGN KEY (`permission_id`) REFERENCES `admin_permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_workflows_stages_permissions_lnk`
--

LOCK TABLES `strapi_workflows_stages_permissions_lnk` WRITE;
/*!40000 ALTER TABLE `strapi_workflows_stages_permissions_lnk` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_workflows_stages_permissions_lnk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `strapi_workflows_stages_workflow_lnk`
--

DROP TABLE IF EXISTS `strapi_workflows_stages_workflow_lnk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `strapi_workflows_stages_workflow_lnk` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `workflow_stage_id` int unsigned DEFAULT NULL,
  `workflow_id` int unsigned DEFAULT NULL,
  `workflow_stage_ord` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `strapi_workflows_stages_workflow_lnk_uq` (`workflow_stage_id`,`workflow_id`),
  KEY `strapi_workflows_stages_workflow_lnk_fk` (`workflow_stage_id`),
  KEY `strapi_workflows_stages_workflow_lnk_ifk` (`workflow_id`),
  KEY `strapi_workflows_stages_workflow_lnk_oifk` (`workflow_stage_ord`),
  CONSTRAINT `strapi_workflows_stages_workflow_lnk_fk` FOREIGN KEY (`workflow_stage_id`) REFERENCES `strapi_workflows_stages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `strapi_workflows_stages_workflow_lnk_ifk` FOREIGN KEY (`workflow_id`) REFERENCES `strapi_workflows` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `strapi_workflows_stages_workflow_lnk`
--

LOCK TABLES `strapi_workflows_stages_workflow_lnk` WRITE;
/*!40000 ALTER TABLE `strapi_workflows_stages_workflow_lnk` DISABLE KEYS */;
/*!40000 ALTER TABLE `strapi_workflows_stages_workflow_lnk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `up_permissions`
--

DROP TABLE IF EXISTS `up_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `up_permissions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `up_permissions_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `up_permissions_created_by_id_fk` (`created_by_id`),
  KEY `up_permissions_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `up_permissions_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `up_permissions_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `up_permissions`
--

LOCK TABLES `up_permissions` WRITE;
/*!40000 ALTER TABLE `up_permissions` DISABLE KEYS */;
INSERT INTO `up_permissions` VALUES (1,'ytpw7s8jh9bhn1ixe5hzwsnm','plugin::users-permissions.auth.changePassword','2026-02-26 18:22:26.527000','2026-02-26 18:22:26.527000','2026-02-26 18:22:26.529000',NULL,NULL,NULL),(2,'cp3mp0wsv2osndheibad6suw','plugin::users-permissions.auth.logout','2026-02-26 18:22:26.527000','2026-02-26 18:22:26.527000','2026-02-26 18:22:26.528000',NULL,NULL,NULL),(3,'jg43kru3y3gw4y8gtqy57m7o','plugin::users-permissions.user.me','2026-02-26 18:22:26.527000','2026-02-26 18:22:26.527000','2026-02-26 18:22:26.528000',NULL,NULL,NULL),(4,'cl7clwwoqr79ih9ru0szxum9','plugin::users-permissions.auth.register','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.272000',NULL,NULL,NULL),(5,'pht6qug4nxmd9zx1yyruy1ka','plugin::users-permissions.auth.forgotPassword','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.272000',NULL,NULL,NULL),(6,'zqkuc37w7r70qtpn288m9hm4','plugin::users-permissions.auth.callback','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.272000',NULL,NULL,NULL),(7,'tt9dy36dd377sxr9sw6zqs1z','plugin::users-permissions.auth.resetPassword','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.272000',NULL,NULL,NULL),(8,'q1lj30yabvk8o5okksws9oqw','plugin::users-permissions.auth.connect','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.272000',NULL,NULL,NULL),(9,'dxnfqwsqv6oqd136vlsawld1','plugin::users-permissions.auth.refresh','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.272000',NULL,NULL,NULL),(10,'nbqx6c00dibnxhf35osdyek8','plugin::users-permissions.auth.emailConfirmation','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.272000',NULL,NULL,NULL),(11,'jisvz8pf3dwmk6ppgnuanldx','plugin::users-permissions.auth.sendEmailConfirmation','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.271000','2026-02-26 18:22:27.272000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `up_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `up_permissions_role_lnk`
--

DROP TABLE IF EXISTS `up_permissions_role_lnk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `up_permissions_role_lnk` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `permission_id` int unsigned DEFAULT NULL,
  `role_id` int unsigned DEFAULT NULL,
  `permission_ord` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `up_permissions_role_lnk_uq` (`permission_id`,`role_id`),
  KEY `up_permissions_role_lnk_fk` (`permission_id`),
  KEY `up_permissions_role_lnk_ifk` (`role_id`),
  KEY `up_permissions_role_lnk_oifk` (`permission_ord`),
  CONSTRAINT `up_permissions_role_lnk_fk` FOREIGN KEY (`permission_id`) REFERENCES `up_permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `up_permissions_role_lnk_ifk` FOREIGN KEY (`role_id`) REFERENCES `up_roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `up_permissions_role_lnk`
--

LOCK TABLES `up_permissions_role_lnk` WRITE;
/*!40000 ALTER TABLE `up_permissions_role_lnk` DISABLE KEYS */;
INSERT INTO `up_permissions_role_lnk` VALUES (1,1,1,1),(2,3,1,1),(3,2,1,1),(4,5,2,1),(5,4,2,1),(6,11,2,1),(7,7,2,1),(8,6,2,1),(9,8,2,1),(10,10,2,1),(11,9,2,1);
/*!40000 ALTER TABLE `up_permissions_role_lnk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `up_roles`
--

DROP TABLE IF EXISTS `up_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `up_roles` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `up_roles_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `up_roles_created_by_id_fk` (`created_by_id`),
  KEY `up_roles_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `up_roles_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `up_roles_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `up_roles`
--

LOCK TABLES `up_roles` WRITE;
/*!40000 ALTER TABLE `up_roles` DISABLE KEYS */;
INSERT INTO `up_roles` VALUES (1,'ucmvc7pcyqlsv1h51vs02n1i','Authenticated','Default role given to authenticated user.','authenticated','2026-02-26 18:22:25.303000','2026-02-26 18:22:25.303000','2026-02-26 18:22:25.304000',NULL,NULL,NULL),(2,'t9ltvqhgrufmoy94ufee36oh','Public','Default role given to unauthenticated user.','public','2026-02-26 18:22:25.792000','2026-02-26 18:22:25.792000','2026-02-26 18:22:25.792000',NULL,NULL,NULL);
/*!40000 ALTER TABLE `up_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `up_users`
--

DROP TABLE IF EXISTS `up_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `up_users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `reset_password_token` varchar(255) DEFAULT NULL,
  `confirmation_token` varchar(255) DEFAULT NULL,
  `confirmed` tinyint(1) DEFAULT NULL,
  `blocked` tinyint(1) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `up_users_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `up_users_created_by_id_fk` (`created_by_id`),
  KEY `up_users_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `up_users_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `up_users_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `up_users`
--

LOCK TABLES `up_users` WRITE;
/*!40000 ALTER TABLE `up_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `up_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `up_users_role_lnk`
--

DROP TABLE IF EXISTS `up_users_role_lnk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `up_users_role_lnk` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int unsigned DEFAULT NULL,
  `role_id` int unsigned DEFAULT NULL,
  `user_ord` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `up_users_role_lnk_uq` (`user_id`,`role_id`),
  KEY `up_users_role_lnk_fk` (`user_id`),
  KEY `up_users_role_lnk_ifk` (`role_id`),
  KEY `up_users_role_lnk_oifk` (`user_ord`),
  CONSTRAINT `up_users_role_lnk_fk` FOREIGN KEY (`user_id`) REFERENCES `up_users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `up_users_role_lnk_ifk` FOREIGN KEY (`role_id`) REFERENCES `up_roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `up_users_role_lnk`
--

LOCK TABLES `up_users_role_lnk` WRITE;
/*!40000 ALTER TABLE `up_users_role_lnk` DISABLE KEYS */;
/*!40000 ALTER TABLE `up_users_role_lnk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `upload_folders`
--

DROP TABLE IF EXISTS `upload_folders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `upload_folders` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `document_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `path_id` int DEFAULT NULL,
  `path` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `created_by_id` int unsigned DEFAULT NULL,
  `updated_by_id` int unsigned DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `upload_folders_path_id_index` (`path_id`),
  UNIQUE KEY `upload_folders_path_index` (`path`),
  KEY `upload_folders_documents_idx` (`document_id`,`locale`,`published_at`),
  KEY `upload_folders_created_by_id_fk` (`created_by_id`),
  KEY `upload_folders_updated_by_id_fk` (`updated_by_id`),
  CONSTRAINT `upload_folders_created_by_id_fk` FOREIGN KEY (`created_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `upload_folders_updated_by_id_fk` FOREIGN KEY (`updated_by_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `upload_folders`
--

LOCK TABLES `upload_folders` WRITE;
/*!40000 ALTER TABLE `upload_folders` DISABLE KEYS */;
/*!40000 ALTER TABLE `upload_folders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `upload_folders_parent_lnk`
--

DROP TABLE IF EXISTS `upload_folders_parent_lnk`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `upload_folders_parent_lnk` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `folder_id` int unsigned DEFAULT NULL,
  `inv_folder_id` int unsigned DEFAULT NULL,
  `folder_ord` double unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `upload_folders_parent_lnk_uq` (`folder_id`,`inv_folder_id`),
  KEY `upload_folders_parent_lnk_fk` (`folder_id`),
  KEY `upload_folders_parent_lnk_ifk` (`inv_folder_id`),
  KEY `upload_folders_parent_lnk_oifk` (`folder_ord`),
  CONSTRAINT `upload_folders_parent_lnk_fk` FOREIGN KEY (`folder_id`) REFERENCES `upload_folders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `upload_folders_parent_lnk_ifk` FOREIGN KEY (`inv_folder_id`) REFERENCES `upload_folders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `upload_folders_parent_lnk`
--

LOCK TABLES `upload_folders_parent_lnk` WRITE;
/*!40000 ALTER TABLE `upload_folders_parent_lnk` DISABLE KEYS */;
/*!40000 ALTER TABLE `upload_folders_parent_lnk` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'strapi_cms'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-09 17:10:50
