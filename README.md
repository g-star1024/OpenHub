# OpenHub

中文 | [English](#english)

OpenHub 是一个免费开源的桌面客户端，用于发现、收藏、查看和下载 GitHub 上的开源应用、开发者工具和命令行工具。当前包含 macOS 原生版和独立 Windows/Tauri 版源码。

![OpenHub icon](Assets/app-icon-source.png)

## 特性

- GitHub 仓库搜索与仓库名精确排序
- 推荐页首屏加载热门项目，并滚动加载至前 100
- 启动后后台预加载各分类首屏内容
- 中文软件分类体系
- 项目列表与详情页展示 GitHub owner avatar
- 仓库文档、Release 信息与下载资源展示
- 仓库简介和 Release 说明异常文本清洗
- 下载源切换与自定义代理模板
- 本地收藏、下载记录与稳定空状态
- 登录 GitHub 后收藏同步 GitHub Star
- GitHub 登录、个人中心、我的仓库与星标仓库
- Fork 仓库、检索个人仓库、克隆到本地工作区
- 内置轻量代码编辑器，支持保存、commit 并同步到 GitHub
- 支持修改本地仓库路径
- 代理设置，可加速 GitHub API 与 git clone / push
- GitHub Token 存储在 macOS Keychain
- 界面语言设置，支持简体中文和 English
- 标准 macOS `.icns` 应用图标
- Windows/Tauri 版本源码，面向 Windows 10 和 Windows 11

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

## 分发说明

OpenHub 不重新分发第三方二进制文件。下载资源来自项目维护者发布的 GitHub Release Assets。下载加速源只改变传输通道，不改变文件来源声明。

当前打包脚本使用 ad-hoc 签名，适合本地测试和开源发布准备。面向普通用户大范围分发前，建议使用 Apple Developer ID 签名并完成 notarization。

## 项目结构

```text
OpenHub/
  Sources/GitHubAppHub/main.swift
  Assets/
  docs/
  design/
  windows/openhub-tauri/
  .github/workflows/windows-tauri.yml
  scripts/package_app.sh
  Package.swift
  README.md
```

## English

OpenHub is a free and open-source desktop client for discovering, collecting, viewing, and downloading open-source apps, developer tools, and CLI utilities from GitHub. It currently includes the native macOS app and a separate Windows/Tauri source tree.

![OpenHub icon](Assets/app-icon-source.png)

## Features

- GitHub repository search with repository-name-aware ranking
- Recommended page loads popular projects first and lazy-loads up to 100
- Background preloading for category first pages
- Chinese-friendly software categories
- GitHub owner avatars in project lists and detail views
- Repository docs, Release information, and downloadable assets
- Sanitized repository descriptions and Release notes
- Download source switching and custom proxy templates
- Local favorites, download history, and stable empty states
- GitHub Star sync after signing in
- GitHub sign-in, account center, owned repositories, and starred repositories
- Fork repositories, search owned repositories, and clone into a local workspace
- Lightweight built-in code editor with save, commit, and GitHub sync
- Configurable local repository workspace path
- Proxy settings for GitHub API and git clone / push
- GitHub Token stored in macOS Keychain
- Interface language settings for Simplified Chinese and English
- Standard macOS `.icns` app icon
- Windows/Tauri source for Windows 10 and Windows 11

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

## Distribution

OpenHub does not redistribute third-party binaries. Downloads come from GitHub Release Assets published by project maintainers. Download mirrors or proxies only change the transport path, not the declared file source.

The current packaging script uses ad-hoc signing for local testing and open-source release preparation. For broad public distribution, use Apple Developer ID signing and notarization.
