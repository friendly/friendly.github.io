# Blog Setup Plan for friendly.github.io

## Overview

Quarto has built-in support for blogs through its **listing** feature. A blog is essentially a collection of posts (individual `.qmd` files) that are automatically organized and displayed with metadata like dates, categories, and descriptions.

## Setup Options

### Option 1: Integrated Blog (Recommended)

Add a blog section directly to your existing site at `friendly.github.io/blog/`

**Pros:**
- Single cohesive site
- Same navigation and styling
- All content in one repository
- Easier to maintain

**Cons:**
- Site rebuild time increases with many posts
- All in one repo (could get large)

### Option 2: Separate Blog Site

Create a separate Quarto blog at a different URL or subdomain.

**Pros:**
- Independent from main site
- Faster builds for each
- Can have different styling

**Cons:**
- Two sites to maintain
- Need to manage cross-linking
- More complex deployment

## Recommended Setup: Integrated Blog

### 1. Directory Structure

```
friendly.github.io/
├── _quarto.yml
├── index.qmd
├── packages.qmd
├── books.qmd
├── courses.qmd
├── software.qmd
├── blog/
│   ├── index.qmd          # Blog listing page
│   └── posts/
│       ├── 2024-01-15-first-post/
│       │   ├── index.qmd
│       │   └── image.png
│       ├── 2024-02-20-second-post/
│       │   └── index.qmd
│       └── ...
└── images/
```

### 2. Configuration Changes

Add to `_quarto.yml`:

```yaml
website:
  navbar:
    left:
      - text: "Home"
        href: index.qmd
      - text: "R Packages"
        href: packages.qmd
      - text: "Books"
        href: books.qmd
      - text: "Courses"
        href: courses.qmd
      - text: "Software"
        href: software.qmd
      - text: "Blog"              # Add this
        href: blog/index.qmd
```

### 3. Create Blog Listing Page

Create `blog/index.qmd`:

```yaml
---
title: "Blog"
listing:
  contents: posts
  sort: "date desc"
  type: default
  categories: true
  sort-ui: false
  filter-ui: false
page-layout: full
---

Thoughts on data visualization, statistical graphics, and R programming.
```

### 4. Blog Listing Display Options

Quarto offers three main listing styles:

**`type: default`** - Simple list with title, date, description, and image
- Clean, professional look
- Good for text-focused posts

**`type: grid`** - Card-based grid layout
- Visual, modern design
- Matches your current package cards style
- Good if posts have featured images

**`type: table`** - Tabular format
- Compact, information-dense
- Good for many posts

**Recommendation:** Use `type: grid` to match your existing card-based design.

### 5. Creating a New Blog Post

Each post is a folder with an `index.qmd` file:

**Create:** `blog/posts/2025-01-15-my-post-title/index.qmd`

```yaml
---
title: "My Post Title"
description: "A brief description of the post"
author: "Michael Friendly"
date: "2025-01-15"
categories: [data-viz, R, ggplot2]
image: "featured-image.png"  # optional
draft: false
---

Your post content goes here...

## Section 1

Content with code chunks:

```{r}
library(ggplot2)
ggplot(mtcars, aes(mpg, hp)) + geom_point()
```

## Section 2

More content...
```

### 6. Post Metadata Fields

- **title**: Post title (required)
- **description**: Brief summary shown in listings
- **author**: Your name (can set default in `_quarto.yml`)
- **date**: Publication date (required for sorting)
- **categories**: Tags for filtering (optional)
- **image**: Featured image for the post card (optional)
- **draft**: Set to `true` to hide from site while working

### 7. Enhanced Blog Configuration

For a more feature-rich blog, update `blog/index.qmd`:

```yaml
---
title: "Blog"
listing:
  contents: posts
  sort: "date desc"
  type: grid
  categories: true
  sort-ui: true          # Allow readers to sort
  filter-ui: true        # Allow category filtering
  page-size: 10          # Posts per page
  image-height: 200px
  fields: [image, date, title, description, categories]
page-layout: full
---

Thoughts on data visualization, statistical graphics, R programming, and the history of data visualization.
```

### 8. Setting Default Metadata

Add to `_quarto.yml` to avoid repeating in each post:

```yaml
website:
  # ... existing config ...

# Blog post defaults
metadata:
  author: "Michael Friendly"

# Freeze computational output by default
execute:
  freeze: auto
```

### 9. Adding RSS Feed

Quarto can automatically generate an RSS feed:

Add to `blog/index.qmd`:

```yaml
---
title: "Blog"
listing:
  # ... existing listing config ...
  feed:
    title: "Michael Friendly's Blog"
    description: "Data visualization, statistical graphics, and R programming"
    items: 20
---
```

This creates `blog/index.xml` that readers can subscribe to.

### 10. Workflow for New Posts

