# Performance Baseline Guide - Phase 4.5

**Phase:** 4.5 - Testing Foundation & Operational Readiness
**Date Created:** 2026-02-13
**Purpose:** Establish performance baseline metrics for monitoring and improvement

---

## Overview

This guide explains how to measure and document baseline performance metrics using Lighthouse and other tools. These baselines serve as reference points for:
- Detecting performance regressions
- Setting performance budgets
- Tracking improvements over time
- Comparing local vs. production performance

---

## Tools Used

### 1. Lighthouse (Chrome DevTools)
- **Purpose:** Comprehensive performance, accessibility, SEO audit
- **Access:** Chrome DevTools (F12) → Lighthouse tab
- **Metrics:** Performance, Accessibility, Best Practices, SEO, PWA

### 2. Chrome DevTools Performance Tab
- **Purpose:** Detailed runtime performance analysis
- **Access:** Chrome DevTools (F12) → Performance tab
- **Metrics:** FPS, CPU usage, network activity, rendering timeline

### 3. WebPageTest.org (Optional)
- **Purpose:** Real-world performance testing from multiple locations
- **Access:** https://www.webpagetest.org
- **Metrics:** Load time, TTFB, Speed Index, filmstrip view

---

## Lighthouse Testing Procedure

### Step 1: Prepare Environment

**Local Testing:**
```bash
# Start backend
cd backend/src/AIEnterprisePatterns.Api
dotnet run

# Start frontend (production build)
npm run build
npm start
```

**Production Testing:**
- Use deployed production URLs
- Test from multiple locations if possible

### Step 2: Run Lighthouse Audits

**Test These Pages:**
1. Home Page: `/`
2. Patterns Listing: `/patterns`
3. Pattern Detail: `/patterns/clean-architecture-ai-refactoring`

**For Each Page:**

1. Open page in Chrome Incognito mode (Ctrl+Shift+N)
2. Open DevTools (F12)
3. Navigate to Lighthouse tab
4. Configure audit:
   - ✅ Performance
   - ✅ Accessibility
   - ✅ Best Practices
   - ✅ SEO
   - ✅ Progressive Web App (if applicable)
5. Select device: Desktop AND Mobile
6. Click "Analyze page load"
7. Save report (Download HTML or JSON)

**Run Multiple Times:**
- Run 3 audits per page
- Take median scores (middle value)
- Discard outliers (extremely high or low)

### Step 3: Record Core Web Vitals

**Key Metrics:**

| Metric | Acronym | Good | Needs Improvement | Poor |
|--------|---------|------|-------------------|------|
| Largest Contentful Paint | LCP | < 2.5s | 2.5-4.0s | > 4.0s |
| First Input Delay | FID | < 100ms | 100-300ms | > 300ms |
| Cumulative Layout Shift | CLS | < 0.1 | 0.1-0.25 | > 0.25 |
| First Contentful Paint | FCP | < 1.8s | 1.8-3.0s | > 3.0s |
| Time to Interactive | TTI | < 3.8s | 3.8-7.3s | > 7.3s |
| Total Blocking Time | TBT | < 200ms | 200-600ms | > 600ms |
| Speed Index | SI | < 3.4s | 3.4-5.8s | > 5.8s |

### Step 4: Document Results

Use the template in `PERFORMANCE_BASELINE_RESULTS_TEMPLATE.md`

---

## Performance Testing Checklist

### Page-Level Tests

**Home Page:**
- [ ] Lighthouse Performance score > 90 (Desktop)
- [ ] Lighthouse Performance score > 80 (Mobile)
- [ ] LCP < 2.5s
- [ ] CLS < 0.1
- [ ] TTI < 3.8s
- [ ] Load time < 2s
- [ ] No render-blocking resources
- [ ] Images optimized (WebP, lazy loading)

**Patterns Listing:**
- [ ] Lighthouse Performance score > 85 (Desktop)
- [ ] Lighthouse Performance score > 75 (Mobile)
- [ ] LCP < 3.0s (data-dependent)
- [ ] Pagination loads instantly
- [ ] Filter/sort updates quickly (<100ms)
- [ ] Scroll performance smooth (60fps)

**Pattern Detail:**
- [ ] Lighthouse Performance score > 90 (Desktop)
- [ ] Lighthouse Performance score > 80 (Mobile)
- [ ] LCP < 2.5s
- [ ] Markdown rendering fast
- [ ] Voting interaction instant (<50ms)
- [ ] Navigation quick

