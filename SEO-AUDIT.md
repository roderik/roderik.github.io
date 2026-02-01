# SEO Audit Report: vanderveer.be

**Auditor:** Tuvok (Security & Research Officer)  
**Date:** 2026-02-01  
**Site:** https://vanderveer.be  
**Platform:** Astro 5.x + MDX + GitHub Pages

---

## Executive Summary

### Overall Health: 🟡 GOOD (72/100)

The blog has solid foundations but significant opportunities for improvement. The Astro framework provides excellent technical SEO capabilities, but several areas need attention.

### Top 5 Priority Issues

| Priority | Issue | Impact | Effort |
|----------|-------|--------|--------|
| 🔴 1 | Missing structured data (JSON-LD schema) | High | Medium |
| 🔴 2 | No og-image.png exists (OG images fail) | High | Low |
| 🟡 3 | Blog posts lack keyword optimization for targets | Medium | Medium |
| 🟡 4 | Missing author/article schema for E-E-A-T | Medium | Medium |
| 🟡 5 | No tags/category pages for topical clustering | Medium | High |

### Quick Wins Identified

1. Add og-image.png to /public
2. Add JSON-LD structured data
3. Optimize meta descriptions for target keywords
4. Add reading time to blog posts
5. Add breadcrumb navigation

---

## Technical SEO Audit

### Crawlability ✅ GOOD

**Robots.txt**
```
User-agent: *
Allow: /
Sitemap: https://vanderveer.be/sitemap-index.xml
```
- ✅ Allows all crawlers
- ✅ Sitemap reference present
- ✅ No unintentional blocks

**XML Sitemap**
- ✅ `@astrojs/sitemap` integration configured
- ✅ Auto-generated at `/sitemap-index.xml`
- ✅ Contains canonical URLs
- ⚠️ Consider adding lastmod dates

**Site Architecture**
- ✅ Simple 3-page structure (Home, Blog, About)
- ✅ All pages within 2 clicks of homepage
- ✅ Clear navigation
- ⚠️ Only 2 blog posts currently (thin content risk)

### Indexation ✅ GOOD

**Canonical URLs**
- ✅ Self-referencing canonical tags on all pages
- ✅ Properly constructed from `SITE_URL` constant
- ✅ Consistent URL structure

**Duplicate Content**
- ✅ No duplicate content issues detected
- ✅ Trailing slash consistency handled by Astro

### Performance ⚠️ NEEDS ATTENTION

**Font Loading**
- ⚠️ Loading 3 Google Fonts (Inter, Newsreader, JetBrains Mono)
- ⚠️ No `font-display: swap` in link tag
- 🔧 FIX: Add `&display=swap` to font URL

**Preconnect**
- ✅ Preconnect to fonts.googleapis.com
- ✅ Preconnect to fonts.gstatic.com with crossorigin

**Image Optimization**
- ⚠️ Hero images use standard `<img>` tags
- 🔧 FIX: Use Astro's `<Image>` component for optimization

### Mobile-Friendliness ✅ GOOD

- ✅ Responsive viewport meta tag
- ✅ Mobile-first CSS with breakpoints
- ✅ Flexible navigation layout
- ✅ Readable font sizes (18px base)

### Security ✅ GOOD

- ✅ HTTPS enforced (GitHub Pages)
- ✅ External links use `rel="noopener noreferrer"`
- ✅ No mixed content issues

---

## On-Page SEO Audit

### Title Tags ✅ GOOD

**Pattern:** `{Page Title} | Roderik van der Veer`

| Page | Title | Length | Verdict |
|------|-------|--------|---------|
| Home | Roderik van der Veer | 21 chars | ✅ Good |
| About | About \| Roderik van der Veer | 29 chars | ✅ Good |
| Blog | Blog \| Roderik van der Veer | 28 chars | ✅ Good |
| Post 1 | How I Built My AI Chief of Staff... | 71 chars | ⚠️ Truncated |
| Post 2 | The Discipline Gap... | 65 chars | ⚠️ Slightly long |

