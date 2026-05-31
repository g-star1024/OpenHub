# OpenHub macOS 应用开发文档

## 1. 产品概述

**产品名称**：OpenHub

**一句话定位**：一个免费开源的桌面应用，用来发现、收藏、展示和下载 GitHub 上的开源桌面应用、CLI 工具和开发者工具。

**核心价值**：

- 帮用户从 GitHub 海量项目中找到真正可安装、可更新、可信赖的 app。
- 用更接近 App Store 的体验展示开源项目，包括截图、版本、下载包、许可证、活跃度和安全提示。
- 支持收藏、下载、更新提醒、本地安装记录和项目合集。
- 支持中文界面、仓库文档和下载加速源，改善中文用户的发现与下载体验。

**开源策略**：

- 客户端、索引规则、分类规则、UI 设计和文档全部开源。
- 默认不托管第三方二进制文件，只跳转或下载 GitHub Release Assets。
- 仓库元数据来自 GitHub API、项目 README、Release、Topics 和用户贡献的 curated catalog。

## 2. 目标用户

**主要用户**：

- macOS、Windows 10、Windows 11 用户：想找免费、开源、可信的桌面应用。
- 开发者：想发现 CLI、开发效率工具、菜单栏工具、编辑器扩展、AI 工具等。
- 开源维护者：希望自己的 macOS 应用获得更好的展示和分发入口。

**典型场景**：

- "我想找一个开源的 Git GUI / 截图工具 / 菜单栏网速工具。"
- "我想知道这个项目有没有 Apple Silicon 版本、最近是否还维护。"
- "我想收藏几个好用工具，换电脑时一键找回。"
- "我想关注某个 app 的新版本发布。"

## 3. 产品边界

### 做什么

- 搜索和浏览 GitHub 上的 app 类项目。
- 展示项目详情、Release、下载资源和维护活跃度。
- 支持收藏、列表、下载记录、版本提醒。
- 支持用户提交项目收录申请。
- 支持基础安全提示，例如签名状态、校验和、下载源、许可证。
- 支持仓库文档维护：为项目补充中文名称、中文简介、分类、安装说明和注意事项。
- 支持下载加速源：在不篡改文件的前提下，为 GitHub Release 下载提供可配置镜像或代理源。

### 暂不做什么

- 不内置破解、重签名、绕过 Gatekeeper 等能力。
- 不重新分发第三方二进制包，除非项目许可证和维护者明确允许。
- 不替代 Homebrew、MacPorts 或 App Store，可以和它们做深链接或安装建议。
- 不承诺所有 GitHub 项目都能一键安装，因为很多项目没有标准化 Release 包。

## 3.1 平台与代码组织

- macOS 正式版：
  - 路径：`Sources/GitHubAppHub`。
  - 技术栈：SwiftUI + AppKit + Swift Package Manager。
  - 打包脚本：`scripts/package_app.sh`。
  - 产物：`OpenHub.app`、`OpenHub.dmg`、`OpenHub.zip`。
  - Bundle Identifier：`io.openhub.desktop`。
  - 当前开源测试版使用 ad-hoc 签名；无 Apple Developer ID 时不做 notarization。
- Windows 10 / Windows 11 版本：
  - 路径：`windows/openhub-tauri`。
  - 技术栈：Tauri v2 + Rust + 静态 Web 前端。
  - 产物：NSIS `.exe` 安装包和 MSI `.msi` 安装包。
  - 应用窗口、NSIS / MSI 安装包、开始菜单和桌面快捷方式统一使用 `src-tauri/icons/icon.ico`，避免 Windows 版本打开后或快捷方式缺失图标。
  - Windows 代码必须和 macOS 原生代码隔离，不能影响 macOS 打包脚本和 SwiftUI 工程。
- CI 打包：
  - Windows 安装包通过 `.github/workflows/windows-tauri.yml` 在 `windows-latest` 环境构建。
  - 本地 macOS 环境只负责源码、前端静态校验、macOS 包和源码包。

## 3.2 GitHub OAuth App 配置

- OAuth App 名称：`OpenHub`。
- OAuth App Client ID：`Ov23li0G0q2gQuxSPoCF`。
- GitHub 仓库地址：`https://github.com/g-star1024/OpenHub`。
- 反馈地址：`https://github.com/g-star1024/OpenHub/issues`。
- 隐私政策地址：`https://github.com/g-star1024/OpenHub/blob/main/README.md`。
- Cloudflare Worker 正式域名：`https://openhub.moomer.ccwu.cc`。
- OAuth App Callback URL：`https://openhub.moomer.ccwu.cc/auth/github/callback`。
- GitHub OAuth 登录集成状态：
  - Cloudflare 后端用于 GitHub OAuth 回调和 session 中转。
  - macOS 客户端已接入 `openhub://auth/callback` URL Scheme。
  - Worker 发起 GitHub 授权时不显式传递 GitHub Web Callback `redirect_uri`，由 GitHub 使用应用后台登记的 Callback URL，避免 Callback URL 严格匹配误判。
  - Worker 授权请求显式传递 `scope=read:user public_repo`，用于读取用户信息、读取公开仓库和执行公开仓库 Star / Unstar。
  - 客户端不得内置 OAuth App Client Secret。
  - 当前客户端仅保留 GitHub OAuth 登录，不再提供 Personal Access Token 备用登录。

## 4. 核心功能

### 4.1 推荐首页

- 取消独立"发现"频道，首次打开 app 默认进入"推荐"分类页。
- 推荐页默认展示 GitHub 热门前 100 项目：
  - 数据范围：优先展示与 macOS app、桌面软件、开发工具、CLI、菜单栏工具相关的仓库。
  - 排序规则：默认按 stars 降序，支持切换为最近增长、最近发布、最近更新、下载可用性。
  - 分页体验：默认只获取前 20 个，用户滚动到底部后继续加载，每次 20 个，最多加载前 100 个。
  - 点击"推荐"分类时，无论当前在哪个页面，都必须返回推荐首页并刷新/恢复热门列表。
