# Setup Flavors, Fastlane & GitHub Actions for Firebase App Distribution

When the user asks to "setup flavors and fastlane and github actions" or "setup CI/CD" or references this file, follow ALL steps below from top to bottom. Do NOT skip any step. Automate everything possible using MCP tools, git commands, and file reads.

---

## Phase 0: Auto-Detect Project Info

Before asking the user anything, auto-detect as much as possible:

### 0a: Package name
Read `android/app/build.gradle.kts` and extract the `applicationId` value from `defaultConfig`.

### 0b: Branch name
Run `git branch` and find the current/active branch (the one with `*`).

### 0c: Firebase App ID
Use the Firebase MCP to get the app ID:
1. First run `firebase_get_environment` to check if a project is active.
2. If no project is active, read `android/app/google-services.json` to find the `project_id`, then run `firebase_update_environment` with that project ID.
3. Run `firebase_list_apps` with `platform: "android"` to get the Firebase App ID.
4. Match the app by package name from step 0a.

### 0d: Existing flavor names
Read `android/app/build.gradle.kts` and check if `productFlavors` already exist. If they do, note the exact names and casing (e.g., `Development` vs `development`).

### 0e: GitHub remote
Run `git remote -v` to extract the GitHub owner and repo name.

### 0f: Firebase CLI Token
The user needs to provide this once. Ask: "Do you have a Firebase CLI token? If not, run `firebase login:ci` in your terminal and paste the token here."
This token is reusable across all projects.

### After auto-detection, confirm with the user:

Show all detected values and ask only for what's missing:
```
Detected:
  - Package name: com.example.chat_material3
  - Branch: master
  - Firebase App ID: 1:350279689384:android:05ea79ec594293e42e0e9d
  - GitHub repo: mkh123213/chatApp
  - Existing flavors: Development, Production

Need from you:
  - Tester emails for Firebase distribution
  - Project display title (for flavor app names)
  - Firebase CLI token (if not provided before)
```

---

## Phase 1: Create Product Flavors — `android/app/build.gradle.kts`

Add inside the `android {}` block, before `buildTypes`. If flavors already exist, update them in place.

**IMPORTANT**: If flavors already exist, use the SAME casing. If creating new ones, use the casing the user prefers. The `--flavor` flag in Flutter CLI is **case-sensitive** and must match exactly.

```kotlin
flavorDimensions += "default"
productFlavors {
    create("Development") {
        dimension = "default"
        applicationIdSuffix = ".dev"
        resValue("string", "app_name", "<project_title> Dev")
    }
    create("Staging") {
        dimension = "default"
        applicationIdSuffix = ".staging"
        resValue("string", "app_name", "<project_title> Staging")
    }
    create("Production") {
        dimension = "default"
        resValue("string", "app_name", "<project_title>")
    }
}
```

If the project only needs Development and Production (no Staging), omit the Staging block.

---

## Phase 2: VS Code Launch Configs — `.vscode/launch.json`

Create the `.vscode/` directory if it doesn't exist. Flavor names in `--flavor` must match **exactly** the names in `build.gradle.kts` (case-sensitive).

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "DEV",
            "request": "launch",
            "type": "dart",
            "flutterMode": "debug",
            "program": "lib/main.dart",
            "args": ["--flavor", "Development", "--target", "lib/main.dart"]
        },
        {
            "name": "STAGING",
            "request": "launch",
            "type": "dart",
            "flutterMode": "debug",
            "program": "lib/main.dart",
            "args": ["--flavor", "Staging", "--target", "lib/main.dart"]
        },
        {
            "name": "PROD",
            "request": "launch",
            "type": "dart",
            "flutterMode": "release",
            "program": "lib/main.dart",
            "args": ["--flavor", "Production", "--target", "lib/main.dart"]
        }
    ]
}
```

If no Staging flavor exists, remove the STAGING config.

---

## Phase 3: Fastlane Setup

### 3a: `android/Gemfile`

```ruby
source "https://rubygems.org"