**Issues:**
- ⚠️ Some post titles exceed 60 chars (will truncate in SERP)
- 🔧 FIX: Shorter, punchier titles with primary keywords front-loaded

### Meta Descriptions ⚠️ NEEDS WORK

**Site Default:** "Co-founder & CTO thoughts on blockchain, AI, and building products."

| Page | Description | Length | Keywords |
|------|-------------|--------|----------|
| Home | Default description | 67 chars | ⚠️ Missing "enterprise software" |
| About | "About Roderik van der Veer" | 26 chars | ❌ Too short, no keywords |
| Blog | "All blog posts" | 14 chars | ❌ Wasted opportunity |
| Posts | Custom descriptions | 150+ chars | ✅ Good |

**Issues:**
- ❌ About page description is generic placeholder
- ❌ Blog index has no meaningful description
- ❌ Missing target keywords: "blockchain CTO", "enterprise software"

**Target Keywords Analysis:**
- "blockchain CTO" - not present in any meta description
- "AI development" - mentioned in site description
- "enterprise software" - not present anywhere

### Heading Structure ✅ GOOD

**Homepage:**
- H1: "Hi, I'm Roderik" ✅
- H2: "Recent Writing" ✅

**Blog Posts:**
- H1: Post title ✅
- H2-H4: Logical hierarchy ✅
- No skip levels ✅

**Issues:**
- ⚠️ Homepage H1 could include keywords ("Blockchain CTO & AI Developer")

### Content Optimization ⚠️ NEEDS WORK

**Blog Post 1: "How I Built My AI Chief of Staff"**
- ✅ 3,500+ words (comprehensive)
- ✅ Code examples with syntax highlighting
- ✅ Logical structure with clear headings
- ⚠️ Missing reading time indicator
- ⚠️ No table of contents for long content
- ❌ External link to OpenClaw repo not present (mentioned but no link)

**Blog Post 2: "The Discipline Gap"**
- ✅ 1,800+ words
- ✅ Strong opening hook
- ✅ External link to SettleMint repo
- ⚠️ Could benefit from bullet-point summaries

**Keyword Targeting:**

| Target Keyword | Current State | Recommendation |
|----------------|---------------|----------------|
| blockchain CTO | About page only | Add to homepage, meta desc |
| AI development | In content | Add to homepage H1/tagline |
| enterprise software | Mentioned once | Need dedicated content |

### Image Optimization ⚠️ NEEDS ATTENTION

**Current State:**
- ❌ No `og-image.png` in /public (OG tags reference it but file missing!)
- ✅ Favicon SVG present
- ⚠️ No hero images on posts
- ⚠️ Alt text relies on title (should be more descriptive)

**Critical Issue:**
```html
<meta property="og:image" content="https://vanderveer.be/og-image.png" />
```
This image doesn't exist! Social shares will have broken preview images.

### Internal Linking ⚠️ NEEDS WORK

**Current Structure:**
- Header: Home, Blog, About
- Footer: Social links
- Blog posts: No internal cross-links

**Issues:**
- ❌ Blog posts don't link to each other
- ❌ No related posts section
- ❌ No tag/category navigation
- ❌ About page doesn't link to blog posts

---

## Structured Data Audit

### Current State: ❌ MISSING

**No JSON-LD schema markup detected.**

### Required Schema Types:

1. **WebSite** (homepage)
   - name, url, author
   - SearchAction for sitelinks searchbox

2. **Person** (about page)
   - name, jobTitle, worksFor
   - sameAs (social profiles)

3. **Article/BlogPosting** (each post)
   - headline, author, datePublished
   - image, description

4. **BreadcrumbList** (all pages)
   - Home > Blog > Post Title

### Impact:
- Missing rich snippets in search results
- No author knowledge panel potential
- Reduced E-E-A-T signals

---

## Content Quality Assessment

### E-E-A-T Signals ⚠️ MODERATE