- 首次打开 app 后后台预加载各分类首屏内容：
  - 推荐页优先加载并展示。
  - 其他分类在后台按顺序预加载前 20 个结果。
  - 切换分类时优先展示已有缓存或离线示例，避免空白页和"重新加载"占位。
  - 预加载失败不阻塞主界面，只在状态栏提示。
  - 预加载失败或返回空结果时不得写入 `categoryPages=1`，该分类必须保持“未成功加载且可重试”状态；用户切换到该分类时应强制重新加载一次。
  - 预加载总结必须区分完全成功与部分失败，不能在出现 401/网络错误时仍提示全部加载成功。
- 今日推荐：人工精选或算法精选，置于热门列表上方。
- 热门榜单：按 stars、最近增长、最近发布、下载可用性排序。
- 分类入口：更符合中文软件浏览习惯，包含效率办公、开发编程、AI 工具、系统增强、菜单栏工具、终端命令行、网络代理、下载工具、截图录屏、图片设计、音视频、笔记写作、阅读翻译、文件管理、安全隐私、学习教育、数据库、浏览器扩展、游戏娱乐、硬件外设。
- 平台筛选：Apple Silicon、Intel、Universal、macOS 最低版本。
- 下载格式筛选：`.dmg`、`.zip`、`.pkg`、`.app`、`.tar.gz`、Homebrew Cask。
- 空状态要求：推荐页加载失败时展示可恢复状态，包括"重新加载""重新登录 GitHub""查看离线示例"，不能导致页面布局变形。

### 4.2 搜索

- 按关键词搜索仓库、项目名、描述、topic。
- 搜索频道点击行为：
  - 点击"搜索"频道时必须切换到搜索页，并聚焦搜索框。
  - 从收藏、下载、设置等频道切回搜索时，保留上次搜索词和结果。
  - 从搜索切回推荐时，推荐页必须显示热门前 100，而不是停留在搜索结果。
- 支持高级筛选：
  - 语言
  - License
  - Star 数区间
  - 最近更新时间
  - 是否有 GitHub Release
  - 是否包含 macOS 可下载资源
  - 是否有签名 / notarization 信息
- 搜索结果展示：
  - 图标 / 项目名 / 描述
  - stars、forks、last release、license
  - 下载包格式
  - 维护状态标签
- 搜索精确度排序：
  - 第一优先级：仓库名完全匹配，例如搜索 `iina` 时 `iina/iina` 排在前面。
  - 第二优先级：仓库名以关键词开头。
  - 第三优先级：仓库名包含关键词。
  - 第四优先级：owner/repo 完整名称匹配。
  - 第五优先级：描述、README、topic 匹配。
  - 同级结果再按 stars、最近更新、是否有 Release、是否有 macOS 下载资源排序。
- 搜索结果应标记匹配原因，例如"仓库名精确匹配""描述匹配""Topic 匹配"。
- 信息清洗：
  - 仓库简介、Release 说明和 README 摘要必须做可读性清洗。
  - 过滤 JSON、转义符、过长 changelog、异常编码片段和重复换行。
  - 无法提取可读描述时展示"该仓库暂无可读简介，请打开 GitHub 查看项目文档。"

### 4.3 应用详情页

- 项目基础信息：名称、作者、描述、官网、GitHub 链接、许可证。
- 项目图标：
  - 优先使用仓库 owner 的 GitHub avatar，保证所有 GitHub 项目都有稳定图标。
  - 后续可扩展解析 README、Homebrew Cask、项目官网 favicon 或自定义 curated catalog 图标。
  - 图标加载失败时回退为项目首字母渐变图标。
- README 摘要：自动提取项目介绍和截图。
- Release 信息：最新版本、发布日期、变更摘要、下载资源。
- 下载面板：按架构和格式列出资源。
- 信任信息：
  - GitHub 仓库地址
  - Release asset 来源
  - 许可证
  - 是否提供 checksum
  - 是否有签名或 notarization 说明
  - 最近提交和最近 Release 时间
- 用户操作：收藏、加入清单、下载、打开 GitHub、复制安装命令。

### 4.4 下载与安装辅助

- 内置下载管理器：进度、暂停、重试、失败原因。
- 下载列表：
  - 用户点击 Release 资源下载后，立即在下载页面展示下载任务。
  - 下载任务展示应用名、资源名、下载源、进度条、状态和错误信息。
  - 下载中支持取消下载。
  - 失败、取消或完成的下载任务支持从下载列表删除。
  - 下载完成后，历史记录中保留资源路径和 SHA256。
  - 历史下载支持右键删除记录；用户可选择只删除记录，或同时删除本地文件。
  - 历史下载删除不得使用下拉按钮格式，必须放在右键菜单中。
- **失败重试与断点续传**：
  - 下载失败时显示"重新下载"按钮，点击可重新发起下载。
  - 右键上下文菜单提供"重新下载（断点续传）"选项。
  - 已下载超过 1KB 的失败任务支持 HTTP Range 断点续传（需服务器支持 Range 请求）。
  - 重试时自动从上次中断位置继续下载。
  - 下载完成后支持直接"安装 / 打开文件"，也支持"打开本地文件夹"。
- 支持下载加速源：
  - 默认源：GitHub Release Asset 原始下载地址。
  - 加速源：用户可在设置中选择镜像源、代理源或自定义加速模板。
  - 自动测速：对可用源进行延迟和可达性检测，优先选择稳定源。
  - 失败回退：加速源失败时自动回退 GitHub 原始源。
  - 下载来源标记：下载记录中明确展示实际使用的源。
- 下载后不自动绕过系统安全机制，只提供正常打开、显示 Finder、校验文件。
- 支持校验 SHA256，如果 Release 提供 checksum 文件。
- 加速源下载完成后仍按原始 Release 的 checksum 或资产大小进行校验；无法校验时显示风险提示。
- 对 `.dmg`、`.zip`、`.pkg` 给出不同提示：
  - `.dmg`：打开镜像。
  - `.zip`：解压并显示。
  - `.pkg`：交给系统安装器。
  - Homebrew Cask：复制或执行安装命令需用户确认。