1. **Create post directory:**
   ```bash
   mkdir blog/posts/YYYY-MM-DD-post-slug
   ```

2. **Create index.qmd:**
   ```bash
   # Copy from a template or create new
   touch blog/posts/YYYY-MM-DD-post-slug/index.qmd
   ```

3. **Write your post** in the `index.qmd` file

4. **Preview locally:**
   ```bash
   quarto preview
   ```
   Or just render:
   ```bash
   quarto render
   ```

5. **Commit and push:**
   ```bash
   git add blog/posts/YYYY-MM-DD-post-slug
   git commit -m "Add blog post: Post Title"
   git push
   ```

### 11. Post Organization Best Practices

**Date-based folders:** `YYYY-MM-DD-descriptive-slug/`
- Easy to sort chronologically
- Slug describes content
- Each post folder can contain images, data, etc.

**Self-contained posts:** Each post folder has everything it needs
- `index.qmd` - the post
- Images used in the post
- Data files if needed
- Supporting R scripts

### 12. Styling Considerations

The blog will automatically use your existing `styles.css`. You may want to add blog-specific styles:

```css
/* Blog post styling */
.blog-post {
  max-width: 800px;
  margin: 0 auto;
}

/* Listing card styling */
.quarto-listing-grid .card {
  /* Inherits from your existing .card styles */
}

/* Featured image in post */
.featured-image {
  width: 100%;
  border-radius: 8px;
  margin-bottom: 2rem;
}
```

### 13. Example First Post

Create `blog/posts/2025-01-welcome/index.qmd`:

```yaml
---
title: "Welcome to My Blog"
description: "Introducing my new blog on data visualization and statistical graphics"
author: "Michael Friendly"
date: "2025-01-15"
categories: [announcement]
---

I'm excited to launch this blog as a space to share thoughts on data visualization, statistical graphics, R programming, and the history of statistical thinking.

## What to Expect

I'll be writing about:

- New developments in my R packages
- Interesting visualizations and graphical methods
- Historical perspectives on data visualization
- Teaching experiences and course materials
- Conference presentations and papers

## Stay Connected

You can follow along via:

- RSS feed (coming soon)
- [BlueSky](https://bsky.app/profile/datavisfriendly.bsky.social)
- [GitHub](https://github.com/friendly)

Stay tuned for more!
```

## Suggested Categories

Categories appear as filterable tags on the blog listing page. Keep them lowercase with hyphens.
Use 1–3 per post; prefer existing categories over creating new ones.

| Category | Use for |
|---|---|
| `announcement` | Site news, new features, welcome posts |
| `R` | General R programming tips and tricks |
| `packages` | R package releases, updates, worked examples |
| `ggplot2` | ggplot2-specific techniques and extensions |
| `data-visualization` | Visualization techniques, principles, design |
| `statistical-graphics` | More formal or technical graphical methods |
| `history` | History of data visualization and statistics |
| `teaching` | Courses, pedagogy, student work |
| `categorical-data` | Categorical data analysis topics |
| `multivariate` | Multivariate data, models, and graphics |
| `quarto` | Quarto tips, book writing, reproducible docs |
| `talks` | Conference presentations and slides |
| `papers` | Publications, preprints, research highlights |

## Implementation Checklist

- [ ] Decide on integrated vs. separate blog
- [ ] Create `blog/` directory
- [ ] Create `blog/posts/` directory
- [ ] Create `blog/index.qmd` with listing configuration
- [ ] Update `_quarto.yml` to add Blog to navbar
- [ ] Write first blog post as a test
- [ ] Render and preview locally
- [ ] Adjust styling if needed
- [ ] Commit and push to GitHub
- [ ] Verify deployment on GitHub Pages

## Additional Features to Consider

1. **Comments:** Add Utterances (GitHub issues), Giscus (GitHub discussions), or Hypothesis
2. **Search:** Enable Quarto's built-in search in `_quarto.yml`
3. **Related posts:** Show related posts at bottom based on categories
4. **Reading time:** Calculate and display estimated reading time
5. **Social sharing:** Add share buttons for posts
6. **Newsletter:** Link to a newsletter signup (e.g., Substack, Buttondown)

## Resources

- [Quarto Blogs Documentation](https://quarto.org/docs/websites/website-blog.html)
- [Quarto Listings Documentation](https://quarto.org/docs/websites/website-listings.html)
- [Example Quarto Blogs](https://quarto.org/docs/gallery/#websites)

## Notes

- All blog posts support the same features as other Quarto documents: code chunks, citations, cross-references, etc.
- The `freeze: auto` option caches R code output, so posts don't need to re-run code on every site build
- You can have multiple blogs on one site (e.g., `/blog/` for main posts, `/notes/` for shorter updates)
- Posts can be written in R Markdown (`.qmd`), Jupyter (`.ipynb`), or plain Markdown (`.md`)