gem "fastlane"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
```

### 3b: `android/fastlane/Appfile`

```
package_name("<package_name>")
```

### 3c: `android/fastlane/Pluginfile`

```ruby
gem 'fastlane-plugin-firebase_app_distribution'
```

### 3d: `android/fastlane/Fastfile`

**CRITICAL RULES for the Fastfile:**
- The token MUST come from `ENV["FIREBASE_CLI_TOKEN"]` — NEVER hardcode a token.
- The `--flavor` value MUST match the exact flavor name in `build.gradle.kts` (case-sensitive).
- The APK path MUST match the build command flags:
  - With `--split-per-abi`: path is `app-armeabi-v7a-<flavor_lowercase>-release.apk`
  - Without `--split-per-abi`: path is `app-<flavor_lowercase>-release.apk`
- The APK path flavor name is always **lowercase** regardless of how it's defined in `build.gradle.kts`.

```ruby
default_platform(:android)

platform :android do
  desc "Build and distribute to Firebase App Distribution"
  lane :firebase_distribution do
    token = ENV["FIREBASE_CLI_TOKEN"]
    UI.user_error!("FIREBASE_CLI_TOKEN is not set. Add it as a GitHub secret.") if token.nil? || token.strip.empty?

    sh "flutter clean"
    sh "flutter build apk --release --flavor Production --split-per-abi --target lib/main.dart --no-tree-shake-icons"
    firebase_app_distribution(
        app: "<firebase_app_id>",
        firebase_cli_token: token,
        android_artifact_type: "APK",
        android_artifact_path: "../build/app/outputs/flutter-apk/app-armeabi-v7a-production-release.apk",
        testers: "<tester_emails>",
        release_notes: "New build from CI",
    )
  end
end
```

**APK Path Reference Table:**

| Build flags | APK path |
|------------|----------|
| `--flavor Production` | `app-production-release.apk` |
| `--flavor Production --split-per-abi` | `app-armeabi-v7a-production-release.apk` |
| `--flavor Development` | `app-development-release.apk` |
| `--flavor Development --split-per-abi` | `app-armeabi-v7a-development-release.apk` |

---

## Phase 4: GitHub Actions Workflow — `.github/workflows/deploy.yml`

Create the `.github/workflows/` directory if it doesn't exist.

**CRITICAL**: The `branches` value MUST match the actual branch name detected in Phase 0b.

```yaml
name: Build & Distribute to Firebase
on:
  push:
    branches:
      - <branch_name>

jobs:
  distribute_to_firebase:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout repo
      uses: actions/checkout@v4

    - name: Set up JDK
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'

    - name: Install Flutter
      uses: subosito/flutter-action@v2
      with:
        channel: stable
        cache: true

    - name: Flutter dependencies
      run: flutter pub get

    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: "3.3"
        bundler-cache: true
        working-directory: android

    - name: Add Linux platform to bundler
      run: bundle lock --add-platform x86_64-linux
      working-directory: android

    - name: Distribute to Firebase
      env:
        FIREBASE_CLI_TOKEN: ${{ secrets.FIREBASE_CLI_TOKEN }}
      run: bundle exec fastlane android firebase_distribution
      working-directory: android
```

**Why no separate "Build APK" step?** The Fastfile already runs `flutter clean` + `flutter build apk`. Running it twice wastes CI minutes and can cause conflicts.

---

## Phase 5: Set GitHub Secret Automatically

Do NOT ask the user to manually set the secret on the GitHub website. Automate it using the following Node.js script via Bash or PowerShell.

### Prerequisites
- The user must provide the Firebase CLI token (from Phase 0f).
- The GitHub remote must be detected (from Phase 0e) — extract `owner` and `repo`.
- A GitHub token with `repo` scope must be available. Check `C:\Users\IRD-83\.mcp.json` for the `GITHUB_PERSONAL_ACCESS_TOKEN` value, or ask the user.

### Automation Script

Run this Node.js script to set the secret. It:
1. Fetches the repo's public key from GitHub API
2. Encrypts the Firebase token using libsodium (NaCl sealed box)
3. Sets the encrypted secret via GitHub API

```bash
npx -y node -e "
const https = require('https');