### 4.5 仓库文档支持

- 应用界面支持简体中文、繁体中文和英文，默认跟随系统语言。
- 项目仓库文档用于补充 GitHub 项目的本地化展示信息：
  - 中文名称
  - 中文一句话简介
  - 中文详细介绍
  - 中文分类
  - 中文标签
  - 安装说明
  - 下载注意事项
  - 常见问题
- 仓库文档与原始 GitHub 数据分离保存，不覆盖项目 README、Release 或许可证原文。
- 仓库文档来源：
  - 官方 curated catalog。
  - 社区 PR 贡献。
  - 维护者认领项目后提交。
- 仓库文档展示规则：
  - 优先展示用户当前语言匹配的本地化内容。
  - 保留"查看原文"入口。
  - 对社区翻译内容展示来源、更新时间和贡献者。
- 仓库文档校验：
  - 必须保留原始项目链接。
  - 不允许修改许可证含义。
  - 不允许添加误导性下载地址。
  - 对机器翻译或 AI 辅助翻译做标记。

### 4.6 收藏与合集

- 本地收藏：默认离线保存。
- GitHub Star 同步：
  - 用户登录 GitHub 后，在 app 内收藏仓库时，同时调用 GitHub Star API。
  - 取消收藏时，同时取消 GitHub Star。
  - 分类列表和搜索列表不展示打开链接、Star / Unstar 等行内功能按钮，保持浏览和选择项目的主流程。
  - 收藏列表不展示额外功能按钮，仓库卡片点击时直接打开对应 GitHub 仓库页面。
  - GitHub Star 同步失败时保留本地收藏状态，并在状态栏提示用户稍后重试。
  - OAuth App 使用 `read:user public_repo` scope，同步公开仓库 Star / Unstar；如后续要管理私有仓库 Star 或私有仓库代码同步，可切换为 `read:user repo` 并要求用户重新授权。
  - 如果返回 HTTP 403，提示用户检查 OAuth App scope、退出登录并重新授权。
  - 未登录时只执行本地收藏，并提示登录后可同步 GitHub Star。
  - GitHub OAuth access token 是唯一登录凭据，同步 Star、读取个人仓库和推送代码时不得读取或依赖备用 Token。
- 自定义合集：例如"新 Mac 必装"、"开发环境"、"菜单栏工具"。
- 可选 iCloud 同步，后续版本实现。
- 导入导出 JSON，方便迁移。
- 空收藏页必须使用稳定布局：
  - 保持与有内容列表相同的页面宽度和标题区域。
  - 展示空状态图标、说明和"去推荐"按钮。
  - 点击"去推荐"必须切换到推荐页。

### 4.7 更新提醒

- 用户收藏或下载过的项目可以订阅 Release。
- 定期检查最新 Release tag。
- 展示版本差异，不强制后台下载。

### 4.8 项目收录

- 客户端提供"提交项目"入口。
- 提交内容包括 GitHub URL、分类、推荐理由、可下载资源说明。
- 开源仓库中维护 `catalog/*.json`，通过 PR 审核收录。

### 4.9 频道与导航状态

- 左侧导航分为三个区域：
  - 顶部：搜索。
  - 中部：分类入口，紧跟在搜索下方；"推荐"是默认首页。
  - 底部：收藏、下载、更新、设置、登录 / 个人中心。

### 4.10 错误报告与问题反馈

- 所有运行时错误、网络失败、GitHub API 失败、下载失败、登录失败、Star 同步失败和窗口未捕获异常，都应记录到本地运行错误队列。
- 错误记录保留最近 200 条，包含时间、来源、当前频道、当前选中仓库和错误消息。
- 设置中心必须提供"下载错误报告"入口：
  - macOS 版本导出 JSON 到用户 Downloads 文件夹，并在 Finder 中定位该文件。
  - Windows/Tauri 版本通过 WebView 下载 JSON 文件，包含浏览器 user agent、当前视图、选中仓库和错误数组。
- 设置中心必须提供"清空错误记录"入口，用户可在反馈后删除本地错误记录。
- 错误报告不得包含 GitHub access token、Keychain 内容或本地源码文件内容。

### 4.11 设置中心清空缓存

- 设置中心必须提供"清空缓存"操作，并通过二次确认弹窗避免误点。
- 清空内容：
  - 本机配置。
  - 收藏列表。
  - 下载记录。
  - 本地仓库列表缓存。
  - 分类缓存和搜索结果。
  - GitHub OAuth session id。
  - GitHub access token。
  - Keychain 中的 `github-session-id`、`github-app-access-token`、历史兼容残留的 `github-fallback-token` 和旧版 `github-token`。
- 不删除：
  - 已下载到磁盘的文件。
  - 本地克隆仓库目录。

### 4.12 代码频道同步流程

- 同步全部改动必须按以下流程执行：
  1. 清理 stale `.git/index.lock`。
  2. 检查 `origin` 远程地址和当前分支。
  3. 解析当前分支。
  4. 确保 git user 配置（`user.name`/`user.email`，缺失时自动设置）。
  5. 暂存全部改动（`git add .`）。
  6. 有 staged 改动时才 commit。
  7. 优先执行原生 `git push`，复用系统 Git 凭据、SSH key、credential helper 和用户已经在 GitHub Desktop / 终端里配置好的认证。
  8. 仅当 push 返回 non-fast-forward / fetch first 时，执行一次 `git pull --rebase --autostash origin <当前分支>` 后再 push。
  9. 仅当原生 Git 凭据认证失败时，才临时使用 GitHub OAuth token URL 重试 HTTPS push；不能默认绕过本机 Git 凭据。
  10. 刷新 Git 状态，并显示 ahead / behind。
