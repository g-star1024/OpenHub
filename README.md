# OpenHub

中文 | [English](#english)

OpenHub 是一个免费开源的 macOS 第三方客户端，用来发现、收藏、展示和下载 GitHub 上的开源 app、开发者工具和命令行工具。

## 功能特性

- GitHub 仓库搜索
- 推荐页GitHub 热门前 20，滚动最多加载前 100
- 推荐 / 搜索频道独立状态与稳定切换
- 搜索结果按仓库名精确度重排
- 仓库简介和 Release 说明异常文本清洗
- 更符合中文浏览习惯的软件分类
- 项目列表和详情页展示 GitHub owner avatar
- 应用详情页、仓库文档、Release 下载资源
- 下载加速源与自定义代理模板
- 收藏、下载记录与稳定空状态
- GitHub 登录和个人中心
- GitHub Token 使用 macOS Keychain 本地保存
- macOS 标准 `.icns` 客户端图标

## 系统要求

- macOS 14.0 或更高版本
- Xcode 16 或 Swift 6 toolchain

## 本地运行

```bash
swift run OpenHub
```

## 一键打包

双击根目录的 `package.command`，或运行：

```bash
./scripts/package_app.sh
```

打包产物会输出到：

```text
dist/OpenHub.app
dist/OpenHub.zip
dist/OpenHub.dmg
```

当前打包脚本会执行 release build、生成 `.app`、写入 `Info.plist`、复制图标、进行 ad-hoc 签名，并输出 zip 和 dmg。

## GitHub 提交建议

建议提交源码、文档、资源和脚本，不提交本地构建产物：

```bash
git init
git add .
git commit -m "Initial OpenHub release"
git branch -M main
git remote add origin https://github.com/g-star1024/OpenHub.git
git push -u origin main
```

`.gitignore` 已忽略 `.build/`、`dist/`、`.DS_Store` 等生成文件。

## 安全与分发说明

OpenHub 不会重新分发第三方二进制文件，下载资源来自项目维护者发布的 GitHub Release Assets。加速源只改变下载通道，不改变文件来源声明。

当前打包脚本使用 ad-hoc 签名，方便本地测试和开源分发准备。公开大范围分发前，建议使用 Apple Developer ID 签名并完成 notarization。

## 项目结构

```text
OpenHub/
  Sources/GitHubAppHub/main.swift
  Assets/
  docs/
  design/
  scripts/package_app.sh
  Package.swift
  README.md
```

## English

OpenHub is a free and open-source third-party macOS client for discovering, collecting, viewing, and downloading open-source apps, developer tools, and CLI utilities from GitHub.

## Features

- GitHub repository search
- Recommended page loads the first 20 popular GitHub projects, then lazy-loads up to 100
- Independent state for Recommended and Search views
- Repository-name-aware search result ranking
- Sanitized repository descriptions and Release notes
- Chinese-friendly software categories
- GitHub owner avatars in project lists and detail views
- Project detail pages, repository docs, and Release asset downloads
- Download source switching and custom proxy templates
- Favorites, download history, and stable empty states
- GitHub sign-in and account center
- GitHub Token stored locally in macOS Keychain
- Standard macOS `.icns` app icon

## Requirements

- macOS 14.0 or later
- Xcode 16 or Swift 6 toolchain

## Run Locally

```bash
swift run OpenHub
```

## Package

Double-click `package.command`, or run:

```bash
./scripts/package_app.sh
```

The packaging output is:

```text
dist/OpenHub.app
dist/OpenHub.zip
dist/OpenHub.dmg
```

The packaging script performs a release build, creates the `.app` bundle, writes `Info.plist`, copies the icon, applies ad-hoc signing, and exports both zip and dmg artifacts.

## Publishing To GitHub

Commit the source code, docs, assets, and scripts. Do not commit local build artifacts:

```bash
git init
git add .
git commit -m "Initial OpenHub release"
git branch -M main
git remote add origin https://github.com/<your-name>/OpenHub.git
git push -u origin main
```

`.gitignore` already excludes `.build/`, `dist/`, `.DS_Store`, and other generated files.

## Security And Distribution

OpenHub does not redistribute third-party binaries. Downloads come from GitHub Release Assets published by project maintainers. Download mirrors or proxies only change the transport path, not the declared file source.

The current packaging script uses ad-hoc signing for local testing and open-source release preparation. For broad public distribution, use Apple Developer ID signing and notarization.
