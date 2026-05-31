# OpenHub

中文 | [English](#english)

OpenHub 是一个免费开源的桌面客户端，用于发现、收藏、查看和下载 GitHub 上的开源应用、开发者工具和命令行工具。当前包含 macOS 原生版和独立 Windows/Tauri 版源码。

<img src="Assets/app-icon-source.png" alt="OpenHub icon" width="128" height="128">

## 特性

- GitHub 仓库搜索与仓库名精确排序
- 推荐页首屏加载热门项目，并滚动加载至前 100
- 启动后后台预加载各分类首屏内容
- 分类预加载失败时不会标记为已完成，切换到该分类会自动重试加载
- 中文软件分类体系
- 项目列表与详情页展示 GitHub owner avatar
- 仓库文档、Release 信息与下载资源展示
- 仓库简介和 Release 说明异常文本清洗
- 下载源切换与自定义代理模板
- 本地收藏、下载记录与稳定空状态
- 登录 GitHub 后收藏同步 GitHub Star
- 分类与搜索列表保持浏览选择体验，不展示打开链接和 Star 操作按钮
- 收藏列表仓库卡片点击后直接打开 GitHub 仓库页面
- GitHub OAuth 登录使用 Starring 读写权限同步 Star；权限不足时会保留本地收藏
- 仅保留 GitHub OAuth 登录，避免历史凭据与 OAuth session 权限冲突
- GitHub 登录、个人中心、我的仓库与星标仓库
- 个人中心“我的仓库”和“星标仓库”使用表格切换，默认各加载 20 个并滚动加载更多
- 个人中心列表使用独立滚动区域，避免未滚动时连续后台分页
- Fork 仓库、检索个人仓库、克隆到本地工作区
- 内置轻量代码编辑器，支持保存、commit 并同步到 GitHub
- 代码编辑器支持基础语法高亮、文件搜索、Git 状态和 diff 概览
- 下载任务进度展示，完成后可直接打开安装包或定位本地文件夹
- 下载列表支持取消下载和删除下载记录
- 代码工作区支持一键同步当前仓库全部本地改动到 GitHub
- 代码同步展示阶段进度并在完成后提示任务完成
- 支持修改本地仓库路径
- 代理设置，可加速 GitHub API 与 git clone / push
- 设置中心支持下载运行错误报告，便于反馈和排查问题
- 设置中心支持二次确认后清空缓存，包括本机配置、收藏、下载记录、仓库列表缓存、分类缓存、搜索结果和 Keychain 登录信息
- 代码频道同步会优先复用本机 Git 凭据直接 push，只有远端非快进时才自动 rebase 重试，并显示 ahead/behind 状态
- GitHub OAuth 登录，session id 和访问令牌存储在 macOS Keychain
- 界面语言设置，支持简体中文和 English
- 标准 macOS `.icns` 应用图标
- Windows/Tauri 版本源码，面向 Windows 10 和 Windows 11
- Windows/Tauri 已配置应用窗口、安装包和快捷方式图标
- Cloudflare Worker + KV + D1 后端，用于 GitHub OAuth 登录

## 系统要求

- macOS 14.0 或更高版本
- Xcode 16 或 Swift 6 toolchain

## 运行

```bash
swift run OpenHub
```

## 打包

```bash
./scripts/package_app.sh
```

输出产物：

```text
dist/OpenHub.app
dist/OpenHub.zip
dist/OpenHub.dmg
```

## Windows/Tauri 版本

Windows 版本位于 `windows/openhub-tauri`，和 macOS SwiftUI 工程隔离。

```powershell
cd windows/openhub-tauri
npm install
npm run build:windows
```

Windows 安装包需要在 Windows 10/11 或 GitHub Actions `windows-latest` 环境构建。仓库内已提供 `.github/workflows/windows-tauri.yml`，可手动触发生成 `.exe` 和 `.msi`。

## Cloudflare 后端

Cloudflare 后端位于 `backend/cloudflare`，用于 GitHub OAuth 登录。它使用 Workers 承载 OAuth 回调，KV 保存短期 state，D1 保存登录 session。

详见 [backend/cloudflare](backend/cloudflare)。

当前 OAuth App Client ID：`Ov23li0G0q2gQuxSPoCF`。Worker 默认请求 `read:user public_repo`，用于读取用户信息、读取公开仓库和同步公开仓库 Star。

## 分发说明

OpenHub 不重新分发第三方二进制文件。下载资源来自项目维护者发布的 GitHub Release Assets。下载加速源只改变传输通道，不改变文件来源声明。

当前打包脚本使用 ad-hoc 签名，适合本地测试和开源发布准备。面向普通用户大范围分发前，建议使用 Apple Developer ID 签名并完成 notarization。

## 隐私政策

OpenHub 是本地优先的开源桌面客户端。应用不会内置第三方统计 SDK，不会主动收集、出售或上传用户的个人数据。

OpenHub 会在本机保存必要配置，包括界面语言、下载源、代理设置、本地仓库路径、收藏列表、下载记录、GitHub OAuth session id 和 GitHub 访问令牌。macOS 版本会将 GitHub session id 和访问令牌保存到系统 Keychain；其他普通配置保存在本机用户环境中。

OpenHub 会在用户主动使用相关功能时请求 GitHub API，例如搜索仓库、读取 Release、登录 GitHub、读取个人仓库、同步 Star、Fork、克隆仓库或推送本地代码。GitHub 请求受 GitHub 隐私政策和账号权限控制。OpenHub 的 Cloudflare 后端仅用于 GitHub OAuth 回调和 session 中转；OpenHub 不会把仓库代码或下载记录发送到 OpenHub 自有服务器。

下载文件来自项目维护者发布的 GitHub Release Assets 或用户配置的下载加速源。若用户启用代理或自定义加速源，请自行确认该服务的可信度和隐私政策。

代码编辑、保存、commit 和 push 操作均由用户主动触发。OpenHub 不会在后台自动上传本地代码。

## 项目结构

```text
OpenHub/
  Sources/GitHubAppHub/main.swift
  Assets/
  docs/
  design/
  backend/cloudflare/
  windows/openhub-tauri/
  .github/workflows/windows-tauri.yml
  scripts/package_app.sh
  Package.swift
  README.md
```

## 最新开发文档

- [产品开发文档](docs/product-development-doc.md)
- [2026-05-29 开发更新记录](docs/development-update-2026-05-29.md)

## English

OpenHub is a free and open-source desktop client for discovering, collecting, viewing, and downloading open-source apps, developer tools, and CLI utilities from GitHub. It currently includes the native macOS app and a separate Windows/Tauri source tree.

<img src="Assets/app-icon-source.png" alt="OpenHub icon" width="128" height="128">

## Features

- GitHub repository search with repository-name-aware ranking
- Recommended page loads popular projects first and lazy-loads up to 100
- Background preloading for category first pages
- Categories that fail to preload are retried automatically when opened
- Chinese-friendly software categories
- GitHub owner avatars in project lists and detail views
- Repository docs, Release information, and downloadable assets
- Sanitized repository descriptions and Release notes
- Download source switching and custom proxy templates
- Local favorites, download history, and stable empty states
- GitHub Star sync after signing in
- Favorite repository cards can open the corresponding GitHub repository page
- Category and search lists keep a clean browsing/selection experience without inline open-link or Star buttons
- Favorite cards open the corresponding GitHub repository directly when clicked
- GitHub OAuth sign-in requests `read:user public_repo` for public repository Star sync and keeps local favorites if remote sync is denied
- GitHub OAuth sign-in is the only authentication mode, avoiding conflicts between fallback tokens and OAuth sessions
- GitHub sign-in, account center, owned repositories, and starred repositories
- Account repositories and starred repositories use a switchable table, load 20 items initially, and lazy-load more on scroll
- Account tables use an isolated scroll area to avoid runaway pagination before the user scrolls
- Fork repositories, search owned repositories, and clone into a local workspace
- Lightweight built-in code editor with save, commit, and GitHub sync
- Basic syntax highlighting, file search, Git status, and diff overview
- Download progress list with open/install and local folder actions
- Cancel active downloads and delete download records
- One-click sync for all local changes in the current repository
- Repository sync shows staged progress and reports completion
- Configurable local repository workspace path
- Proxy settings for GitHub API and git clone / push
- Settings can export runtime error reports for troubleshooting
- Settings can clear app cache after confirmation, including local settings, favorites, download history, repository caches, category caches, search results, and Keychain login entries
- Code sync reuses local Git credentials for a native push first, rebases only on non-fast-forward errors, and reports ahead/behind status
- GitHub OAuth sign-in with session id and access token stored in macOS Keychain
- Interface language settings for Simplified Chinese and English
- Standard macOS `.icns` app icon
- Windows/Tauri source for Windows 10 and Windows 11
- Windows/Tauri config includes app-window, installer, and shortcut icons
- Cloudflare Worker + KV + D1 backend for GitHub OAuth sign-in

## Requirements

- macOS 14.0 or later
- Xcode 16 or Swift 6 toolchain

## Run

```bash
swift run OpenHub
```

## Package

```bash
./scripts/package_app.sh
```

Artifacts:

```text
dist/OpenHub.app
dist/OpenHub.zip
dist/OpenHub.dmg
```

## Windows/Tauri

The Windows edition lives in `windows/openhub-tauri` and is isolated from the macOS SwiftUI project.

```powershell
cd windows/openhub-tauri
npm install
npm run build:windows
```

Windows installers must be built on Windows 10/11 or GitHub Actions `windows-latest`. The repository includes `.github/workflows/windows-tauri.yml` to produce `.exe` and `.msi` artifacts.

## Cloudflare Backend

The Cloudflare backend lives in `backend/cloudflare` and powers GitHub OAuth sign-in. It uses Workers for OAuth callbacks, KV for short-lived state, and D1 for login sessions.

See [backend/cloudflare](backend/cloudflare).

Current OAuth App Client ID: `Ov23li0G0q2gQuxSPoCF`. The Worker requests `read:user public_repo` by default for user lookup, public repository access, and public repository Star sync.

## Distribution

OpenHub does not redistribute third-party binaries. Downloads come from GitHub Release Assets published by project maintainers. Download mirrors or proxies only change the transport path, not the declared file source.

The current packaging script uses ad-hoc signing for local testing and open-source release preparation. For broad public distribution, use Apple Developer ID signing and notarization.

## Privacy Policy

OpenHub is a local-first open-source desktop client. It does not include third-party analytics SDKs and does not proactively collect, sell, or upload personal data.

OpenHub stores necessary local settings on the user's device, including interface language, download sources, proxy settings, local repository path, favorites, download history, GitHub OAuth session id, and GitHub access token. The macOS app stores the GitHub session id and access token in the system Keychain; regular settings are stored in the local user environment.

OpenHub calls GitHub APIs only when the user uses related features, such as repository search, Release lookup, GitHub sign-in, owned repository lookup, Star sync, Fork, clone, or pushing local code. GitHub requests are governed by GitHub's privacy policy and account permissions. OpenHub's Cloudflare backend is used only for GitHub OAuth callback and session relay; OpenHub does not send repository code or download history to an OpenHub-owned server.

Downloaded files come from GitHub Release Assets published by project maintainers or user-configured download mirrors/proxies. If users enable a proxy or custom mirror, they should verify that service's trustworthiness and privacy policy.

Code editing, saving, committing, and pushing are explicitly user-triggered. OpenHub does not automatically upload local code in the background.