- 如果本地已经提交但未推送，状态面板必须显示"有本地提交未推送"，不能只显示"工作区干净"。
- 如果连接 `github.com:443` 失败，提示用户本地提交已存在但尚未推送，并引导检查网络或代理。
- **Git 进程环境**：所有 git 操作通过 `gitEnvironment()` 继承用户 shell 环境（HOME、SSH_AUTH_SOCK 等），确保 SSH 密钥和 credential helpers 可用。
- **不再强制注入代理**：`gitArguments()` 不再向所有 git 命令注入 `-c http.proxy=...`，避免在直连网络可用时被错误代理拦截导致同步失败。
- **超时保护**：网络操作 120 秒超时，本地操作 30 秒超时，防止 git 进程永久挂起。
- **诊断工具**：代码频道底部面板提供诊断按钮，可检查 git 版本、remote 配置、分支、用户配置、网络连通性和代理设置。

### 4.13 个人中心仓库表格

- 个人中心头部 GitHub 账号卡片保持稳定，不因列表切换而变化。
- "我的仓库"和"星标仓库"使用 table/segmented 切换。
- 默认各加载 20 个，列表滚动到底部后每次继续加载 20 个。
- 个人中心仓库表格必须使用独立固定高度滚动区域，不能依赖外层页面滚动触发加载；避免列表初次渲染时末行 `onAppear` 连续触发，把后续分页一次性加载完导致 app 卡死。
- 列表操作按钮固定宽度并居中，避免滚动和切换时布局跳动。

### 4.14 图标与 Windows 打包

- macOS 图标源图必须保持 1024x1024，并重新生成完整 `.iconset` 与 `.icns`。
- Windows/Tauri 图标必须同步更新 PNG 资源和 `icon.ico`。
- README 中展示图标限制为 128x128。
- Windows Tauri release 必须使用 `windows_subsystem = "windows"`，避免启动时弹出 cmd。
- Windows NSIS 安装模式使用当前用户安装，减少管理员权限弹窗。
- 每个频道点击都必须有明确响应，不允许出现"点击无反应"。
- 频道切换时保留各自上下文：
  - 推荐/分类：保留热门榜单、分类和滚动位置。
  - 搜索：保留搜索词、筛选项和结果。
  - 收藏：保留收藏列表和当前合集。
  - 下载：保留下载记录和下载队列。
  - 设置：保留未保存的表单输入，离开前提示保存。
- 所有空页面必须使用同一套 `EmptyState` 组件，固定标题区、内容区和操作区，避免页面塌陷或变形。

### 4.10 GitHub 登录与个人中心

- 只支持 GitHub 账号登录。
- 正式版主登录方式使用 GitHub OAuth App：
  - 用户点击登录后打开 GitHub 授权页面。
  - Cloudflare Worker 负责 OAuth callback 和 token exchange。
  - macOS 客户端通过 `openhub://auth/callback` 接收 `session_id`。
  - 客户端调用 `/auth/session` 获取当前会话信息，并将 session id 与访问令牌保存到 macOS Keychain。
  - GitHub OAuth 授权 URL 传递 `scope=read:user public_repo`，权限由 OAuth App scope 和用户授权决定。
- 不再提供 GitHub Personal Access Token 登录入口：
  - 登录入口统一为 GitHub OAuth。
  - macOS 使用系统 `ASWebAuthenticationSession`，授权页在当前 app 登录流程内打开，回调不会再拉起新的 OpenHub 实例。
  - Windows/Tauri 使用同一个 Cloudflare OAuth 后端，在当前 Tauri WebView 中跳转授权并带 `session_id` 回到应用页面。
  - 用户输入 token 后调用 GitHub `/user` 验证身份。
  - 登录成功后展示头像、用户名、昵称、个人主页链接。
  - token 存储在本地 macOS Keychain。
  - 如需 Fork、克隆私有仓库或使用 OAuth token 直接 push 私有仓库，需要将 Worker scope 调整为 `read:user repo` 并让用户重新授权；默认代码同步优先使用本机 Git 凭据。
- 个人中心展示：
  - 我的仓库。
  - 我的仓库检索。
  - 我的星标仓库。
  - 星标仓库检索。
  - 我的仓库和星标仓库默认各加载前 20 个，列表滚动到底部后每次继续加载 20 个。
  - GitHub 主页入口。
  - 克隆仓库到本地工作区。
  - Fork 仓库到自己的 GitHub 账号。
  - 退出登录。
- 我的仓库和星标仓库搜索结果必须支持一键打开 GitHub 网页端。
- 列表操作排序：stars 数量必须展示在"打开""克隆"等功能按钮前面。
- 列表功能按钮固定宽度并居中展示，避免按钮数量变化导致列表抖动。
- 登录失败时展示明确错误，不能影响发现和搜索基础浏览。

### 4.11 语言设置

- 设置中心提供界面语言设置。
- 首版支持：
  - 跟随系统
  - 简体中文
  - English
- 切换语言后立即更新主要界面文案，包括侧边栏、搜索框、设置、个人中心、空状态和主要按钮。
- 分类名称必须纳入界面语言包，不允许直接展示内部枚举中文值：
  - 简体中文：推荐、热门、效率办公、开发编程等。
  - English：Recommended、Popular、Productivity、Developer Tools 等。
  - 列表标题、侧边栏分类入口、项目卡片分类标签必须同步切换。
- 仓库原始信息、Release 文本和项目 README 不做强制翻译，只清洗异常文本。

### 4.12 Windows Tauri 版

- 首版目标：
  - 支持 Windows 10 和 Windows 11。
  - 默认进入推荐分类。
  - 支持分类浏览、滚动加载、分类预加载、搜索、收藏、下载链接打开、下载记录、设置中心、语言切换、GitHub OAuth 登录和 Star 同步。
  - Release 构建必须使用 Windows GUI subsystem，启动客户端时不得弹出 cmd/控制台窗口。
  - NSIS 安装模式默认使用当前用户安装，避免普通安装流程触发管理员控制台。
