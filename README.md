# vanderveer.be

Personal blog built with [Astro](https://astro.build), deployed on GitHub Pages.

## Quick Start

```bash
# Install dependencies
npm install

# Start dev server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## Project Structure

```
├── src/
│   ├── components/     # Reusable Astro components
│   ├── content/
│   │   └── blog/       # Markdown blog posts
│   ├── layouts/        # Page layouts
│   ├── pages/          # Route pages
│   └── styles/         # Global CSS
├── public/             # Static assets
└── astro.config.mjs    # Astro configuration
```

## Writing Posts

Create a new `.md` file in `src/content/blog/`:

```markdown
---
title: 'Post Title'
description: 'A brief description'
pubDate: 2026-01-20
tags: ['tag1', 'tag2']
draft: false
---

Your content here...
```

## Deployment

Pushes to `main` automatically deploy via GitHub Actions.

## Configuration

Edit `src/consts.ts` to update site metadata and social links.