const GITHUB_TOKEN = '<github_token>';
const OWNER = '<owner>';
const REPO = '<repo>';
const SECRET_NAME = 'FIREBASE_CLI_TOKEN';
const SECRET_VALUE = '<firebase_cli_token>';

function request(method, path, body) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'api.github.com',
      path: path,
      method: method,
      headers: {
        'Authorization': 'Bearer ' + GITHUB_TOKEN,
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'claude-code',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    };
    if (body) options.headers['Content-Type'] = 'application/json';
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => resolve({ status: res.statusCode, data: JSON.parse(data || '{}') }));
    });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

(async () => {
  // Step 1: Get repo public key
  const keyResp = await request('GET', '/repos/' + OWNER + '/' + REPO + '/actions/secrets/public-key');
  if (keyResp.status !== 200) { console.error('Failed to get public key:', keyResp.data); process.exit(1); }
  const { key, key_id } = keyResp.data;

  // Step 2: Encrypt using libsodium
  const sodium = require(require('child_process').execSync('npm root -g').toString().trim() + '/libsodium-wrappers');
  await sodium.ready;
  const binkey = sodium.from_base64(key, sodium.base64_variants.ORIGINAL);
  const binsec = sodium.from_string(SECRET_VALUE);
  const encrypted = sodium.crypto_box_seal(binsec, binkey);
  const encrypted_value = sodium.to_base64(encrypted, sodium.base64_variants.ORIGINAL);

  // Step 3: Set secret
  const setResp = await request('PUT', '/repos/' + OWNER + '/' + REPO + '/actions/secrets/' + SECRET_NAME, {
    encrypted_value: encrypted_value,
    key_id: key_id,
  });
  if (setResp.status === 201 || setResp.status === 204) {
    console.log('Secret FIREBASE_CLI_TOKEN set successfully!');
  } else {
    console.error('Failed to set secret:', setResp.data);
    process.exit(1);
  }
})();
"
```

**IMPORTANT**: If the above script fails because `libsodium-wrappers` is not installed globally, run this first:
```bash
npm install -g libsodium-wrappers
```

Then re-run the script.

**Alternative simpler approach if libsodium is problematic:**

Use the `tweetsodium` package inline:

```bash
npx -y -p tweetsodium -p @octokit/rest node -e "
const { Octokit } = require('@octokit/rest');
const sodium = require('tweetsodium');