- 技术约束：
  - Windows 版不复用 macOS SwiftUI/AppKit 代码。
  - 前端逻辑集中在 `windows/openhub-tauri/web`。
  - Tauri 壳和 Windows 打包配置集中在 `windows/openhub-tauri/src-tauri`。
  - 设置和 Token 首版存储在 Tauri WebView 本地存储，后续迁移到 Tauri 安全存储插件。
- 打包要求：
  - 本地 Windows 环境可执行 `windows/openhub-tauri/scripts/build-windows.ps1`。
  - GitHub Actions 可手动触发 `Build Windows Tauri` 工作流。
  - 产物上传为 `OpenHub-Windows` artifact，包含 `.exe` 和 `.msi`。

### 4.13 Fork、本地仓库和代码编辑

- Fork 功能：
  - 在非本人项目的详情页提供 Fork 操作。
  - 个人中心的"我的仓库"均为自己已有仓库，不提供 Fork 自己仓库的入口。
  - 使用 GitHub REST API `POST /repos/{owner}/{repo}/forks` 创建 Fork。
  - Fork 成功后将新仓库插入个人仓库列表。
  - Fork 失败时保留当前页面状态，并在状态栏提示错误。
- 本地仓库路径：
  - 设置中心提供本地仓库根路径。
  - 默认路径为用户文档目录下的 `OpenHubRepos`。
  - 用户可通过目录选择器修改路径。
  - 修改后扫描路径下已有 Git 仓库。
- 下载/克隆自己的仓库：
  - 个人中心支持检索自己的仓库。
  - 仓库列表提供"克隆"按钮。
  - 默认使用 `git clone https://github.com/{owner}/{repo}.git` 下载到本地工作区。
  - 如果目录已存在，不重复克隆，直接进入代码工作区。
- 内置代码编辑：
  - 新增"代码"频道。
  - 左侧展示本地仓库、文件搜索和可编辑文本文件列表。
  - 支持常见文本文件：Swift、Markdown、JSON、JavaScript、TypeScript、HTML、CSS、Rust、TOML、YAML、Shell、PowerShell 等。
  - 大文件、二进制文件、`.git`、`node_modules`、`target`、`dist`、构建缓存默认隐藏。
  - 本地仓库路径可以选择仓库根目录，也可以选择包含多个仓库的上级工作区。
  - 本地仓库列表只展示包含 `.git` 的有效仓库；历史缓存中的无效路径必须自动剔除。
  - Git 状态读取前必须校验当前路径是否为 Git 仓库，避免展示 `fatal: not a git repository` 这类原始错误。
  - 编辑后可保存到本地文件。
  - 编辑器支持基础语法高亮，包括关键词、字符串、注释和常量。
  - 展示当前 Git 分支、变更状态和 diff 概览。
  - 底部 Git 面板需要分区清晰：状态摘要、变更列表、diff 概览和提交区域不得拥挤重叠。
  - 提供删除本地仓库入口，删除成功提示必须明确"只删除本地仓库，不删除 GitHub 远程仓库"。
- 同步到 GitHub：
  - 代码工作区提供 Commit message 输入框。
  - 点击"同步到 GitHub / 同步全部到 GitHub"后，一键同步当前本地仓库的所有本地文件改动。
  - 同步流程执行 `git add .`、`git commit -m`、`git push`。
  - 同步过程展示阶段进度：准备、暂存、提交、推送、刷新状态、完成。
  - 同步完成后状态栏提示"同步任务完成"。
  - 默认 push 必须依赖本机 Git 凭据，行为尽量接近 GitHub Desktop / 终端 `git push`；GitHub OAuth token 只作为认证失败后的兜底，不作为默认路径。
  - 本地仓库扫描时必须从 `git remote get-url origin` 自动解析 `owner/repo`，避免只用文件夹名导致 push 到错误仓库。
  - 同步前清理 stale `.git/index.lock`，避免上一次 git 失败留下锁文件后无法继续同步。
  - OAuth token 同步私有仓库或推送代码时，需要使用 `repo` scope；默认公开版 scope 为 `public_repo`。
  - 同步失败时展示 Git 输出，便于用户处理权限、冲突或凭据问题。
- 代理设置：
  - 设置中心新增代理设置。
  - 支持 HTTP/HTTPS/SOCKS 代理地址，例如 `http://127.0.0.1:7890` 或 `socks5://127.0.0.1:7890`。
  - 代理应用到 GitHub API 请求和 OpenHub 内执行的 git clone / git push。
  - 用户遇到 `Failed to connect to github.com port 443` 时，优先提示配置代理服务器。
- 约束：
  - 首版是轻量代码编辑器，不替代 Xcode、VS Code 或 JetBrains IDE。
  - 首版不自动解决 merge conflict。
  - 首版不执行未确认的 destructive git 操作。

### 4.14 项目创建入口

- 顶部右侧入口文案统一为"创建项目 / Create Project"。
- 点击后打开 GitHub 新建仓库页面。

### 4.15 Cloudflare GitHub OAuth 后端

- 后端代码独立放置在 `backend/cloudflare`，不能影响 macOS 和 Windows 客户端打包。
- 目标：
  - 支持 GitHub OAuth Web flow。
  - 将 OAuth App Client Secret 保存在 Cloudflare Worker Secret 中。
  - 使用 KV 保存短期 OAuth state，默认 10 分钟过期。
  - 使用 D1 保存登录 session 和 GitHub user token。
  - 为正式版客户端提供 GitHub OAuth 登录能力。
- OAuth token 格式兼容性：
  - 当前 OpenHub 只使用 OAuth user token。
  - 后端 D1 `access_token` 使用 `TEXT`，macOS 使用 Keychain `String`，Windows 使用 WebView localStorage，均不假设 token 长度或固定前缀。
  - 如果后续接入 installation token，必须兼容新的 `ghs_...` stateless token，不能硬编码 40 位长度、固定前缀或旧格式正则。
