# OpenHub Development Update - 2026-05-29

## Scope

This update addresses the latest desktop source package:

- Favorites list navigation to the corresponding GitHub repository page.
- Category and search lists no longer show inline open-link or Star buttons.
- Favorites list cards open the GitHub repository directly when clicked, without extra action buttons.
- Windows app, installer, Start Menu, and shortcut icon consistency.
- Windows/Tauri parity for current discovery, favorites, Star sync, settings, language, and error-report features.
- Settings-center runtime error report export.
- GitHub App is now the only sign-in path; fallback token login has been removed to avoid Star permission conflicts.
- Account center repository table switching and 10-item pagination.
- Settings-center clear-cache action with confirmation.
- Code workspace sync flow with stale lock cleanup, pull rebase/autostash, branch-targeted push, and ahead/behind status.
- Regenerated macOS `.icns` and Windows/Tauri PNG icons from the 1024x1024 source image.

## macOS Changes

- GitHub App access token is the only app credential. Star sync, account data, and Git push use the active App session token.
- GitHub authorization now uses `ASWebAuthenticationSession`, so OAuth opens inside the current app sign-in flow and the callback is captured by the running app instead of launching a second instance.
- Favorites list row click opens the repository GitHub page.
- Repository rows in category/search views are selection-only. Favorite rows open GitHub directly.
- Favorites still remain local-first; Star sync is handled by detail/favorite state changes, not row-level buttons.
- Settings now includes a runtime error section:
  - records status messages that indicate runtime failures,
  - keeps the latest 200 records,
  - exports a JSON report to Downloads,
  - can clear local error records.
- Settings now includes `Clear Cache` with a confirmation dialog. It clears local settings, favorites, download history, repository list caches, category/search caches, GitHub session ids, access tokens, and Keychain login entries. It does not delete downloaded files or local cloned repositories.
- Account center keeps the GitHub profile header stable and switches `My Repositories` / `Starred Repositories` in a table view. Each list loads 20 repositories initially and loads 20 more when the table scrolls to the bottom.
- Account repository tables now own their own fixed-height scroll container. This prevents the last row from appearing during the outer page layout and repeatedly triggering background pagination before the user scrolls.
- Reviewed the upcoming GitHub App installation token format change. OpenHub currently uses OAuth user-to-server tokens, stores tokens as unconstrained text/string values, and does not parse token prefixes or lengths; no code migration is required for the current auth flow.
- Code sync now clears stale `.git/index.lock`, stages all changes, commits only when staged changes exist, pulls with `--rebase --autostash`, pushes `HEAD:refs/heads/<current branch>`, refreshes ahead/behind status, and shows `Local commits not pushed` instead of a misleading clean-worktree message.

## Windows/Tauri Changes

- Account center uses the same table switching pattern and 10-item lazy loading on scroll.
- Settings includes a clear-cache action with a confirmation dialog for WebView local storage.
- Category/search repository cards no longer expose direct `Open GitHub` or `Sync Star / Unstar` actions.
- Favorites repository cards open GitHub directly when clicked.
- GitHub App sign-in uses the same Cloudflare OAuth backend. The Windows webview navigates through the OAuth flow and returns with a `session_id`; Star sync uses the resulting App session token.
- Settings now exports a JSON runtime error report from WebView local storage.
- Runtime errors are collected from:
  - failed status messages,
  - GitHub API failures,
  - search/category/login/star failures,
  - `window.error`,
  - unhandled promise rejections.
- Tauri bundle icon configuration keeps `icons/icon.ico` in the bundle icon list for Windows installers and shortcuts.
- Runtime window icon is set during Rust startup with `app.set_icon(...)` from `src-tauri/icons/icon.png`, because Tauri v2 config does not accept an `app.windows[].icon` field.
- Release mode keeps `windows_subsystem = "windows"` and NSIS uses current-user install mode.

## Build Notes

- macOS build and packaging can be done locally with:

```bash
./scripts/package_app.sh
```

- Windows installers must be built on Windows 10/11 or GitHub Actions with Rust, Node.js, Visual Studio Build Tools, and WebView2:

```powershell
cd windows/openhub-tauri
npm install
npm run build:windows
```

- This macOS environment does not include `cargo` / `rustc`, so it can validate JavaScript and Tauri config entry points but cannot produce NSIS / MSI installers locally.

## Privacy

Runtime error reports intentionally exclude GitHub tokens, Keychain values, and local repository file contents. They include only app metadata, current view, selected repository name, status text, and recorded error messages.