(async () => {
  const octokit = new Octokit({ auth: '<github_token>' });
  const owner = '<owner>';
  const repo = '<repo>';

  const { data: { key, key_id } } = await octokit.actions.getRepoPublicKey({ owner, repo });

  const messageBytes = Buffer.from('<firebase_cli_token>');
  const keyBytes = Buffer.from(key, 'base64');
  const encryptedBytes = sodium.seal(messageBytes, keyBytes);
  const encrypted_value = Buffer.from(encryptedBytes).toString('base64');

  await octokit.actions.createOrUpdateRepoSecret({
    owner, repo,
    secret_name: 'FIREBASE_CLI_TOKEN',
    encrypted_value,
    key_id,
  });
  console.log('Secret FIREBASE_CLI_TOKEN set successfully!');
})();
"
```

### After setting the secret, verify it exists:

```bash
curl -s -H "Authorization: Bearer <github_token>" -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/<owner>/<repo>/actions/secrets | grep FIREBASE_CLI_TOKEN
```

Or with PowerShell:
```powershell
$headers = @{ Authorization = "Bearer <github_token>"; Accept = "application/vnd.github+json" }
(Invoke-RestMethod -Uri "https://api.github.com/repos/<owner>/<repo>/actions/secrets" -Headers $headers).secrets | Select-Object name
```

---

## Phase 6: Push All Files to GitHub

After creating all files locally (Phases 1-4), commit and push:

### Option A: Push via GitHub MCP (preferred)
Use `mcp__github__push_files` to push all changed files in a single commit:
- owner: detected from Phase 0e
- repo: detected from Phase 0e
- branch: detected from Phase 0b
- message: "setup: add flavors, fastlane, and GitHub Actions CI/CD"
- files: all files created/modified in Phases 1-4

### Option B: Push via git (fallback if MCP lacks permissions)
```bash
git add .github/workflows/deploy.yml .vscode/launch.json android/app/build.gradle.kts android/Gemfile android/fastlane/Appfile android/fastlane/Pluginfile android/fastlane/Fastfile
git commit -m "setup: add flavors, fastlane, and GitHub Actions CI/CD"
git push origin <branch_name>
```

If git push fails with "refusing to allow... without workflow scope", set the remote URL with token:
```
git remote set-url origin https://<github_token>@github.com/<owner>/<repo>.git
git push origin <branch_name>
git remote set-url origin https://github.com/<owner>/<repo>.git
```

---

## Phase 7: Verify Everything

### 7a: Check GitHub Action triggered
Run via PowerShell or Bash:
```powershell
$headers = @{ Authorization = "Bearer <github_token>"; Accept = "application/vnd.github+json" }
$resp = Invoke-RestMethod -Uri "https://api.github.com/repos/<owner>/<repo>/actions/runs?per_page=1" -Headers $headers
$run = $resp.workflow_runs[0]
Write-Output "Status: $($run.status) | Conclusion: $($run.conclusion) | Branch: $($run.head_branch)"
Write-Output "URL: $($run.html_url)"
```

### 7b: Report result to user
- If `status: in_progress` → "GitHub Action is running. Check progress at: <url>"
- If `status: completed, conclusion: success` → "Build and distribution succeeded!"
- If `status: completed, conclusion: failure` → Read the logs and diagnose

### 7c: Common failure diagnostics
| Error in logs | Cause | Fix |
|--------------|-------|-----|
| `FIREBASE_CLI_TOKEN is not set` | Secret missing or misnamed | Re-run Phase 5 |
| `Could not find APK` | APK path doesn't match build flags | Check Fastfile path vs APK Path Reference Table |
| `flavor not found` | Flavor name case mismatch | Match Fastfile `--flavor` to `build.gradle.kts` exactly |
| `workflow trigger didn't fire` | Branch name mismatch | Match workflow YAML `branches:` to actual branch |
| `refusing to allow... workflow scope` | GitHub token missing `workflow` scope | Token needs `repo` + `workflow` scopes |
| `Gemfile.lock platform` | Missing linux platform | Workflow has `bundle lock --add-platform x86_64-linux` step |

---

## Summary: What's Automated vs What Needs User Input

| Step | Automated? | How |
|------|-----------|-----|
| Detect package name | Yes | Read `build.gradle.kts` |
| Detect branch name | Yes | `git branch` |
| Detect Firebase App ID | Yes | Firebase MCP `firebase_list_apps` |
| Detect GitHub owner/repo | Yes | `git remote -v` |
| Detect existing flavors | Yes | Read `build.gradle.kts` |
| Create all config files | Yes | Edit/Write tools |
| Set GitHub secret | Yes | Node.js script with GitHub API + libsodium |
| Push to GitHub | Yes | GitHub MCP or git push |
| Verify action runs | Yes | GitHub API |
| **Tester emails** | **No — ask user** | User provides |
| **Project display title** | **No — ask user** | User provides (or derive from project name) |
| **Firebase CLI token** | **No — ask user once** | User runs `firebase login:ci` and pastes token |
| **GitHub token** | **No — read from config** | Read from `~/.mcp.json` `GITHUB_PERSONAL_ACCESS_TOKEN` |

---

## File Tree After Completion

```
project/
├── .github/
│   └── workflows/
│       └── deploy.yml                    ← GitHub Actions workflow
├── .vscode/
│   └── launch.json                       ← VS Code flavor launch configs
├── android/
│   ├── Gemfile                           ← Ruby dependencies for Fastlane
│   ├── app/
│   │   └── build.gradle.kts             ← Product flavors defined here
│   └── fastlane/
│       ├── Appfile                       ← Package name
│       ├── Pluginfile                    ← Firebase App Distribution plugin
│       └── Fastfile                      ← Build + distribute lane
```
