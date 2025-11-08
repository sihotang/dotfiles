# GitHub Pages Setup

If you encounter the error "Get Pages site failed", follow these steps:

## Manual Setup (Required First Time)

1. Go to your repository on GitHub
2. Click **Settings** → **Pages** (under "Code and automation")
3. Under **Source**, select **GitHub Actions**
4. Save the settings

## Automatic Enablement

The workflow includes `enablement: true` which should automatically enable Pages, but you may still need to do the manual setup above if your repository doesn't have Pages enabled yet.

## Verify Setup

After enabling Pages:
- The workflow will run automatically on pushes to `docs/**`
- You can also trigger it manually from the **Actions** tab
- Once deployed, your site will be available at: `https://YOUR_USERNAME.github.io/dotfiles/`

