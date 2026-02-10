# CurseForge upload (GitHub Actions)

This workflow builds a zip of the addon and uploads it to CurseForge. It runs **only when you trigger it manually** from the Actions tab.

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

## 3. Get game version IDs (WoW)

CurseForge needs **game version IDs** (e.g. for WoW 12.0 retail). You can get them in either way:

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

- **Automatically when you publish a Release**  
  In GitHub: **Releases** → **Create a new release** → choose a tag (e.g. `v1.0.0`), write the release notes → **Publish release**. The workflow runs and uploads to CurseForge with that changelog. No run on push to any branch (including main).

- **Manually**  
  **Actions** → **CurseForge Upload** → **Run workflow**. Enter **Version** (e.g. `1.0.0`) and optionally **Changelog**.

The zip is also uploaded as a **workflow artifact** so you can download it from the run page.

## 6. Zip contents

The zip is built from the repo root and excludes:

- `.git`, `.github`, `.idea`, `.gitignore`
- `*.psd`
- `version.txt`, `changelog.txt` (only used during the workflow)

The zip root folder is `ElitePlayerFrame_Enhacned_CustomSkins/`, so users get the correct addon folder when they extract it.
