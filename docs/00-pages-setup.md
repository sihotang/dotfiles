# GitHub Pages Setup

## ⚠️ Important: Manual Setup Required

GitHub Pages **must be enabled manually** in your repository settings before the workflow can deploy.

## Step-by-Step Setup

1. **Go to your repository on GitHub**
   - Navigate to: `https://github.com/YOUR_USERNAME/dotfiles`

2. **Open Settings**
   - Click the **Settings** tab (top menu)

3. **Navigate to Pages**
   - In the left sidebar, click **Pages** (under "Code and automation")

4. **Configure Source**
   - Under **Source**, select **GitHub Actions** (not "Deploy from a branch")
   - Click **Save**

5. **Verify**
   - You should see a message that Pages is ready to be deployed via Actions

## After Setup

Once Pages is enabled:
- The workflow will run automatically on pushes to `docs/**`
- You can also trigger it manually from the **Actions** tab → **Deploy GitHub Pages** → **Run workflow**
- Once deployed, your site will be available at: `https://YOUR_USERNAME.github.io/dotfiles/`

## Troubleshooting

**Error: "Resource not accessible by integration"**
- This means Pages isn't enabled yet. Follow the manual setup steps above.

**Error: "Get Pages site failed"**
- Ensure Pages is enabled in Settings → Pages → Source = "GitHub Actions"
- The workflow cannot automatically enable Pages - it must be done manually.

