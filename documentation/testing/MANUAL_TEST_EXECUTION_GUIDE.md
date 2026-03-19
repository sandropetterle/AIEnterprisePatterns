# Manual Test Execution Guide - Phase 4.5

**Phase:** 4.5 - Testing Foundation & Operational Readiness
**Date Created:** 2026-02-13
**Purpose:** Guide for executing comprehensive manual testing

---

## Overview

This guide explains how to execute the comprehensive test plan from [MANUAL_TEST_PLAN.md](MANUAL_TEST_PLAN.md) and record results systematically.

---

## Prerequisites

### 1. Start Backend (ASP.NET Core)

```bash
cd backend/src/AIEnterprisePatterns.Api
dotnet run
```

**Verify:** Navigate to http://localhost:5255/health
- Should see: `"Healthy"`

**Swagger (Development only):** http://localhost:5255/swagger

### 2. Start Frontend (Next.js)

```bash
# From project root
npm run dev
```

**Verify:** Navigate to http://localhost:3000
- Should see the home page load

### 3. Verify Database

Backend should auto-create SQLite database with seed data on first run.

**Verify seed data exists:**
```bash
# Check if database file exists
ls backend/src/AIEnterprisePatterns.Api/aipatterns.db

# Or verify via Swagger:
# Open http://localhost:5255/swagger
# Execute GET /api/patterns - should return 6 patterns
```

---

## Test Execution Process

### Step 1: Create Test Results File

Copy the template to create a new test run file:

```bash
cp documentation/test_results/MANUAL_TEST_RESULTS_TEMPLATE.md \
   documentation/test_results/manual_test_run_$(date +%Y-%m-%d_%H-%M).md
```

### Step 2: Execute Test Suites

Work through each test suite in [MANUAL_TEST_PLAN.md](MANUAL_TEST_PLAN.md):

1. **Home Page Tests** (Suite 1)
2. **Patterns Listing Tests** (Suite 2)
3. **Pattern Detail Tests** (Suite 3)
4. **Visual & Responsive Tests** (Suite 4)
5. **Navigation & Links** (Suite 5)
6. **Error Handling** (Suite 6)
7. **Performance** (Suite 7)
8. **Accessibility** (Suite 8)
9. **Security** (Suite 9)

For each test:
- ✅ **Pass** - Feature works as expected
- ❌ **Fail** - Feature doesn't work or has issues
- ⚠️ **Partial** - Works but with minor issues
- ⏭️ **Skipped** - Not tested (note reason)

### Step 3: Document Issues

For each failure, record:
- **Test ID** - Reference from test plan
- **Issue Description** - What went wrong
- **Steps to Reproduce** - How to trigger the issue
- **Expected Behavior** - What should happen
- **Actual Behavior** - What actually happens
- **Severity** - Critical, High, Medium, Low
- **Screenshots** - If applicable

### Step 4: Calculate Results

After completing all tests:
```
Pass Rate = (Passed Tests / Total Tests) × 100%
```

**Target:** >95% pass rate for production readiness

---

## Testing Tips

### Browser Testing

**Test in multiple browsers:**
- Chrome/Edge (Chromium)
- Firefox
- Safari (if on Mac)

**Viewport testing:**
- Desktop: 1920x1080
- Tablet: 768x1024
- Mobile: 375x667

Use browser DevTools (F12) → Device Toolbar to simulate viewports.

### API Testing

Use Swagger UI or tools like Postman/Insomnia to test API endpoints directly:
- http://localhost:5255/swagger

**Critical endpoints:**
- `GET /api/patterns` - List patterns
- `GET /api/patterns/{slug}` - Get pattern by slug
- `POST /api/patterns/{id}/vote` - Vote for pattern
- `GET /api/patterns/featured` - Featured patterns
- `GET /api/patterns/trending` - Trending patterns

### Error Scenario Testing