- 部署包要求：
  - Cloudflare 后端部署代码单独位于 `backend/cloudflare`。
  - 包含 Worker 源码、D1 migration、Wrangler 配置、依赖清单和本地 secret 示例。
  - 部署教程不写入 README，仅在交付说明中提供。
- 当前端点：
  - `GET /health`
  - `GET /auth/github/start`
    - 只接收桌面端回调地址 `openhub://auth/callback` 作为本地返回目标。
    - 不向 GitHub authorize URL 显式传递 Web Callback `redirect_uri`。
  - `GET /auth/github/callback`
  - `GET /auth/session`
  - `POST /auth/logout`
- 安全约束：
  - Client Secret、Private Key 不得写入客户端或仓库。
  - 公开测试版不再保留 Personal Access Token 手动登录。
  - D1 中 token 首版为 MVP 存储，公开生产前需要增加加密、过期清理、CORS 白名单和速率限制。

## 5. 数据来源与 GitHub API

### 5.1 数据来源

- GitHub REST API：仓库、搜索、Release、Topics、README、用户信息、用户仓库、星标仓库。
- GitHub Release Assets：下载包列表。
- GitHub GraphQL API：可选，用于批量查询和减少请求次数。
- 社区 curated catalog：补充分类、图标、截图、安装方式、兼容性。
- 仓库文档 catalog：补充中文名称、中文简介、中文安装说明和本地化标签。
- Homebrew Cask：可选，用于补充安装命令和 cask 名称。

### 5.2 GitHub API 注意事项

- 未认证请求限流较低，登录后统一使用 GitHub OAuth session token 提高 API 可用性。
- 认证后限流提升，但必须安全存储 token，建议使用 macOS Keychain。
- Search API 有自己的查询限制和排序规则，不适合作为唯一实时数据源。
- Release Assets 的文件命名没有统一规范，需要做启发式解析。

官方参考：

