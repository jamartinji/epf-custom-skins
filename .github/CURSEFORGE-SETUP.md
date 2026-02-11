# CurseForge upload (GitHub Actions)

This workflow builds a zip of the addon and uploads it to CurseForge. It runs when you **publish a GitHub Release** (automatic) or when you **run it manually** from the Actions tab.

## 1. Create the project on CurseForge (once)

1. Go to [CurseForge WoW](https://www.curseforge.com/wow/addons) and create a new project if you haven’t already.

### Where to get CURSEFORGE_PROJECT_ID

The **Project ID** is a **number** (e.g. `123456`), not the addon name in the URL.

- Open your addon’s page on CurseForge (e.g. `https://www.curseforge.com/wow/addons/your-addon-slug`).
- Click **“Upload”** or **“Project details”** / **“Edit project”** (as author).
- In the browser address bar or in the page, look for a numeric ID:
  - Sometimes the upload/edit URL looks like `.../projects/123456/...` → that number is the Project ID.
  - On some pages the ID is shown in the sidebar or in “About project”.
- You can also open **Developer tools (F12)** → **Network** tab → upload a file manually and look at the request URL; it often contains `/projects/123456/`.
- If your addon is already on CurseForge, the ID may appear in the **API** or in the **project settings** URL when you are logged in as the author.

Use that number as the value of the `CURSEFORGE_PROJECT_ID` secret (e.g. `123456`).

## 2. Get an API token

1. Go to [CurseForge API Tokens](https://authors-old.curseforge.com/account/api-tokens) (log in with your CurseForge account).
2. Create a token and copy it. You’ll use it as `CURSEFORGE_API_TOKEN`.

## 3. Game version (WoW) — first release

**Manual upload (first release):** If you upload the .zip manually on the CurseForge website, **you do not need the ID**. On the Upload form you will see a list of versions by name (e.g. "World of Warcraft: 12.0.0" or "Retail - 12.0"). Choose the one that matches your addon (your TOC is 120000/120010 → choose **Retail 12.0**) and publish. CurseForge uses the ID behind the scenes.

**For the workflow or the API** you need the numeric **game version ID**. CurseForge needs **game version IDs** (e.g. for WoW 12.0 retail). You can get them in either way:

- **From the CurseForge upload page**  
  When you upload a file manually, the form shows which game versions you’re selecting. Inspect the form/network tab or the project’s “Game versions” section to see the numeric IDs.

- **From the API**  
  Call (with your token).  
  **PowerShell (Windows):** `curl` is an alias of `Invoke-WebRequest` and has different syntax. Use either:

  ```powershell
  Invoke-RestMethod -Uri "https://wow.curseforge.com/api/game/versions" -Headers @{ "X-Api-Token" = "YOUR_TOKEN" }
  ```

  or, if you have curl.exe (e.g. from Git for Windows):

  ```powershell
  curl.exe -s -H "X-Api-Token: YOUR_TOKEN" "https://wow.curseforge.com/api/game/versions"
  ```

  **Bash / Git Bash:**

  ```bash
  curl -s -H "X-Api-Token: YOUR_TOKEN" "https://wow.curseforge.com/api/game/versions"
  ```

  Find the IDs for the WoW versions you support (e.g. **120000** for 12.0, **120010** for a test build). Use the same IDs you’d choose in the manual upload form.

Use a **comma-separated** list of IDs, e.g. `1234,5678`, for the secret `CURSEFORGE_GAME_VERSION_IDS`.

## 4. GitHub secrets

In your repo: **Settings → Secrets and variables → Actions** → **New repository secret**. Add:

| Secret name | Description |
|-------------|-------------|
| `CURSEFORGE_API_TOKEN` | Your CurseForge API token |
| `CURSEFORGE_PROJECT_ID` | Your CurseForge **project ID** (number) |
| `CURSEFORGE_GAME_VERSION_IDS` | Comma-separated game version IDs (e.g. `1234,5678`) for WoW |

After saving, the workflow can use these to upload.

## 5. How to run the workflow

- **Recommended: Create version tag (then CurseForge runs automatically)**  
  **Actions** → **Create version tag** → **Run workflow**. This reads the version from the addon `.toc`, creates the tag (e.g. `v1.0.2`), pushes it, and **creates a GitHub Release** for that tag. Publishing the release triggers **CurseForge Upload** automatically, so the zip is built and sent to CurseForge. One click, no manual release needed.

- **Manual release (tag already exists)**  
  In GitHub: **Releases** → **Create a new release** → choose the tag (e.g. `v1.0.2`), write the release notes → **Publish release**. The CurseForge workflow runs and uploads with that changelog.

- **Manual upload (no release)**  
  **Actions** → **CurseForge Upload** → **Run workflow**. Enter **Version** (e.g. `1.0.2`) and optionally **Changelog**. Use this if you only want to upload to CurseForge without creating a tag or release.

**Important:** Creating **only** a tag (e.g. with `git tag v1.0.2 && git push origin v1.0.2`) does **not** trigger the CurseForge workflow. The trigger is **publishing a GitHub Release**. Use **Create version tag** so the release is created for you.

A **copy is also saved as an artifact** if you want to download it. When you download the artifact (e.g. `addon-1.0.0`), GitHub gives you a zip that *contains* the addon zip; that is a GitHub Actions limitation. If the CurseForge upload succeeded, you do not need to use the artifact to upload.

## 6. Zip contents

The zip is built from the repo root and excludes:

- `.git`, `.github`, `.idea`, `.gitignore`
- `*.psd`
- `version.txt`, `changelog.txt` (only used during the workflow)

The zip root folder is `ElitePlayerFrame_Enhanced_CustomSkins/`, so users get the correct addon folder when they extract it.
