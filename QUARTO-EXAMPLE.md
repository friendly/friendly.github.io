# Quarto Example Branch

This branch demonstrates what the site would look like using Quarto instead of R Markdown + Jekyll.

## What's Different

### Structure
- **_quarto.yml**: Single config file for entire site (theme, navigation, settings)
- **index.qmd**: Home page with overview and navigation cards
- **packages.qmd**: R packages with card-based layout
- **books.qmd**: Books page
- **courses.qmd**: Courses page
- **software.qmd**: SAS macros and other software
- **styles.css**: Custom CSS for enhanced styling

### Features
- Modern Bootstrap 5 design with responsive cards
- Dark mode support (toggle in navbar)
- Automatic navigation bar from config
- Card hover effects
- Mobile-friendly responsive layout
- GitHub icon linking to your profile

## How to Use

### Prerequisites
1. Install Quarto: https://quarto.org/docs/get-started/

### Render the Site
```bash
# Preview locally
quarto preview

# Or render to docs/ folder
quarto render
```

### Deploy to GitHub Pages

#### Option 1: Manual (what's configured now)
```bash
quarto render
git add docs/
git commit -m "Update site"
git push
```

Then configure GitHub Pages to serve from `/docs` folder.

#### Option 2: Using Quarto Publish (easier)
```bash
quarto publish gh-pages
```

This automatically builds and deploys to GitHub Pages.

## Comparison with Current Setup

### R Markdown + Jekyll (current master)
- ✓ Familiar R Markdown workflow
- ✗ Limited Jekyll theme options
- ✗ Manual HTML/CSS for modern design
- ✗ Separate config files
- ✗ No built-in dark mode

### Quarto (this branch)
- ✓ Nearly identical .qmd syntax to .Rmd
- ✓ Modern, professional themes out of the box
- ✓ Built-in card/grid components
- ✓ Single _quarto.yml config
- ✓ Dark mode included
- ✓ Better for multi-page sites
- ✓ Native blog support

## Next Steps

1. **Try it locally**: Run `quarto preview` to see the site
2. **Customize**: Edit _quarto.yml to change theme, colors, etc.
3. **Add content**: Create more .qmd pages as needed
4. **Deploy**: Use `quarto publish gh-pages` when ready

## Converting Existing Content

Your existing `.Rmd` files can be converted to `.qmd` with minimal changes:
- Rename `.Rmd` to `.qmd`
- Update YAML header (see examples in this branch)
- Most R code chunks work identically
