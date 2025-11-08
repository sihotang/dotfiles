# Jekyll Themes Guide

This guide shows you how to change and customize the theme for your GitHub Pages site.

## Built-in Jekyll Themes

GitHub Pages supports these built-in themes. To change themes, update `_config.yml`:

### Available Themes

1. **Minimal** (current)
   ```yaml
   theme: jekyll-theme-minimal
   ```
   - Clean, simple design
   - Good for documentation

2. **Cayman**
   ```yaml
   theme: jekyll-theme-cayman
   ```
   - Modern, colorful
   - Great for project documentation

3. **Hacker**
   ```yaml
   theme: jekyll-theme-hacker
   ```
   - Dark theme with green text
   - Tech/developer focused

4. **Midnight**
   ```yaml
   theme: jekyll-theme-midnight
   ```
   - Dark blue theme
   - Easy on the eyes

5. **Slate**
   ```yaml
   theme: jekyll-theme-slate
   ```
   - Dark gray theme
   - Professional look

6. **Modernist**
   ```yaml
   theme: jekyll-theme-modernist
   ```
   - Clean, modern design
   - Minimalist approach

7. **Tactile**
   ```yaml
   theme: jekyll-theme-tactile
   ```
   - Paper-like appearance
   - Traditional documentation style

8. **Time Machine**
   ```yaml
   theme: jekyll-theme-time-machine
   ```
   - Vintage look
   - Retro aesthetic

9. **Leap Day**
   ```yaml
   theme: jekyll-theme-leap-day
   ```
   - Light, colorful
   - Playful design

10. **Merlot**
    ```yaml
    theme: jekyll-theme-merlot
    ```
    - Wine-colored theme
    - Elegant appearance

11. **Dinky**
    ```yaml
    theme: jekyll-theme-dinky
    ```
    - Simple, compact
    - Minimal design

## How to Change Theme

1. **Edit `_config.yml`**:
   ```yaml
   theme: jekyll-theme-THEME-NAME
   ```

2. **Update `Gemfile`** (if needed):
   ```ruby
   gem "jekyll-theme-THEME-NAME"
   ```

3. **Commit and push**:
   ```bash
   git add _config.yml Gemfile
   git commit -m "chore: change theme to THEME-NAME"
   git push
   ```

4. **Wait for deployment** - GitHub Pages will rebuild automatically

## Using Remote Themes

You can also use themes from GitHub that aren't built-in:

1. **Update `_config.yml`**:
   ```yaml
   remote_theme: USERNAME/REPOSITORY
   plugins:
     - jekyll-remote-theme
   ```

2. **Update `Gemfile`**:
   ```ruby
   gem "jekyll-remote-theme"
   ```

## Customizing Themes

### Custom CSS

Create `assets/css/style.scss`:

```scss
---
---

@import "{{ site.theme }}";

/* Your custom styles */
body {
  font-family: 'Your Font', sans-serif;
}

h1 {
  color: #your-color;
}
```

### Custom Layouts

1. Create `_layouts/` directory
2. Copy layout from theme repository
3. Modify as needed

## Recommended Themes for Documentation

- **Cayman** - Best for technical documentation
- **Minimal** - Clean and simple (current)
- **Modernist** - Modern, professional
- **Midnight** - Dark mode, easy on eyes

## Preview Themes

You can preview themes locally:

```bash
cd docs
bundle install
bundle exec jekyll serve
```

Then visit `http://localhost:4000` to see your site.