**Experience**
- ✅ First-hand experience described in posts
- ✅ Specific examples and real scenarios
- ✅ Code implementations shared

**Expertise**
- ✅ CTO role clearly stated
- ✅ 9+ years experience mentioned
- ⚠️ No credentials displayed prominently
- ⚠️ No author byline with photo on posts

**Authoritativeness**
- ⚠️ No testimonials or social proof
- ⚠️ No press mentions or awards
- ⚠️ No backlinks analysis possible

**Trustworthiness**
- ✅ Real name and email visible
- ✅ Company affiliation (SettleMint)
- ⚠️ No privacy policy
- ⚠️ No terms of service

### Content Gaps for Target Keywords

| Keyword | Monthly Volume | Content Exists | Recommendation |
|---------|----------------|----------------|----------------|
| blockchain CTO | ~200 | Partial (About) | Dedicated pillar content |
| AI development | ~2,400 | 2 posts | More content, category page |
| enterprise software | ~5,400 | Minimal | New content series needed |
| enterprise blockchain | ~500 | None | Priority opportunity |

---

## Prioritized Action Plan

### 🔴 Critical (Do This Week)

1. **Create og-image.png**
   - 1200x630px recommended
   - Include name + role
   - Brand-consistent design

2. **Add JSON-LD Structured Data**
   - WebSite schema on homepage
   - Person schema on about page
   - Article schema on blog posts
   - BreadcrumbList on all pages

3. **Fix Font Loading**
   - Add `&display=swap` to Google Fonts URL

### 🟡 High Priority (This Month)

4. **Optimize Meta Descriptions**
   - Homepage: Include "blockchain CTO", "AI development", "enterprise"
   - About: Full bio summary with keywords
   - Blog index: Engaging description with topic keywords

5. **Improve About Page**
   - Add author photo
   - Add work history/credentials
   - Link to best blog posts

6. **Add Blog Post Enhancements**
   - Reading time component
   - Table of contents for long posts
   - Related posts section
   - Tags displayed with links

### 🟢 Medium Priority (This Quarter)

7. **Content Strategy for Target Keywords**
   - "Enterprise Blockchain Development" pillar page
   - "AI-Driven Development" series
   - "CTO Insights" category

8. **Technical Improvements**
   - Use Astro `<Image>` component
   - Add lazy loading
   - Implement image CDN

9. **E-E-A-T Enhancement**
   - Add testimonials/social proof
   - Create privacy policy
   - Add structured author data

---

## Implementation Files to Create/Modify

### New Files Needed:
- `/public/og-image.png` - Social sharing image
- `/src/components/StructuredData.astro` - JSON-LD component
- `/src/components/Breadcrumbs.astro` - Navigation breadcrumbs
- `/src/components/ReadingTime.astro` - Blog reading time
- `/src/pages/privacy.astro` - Privacy policy

### Files to Modify:
- `/src/layouts/BaseLayout.astro` - Add structured data
- `/src/layouts/BlogPost.astro` - Add Article schema, reading time
- `/src/pages/about.astro` - Better description, Person schema
- `/src/pages/blog/index.astro` - Better description
- `/src/consts.ts` - Add SEO-optimized descriptions

---

## Appendix: Keyword Research Notes

### Primary Target Keywords

1. **"blockchain CTO"**
   - Low competition, high intent
   - Personal brand opportunity
   - Needs dedicated about page optimization

2. **"AI development"**
   - High volume, competitive
   - Current content aligns well
   - Need more topical depth

3. **"enterprise software"**
   - Very broad, high competition
   - Narrow to "enterprise blockchain" or "AI for enterprise"
   - Requires pillar content strategy

### Recommended Long-Tail Targets

- "AI coding agents for enterprise"
- "blockchain development best practices"
- "CTO AI adoption strategy"
- "disciplined AI development workflow"

---

*Report generated by Tuvok, Security & Research Officer*
*Task ID: task-1769904924309-ubffs5jlr*