**Test error handling:**
1. **404 Not Found** - Navigate to `/patterns/nonexistent-slug`
2. **Network Error** - Stop backend while frontend is running, try to load data
3. **Validation Error** - Try to create pattern with invalid data (via Swagger)
4. **Rate Limiting** - Spam vote endpoint (>10 times in 1 minute per IP)

### Performance Testing

**Check loading times:**
- Home page should load in <2s
- Patterns listing should load in <2s
- Pattern detail should load in <1.5s

**Check for:**
- Smooth scrolling
- No layout shifts
- Fast navigation
- Responsive interactions

### Accessibility Testing

**Keyboard navigation:**
- Tab through all interactive elements
- Use Enter/Space to activate buttons
- Verify focus indicators are visible

**Screen reader testing (optional):**
- Windows: NVDA (free)
- Mac: VoiceOver (built-in)
- Chrome: ChromeVox extension

**Color contrast:**
- Use browser DevTools → Lighthouse → Accessibility audit

---

## Common Issues & Solutions

### Issue: Backend not starting

**Error:** Port 5255 already in use

**Solution:**
```bash
# Find and kill process on port 5255 (Windows)
netstat -ano | findstr :5255
taskkill /PID <pid> /F

# Or change port in launchSettings.json
```

### Issue: Frontend not loading patterns

**Symptoms:** "Failed to load patterns" error

**Check:**
1. Is backend running? http://localhost:5255/health
2. Is CORS configured? Backend allows http://localhost:3000 by default
3. Check browser console for error messages (F12)
4. Verify `NEXT_PUBLIC_API_BASE_URL` in `.env.local`

### Issue: Database is empty

**Solution:** Delete database and restart backend to trigger seed data:
```bash
rm backend/src/AIEnterprisePatterns.Api/aipatterns.db
cd backend/src/AIEnterprisePatterns.Api
dotnet run
```

### Issue: Markdown not rendering

**Check:**
- Pattern has `FullContent` in database
- react-markdown is installed: `npm list react-markdown`
- No console errors in browser

---

## Test Result Reporting

### Pass Criteria

**Production Ready** if:
- ✅ 95%+ pass rate overall
- ✅ All Critical tests passing
- ✅ No High severity bugs
- ✅ All security tests passing
- ✅ Performance meets targets

**Needs Fixes** if:
- ⚠️ 85-95% pass rate
- ⚠️ 1-2 Critical tests failing
- ⚠️ 3-5 High severity bugs

**Blocking Issues** if:
- ❌ <85% pass rate
- ❌ 3+ Critical tests failing
- ❌ Security vulnerabilities found

### Report Template

After testing, create a summary report:

```markdown
# Manual Test Execution Report

**Date:** YYYY-MM-DD
**Tester:** Your Name
**Environment:** Local Development
**Browsers Tested:** Chrome 120, Firefox 121, Safari 17

## Results Summary

- **Total Tests:** X
- **Passed:** X (XX%)
- **Failed:** X (XX%)
- **Skipped:** X (XX%)

## Critical Issues

1. [Issue #1 Title] - Severity: Critical
   - Description: ...
   - Impact: ...

## High Priority Issues

1. [Issue #2 Title] - Severity: High

## Recommendations

- Fix critical issues before production
- Consider fixes for high priority items
- Medium/low issues can be backlog

## Conclusion

[Ready for Production / Needs Fixes / Blocking Issues]
```

---

## Next Steps After Testing

1. **Document all issues** in GitHub Issues
2. **Prioritize fixes** (Critical → High → Medium → Low)
3. **Create remediation plan** if needed
4. **Retest after fixes** to verify resolution
5. **Update test results** document with final status

---

## Reference Links

- [MANUAL_TEST_PLAN.md](MANUAL_TEST_PLAN.md) - Full test scenarios
- [TESTING_STRATEGY.md](../TESTING_STRATEGY.md) - Overall testing approach
- [Backend API Docs](http://localhost:5255/swagger) - Swagger UI (dev only)

---

**Created:** 2026-02-13
**Updated:** 2026-02-13
**Author:** Claude Code