### Network Performance

- [ ] Minimize HTTP requests (< 50 for home page)
- [ ] Enable compression (gzip/brotli)
- [ ] Use HTTP/2
- [ ] Implement caching headers
- [ ] CDN for static assets (if applicable)

### Bundle Size

**Measure with:**
```bash
npm run build
# Check output for bundle sizes
```

**Targets:**
- Main JS bundle: < 200KB (gzipped)
- CSS bundle: < 50KB (gzipped)
- Total initial load: < 300KB (gzipped)

### Image Optimization

- [ ] Images in modern formats (WebP, AVIF)
- [ ] Responsive images (srcset)
- [ ] Lazy loading enabled
- [ ] Appropriate compression
- [ ] No oversized images

---

## Performance Optimization Quick Wins

If baseline is below target, try these optimizations:

### 1. Image Optimization
```bash
# Use next/image component (already using)
<Image src="/pattern.jpg" width={300} height={200} alt="..." />
```

### 2. Code Splitting
```javascript
// Dynamic imports for heavy components
const HeavyComponent = dynamic(() => import('./HeavyComponent'))
```

### 3. Font Optimization
```javascript
// Use next/font (already configured)
import { Inter } from 'next/font/google'
const inter = Inter({ subsets: ['latin'] })
```

### 4. API Response Caching
```typescript
// Already implemented - verify revalidation times
export const revalidate = 300 // 5 minutes
```

### 5. Database Query Optimization
- Use projections (already done)
- Add indexes on frequently queried columns
- Implement query result caching

---

## Continuous Monitoring

### Set Up Performance Budgets

Create `next.config.js` performance budgets:
```javascript
module.exports = {
  performanceBudgets: {
    'first-contentful-paint': 1.8,
    'largest-contentful-paint': 2.5,
    'cumulative-layout-shift': 0.1,
  }
}
```

### Automated Lighthouse CI

Add to GitHub Actions (future enhancement):
```yaml
- name: Run Lighthouse CI
  run: |
    npm install -g @lhci/cli
    lhci autorun
```

### Monitor in Production

Use Application Insights browser telemetry:
- Page load times
- AJAX call durations
- User interactions
- Error rates

---

## Performance Baseline Template

Save results using this template:

```markdown
# Performance Baseline - [Date]

## Environment
- **URL:** http://localhost:3000 (or production)
- **Device:** Desktop (1920x1080) / Mobile (375x667)
- **Network:** Fast 3G / 4G / WiFi
- **Browser:** Chrome XXX

## Lighthouse Scores (Median of 3 runs)

### Home Page
| Metric | Desktop | Mobile |
|--------|---------|--------|
| Performance | XX | XX |
| Accessibility | XX | XX |
| Best Practices | XX | XX |
| SEO | XX | XX |

### Core Web Vitals
| Metric | Value | Status |
|--------|-------|--------|
| LCP | X.Xs | ✅ Good |
| FID | XXms | ✅ Good |
| CLS | 0.XX | ✅ Good |
| FCP | X.Xs | ✅ Good |
| TTI | X.Xs | ✅ Good |

## Opportunities for Improvement
1. [Opportunity 1]
2. [Opportunity 2]
```

---

## Troubleshooting

### Low Performance Scores

**Common Causes:**
1. Unoptimized images
2. Render-blocking resources
3. Large JavaScript bundles
4. Slow API responses
5. No caching headers

**Debug Steps:**
1. Check Lighthouse "Opportunities" section
2. Review Network tab for slow requests
3. Analyze bundle sizes
4. Check for unused code
5. Verify caching is working

### Inconsistent Results

**Solutions:**
- Run in Incognito mode
- Clear cache between runs
- Close other tabs/apps
- Use consistent network conditions
- Take median of 3+ runs

---

## Next Steps

After establishing baseline:

1. **Set Performance Budgets** - Define acceptable thresholds
2. **Monitor Regularly** - Weekly or after each deployment
3. **Track Trends** - Compare over time to detect regressions
4. **Optimize** - Address issues found in audits
5. **Retest** - Verify improvements

---

**Reference Links:**
- [Web Vitals](https://web.dev/vitals/)
- [Lighthouse Scoring](https://developer.chrome.com/docs/lighthouse/performance/performance-scoring/)
- [Next.js Performance](https://nextjs.org/docs/app/building-your-application/optimizing)

---

**Created:** 2026-02-13
**Author:** Claude Code
