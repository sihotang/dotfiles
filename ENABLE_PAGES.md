# How to Enable GitHub Pages

Follow these steps to enable GitHub Pages for your repository:

## Step 1: Navigate to Repository Settings

1. Go to your repository: `https://github.com/sihotang/dotfiles`
2. Click on the **Settings** tab (located in the top menu bar, next to "Code", "Issues", "Pull requests", etc.)

## Step 2: Find Pages Settings

1. In the left sidebar, scroll down to find **Pages** (under the "Code and automation" section)
2. Click on **Pages**

## Step 3: Configure Pages Source

1. You'll see a section titled **"Source"** or **"Build and deployment"**
2. Under **Source**, you'll see a dropdown menu
3. Click the dropdown and select **"GitHub Actions"** (NOT "Deploy from a branch")
4. Click **Save** button

## Step 4: Verify

After saving, you should see:
- A message saying "Your site is ready to be published at..."
- Or "Your GitHub Pages site is currently being built from..."
- The workflow will now be able to deploy

## Step 5: Trigger the Workflow

After enabling Pages, you can:

**Option A: Wait for automatic trigger**
- Make a change to any file in `docs/` folder
- Push the change
- The workflow will run automatically

**Option B: Manual trigger**
1. Go to the **Actions** tab in your repository
2. Click on **"Deploy GitHub Pages"** workflow
3. Click **"Run workflow"** button (top right)
4. Select the branch (usually `main`)
5. Click **"Run workflow"**

## Step 6: Check Deployment

1. Go to the **Actions** tab
2. You should see the "Deploy GitHub Pages" workflow running
3. Once it completes (green checkmark), your site will be live
4. Visit: `https://sihotang.github.io/dotfiles/`

## Troubleshooting

**If you don't see "Pages" in Settings:**
- Make sure you're the repository owner or have admin access
- Some organizations may have Pages disabled

**If "GitHub Actions" option is not available:**
- Your repository might need to be public, or
- You need to enable GitHub Actions in repository settings first

**If workflow still fails after enabling:**
- Check the Actions tab for error messages
- Ensure the `github-pages` environment exists (it should be created automatically)

## Quick URL Reference

- Repository: `https://github.com/sihotang/dotfiles`
- Settings: `https://github.com/sihotang/dotfiles/settings`
- Pages Settings: `https://github.com/sihotang/dotfiles/settings/pages`
- Actions: `https://github.com/sihotang/dotfiles/actions`
- Your Site: `https://sihotang.github.io/dotfiles/` (after deployment)

