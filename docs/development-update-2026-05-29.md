# OpenHub Development Update - 2026-05-29 (v1.0.1)

## Scope

This update covers OAuth App migration, GitHub Star sync fix, download retry with resume support, and code-sync module refactoring, plus full packaging.

- **GitHub OAuth App Migration**: Replaced the previous GitHub App permission model with OAuth App sign-in for user-level Star / Unstar operations. The Worker now requests `read:user public_repo` and uses OAuth App Client ID `Ov23li0G0q2gQuxSPoCF`.
- **GitHub Star Sync Fix**: Star sync now uses the OAuth user token. If GitHub returns 403, the client asks the user to confirm OAuth scope and re-authorize instead of pointing to GitHub App installation permissions.
- **Category Preload Retry**: Failed or empty category preloads now remain retryable and reload automatically when the user opens that category.
- **Download Retry & Resume**: Added right-click retry button for failed downloads, with HTTP Range-based resumable download support.
- **Code Sync Module Overhaul**: Complete rewrite of the git sync logic (from earlier session).
- **macOS App Packaging**: Local build, ad-hoc signing, DMG and ZIP output.
- **Windows App Packaging**: GitHub Actions CI/CD build via `.github/workflows/windows-tauri.yml`.
- **Source Archives**: Full source packages for macOS, Windows/Tauri, and Cloudflare backend.
- **Development Docs**: Updated product development documentation and this update log.

## macOS Changes

### 1. GitHub Star Sync Fix

**Problem**: Users reported that clicking the star icon in the app saved local favorites successfully but GitHub Star sync failed with error `403 {"message":"Resource not accessible by integration","documentation_url":"..."}`.

**Root Cause**: OpenHub needs to perform user-level Star / Unstar actions. OAuth App authorization with an explicit `public_repo` scope matches this flow better than GitHub App installation permissions.

**Fixes Applied**:

- **Improved 403 error message in `GitHubClient.request()`**: When `/user/starred` returns 403, the error now asks users to confirm OAuth App scope includes `public_repo`, sign out, and authorize again.
- **Enhanced error handling in `toggleFavorite()`**: Different HTTP errors now produce different status messages:
  - `403`: "本地收藏已保存，GitHub Star 同步失败：[detailed permission guidance]"
  - `401/404`: "GitHub Star 同步失败（认证过期），请重新登录 GitHub"
  - Other: "本地收藏已保存，GitHub Star 暂时无法同步：[error]"

### 2. Download Retry & Resumable Download

**New Features**:

- **Retry button on failed downloads**: `DownloadJobRow` now shows a prominent "重新下载" button when job state is `.failed`. Clicking triggers `retryDownload()`.
- **Right-click context menu on all download jobs**:
  - Failed jobs: "重新下载（断点续传）" / "重新下载"
  - Completed jobs: "打开文件" / "在 Finder 中显示"
  - All non-downloading jobs: "删除"
- **HTTP Range-based resume**: When retrying a failed download that had downloaded >1KB:
  - The `downloadFile()` method now accepts `resumeFromBytes: Int64` parameter
  - It sends `Range: bytes={resumeFromBytes}-` header to request only the remaining data
  - Server must support Range requests (GitHub CDN does)
- **`DownloadJob` struct extended** with fields:
  - `originalURL: String?` — stores the original download URL for retry
  - `partialFileURL: URL?` — stores partial file reference
  - `bytesDownloaded: Int64` — tracks how much was downloaded before failure
  - `retry: (() -> Void)?` — closure to trigger retry
- **`retryDownload()` method**: Creates a new download job from a failed one, using stored `originalURL`, `bytesDownloaded` for resume.
- **Failure message improvement**: When >1KB was downloaded before failure, message shows "下载失败（已下载 X MB，可右键重试）" instead of generic error.

### 3. Code Sync Module Refactoring (from earlier session)

The entire git sync subsystem was refactored to fix persistent sync failures. Key changes:

- Removed forced proxy injection from `gitArguments()`
- New `gitEnvironment()` method for proper Process environment inheritance
- Timeout protection: 120s network / 30s local operations
- Replaced the old eager fetch/rebase/token-URL push path with a GitHub Desktop-like flow:
  - stage all files and commit only when staged changes exist,
  - push with native local Git credentials first,
  - run `pull --rebase --autostash` only after a non-fast-forward rejection,
  - use the GitHub OAuth token URL only as an authentication fallback.
- Diagnostic tooling (`diagnoseGitRemote`) with UI button
- Expanded `friendlyGitSyncError` with actionable messages

### Swift 6 Concurrency Fixes

- All closures use `Task.detached` pattern for `@Sendable` compliance
- `usleep` instead of `Thread.sleep` in async contexts
- Fixed brace balance issues in nested closure structures

## Windows/Tauri Changes

No changes to the Windows/Tauri codebase in this update.

## Packaging

### macOS Build (Local)

```bash
./scripts/package_app.sh
```

Output artifacts in `dist/`:
- `OpenHub.app` - macOS application bundle
- `OpenHub.zip` - Compressed app
- `OpenHub.dmg` - Disk image for distribution

### Windows Build (GitHub Actions)

Trigger via GitHub Actions workflow `.github/workflows/windows-tauri.yml`:
1. Manual `workflow_dispatch`
2. Push to `windows/openhub-tauri/**`

Output: NSIS `.exe` + MSI `.msi`

### Source Archives

- `OpenHub-source.zip` - Complete source code (27 MB)
- `OpenHub-Windows-source.zip` - Windows/Tauri source (714 KB)
- `OpenHub-Cloudflare-source.zip` - Cloudflare backend source (16 KB)

## Build Notes

- macOS build: zero warnings, zero errors in Swift 6 strict mode.
- macOS minimum deployment target: macOS 14.0.
- Ad-hoc signed (no notarization).
- Download resume uses HTTP Range headers; requires server-side support (GitHub CDN supports this).

## Privacy

Runtime error reports intentionally exclude GitHub tokens, Keychain values, and local repository file contents.