- [GitHub REST API Rate Limits](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api)
- [GitHub Search Repositories API](https://docs.github.com/en/rest/search/search)
- [GitHub Releases API](https://docs.github.com/en/rest/releases/releases)

## 6. 技术方案

### 6.1 推荐技术栈

**优先方案：Swift + SwiftUI**

- 更原生的 macOS 体验。
- 更容易使用 Keychain、Finder、通知、菜单栏、文件下载、沙盒权限。
- 应用体积和性能更可控。
- 适合免费开源项目长期维护。

**备选方案：Tauri + React**

- 前端开发效率高，跨平台潜力强。
- macOS 原生感需要额外打磨。
- 适合已有 Web 技术团队。

本项目推荐 SwiftUI，除非团队强依赖 Web 技术栈。

### 6.2 模块划分

- `AppShell`：窗口、导航、主题、快捷键。
- `NavigationState`：频道切换、上下文保留、空状态导航动作。
- `CatalogHome`：推荐首页、分类、GitHub 热门前 100、分页加载、榜单。
- `CategoryPreloader`：启动后预加载各分类首屏内容并维护分类缓存。
- `Search`：搜索框、筛选器、结果列表、精确度重排。
- `AppDetail`：详情页、README 摘要、Release 面板。
- `ProjectIconResolver`：项目图标解析，优先使用 GitHub owner avatar。
- `DownloadManager`：下载队列、进度、校验、文件打开。
- `DownloadSourceManager`：GitHub 原始源、镜像源、自定义加速源、测速和回退。
- `Catalog`：本地 curated catalog、分类、榜单配置。
- `LocalizationPack`：仓库文档、本地化字段、翻译来源和版本管理。
- `GitHubClient`：REST/GraphQL API、鉴权、限流、缓存。
- `Persistence`：收藏、合集、下载记录、设置。
- `SecurityAdvisor`：许可证、签名、checksum、维护状态提示。
- `UpdateWatcher`：Release 检查和通知。
- `Account`：GitHub 登录状态、个人信息、我的仓库、星标仓库。
- `LanguageSettings`：界面语言偏好、运行时文案切换。

### 6.3 本地存储

建议使用 SQLite 或 SwiftData。

核心表：

- `repositories`
- `releases`
- `assets`
- `favorites`
- `category_cache`
- `collections`
- `downloads`
- `download_sources`
- `localization_packs`
- `settings`
- `catalog_entries`
- `navigation_state`

### 6.4 缓存策略

- 搜索结果缓存 10-30 分钟。
- 仓库详情缓存 6-24 小时。
- Release 信息缓存 1-6 小时。
- README 和截图缓存 24 小时。
- 用户手动刷新时绕过缓存。

### 6.5 Release Asset 识别规则

常见 macOS 文件名模式：

- `mac`
- `macos`
- `darwin`
- `osx`
- `arm64`
- `aarch64`
- `x64`
- `x86_64`
- `universal`
- `.dmg`
- `.pkg`
- `.zip`

建议输出字段：

```json
{
  "platform": "macOS",
  "arch": "universal | arm64 | x64 | unknown",
  "format": "dmg | zip | pkg | app | tar.gz | unknown",
  "confidence": 0.0,
  "reason": "filename matched dmg + arm64"
}
```

### 6.6 推荐页 Top 100 策略

推荐页默认请求 GitHub 热门仓库，并在客户端进行 macOS 相关性过滤。为了避免首屏卡顿，首次只请求 20 个。

默认查询建议：

```text
macos app OR macos tool OR desktop app stars:>500
```

接口策略：

- 使用 GitHub Search Repositories API。
- `sort=stars`，`order=desc`，`per_page=20`。
- 使用 `page=1...5` 滚动加载，最多累计 100 个。
- 如果某一页返回不足 20 个，再追加分类查询补足。
- 对结果做客户端二次过滤，优先保留名称、描述、topic、README 中包含 `macos`、`darwin`、`desktop`、`menubar`、`cli`、`swift`、`electron`、`tauri`、`dmg`、`homebrew` 的项目。
- 首页缓存 30 分钟，手动刷新时重新请求。

推荐页验收标准：

- 首次打开 app 时展示热门项目，而不是空白页。
- 首屏网络请求目标是 20 个仓库，避免一次性拉取 100 导致卡顿。
- 列表滚动到底部时自动加载下一页，状态栏显示加载进度。
- 点击左侧"推荐"时，无论当前在哪个频道，都能回到推荐页。
- 网络失败时展示稳定空状态，不改变窗口布局。

### 6.6.1 信息清洗规则

仓库信息展示前必须经过 `ReadableTextSanitizer`：

- 将 `\\n`、`\\t`、多余空格转换为普通可读文本。
- 如果内容疑似 JSON、版本 changelog、转义字符串或超过合理长度，降级为默认简介。
- 列表页描述最多展示 2 行。
- 详情页描述最多展示 4 行。
- Release 说明最多展示摘要，不直接把超长 JSON 或 changelog 全量塞入详情页。

### 6.7 搜索精确度重排

GitHub Search API 返回结果后，客户端需要进行二次排序，避免高 star 但不相关的项目排在精确仓库名前面。

建议评分：

```text
repo name exact match      +1000
repo name prefix match     +800
repo name contains query   +600
full name exact match      +550
owner exact match          +300
topic exact match          +250
description contains query +150
has release                +80
has macOS asset            +100
stars score                min(stars / 100, 200)
recent update score        0-80
```

排序规则：

1. 先按匹配分降序。
2. 匹配分相同再按 stars 降序。
3. 再按最近更新时间降序。
4. 对完全仓库名匹配结果显示"精确匹配"标签。

### 6.8 中文分类体系

分类需要符合中文用户浏览软件的习惯，建议首版内置以下分类：

- 推荐
- 热门
- 效率办公
- 开发编程
- AI 工具
- 系统增强
- 菜单栏工具
- 终端命令行
- 网络代理
- 下载工具
- 截图录屏
- 图片设计
- 音视频
- 笔记写作
- 阅读翻译
- 文件管理
- 安全隐私
- 学习教育
- 数据库
- 浏览器扩展
- 游戏娱乐
- 硬件外设

### 6.9 空状态组件规范

所有无内容页面统一使用 `EmptyState` 组件，避免收藏页、下载页切换时布局塌陷。

组件结构：

- 固定页面标题区。
- 居中的图标或轻量插画。
- 一句明确说明。
- 一个主操作按钮。
- 可选次操作按钮。

页面对应动作：

- 收藏为空：主按钮"去推荐"，切换到推荐分类。
- 下载为空：主按钮"去搜索"，切换到搜索频道并聚焦搜索框。
- 搜索无结果：主按钮"调整关键词"，次按钮"查看热门项目"。
- 推荐加载失败：主按钮"重新加载"，次按钮"检查 Token 设置"。

### 6.10 安全与隐私

- Token 存入 Keychain，不写入普通配置文件。
- 下载 URL 和本地路径只保存在用户设备。
- 默认不开启遥测。
- 如需匿名统计，必须清晰开关，并在 README 中说明。
- 对所有第三方项目展示来源链接和许可证。
- 下载前明确提示："该应用来自 GitHub 项目维护者，不由本应用签名或担保。"
- 加速源只改变下载通道，不改变文件来源声明；界面必须同时展示原始 Release 地址和实际下载源。
- 自定义加速源不默认启用，用户添加前需要确认风险。
- 不内置不可信、不可审计或会替换文件内容的下载源。
- 仓库文档不能隐藏原始项目名称、作者、许可证和 GitHub 链接。

### 6.11 下载加速源设计

加速源配置建议使用模板化 URL，避免对每个项目手动维护下载地址。

```json
{
  "id": "custom-github-proxy",
  "name": "Custom GitHub Proxy",
  "type": "proxy",
  "enabled": false,
  "urlTemplate": "https://example.com/{originalUrl}",
  "supportsChecksum": true,
  "priority": 50
}
```

下载源选择流程：

1. 解析 GitHub Release Asset 原始 URL。
2. 读取用户设置和内置可用源列表。
3. 对启用源进行轻量测速和可达性检查。
4. 选择最快且可信度满足要求的源。
5. 下载完成后执行 checksum、文件大小或 content-type 校验。
6. 校验失败时删除文件，提示用户并回退原始源。

内置源策略：

- MVP 阶段仅提供"原始 GitHub 源"和"自定义加速源模板"。
- 公共加速源需要可审计、稳定、明确隐私政策后再考虑预置。
- 企业或团队用户可通过配置文件导入内部镜像源。

### 6.12 仓库文档数据结构

仓库文档建议以 JSON 维护，随 curated catalog 一起开源。

```json
{
  "repo": "owner/name",
  "locale": "zh-Hans",
  "displayName": "中文名称",
  "tagline": "一句话中文简介",
  "description": "中文详细介绍",
  "installNotes": "安装说明",
  "downloadNotes": "下载注意事项",
  "tags": ["效率", "菜单栏"],
  "source": "community",
  "contributors": ["github-user"],
  "updatedAt": "2026-05-25"
}
```

仓库文档版本规则：

- 以 `repo + locale` 作为唯一键。
- 每次修改记录贡献者和更新时间。
- 原项目 README 或 Release 发生重大变化时标记"可能过期"。
- 客户端可离线缓存仓库文档，但应支持手动刷新。

## 7. 信息架构

主导航建议：

- Search：搜索
- Categories：分类，位于搜索下方，其中"推荐"是默认首页。
- Collections：收藏与合集
- Downloads：下载
- Updates：更新
- Settings：设置
- Account：登录 / 个人中心

导航验收：

- 推荐/分类和搜索是两个独立区域，不共享页面状态。
- 分类区域上移到搜索下方，收藏、下载、更新、设置、登录整体下移。
- 点击"推荐"必须返回推荐页并显示热门前 100 或缓存结果。
- 任意频道点击"搜索"必须返回搜索页并聚焦搜索框。
- 收藏和下载为空时仍保持完整页面结构。

详情页结构：

- Header：图标、名称、作者、主操作。
- Summary：描述、标签、star、license、latest release。
- Screenshots / README Preview：截图与介绍。
- Downloads：可下载资源。
- Trust：信任与安全信息。
- Repository Docs：仓库文档信息、翻译来源、查看原文。
- Releases：版本历史。

## 8. UI 设计原则

- 像 macOS 工具，不像网页商城。
- 用信息密度服务效率，避免过度营销化大卡片。
- 搜索和筛选始终优先，让用户快速缩小范围。
- 明确区分"发现项目"和"下载二进制文件"两个动作。
- 左侧频道点击反馈要即时，选中态、标题和内容区必须同步变化。
- 推荐页应更像中文软件目录：分类清晰、榜单明确、支持快速浏览热门项目。
- 分类标题只展示分类名，不在标题后追加"热门项目"等重复文案。
- 列表副标题固定为"GitHub 热门前 100，滚动浏览"，不展示"默认加载"等实现文案。
- 下载按钮旁展示当前下载源，允许用户切换原始源或加速源。
- 仓库文档内容旁保留原文入口，避免中文描述替代项目官方信息。
- 安全信息要可见，但不要制造恐慌。
- 支持浅色 / 深色模式。
- 支持键盘导航和 VoiceOver。
- 空状态页面不可使用会撑坏布局的大面积系统占位组件，应使用固定尺寸的自定义空状态。
- App icon 设计方向：清爽、明亮、识别度高，避免过多小块、暗色大面积底座和复杂细节。

## 9. MVP 范围

### MVP 必做

- 推荐页展示 GitHub 热门前 100 项目。
- 推荐页默认首屏加载前 20，滚动最多加载前 100。
- 首次打开后预加载各分类首屏内容。
- 推荐/分类、搜索、收藏、下载、设置频道切换稳定可用。
- 项目列表和详情页展示项目图标，优先使用 GitHub owner avatar。
- GitHub 仓库搜索。
- 搜索结果按仓库名精确度重排。
- 仓库信息乱码和异常长 JSON 文本清洗。
- GitHub 登录和个人中心。
- 详情页展示仓库、README 摘要、最新 Release。
- Release Asset 下载。
- 自定义下载加速源。
- 简体中文界面。
- 仓库文档基础展示。
- 收藏。
- 收藏同步 GitHub Star。
- 设置中心语言切换。
- 下载记录。
- 收藏和下载空状态固定布局。
- 中文软件分类体系。
- 本地缓存。
- GitHub OAuth 登录与权限设置。
- 基础安全提示。

### MVP 可延后

- iCloud 同步。
- 用户评分。
- 自动安装。
- Homebrew 集成。
- AI 摘要。
- 繁体中文完整适配。
- 公共加速源推荐和自动测速排序。
- 社区 PR 收录后台。

## 10. 版本路线图

### v0.1 Prototype

- SwiftUI 基础窗口与导航。
- 修复频道切换状态，推荐/分类和搜索独立响应。
- 分类区域上移，账户区域下移。
- GitHub 搜索接入。
- 推荐页前 20 首屏加载，滚动加载到前 100。
- 搜索精确度重排。
- 仓库信息清洗。
- GitHub 登录与个人中心。
- 项目详情页。
- Release Assets 展示。
- 简体中文界面框架。
- 收藏和下载空状态。
- 新版轻量 App icon。

### v0.2 MVP

- 下载管理器。
- 自定义下载加速源和失败回退。
- 收藏和合集。
- 缓存与离线记录。
- Token 设置与 Keychain。
- 仓库文档基础展示。

### v0.3 Public Beta

- curated catalog。
- 仓库文档贡献流程。
- 分类榜单。
- 更完整的中文分类和榜单运营配置。
- 更新提醒。
- 安全提示增强。
- 加速源测速与下载源切换。

### v1.0

- 完整暗色模式。
- 完整简体中文、繁体中文、英文语言包。
- 可访问性检查。
- 签名、notarization、自动更新。
- 项目网站和文档完善。

## 11. 开源仓库结构建议

```text
github-apphub/
  App/
    Sources/
    Tests/
  Catalog/
    categories.json
    entries/
    localization/
      zh-Hans/
      zh-Hant/
  Docs/
    product.md
    api.md
    security.md
    contributing.md
  Design/
    mockups/
    icons/
  Scripts/
    validate-catalog.swift
  README.md
  LICENSE
```

## 12. 关键风险

- GitHub API 限流：需要缓存、token 和降级策略。
- Release 命名不统一：需要启发式解析和人工修正。
- 下载安全责任：必须清晰说明来源、许可证和风险。
- 下载加速源可信度：镜像或代理可能失效、限速、替换内容或泄露下载行为，需要校验、回退和风险提示。
- 仓库文档准确性：翻译可能过期或误导，需要贡献审核、原文入口和过期标记。
- 项目维护状态难判断：需要综合 stars、最近 commit、release、issue 活跃度。
- 法律与商标：不要暗示 GitHub 官方背书，名称和图标避免混淆。

## 13. 成功指标

- 搜索到可下载 macOS app 的成功率。
- 推荐页热门前 100 加载成功率。
- 搜索仓库名精确匹配 Top 3 命中率。
- 频道切换成功率和空状态布局问题数。
- 用户从搜索到下载的完成率。
- 收藏项目数量。
- 更新提醒点击率。
- 仓库文档覆盖率和仓库文档纠错 PR 数量。
- 加速源下载成功率、校验失败率和原始源回退率。
- curated catalog PR 数量。
- 用户报告的错误下载资源数量下降。

## 14. 产品设计图

设计图文件位于：

```text
design/product-mockup.svg
```

这张图展示了 macOS 主窗口、左侧导航、搜索筛选、应用列表、详情页、下载资源和信任信息面板。
