import SwiftUI
import Foundation
import AppKit
import CryptoKit
import Security
import AuthenticationServices

struct Repository: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let fullName: String
    let owner: String
    let description: String
    let stars: Int
    let forks: Int
    let language: String
    let license: String
    let htmlURL: String
    let avatarURL: String
    let updatedAt: Date
    var category: AppCategory
    var localized: LocalizationPack?
    var matchReason: String

    var displayName: String { localized?.displayName.isEmpty == false ? localized!.displayName : name }
    var tagline: String { localized?.tagline.isEmpty == false ? localized!.tagline : description }
}

struct ReleaseAsset: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let browserDownloadURL: String
    let size: Int
    let downloadCount: Int
    let contentType: String

    var formattedSize: String { ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file) }
    var architecture: String {
        let lower = name.lowercased()
        if lower.contains("universal") { return "Universal" }
        if lower.contains("arm64") || lower.contains("aarch64") { return "Apple Silicon" }
        if lower.contains("x64") || lower.contains("x86_64") || lower.contains("amd64") { return "Intel" }
        return "Unknown"
    }
    var format: String {
        let lower = name.lowercased()
        for ext in ["dmg", "pkg", "zip", "app", "tar.gz"] where lower.hasSuffix(ext) {
            return ext.uppercased()
        }
        return "Asset"
    }
}

struct Release: Codable, Hashable {
    let tagName: String
    let name: String
    let body: String
    let publishedAt: Date?
    let htmlURL: String
    let assets: [ReleaseAsset]
}

struct DownloadRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let appName: String
    let assetName: String
    let sourceName: String
    let originalURL: String
    let savedPath: String
    let downloadedAt: Date
    let checksum: String?
}

struct DownloadJob: Identifiable, Hashable {
    enum State: String {
        case downloading = "下载中"
        case completed = "已完成"
        case failed = "失败"
        case cancelled = "已取消"
    }

    let id: UUID
    let appName: String
    let assetName: String
    let sourceName: String
    var originalURL: String?
    var progress: Double
    var state: State
    var savedPath: String?
    var partialFileURL: URL?
    var bytesDownloaded: Int64
    var message: String
    var cancel: (() -> Void)?
    var retry: (() -> Void)?

    static func == (lhs: DownloadJob, rhs: DownloadJob) -> Bool {
        lhs.id == rhs.id &&
        lhs.appName == rhs.appName &&
        lhs.assetName == rhs.assetName &&
        lhs.sourceName == rhs.sourceName &&
        lhs.progress == rhs.progress &&
        lhs.state == rhs.state &&
        lhs.savedPath == rhs.savedPath
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(appName)
        hasher.combine(assetName)
        hasher.combine(sourceName)
        hasher.combine(progress)
        hasher.combine(state)
        hasher.combine(savedPath)
    }
}

struct DownloadSource: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var type: String
    var enabled: Bool
    var urlTemplate: String
    var priority: Int

    func resolvedURL(for original: String) -> URL? {
        if id == "github-original" { return URL(string: original) }
        let encoded = original.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? original
        let raw = urlTemplate
            .replacingOccurrences(of: "{originalUrl}", with: original)
            .replacingOccurrences(of: "{encodedOriginalUrl}", with: encoded)
        return URL(string: raw)
    }
}

struct LocalRepository: Identifiable, Codable, Hashable {
    let id: UUID
    var fullName: String
    var path: String
    var remoteURL: String
    var updatedAt: Date
}

struct CodeFile: Identifiable, Hashable {
    let id = UUID()
    let relativePath: String
    let absolutePath: String
}

struct ProxySettings: Codable, Hashable {
    var enabled: Bool
    var server: String

    var normalizedURL: URL? {
        guard enabled else { return nil }
        let trimmed = server.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if trimmed.contains("://") { return URL(string: trimmed) }
        return URL(string: "http://\(trimmed)")
    }
}

struct RuntimeErrorRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let message: String
    let source: String
    let section: String
    let createdAt: Date
}

struct RuntimeErrorExport: Codable {
    let app: String
    let exportedAt: Date
    let section: String
    let selectedRepository: String?
    let status: String
    let errors: [RuntimeErrorRecord]
}

struct GitHubUser: Identifiable, Codable, Hashable {
    let id: Int
    let login: String
    let name: String?
    let avatarURL: String
    let htmlURL: String
    let publicRepos: Int
    let followers: Int
    let following: Int

    var displayName: String { name?.isEmpty == false ? name! : login }
}

struct GitHubAuthSession: Codable, Hashable {
    let sessionId: String
    let login: String
    let userId: Int
    let accessToken: String
    let tokenType: String
    let scope: String
    let expiresAt: String?
}

struct LocalizationPack: Codable, Hashable {
    let locale: String
    let displayName: String
    let tagline: String
    let description: String
    let installNotes: String
    let downloadNotes: String
    let tags: [String]
    let source: String
    let updatedAt: String
}

enum AppCategory: String, Codable, CaseIterable, Identifiable {
    case recommended = "推荐"
    case hot = "热门"
    case productivity = "效率办公"
    case developer = "开发编程"
    case ai = "AI 工具"
    case system = "系统增强"
    case menuBar = "菜单栏工具"
    case terminal = "终端命令行"
    case network = "网络代理"
    case downloader = "下载工具"
    case capture = "截图录屏"
    case design = "图片设计"
    case media = "音视频"
    case writing = "笔记写作"
    case translation = "阅读翻译"
    case files = "文件管理"
    case security = "安全隐私"
    case education = "学习教育"
    case database = "数据库"
    case browser = "浏览器扩展"
    case games = "游戏娱乐"
    case hardware = "硬件外设"

    var id: String { rawValue }
    var nameKey: String {
        switch self {
        case .recommended: "recommended"
        case .hot: "hot"
        case .productivity: "productivity"
        case .developer: "developer"
        case .ai: "ai"
        case .system: "system"
        case .menuBar: "menuBar"
        case .terminal: "terminal"
        case .network: "network"
        case .downloader: "downloader"
        case .capture: "capture"
        case .design: "design"
        case .media: "media"
        case .writing: "writing"
        case .translation: "translation"
        case .files: "files"
        case .security: "security"
        case .education: "education"
        case .database: "database"
        case .browser: "browser"
        case .games: "games"
        case .hardware: "hardware"
        }
    }

    var query: String {
        switch self {
        case .recommended: "macos app stars:>500"
        case .hot: "macos stars:>1000"
        case .productivity: "macos productivity app"
        case .developer: "macos developer tool"
        case .ai: "macos ai llm app"
        case .system: "macos utility system"
        case .menuBar: "macos menu bar app"
        case .terminal: "macos terminal cli"
        case .network: "macos proxy network"
        case .downloader: "macos download manager"
        case .capture: "macos screenshot screen recorder"
        case .design: "macos image design"
        case .media: "macos media player"
        case .writing: "macos notes markdown editor"
        case .translation: "macos reader translation"
        case .files: "macos file manager"
        case .security: "macos security privacy"
        case .education: "macos learning education"
        case .database: "macos database client"
        case .browser: "browser extension macos"
        case .games: "macos game"
        case .hardware: "macos hardware driver"
        }
    }

    var symbol: String {
        switch self {
        case .recommended: "sparkles"
        case .hot: "flame"
        case .productivity: "briefcase"
        case .developer: "hammer"
        case .ai: "brain"
        case .system: "switch.2"
        case .menuBar: "menubar.rectangle"
        case .terminal: "terminal"
        case .network: "network"
        case .downloader: "arrow.down.circle"
        case .capture: "camera.viewfinder"
        case .design: "paintpalette"
        case .media: "play.rectangle"
        case .writing: "note.text"
        case .translation: "book"
        case .files: "folder"
        case .security: "lock.shield"
        case .education: "graduationcap"
        case .database: "cylinder.split.1x2"
        case .browser: "safari"
        case .games: "gamecontroller"
        case .hardware: "cpu"
        }
    }
}

enum AppSection: String, CaseIterable, Identifiable {
    case catalog = "推荐"
    case search = "搜索"
    case collections = "收藏"
    case code = "代码"
    case downloads = "下载"
    case updates = "更新"
    case settings = "设置"
    case account = "登录"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .catalog: "sparkles"
        case .search: "magnifyingglass"
        case .collections: "star"
        case .code: "curlybraces.square"
        case .downloads: "arrow.down.circle"
        case .updates: "clock.arrow.circlepath"
        case .settings: "gearshape"
        case .account: "person.crop.circle"
        }
    }
}

enum AccountRepositoryTab: String, CaseIterable, Identifiable {
    case owned = "我的仓库"
    case starred = "星标仓库"

    var id: String { rawValue }
}

enum AppLanguage: String, Codable, CaseIterable, Identifiable {
    case system = "system"
    case zhHans = "zh-Hans"
    case en = "en"

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .system: "跟随系统 / System"
        case .zhHans: "简体中文"
        case .en: "English"
        }
    }
}

enum L10n {
    static func text(_ key: String, language: AppLanguage) -> String {
        let effective: AppLanguage
        if language == .system {
            effective = Locale.preferredLanguages.first?.lowercased().hasPrefix("zh") == true ? .zhHans : .en
        } else {
            effective = language
        }

        let zh = zhHans[key] ?? key
        let en = english[key] ?? zh
        return effective == .en ? en : zh
    }

    static func categoryName(_ category: AppCategory, language: AppLanguage) -> String {
        text("category.\(category.nameKey)", language: language)
    }

    private static let zhHans: [String: String] = [
        "category.recommended": "推荐",
        "category.hot": "热门",
        "category.productivity": "效率办公",
        "category.developer": "开发编程",
        "category.ai": "AI 工具",
        "category.system": "系统增强",
        "category.menuBar": "菜单栏工具",
        "category.terminal": "终端命令行",
        "category.network": "网络代理",
        "category.downloader": "下载工具",
        "category.capture": "截图录屏",
        "category.design": "图片设计",
        "category.media": "音视频",
        "category.writing": "笔记写作",
        "category.translation": "阅读翻译",
        "category.files": "文件管理",
        "category.security": "安全隐私",
        "category.education": "学习教育",
        "category.database": "数据库",
        "category.browser": "浏览器扩展",
        "category.games": "游戏娱乐",
        "category.hardware": "硬件外设",
        "search": "搜索",
        "favorites": "收藏",
        "code": "代码",
        "downloads": "下载",
        "updates": "更新",
        "settings": "设置",
        "account": "登录",
        "accountCenter": "个人中心",
        "appSubtitle": "GitHub 开源应用浏览器",
        "categories": "分类",
        "searchResults": "搜索结果",
        "recommendedSubtitle": "GitHub 热门前 100，滚动浏览",
        "searchSubtitle": "按仓库名精确度、stars 和更新时间排序",
        "searchPlaceholder": "输入仓库名可精确排序，例如 iina、rectangle、utm",
        "submitProject": "创建项目",
        "continueLoading": "继续加载热门项目...",
        "repositoryDocs": "仓库文档",
        "downloadAssets": "下载资源",
        "trustInfo": "信任信息",
        "releaseInfo": "版本信息",
        "language": "语言",
        "interfaceLanguage": "界面语言",
        "saveSettings": "保存设置",
        "githubToken": "GitHub OAuth 登录",
        "tokenKeychain": "OpenHub 仅使用 GitHub OAuth 登录；session id 和 access token 会保存在本机 macOS Keychain。",
        "downloadSource": "下载源",
        "defaultDownloadSource": "默认下载源",
        "localizationNote": "当前支持简体中文和 English。仓库原始内容不会被强制翻译。",
        "goRecommended": "去推荐",
        "goSearch": "去搜索",
        "viewRecommended": "查看推荐",
        "emptyFavorites": "还没有收藏项目",
        "emptyDownloads": "还没有下载记录",
        "emptyUpdates": "暂无更新提醒",
        "selectProject": "选择一个项目",
        "loginGitHub": "登录 GitHub",
        "githubAccount": "GitHub 账号",
        "logout": "退出登录",
        "openGitHub": "打开 GitHub",
        "refresh": "刷新",
        "myRepos": "我的仓库",
        "starredRepos": "星标仓库",
    ]

    private static let english: [String: String] = [
        "category.recommended": "Recommended",
        "category.hot": "Popular",
        "category.productivity": "Productivity",
        "category.developer": "Developer Tools",
        "category.ai": "AI Tools",
        "category.system": "System Utilities",
        "category.menuBar": "Menu Bar",
        "category.terminal": "Terminal & CLI",
        "category.network": "Network & Proxy",
        "category.downloader": "Downloaders",
        "category.capture": "Screen Capture",
        "category.design": "Design",
        "category.media": "Media",
        "category.writing": "Notes & Writing",
        "category.translation": "Reading & Translation",
        "category.files": "File Management",
        "category.security": "Security & Privacy",
        "category.education": "Learning",
        "category.database": "Databases",
        "category.browser": "Browser Extensions",
        "category.games": "Games",
        "category.hardware": "Hardware",
        "search": "Search",
        "favorites": "Favorites",
        "code": "Code",
        "downloads": "Downloads",
        "updates": "Updates",
        "settings": "Settings",
        "account": "Sign In",
        "accountCenter": "Account",
        "appSubtitle": "GitHub open-source app browser",
        "categories": "Categories",
        "searchResults": "Search Results",
        "recommendedSubtitle": "GitHub Top 100, scroll to browse",
        "searchSubtitle": "Ranked by repository-name match, stars, and update time",
        "searchPlaceholder": "Type a repository name, e.g. iina, rectangle, utm",
        "submitProject": "Create Project",
        "continueLoading": "Loading more popular projects...",
        "repositoryDocs": "Repository Docs",
        "downloadAssets": "Downloads",
        "trustInfo": "Trust",
        "releaseInfo": "Release",
        "language": "Language",
        "interfaceLanguage": "Interface Language",
        "saveSettings": "Save Settings",
        "githubToken": "GitHub OAuth Sign In",
        "tokenKeychain": "OpenHub only uses GitHub OAuth sign-in. The session id and access token are stored locally in macOS Keychain.",
        "downloadSource": "Download Source",
        "defaultDownloadSource": "Default Source",
        "localizationNote": "Supports Simplified Chinese and English. Repository content is not force-translated.",
        "goRecommended": "Recommended",
        "goSearch": "Search",
        "viewRecommended": "Recommended",
        "emptyFavorites": "No favorites yet",
        "emptyDownloads": "No downloads yet",
        "emptyUpdates": "No updates yet",
        "selectProject": "Select a project",
        "loginGitHub": "Sign in with GitHub",
        "githubAccount": "GitHub Account",
        "logout": "Sign Out",
        "openGitHub": "Open GitHub",
        "refresh": "Refresh",
        "myRepos": "My Repositories",
        "starredRepos": "Starred Repositories",
    ]
}

enum ReadableTextSanitizer {
    static let fallback = "该仓库暂无可读简介，请打开 GitHub 查看项目文档。"

    static func repositoryDescription(_ raw: String?) -> String {
        let value = clean(raw)
        guard !looksUnreadable(value, maxLength: 360) else { return fallback }
        return clipped(value, limit: 220)
    }

    static func documentText(_ raw: String?) -> String {
        let value = clean(raw)
        guard !looksUnreadable(value, maxLength: 520) else { return fallback }
        return clipped(value, limit: 360)
    }

    static func releaseNotes(_ raw: String?) -> String {
        let value = clean(raw)
        guard !looksUnreadable(value, maxLength: 1400) else { return "该 Release 说明较长或格式异常，请打开 GitHub 查看完整内容。" }
        return clipped(value, limit: 900)
    }

    private static func clean(_ raw: String?) -> String {
        guard var value = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return fallback
        }
        value = value
            .replacingOccurrences(of: "\\n", with: " ")
            .replacingOccurrences(of: "\\t", with: " ")
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
        while value.contains("  ") {
            value = value.replacingOccurrences(of: "  ", with: " ")
        }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func looksUnreadable(_ value: String, maxLength: Int) -> Bool {
        if value.isEmpty || value == fallback { return true }
        if value.count > maxLength { return true }
        let lower = value.lowercased()
        if lower.contains("\"releases\"") || lower.contains("discard all changes") { return true }
        let symbols = value.filter { "{}[]\\\"".contains($0) }.count
        return symbols > max(18, value.count / 12)
    }

    private static func clipped(_ value: String, limit: Int) -> String {
        if value.count <= limit { return value }
        return String(value.prefix(limit)).trimmingCharacters(in: .whitespacesAndNewlines) + "..."
    }
}

@MainActor
final class GitHubClient {
    private let authBackendBaseURL = URL(string: "https://openhub.moomer.ccwu.cc")!
    private let decoder: JSONDecoder
    var proxyURL: URL?

    init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

    func discoverTop(category: AppCategory, page: Int, token: String?) async throws -> [Repository] {
        let queries = category == .recommended
            ? ["macos app stars:>500", "macos tool stars:>500", "desktop app macos stars:>300"]
            : [category.query]
        var merged: [Repository] = []
        for query in queries where merged.count < 20 {
            let pageItems = try await searchRaw(query: query, sort: "stars", page: page, perPage: 20, token: token)
            merged.append(contentsOf: pageItems)
        }
        return Array(deduplicate(merged).prefix(20)).map { repo in
            var item = repo
            item.matchReason = category == .recommended ? "GitHub 热门" : category.rawValue
            return item
        }
    }

    func search(query: String, token: String?) async throws -> [Repository] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let apiQuery = trimmed.isEmpty ? "macos app" : "\(trimmed) in:name,description,readme"
        let repos = try await searchRaw(query: apiQuery, sort: "stars", page: 1, perPage: 100, token: token)
        return rerank(repos, query: trimmed)
    }

    func currentUser(token: String) async throws -> GitHubUser {
        let data = try await request(URL(string: "https://api.github.com/user")!, token: token)
        let user = try decoder.decode(UserResponse.self, from: data)
        return GitHubUser(id: user.id, login: user.login, name: user.name, avatarURL: user.avatarUrl, htmlURL: user.htmlUrl, publicRepos: user.publicRepos, followers: user.followers, following: user.following)
    }

    func githubAppAuthorizationURL() -> URL {
        var components = URLComponents(url: authBackendBaseURL.appendingPathComponent("auth/github/start"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "redirect_uri", value: "openhub://auth/callback")]
        return components.url!
    }

    func githubAppSession(sessionID: String) async throws -> GitHubAuthSession {
        var components = URLComponents(url: authBackendBaseURL.appendingPathComponent("auth/session"), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "session_id", value: sessionID)]
        let data = try await request(components.url!, token: nil)
        return try decoder.decode(GitHubAuthSession.self, from: data)
    }

    func logoutGitHubAppSession(sessionID: String) async {
        let url = authBackendBaseURL.appendingPathComponent("auth/logout")
        _ = try? await request(url, method: "POST", token: sessionID, body: Data())
    }

    func userRepositories(token: String, page: Int = 1, perPage: Int = 20) async throws -> [Repository] {
        let data = try await request(URL(string: "https://api.github.com/user/repos?sort=updated&per_page=\(perPage)&page=\(page)")!, token: token)
        let items = try decoder.decode([RepositoryItem].self, from: data)
        return items.map(repository(from:))
    }

    func starredRepositories(token: String, page: Int = 1, perPage: Int = 20) async throws -> [Repository] {
        let data = try await request(URL(string: "https://api.github.com/user/starred?sort=updated&per_page=\(perPage)&page=\(page)")!, token: token)
        let items = try decoder.decode([RepositoryItem].self, from: data)
        return items.map(repository(from:))
    }

    func forkRepository(owner: String, repo: String, token: String) async throws -> Repository {
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/forks")!
        let data = try await request(url, method: "POST", token: token, body: Data("{}".utf8))
        let item = try decoder.decode(RepositoryItem.self, from: data)
        return repository(from: item)
    }

    func starRepository(owner: String, repo: String, token: String) async throws {
        let url = URL(string: "https://api.github.com/user/starred/\(owner)/\(repo)")!
        _ = try await request(url, method: "PUT", token: token, emptySuccessCodes: [204], body: Data())
    }

    func unstarRepository(owner: String, repo: String, token: String) async throws {
        let url = URL(string: "https://api.github.com/user/starred/\(owner)/\(repo)")!
        _ = try await request(url, method: "DELETE", token: token, emptySuccessCodes: [204])
    }

    func latestRelease(owner: String, repo: String, token: String?) async throws -> Release {
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/releases/latest")!
        let data = try await request(url, token: token)
        let release = try decoder.decode(ReleaseResponse.self, from: data)
        return Release(
            tagName: release.tagName,
            name: release.name ?? release.tagName,
            body: ReadableTextSanitizer.releaseNotes(release.body),
            publishedAt: release.publishedAt,
            htmlURL: release.htmlUrl,
            assets: release.assets.map {
                ReleaseAsset(
                    id: $0.id,
                    name: $0.name,
                    browserDownloadURL: $0.browserDownloadUrl,
                    size: $0.size,
                    downloadCount: $0.downloadCount,
                    contentType: $0.contentType ?? ""
                )
            }
        )
    }

    private func searchRaw(query: String, sort: String, page: Int, perPage: Int, token: String?) async throws -> [Repository] {
        var components = URLComponents(string: "https://api.github.com/search/repositories")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "sort", value: sort),
            URLQueryItem(name: "order", value: "desc"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]

        let data = try await request(components.url!, token: token)
        let response = try decoder.decode(SearchResponse.self, from: data)
        return response.items.map(repository(from:))
    }

    private func request(_ url: URL, method: String = "GET", token: String?, emptySuccessCodes: Set<Int> = [], body: Data? = nil) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("OpenHub/1.0.0 (GitHub OAuth)", forHTTPHeaderField: "User-Agent")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        if let token, !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let session = sessionForCurrentProxy()
        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, emptySuccessCodes.contains(http.statusCode) {
            return data
        }
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            let message = String(data: data, encoding: .utf8) ?? ""
            if http.statusCode == 403, url.path.contains("/user/starred") {
                let isResourceError = message.contains("Resource not accessible") || message.contains("not authorized")
                let detail = isResourceError
                    ? "OAuth App 缺少 Star 权限。请确认 OAuth App 授权 scope 包含 public_repo，然后退出登录并重新授权。"
                    : "请确认 OAuth App 授权 scope 包含 public_repo，修改 OAuth App 配置或后端 scope 后需退出登录并重新授权。\(message.isEmpty ? "" : " GitHub: \(message)")"
                throw NSError(domain: "GitHub", code: http.statusCode, userInfo: [
                    NSLocalizedDescriptionKey: detail
                ])
            }
            throw NSError(domain: "GitHub", code: http.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "GitHub API 请求失败：HTTP \(http.statusCode)\(message.isEmpty ? "" : " \(message)")"
            ])
        }
        return data
    }

    private func sessionForCurrentProxy() -> URLSession {
        guard let proxyURL,
              let host = proxyURL.host,
              let port = proxyURL.port else {
            return .shared
        }
        let configuration = URLSessionConfiguration.ephemeral
        let scheme = proxyURL.scheme?.lowercased() ?? "http"
        var proxy: [AnyHashable: Any]
        if scheme.hasPrefix("socks") {
            proxy = [
                kCFNetworkProxiesSOCKSEnable as String: true,
                kCFNetworkProxiesSOCKSProxy as String: host,
                kCFNetworkProxiesSOCKSPort as String: port
            ]
        } else {
            proxy = [
                kCFNetworkProxiesHTTPEnable as String: true,
                kCFNetworkProxiesHTTPProxy as String: host,
                kCFNetworkProxiesHTTPPort as String: port,
                kCFNetworkProxiesHTTPSEnable as String: true,
                kCFNetworkProxiesHTTPSProxy as String: host,
                kCFNetworkProxiesHTTPSPort as String: port
            ]
        }
        if let user = proxyURL.user, let password = proxyURL.password {
            proxy[kCFProxyUsernameKey as String] = user
            proxy[kCFProxyPasswordKey as String] = password
        }
        configuration.connectionProxyDictionary = proxy
        return URLSession(configuration: configuration)
    }

    private func rerank(_ repos: [Repository], query: String) -> [Repository] {
        guard !query.isEmpty else { return repos }
        let normalized = query.lowercased()
        return repos.map { repo in
            var copy = repo
            let name = repo.name.lowercased()
            let fullName = repo.fullName.lowercased()
            let owner = repo.owner.lowercased()
            let description = repo.description.lowercased()
            if name == normalized {
                copy.matchReason = "仓库名精确匹配"
            } else if name.hasPrefix(normalized) {
                copy.matchReason = "仓库名前缀匹配"
            } else if name.contains(normalized) {
                copy.matchReason = "仓库名包含匹配"
            } else if fullName == normalized {
                copy.matchReason = "完整仓库名匹配"
            } else if owner == normalized {
                copy.matchReason = "作者匹配"
            } else if description.contains(normalized) {
                copy.matchReason = "描述匹配"
            } else {
                copy.matchReason = "相关结果"
            }
            return copy
        }
        .sorted {
            let left = matchScore($0, query: normalized)
            let right = matchScore($1, query: normalized)
            if left != right { return left > right }
            if $0.stars != $1.stars { return $0.stars > $1.stars }
            return $0.updatedAt > $1.updatedAt
        }
    }

    private func matchScore(_ repo: Repository, query: String) -> Double {
        let name = repo.name.lowercased()
        let fullName = repo.fullName.lowercased()
        let owner = repo.owner.lowercased()
        let description = repo.description.lowercased()
        var score = min(Double(repo.stars) / 100.0, 200)
        if name == query { score += 1000 }
        else if name.hasPrefix(query) { score += 800 }
        else if name.contains(query) { score += 600 }
        if fullName == query { score += 550 }
        if owner == query { score += 300 }
        if description.contains(query) { score += 150 }
        score += recencyScore(repo.updatedAt)
        return score
    }

    private func recencyScore(_ date: Date) -> Double {
        let days = max(1, Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 365)
        return max(0, 80 - Double(days) / 7)
    }

    private func repository(from item: RepositoryItem) -> Repository {
        let description = ReadableTextSanitizer.repositoryDescription(item.description)
        return Repository(
            id: item.id,
            name: item.name,
            fullName: item.fullName,
            owner: item.owner.login,
            description: description,
            stars: item.stargazersCount,
            forks: item.forksCount,
            language: item.language ?? "Unknown",
            license: item.license?.spdxId ?? "Unknown",
            htmlURL: item.htmlUrl,
            avatarURL: item.owner.avatarUrl,
            updatedAt: item.updatedAt,
            category: inferCategory(from: item),
            localized: LocalizationCatalog.pack(for: item.fullName, fallbackName: item.name, fallbackDescription: description),
            matchReason: "GitHub 搜索"
        )
    }

    private func deduplicate(_ repos: [Repository]) -> [Repository] {
        var seen = Set<String>()
        return repos.filter { seen.insert($0.fullName).inserted }
    }

    private func inferCategory(from item: RepositoryItem) -> AppCategory {
        let text = "\(item.name) \(item.description ?? "") \(item.language ?? "")".lowercased()
        if text.contains("menu bar") || text.contains("menubar") { return .menuBar }
        if text.contains("ai") || text.contains("llm") || text.contains("chatgpt") { return .ai }
        if text.contains("terminal") || text.contains("cli") { return .terminal }
        if text.contains("download") { return .downloader }
        if text.contains("screenshot") || text.contains("record") { return .capture }
        if text.contains("player") || text.contains("media") || text.contains("video") { return .media }
        if text.contains("security") || text.contains("privacy") || text.contains("password") { return .security }
        if text.contains("database") || text.contains("sql") { return .database }
        if text.contains("developer") || text.contains("git") || text.contains("code") { return .developer }
        if text.contains("file") || text.contains("finder") { return .files }
        return .productivity
    }
}

private struct SearchResponse: Decodable { let items: [RepositoryItem] }
private struct RepositoryItem: Decodable {
    let id: Int
    let name: String
    let fullName: String
    let owner: Owner
    let description: String?
    let stargazersCount: Int
    let forksCount: Int
    let language: String?
    let license: License?
    let htmlUrl: String
    let updatedAt: Date
}
private struct Owner: Decodable {
    let login: String
    let avatarUrl: String
}
private struct License: Decodable { let spdxId: String? }
private struct UserResponse: Decodable {
    let id: Int
    let login: String
    let name: String?
    let avatarUrl: String
    let htmlUrl: String
    let publicRepos: Int
    let followers: Int
    let following: Int
}
private struct ReleaseResponse: Decodable {
    let tagName: String
    let name: String?
    let body: String?
    let publishedAt: Date?
    let htmlUrl: String
    let assets: [AssetResponse]
}
private struct AssetResponse: Decodable {
    let id: Int
    let name: String
    let browserDownloadUrl: String
    let size: Int
    let downloadCount: Int
    let contentType: String?
}

enum LocalizationCatalog {
    static func pack(for fullName: String, fallbackName: String, fallbackDescription: String) -> LocalizationPack {
        let known: [String: LocalizationPack] = [
            "iina/iina": LocalizationPack(locale: "zh-Hans", displayName: "IINA", tagline: "为 macOS 打造的现代媒体播放器", description: "基于 mpv 的开源播放器，支持丰富的视频格式和原生 macOS 体验。", installNotes: "建议下载 Universal DMG。", downloadNotes: "优先选择 GitHub Release 中的 dmg 文件。", tags: ["音视频", "播放器"], source: "内置仓库文档", updatedAt: "2026-05-28"),
            "utmapp/UTM": LocalizationPack(locale: "zh-Hans", displayName: "UTM", tagline: "在 macOS 上运行虚拟机", description: "适合运行 Linux、Windows 和其他系统的开源虚拟机工具。", installNotes: "Apple Silicon 用户优先选择 arm64 或 universal 包。", downloadNotes: "文件较大，建议开启稳定下载源。", tags: ["开发编程", "虚拟机"], source: "内置仓库文档", updatedAt: "2026-05-28")
        ]
        if let pack = known[fullName.lowercased()] { return pack }
        let readable = ReadableTextSanitizer.documentText(fallbackDescription)
        return LocalizationPack(locale: "zh-Hans", displayName: fallbackName, tagline: readable, description: readable, installNotes: "请查看项目 README 和 Release 说明。", downloadNotes: "下载前确认文件格式、架构和来源。", tags: [], source: "自动基础仓库文档", updatedAt: "2026-05-28")
    }
}

@MainActor
final class AppStoreModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var section: AppSection = .catalog
    @Published var category: AppCategory = .recommended
    @Published var query = ""
    @Published var discoverRepositories: [Repository] = SampleData.repositories
    @Published var searchRepositories: [Repository] = []
    @Published var selected: Repository? = SampleData.repositories.first
    @Published var latestRelease: Release?
    @Published var favorites: [Repository] = []
    @Published var downloads: [DownloadRecord] = []
    @Published var downloadJobs: [DownloadJob] = []
    private var downloadTasks: [UUID: URLSessionTask] = [:]
    @Published var sources: [DownloadSource] = [
        DownloadSource(id: "github-original", name: "GitHub 原始源", type: "origin", enabled: true, urlTemplate: "{originalUrl}", priority: 0),
        DownloadSource(id: "custom-proxy", name: "自定义加速源", type: "proxy", enabled: false, urlTemplate: "https://example.com/{originalUrl}", priority: 50)
    ]
    @Published var selectedSourceID = "github-original"
    @Published var appLanguage: AppLanguage = .system
    @Published var proxySettings = ProxySettings(enabled: false, server: "")
    @Published var githubAppAccessToken = ""
    @Published var status = "准备就绪" {
        didSet { captureRuntimeErrorIfNeeded(status, source: "status") }
    }
    @Published var runtimeErrors: [RuntimeErrorRecord] = []
    @Published var isLoading = false
    @Published var downloadProgress: Double = 0
    @Published var hasLoadedDiscover = false
    @Published var categoryRepositories: [AppCategory: [Repository]] = [:]
    @Published var categoryPages: [AppCategory: Int] = [:]
    @Published var categoryCanLoadMore: [AppCategory: Bool] = [:]
    @Published var isPreloadingCategories = false
    @Published var githubUser: GitHubUser?
    @Published var githubSessionID = ""
    @Published var userRepositories: [Repository] = []
    @Published var starredRepositories: [Repository] = []
    @Published var isAccountLoading = false
    @Published var userRepositoriesPage = 1
    @Published var starredRepositoriesPage = 1
    @Published var canLoadMoreUserRepositories = true
    @Published var canLoadMoreStarredRepositories = true
    @Published var accountRepositoryQuery = ""
    @Published var starredRepositoryQuery = ""
    @Published var accountRepositoryTab: AccountRepositoryTab = .owned
    @Published var workspacePath = ""
    @Published var localRepositories: [LocalRepository] = []
    @Published var selectedLocalRepository: LocalRepository?
    @Published var codeFiles: [CodeFile] = []
    @Published var selectedCodeFile: CodeFile?
    @Published var codeText = ""
    @Published var codeSearch = ""
    @Published var gitStatusText = ""
    @Published var gitDiffText = ""
    @Published var gitSyncStateText = "未读取 Git 状态"
    @Published var currentBranch = ""
    @Published var isSyncingRepository = false
    @Published var syncProgress: Double = 0
    @Published var syncMessage = "准备同步"
    @Published var commitMessage = "Update from OpenHub"

    private let client = GitHubClient()
    private let storage = LocalStorage()
    private let keychain = KeychainStore(service: "io.openhub.desktop")
    private var webAuthenticationSession: ASWebAuthenticationSession?

    override init() {
        super.init()
        favorites = storage.load([Repository].self, key: "favorites") ?? []
        downloads = storage.load([DownloadRecord].self, key: "downloads") ?? []
        runtimeErrors = storage.load([RuntimeErrorRecord].self, key: "runtimeErrors") ?? []
        sources = storage.load([DownloadSource].self, key: "sources") ?? sources
        selectedSourceID = storage.load(String.self, key: "selectedSourceID") ?? selectedSourceID
        appLanguage = storage.load(AppLanguage.self, key: "appLanguage") ?? .system
        proxySettings = storage.load(ProxySettings.self, key: "proxySettings") ?? proxySettings
        workspacePath = storage.load(String.self, key: "workspacePath") ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("OpenHubRepos", isDirectory: true).path
        localRepositories = (storage.load([LocalRepository].self, key: "localRepositories") ?? []).filter { isGitRepository(URL(fileURLWithPath: $0.path, isDirectory: true)) }
        selectedLocalRepository = localRepositories.first
        categoryRepositories[.recommended] = SampleData.repositories
        categoryCanLoadMore = Dictionary(uniqueKeysWithValues: AppCategory.allCases.map { ($0, true) })
        githubSessionID = keychain.read(account: "github-session-id") ?? ""
        githubAppAccessToken = keychain.read(account: "github-app-access-token") ?? ""
        keychain.delete(account: "github-fallback-token")
        applyProxySettings()
    }

    var selectedSource: DownloadSource {
        sources.first(where: { $0.id == selectedSourceID }) ?? sources[0]
    }

    var visibleRepositories: [Repository] {
        switch section {
        case .catalog: categoryRepositories[category] ?? fallbackRepositories(for: category)
        case .search: searchRepositories
        case .collections: favorites
        default: []
        }
    }

    var isLoggedIn: Bool { githubUser != nil }

    var activeGitHubToken: String {
        githubAppAccessToken.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canLoadMoreDiscover: Bool {
        categoryCanLoadMore[category, default: true]
    }

    func text(_ key: String) -> String {
        L10n.text(key, language: appLanguage)
    }

    func title(for section: AppSection) -> String {
        switch section {
        case .catalog: return AppSection.catalog.rawValue
        case .search: return text("search")
        case .collections: return text("favorites")
        case .code: return text("code")
        case .downloads: return text("downloads")
        case .updates: return text("updates")
        case .settings: return text("settings")
        case .account: return isLoggedIn ? text("accountCenter") : text("account")
        }
    }

    func title(for category: AppCategory) -> String {
        L10n.categoryName(category, language: appLanguage)
    }

    func matchReason(for repository: Repository) -> String {
        if repository.matchReason == "GitHub 热门" {
            return appLanguage == .en ? "GitHub Popular" : "GitHub 热门"
        }
        if repository.matchReason == repository.category.rawValue {
            return title(for: repository.category)
        }
        return repository.matchReason
    }

    func bootstrap() {
        guard !hasLoadedDiscover else { return }
        hasLoadedDiscover = true
        Task {
            await restoreGitHubLoginIfNeeded()
            await loadDiscover(force: false)
            await preloadCategories()
        }
    }

    func navigate(to section: AppSection) {
        self.section = section
        status = "已切换到\(section.rawValue)"
        switch section {
        case .catalog:
            if categoryRepositories[category]?.isEmpty != false || !hasLoadedDiscover {
                Task { await loadDiscover(force: false) }
            } else {
                selected = selected ?? categoryRepositories[category]?.first
            }
        case .search:
            status = query.isEmpty ? "输入仓库名可获得更精确排序" : "保留上次搜索：\(query)"
            selected = searchRepositories.first ?? selected
        case .collections:
            selected = favorites.first ?? selected
        case .code:
            scanLocalRepositories()
        case .account:
            if githubUser != nil && userRepositories.isEmpty && !isAccountLoading {
                Task { await refreshAccountData() }
            }
        default:
            break
        }
    }

    func loadDiscover(force: Bool) async {
        if isLoading { return }
        let currentCategory = category
        if force {
            categoryPages[currentCategory] = 0
            categoryCanLoadMore[currentCategory] = true
        }
        guard categoryCanLoadMore[currentCategory, default: true] else { return }
        isLoading = true
        let nextPage = categoryPages[currentCategory, default: 0] + 1
        status = nextPage == 1 ? "正在加载 GitHub 热门前 20..." : "正在继续加载热门项目..."
        defer { isLoading = false }
        do {
            let result = try await client.discoverTop(category: currentCategory, page: nextPage, token: activeGitHubToken)
            if nextPage == 1 {
                categoryRepositories[currentCategory] = result.isEmpty ? fallbackRepositories(for: currentCategory) : result
            } else {
                let currentList = categoryRepositories[currentCategory] ?? []
                let existing = Set(currentList.map(\.fullName))
                categoryRepositories[currentCategory] = currentList + result.filter { !existing.contains($0.fullName) }
            }
            let loadedCount = categoryRepositories[currentCategory]?.count ?? 0
            categoryPages[currentCategory] = nextPage
            categoryCanLoadMore[currentCategory] = loadedCount < 100 && !result.isEmpty && nextPage < 5
            if category == currentCategory && section == .catalog {
                selected = selected ?? categoryRepositories[currentCategory]?.first
                if nextPage == 1, let first = categoryRepositories[currentCategory]?.first { await loadRelease(for: first) }
            }
            status = "已加载 \(loadedCount)/100 个 GitHub 热门项目"
        } catch {
            status = "热门项目加载失败，已显示离线示例：\(error.localizedDescription)"
            if nextPage == 1, categoryRepositories[currentCategory]?.isEmpty != false {
                categoryRepositories[currentCategory] = fallbackRepositories(for: currentCategory)
                if category == currentCategory {
                    selected = categoryRepositories[currentCategory]?.first
                }
            }
            categoryPages[currentCategory] = max(categoryPages[currentCategory, default: 0], nextPage == 1 ? 0 : nextPage - 1)
            categoryCanLoadMore[currentCategory] = nextPage == 1
        }
    }

    func loadMoreDiscoverIfNeeded(current repository: Repository) {
        guard section == .catalog, canLoadMoreDiscover, !isLoading else { return }
        guard visibleRepositories.last?.fullName == repository.fullName else { return }
        Task { await loadDiscover(force: false) }
    }

    func performSearch() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            section = .search
            status = "请输入仓库名或关键词"
            return
        }
        section = .search
        isLoading = true
        status = "正在精确搜索 GitHub..."
        defer { isLoading = false }
        do {
            let result = try await client.search(query: trimmed, token: activeGitHubToken)
            searchRepositories = result
            selected = result.first
            status = result.isEmpty ? "没有找到结果" : "找到 \(result.count) 个结果，已按仓库名精确度排序"
            if let first = result.first { await loadRelease(for: first) }
        } catch {
            status = error.localizedDescription
        }
    }

    func choose(category: AppCategory) {
        self.category = category
        section = .catalog
        let cached = categoryRepositories[category] ?? fallbackRepositories(for: category)
        selected = cached.first ?? selected
        if !hasSuccessfullyLoaded(category) {
            categoryCanLoadMore[category] = true
            Task { await loadDiscover(force: true) }
        }
    }

    private func hasSuccessfullyLoaded(_ category: AppCategory) -> Bool {
        categoryPages[category, default: 0] > 0 && categoryRepositories[category]?.isEmpty == false
    }

    func select(_ repository: Repository) {
        selected = repository
        latestRelease = nil
        Task { await loadRelease(for: repository) }
    }

    func loadRelease(for repository: Repository) async {
        do {
            latestRelease = try await client.latestRelease(owner: repository.owner, repo: repository.name, token: activeGitHubToken)
            status = latestRelease?.assets.isEmpty == true ? "最新 Release 没有可下载资源" : "已加载最新 Release"
        } catch {
            latestRelease = nil
            status = "未找到最新 Release，可打开 GitHub 查看"
        }
    }

    func toggleFavorite(_ repository: Repository) async {
        let wasFavorite = favorites.contains(where: { $0.fullName == repository.fullName })
        if let index = favorites.firstIndex(where: { $0.fullName == repository.fullName }) {
            favorites.remove(at: index)
        } else {
            favorites.append(repository)
        }
        storage.save(favorites, key: "favorites")

        let trimmed = activeGitHubToken
        guard !trimmed.isEmpty else {
            status = wasFavorite ? "已取消本地收藏" : "已加入本地收藏"
            return
        }
        do {
            if wasFavorite {
                try await client.unstarRepository(owner: repository.owner, repo: repository.name, token: trimmed)
                starredRepositories.removeAll { $0.fullName == repository.fullName }
                status = "已取消收藏并同步 GitHub Star"
            } else {
                try await client.starRepository(owner: repository.owner, repo: repository.name, token: trimmed)
                if !starredRepositories.contains(where: { $0.fullName == repository.fullName }) {
                    starredRepositories.insert(repository, at: 0)
                }
                status = "已收藏并同步 GitHub Star"
            }
        } catch {
            let nsError = error as NSError
            if nsError.code == 403 {
                status = "本地收藏已保存，GitHub Star 同步失败：\(error.localizedDescription)"
            } else if nsError.code == 401 || nsError.code == 404 {
                status = "GitHub Star 同步失败（认证过期），请重新登录 GitHub"
            } else {
                status = "本地收藏已保存，GitHub Star 暂时无法同步：\(error.localizedDescription)"
            }
        }
    }

    func isFavorite(_ repository: Repository) -> Bool {
        favorites.contains(where: { $0.fullName == repository.fullName })
    }

    func saveSettings() {
        storage.save(sources, key: "sources")
        storage.save(selectedSourceID, key: "selectedSourceID")
        storage.save(appLanguage, key: "appLanguage")
        storage.save(workspacePath, key: "workspacePath")
        storage.save(proxySettings, key: "proxySettings")
        applyProxySettings()
        keychain.delete(account: "github-fallback-token")
        keychain.delete(account: "github-token")
        status = "设置已保存"
    }

    func exportRuntimeErrors() {
        let export = RuntimeErrorExport(
            app: "OpenHub macOS",
            exportedAt: Date(),
            section: section.rawValue,
            selectedRepository: selected?.fullName,
            status: status,
            errors: runtimeErrors
        )
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(export)
            let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            let formatter = ISO8601DateFormatter()
            let filename = "openhub-runtime-errors-\(formatter.string(from: Date()).replacingOccurrences(of: ":", with: "-")).json"
            let destination = downloadsURL.appendingPathComponent(filename)
            try data.write(to: destination, options: .atomic)
            NSWorkspace.shared.activateFileViewerSelecting([destination])
            status = "错误报告已下载到 Downloads：\(filename)"
        } catch {
            status = "错误报告下载失败：\(error.localizedDescription)"
        }
    }

    func clearRuntimeErrors() {
        runtimeErrors.removeAll()
        storage.save(runtimeErrors, key: "runtimeErrors")
        status = "运行错误记录已清空"
    }

    func clearAllCacheWithConfirmation() {
        let alert = NSAlert()
        alert.messageText = "清空 OpenHub 缓存？"
        alert.informativeText = """
        将清空本机配置、收藏列表、下载记录、本地仓库列表缓存、分类缓存、搜索结果、GitHub OAuth session id、GitHub access token，以及 Keychain 中的 GitHub OAuth 登录信息。

        不会删除已下载到磁盘的文件，也不会删除本地克隆仓库目录。
        """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "清空缓存")
        alert.addButton(withTitle: "取消")
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        clearAllCache()
    }

    private func clearAllCache() {
        favorites = []
        downloads = []
        downloadJobs = []
        runtimeErrors = []
        sources = [
            DownloadSource(id: "github-original", name: "GitHub 原始源", type: "origin", enabled: true, urlTemplate: "{originalUrl}", priority: 0),
            DownloadSource(id: "custom-proxy", name: "自定义加速源", type: "proxy", enabled: false, urlTemplate: "https://example.com/{originalUrl}", priority: 50)
        ]
        selectedSourceID = "github-original"
        appLanguage = .system
        proxySettings = ProxySettings(enabled: false, server: "")
        githubAppAccessToken = ""
        githubSessionID = ""
        githubUser = nil
        userRepositories = []
        starredRepositories = []
        userRepositoriesPage = 1
        starredRepositoriesPage = 1
        canLoadMoreUserRepositories = true
        canLoadMoreStarredRepositories = true
        accountRepositoryQuery = ""
        starredRepositoryQuery = ""
        searchRepositories = []
        query = ""
        categoryRepositories = [.recommended: SampleData.repositories]
        categoryPages = [:]
        categoryCanLoadMore = Dictionary(uniqueKeysWithValues: AppCategory.allCases.map { ($0, true) })
        localRepositories = []
        selectedLocalRepository = nil
        codeFiles = []
        selectedCodeFile = nil
        codeText = ""
        gitStatusText = ""
        gitDiffText = ""
        gitSyncStateText = "未读取 Git 状态"
        currentBranch = ""
        workspacePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("OpenHubRepos", isDirectory: true).path

        storage.remove(keys: [
            "favorites", "downloads", "runtimeErrors", "sources", "selectedSourceID", "appLanguage",
            "workspacePath", "proxySettings", "token", "localRepositories"
        ])
        keychain.delete(account: "github-session-id")
        keychain.delete(account: "github-app-access-token")
        keychain.delete(account: "github-fallback-token")
        keychain.delete(account: "github-token")
        applyProxySettings()
        status = "缓存已清空；下载文件和本地克隆仓库目录未删除"
    }

    private func captureRuntimeErrorIfNeeded(_ message: String, source: String) {
        let lowercased = message.lowercased()
        let markers = ["失败", "错误", "error", "failed", "exception", "无法", "未找到"]
        guard markers.contains(where: { lowercased.contains($0.lowercased()) }) else { return }
        if runtimeErrors.first?.message == message { return }
        runtimeErrors.insert(RuntimeErrorRecord(id: UUID(), message: message, source: source, section: section.rawValue, createdAt: Date()), at: 0)
        if runtimeErrors.count > 200 {
            runtimeErrors.removeLast(runtimeErrors.count - 200)
        }
        storage.save(runtimeErrors, key: "runtimeErrors")
    }

    func applyProxySettings() {
        client.proxyURL = proxySettings.normalizedURL
    }

    func preloadCategories() async {
        guard !isPreloadingCategories else { return }
        isPreloadingCategories = true
        defer { isPreloadingCategories = false }
        var successCount = 0
        var failedCount = 0

        for preloadCategory in AppCategory.allCases {
            if categoryPages[preloadCategory, default: 0] > 0 { continue }
            do {
                let result = try await client.discoverTop(category: preloadCategory, page: 1, token: activeGitHubToken)
                guard !result.isEmpty else {
                    if categoryRepositories[preloadCategory]?.isEmpty != false {
                        categoryRepositories[preloadCategory] = fallbackRepositories(for: preloadCategory)
                    }
                    categoryPages[preloadCategory] = 0
                    categoryCanLoadMore[preloadCategory] = true
                    failedCount += 1
                    continue
                }
                let list = result
                categoryRepositories[preloadCategory] = list
                categoryPages[preloadCategory] = 1
                categoryCanLoadMore[preloadCategory] = list.count < 100
                successCount += 1
                if section == .catalog, category == preloadCategory, selected == nil {
                    selected = list.first
                }
            } catch {
                if categoryRepositories[preloadCategory]?.isEmpty != false {
                    categoryRepositories[preloadCategory] = fallbackRepositories(for: preloadCategory)
                }
                categoryPages[preloadCategory] = 0
                categoryCanLoadMore[preloadCategory] = true
                failedCount += 1
            }
        }
        status = failedCount == 0 ? "分类内容预加载完成" : "分类预加载完成 \(successCount) 个，\(failedCount) 个将在切换时重试"
    }

    func startGitHubAppLogin() {
        status = "正在打开 GitHub 授权页面..."
        webAuthenticationSession?.cancel()
        let session = ASWebAuthenticationSession(url: client.githubAppAuthorizationURL(), callbackURLScheme: "openhub") { [weak self] callbackURL, error in
            Task { @MainActor in
                guard let self else { return }
                self.webAuthenticationSession = nil
                if let callbackURL {
                    self.handleOpenURL(callbackURL)
                    return
                }
                if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
                    self.status = "GitHub 登录已取消"
                    return
                }
                if let error {
                    self.status = "GitHub 登录失败：\(error.localizedDescription)"
                }
            }
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = false
        webAuthenticationSession = session
        if !session.start() {
            status = "GitHub 登录窗口打开失败"
            webAuthenticationSession = nil
        }
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        NSApp.keyWindow ?? NSApp.windows.first ?? ASPresentationAnchor()
    }

    func handleOpenURL(_ url: URL) {
        guard url.scheme == "openhub", url.host == "auth", url.path == "/callback" else { return }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let error = components?.queryItems?.first(where: { $0.name == "error" })?.value {
            status = "GitHub 授权失败：\(error)"
            return
        }
        guard let sessionID = components?.queryItems?.first(where: { $0.name == "session_id" })?.value, !sessionID.isEmpty else {
            status = "GitHub 授权回调缺少 session_id"
            return
        }
        Task { await completeGitHubAppLogin(sessionID: sessionID) }
    }

    func restoreGitHubLoginIfNeeded() async {
        if !githubSessionID.isEmpty {
            await completeGitHubAppLogin(sessionID: githubSessionID, isRestoring: true)
            return
        }
    }

    func completeGitHubAppLogin(sessionID: String, isRestoring: Bool = false) async {
        isAccountLoading = true
        status = isRestoring ? "正在恢复 GitHub 登录..." : "正在完成 GitHub 登录..."
        defer { isAccountLoading = false }
        do {
            let session = try await client.githubAppSession(sessionID: sessionID)
            githubSessionID = session.sessionId
            githubAppAccessToken = session.accessToken
            githubUser = try await client.currentUser(token: session.accessToken)
            try keychain.save(session.sessionId, account: "github-session-id")
            try keychain.save(session.accessToken, account: "github-app-access-token")
            keychain.delete(account: "github-token")
            status = "已通过 GitHub 登录：\(githubUser?.login ?? session.login)"
            await refreshAccountData()
            section = .account
        } catch {
            if !isRestoring {
                status = "GitHub OAuth 登录失败：\(error.localizedDescription)"
            }
        }
    }

    func refreshAccountData() async {
        let trimmed = activeGitHubToken
        guard !trimmed.isEmpty else { return }
        isAccountLoading = true
        defer { isAccountLoading = false }
        do {
            async let repos = client.userRepositories(token: trimmed, page: 1)
            async let starred = client.starredRepositories(token: trimmed, page: 1)
            userRepositories = try await repos
            starredRepositories = try await starred
            userRepositoriesPage = 1
            starredRepositoriesPage = 1
            canLoadMoreUserRepositories = userRepositories.count >= 20
            canLoadMoreStarredRepositories = starredRepositories.count >= 20
            status = "个人中心已更新"
        } catch {
            status = "个人中心加载失败：\(error.localizedDescription)"
        }
    }

    func loadMoreUserRepositories() async {
        await loadMoreAccountRepositories(kind: .owned)
    }

    func loadMoreStarredRepositories() async {
        await loadMoreAccountRepositories(kind: .starred)
    }

    private enum AccountRepositoryKind { case owned, starred }

    private func loadMoreAccountRepositories(kind: AccountRepositoryKind) async {
        let trimmed = activeGitHubToken
        guard !trimmed.isEmpty, !isAccountLoading else { return }
        isAccountLoading = true
        defer { isAccountLoading = false }
        do {
            switch kind {
            case .owned:
                guard canLoadMoreUserRepositories else { return }
                let next = userRepositoriesPage + 1
                let repos = try await client.userRepositories(token: trimmed, page: next)
                appendUnique(repos, to: &userRepositories)
                userRepositoriesPage = next
                canLoadMoreUserRepositories = repos.count >= 20
                status = repos.isEmpty ? "没有更多自己的仓库" : "已加载更多自己的仓库"
            case .starred:
                guard canLoadMoreStarredRepositories else { return }
                let next = starredRepositoriesPage + 1
                let repos = try await client.starredRepositories(token: trimmed, page: next)
                appendUnique(repos, to: &starredRepositories)
                starredRepositoriesPage = next
                canLoadMoreStarredRepositories = repos.count >= 20
                status = repos.isEmpty ? "没有更多星标仓库" : "已加载更多星标仓库"
            }
        } catch {
            status = "加载更多失败：\(error.localizedDescription)"
        }
    }

    private func appendUnique(_ repos: [Repository], to list: inout [Repository]) {
        let existing = Set(list.map(\.fullName))
        list.append(contentsOf: repos.filter { !existing.contains($0.fullName) })
    }

    var filteredUserRepositories: [Repository] {
        let trimmed = accountRepositoryQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return userRepositories }
        return userRepositories.filter {
            $0.fullName.lowercased().contains(trimmed) ||
            $0.name.lowercased().contains(trimmed) ||
            $0.description.lowercased().contains(trimmed)
        }
    }

    var filteredStarredRepositories: [Repository] {
        let trimmed = starredRepositoryQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return starredRepositories }
        return starredRepositories.filter {
            $0.fullName.lowercased().contains(trimmed) ||
            $0.name.lowercased().contains(trimmed) ||
            $0.description.lowercased().contains(trimmed)
        }
    }

    func chooseWorkspacePath() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "选择"
        if panel.runModal() == .OK, let url = panel.url {
            workspacePath = url.path
            storage.save(workspacePath, key: "workspacePath")
            scanLocalRepositories()
            status = "本地仓库路径已更新"
        }
    }

    func forkSelectedRepository() async {
        guard let repository = selected else {
            status = "请先选择要 Fork 的项目"
            return
        }
        await forkRepository(repository)
    }

    func forkRepository(_ repository: Repository) async {
        let trimmed = activeGitHubToken
        guard !trimmed.isEmpty else {
            status = "请先登录 GitHub，账号授权需要 repo 权限"
            return
        }
        isAccountLoading = true
        status = "正在 Fork \(repository.fullName)..."
        defer { isAccountLoading = false }
        do {
            let forked = try await client.forkRepository(owner: repository.owner, repo: repository.name, token: trimmed)
            if !userRepositories.contains(where: { $0.fullName == forked.fullName }) {
                userRepositories.insert(forked, at: 0)
            }
            status = "Fork 已创建：\(forked.fullName)"
        } catch {
            status = "Fork 失败：\(error.localizedDescription)"
        }
    }

    func cloneRepository(_ repository: Repository) async {
        await runGitRepositoryCommand(repository: repository, commandName: "下载") { destination in
            ["clone", "https://github.com/\(repository.fullName).git", destination.path]
        }
    }

    /// 诊断 Git 远程仓库配置和网络连通性
    func diagnoseGitRemote(for local: LocalRepository) async -> String {
        let directory = URL(fileURLWithPath: local.path, isDirectory: true)
        var report: [String] = ["=== Git 远程诊断 ==="]

        // 1. 检查 git 版本
        do {
            let version = try await runGit(["version"], in: directory)
            report.append("Git 版本: \(version.trimmingCharacters(in: .whitespacesAndNewlines))")
        } catch {
            report.append("Git 版本: 无法获取 (\(error.localizedDescription))")
        }

        // 2. 检查 remote 配置
        do {
            let remoteURL = try await runGit(["remote", "get-url", "origin"], in: directory)
            report.append("Remote origin: \(remoteURL.trimmingCharacters(in: .whitespacesAndNewlines))")
        } catch {
            report.append("Remote origin: 未配置或无法读取")
        }

        // 3. 检查当前分支
        do {
            let branch = try await currentGitBranch(in: directory)
            report.append("当前分支: \(branch)")
        } catch {
            report.append("当前分支: 无法获取 (\(error.localizedDescription))")
        }

        // 4. 检查 git config 中的用户信息
        for key in ["user.name", "user.email"] {
            do {
                let value = try await runGit(["config", key], in: directory)
                report.append("\(key): \(value.trimmingCharacters(in: .whitespacesAndNewlines))")
            } catch {
                report.append("\(key): 未配置")
            }
        }

        // 5. 尝试 ls-remote 测试网络连通性
        do {
            let refs = try await runGit(["ls-remote", "--heads", "origin"], in: directory)
            let count = refs.split(separator: "\n").count
            report.append("网络连通性: 正常（获取到 \(count) 个远程分支）")
        } catch {
            report.append("网络连通性: 失败 - \(error.localizedDescription)")
        }

        // 6. 检查代理设置
        if proxySettings.enabled {
            report.append("代理设置: 已启用 - \(proxySettings.server)")
        } else {
            report.append("代理设置: 未启用（直连）")
        }

        return report.joined(separator: "\n")
    }

    func syncSelectedLocalRepository() async {
        guard let local = selectedLocalRepository else {
            status = "请先选择本地仓库"
            return
        }
        let directory = URL(fileURLWithPath: local.path, isDirectory: true)
        isSyncingRepository = true
        syncProgress = 0.0
        syncMessage = "准备同步"
        defer { isSyncingRepository = false }

        do {
            try cleanupStaleGitLock(in: directory)

            syncProgress = 0.1
            syncMessage = "正在检查仓库配置..."
            _ = try await requireOriginRemote(in: directory)
            let branch = try await currentGitBranch(in: directory)

            syncProgress = 0.2
            syncMessage = "正在检查 Git 配置..."
            try await ensureGitConfig(in: directory)

            syncProgress = 0.35
            syncMessage = "正在暂存本地改动..."
            _ = try await runGit(["add", "."], in: directory)

            let hasStagedChanges = await gitCommandSucceeds(["diff", "--cached", "--quiet"], in: directory) == false
            if hasStagedChanges {
                syncMessage = "正在创建本地提交..."
                let msg = commitMessage.isEmpty ? "Update from OpenHub" : commitMessage
                _ = try await runGit(["commit", "-m", msg], in: directory)
            } else {
                syncMessage = "无新改动，检查是否有本地提交待推送..."
            }

            syncProgress = 0.65
            syncMessage = "正在推送到 GitHub..."
            try await pushLikeGitHubDesktop(directory: directory, branch: branch)

            syncProgress = 0.95
            syncMessage = "正在刷新状态..."
            await refreshGitStatus()

            syncProgress = 1.0
            syncMessage = "同步完成 ✅"
            status = "同步完成：已推送 \(branch) 到 GitHub"
        } catch {
            syncMessage = "同步失败"
            syncProgress = 0
            let friendlyMsg = friendlyGitSyncError(error.localizedDescription)
            status = "同步失败：\(friendlyMsg)"
            await refreshGitStatus()
        }
    }

    /// 确保 git 配置了 user.name 和 user.email
    private func ensureGitConfig(in directory: URL) async throws {
        // 检查 user.name
        let nameResult = try? await runGit(["config", "user.name"], in: directory)
        if nameResult == nil || nameResult!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // 尝试从全局 git config 或系统获取用户名
            let fallbackName = NSFullUserName()
            _ = try? await runGit(["config", "user.name", fallbackName], in: directory)
        }

        // 检查 user.email
        let emailResult = try? await runGit(["config", "user.email"], in: directory)
        if emailResult == nil || emailResult!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let fallbackEmail = "openhub@local"
            _ = try? await runGit(["config", "user.email", fallbackEmail], in: directory)
        }
    }

    /// 尽量复用用户本机 Git 凭据，行为接近 GitHub Desktop / 终端 git push。
    private func pushLikeGitHubDesktop(directory: URL, branch: String) async throws {
        do {
            try await pushUsingNativeGitCredentials(directory: directory, branch: branch)
            return
        } catch {
            let message = error.localizedDescription
            if isNonFastForwardError(message) {
                syncProgress = 0.72
                syncMessage = "远端有更新，正在 rebase 后重试..."
                _ = try await runGit(["pull", "--rebase", "--autostash", "origin", branch], in: directory)
                try await pushUsingNativeGitCredentials(directory: directory, branch: branch)
                return
            }

            if isAuthenticationError(message),
               let remoteFullName = try? await resolvedRemoteFullNameFromGit(in: directory),
               !activeGitHubToken.isEmpty {
                syncProgress = 0.75
                syncMessage = "系统 Git 凭据失败，正在使用 GitHub 登录凭据重试..."
                try await pushUsingGitHubOAuthToken(directory: directory, branch: branch, remoteFullName: remoteFullName, token: activeGitHubToken)
                return
            }

            throw error
        }
    }

    private func pushUsingNativeGitCredentials(directory: URL, branch: String) async throws {
        if await hasUpstream(in: directory) {
            _ = try await runGit(["push"], in: directory)
        } else {
            _ = try await runGit(["push", "-u", "origin", branch], in: directory)
        }
    }

    private func pushUsingGitHubOAuthToken(directory: URL, branch: String, remoteFullName: String, token: String) async throws {
        let encodedToken = token.addingPercentEncoding(withAllowedCharacters: .urlPasswordAllowed) ?? token
        let tokenURL = "https://x-access-token:\(encodedToken)@github.com/\(remoteFullName).git"
        _ = try await runGit(["push", tokenURL, "HEAD:refs/heads/\(branch)"], in: directory)
    }

    func deleteSelectedLocalRepository() {
        guard let local = selectedLocalRepository else {
            status = "请先选择本地仓库"
            return
        }
        let alert = NSAlert()
        alert.messageText = "删除本地仓库？"
        alert.informativeText = "该操作只会删除本地路径：\(local.path)，不会删除 GitHub 远程仓库。"
        alert.addButton(withTitle: "删除本地仓库")
        alert.addButton(withTitle: "取消")
        alert.alertStyle = .warning
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        do {
            try FileManager.default.removeItem(atPath: local.path)
            localRepositories.removeAll { $0.id == local.id }
            storage.save(localRepositories, key: "localRepositories")
            selectedLocalRepository = localRepositories.first
            codeFiles = []
            selectedCodeFile = nil
            codeText = ""
            if let selectedLocalRepository { loadCodeFiles(for: selectedLocalRepository) }
            status = "本地仓库已删除。该功能只能删除本地仓库，不会删除 GitHub 远程仓库。"
        } catch {
            status = "删除本地仓库失败：\(error.localizedDescription)"
        }
    }

    func scanLocalRepositories() {
        let root = URL(fileURLWithPath: workspacePath, isDirectory: true)
        try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        var scanned: [LocalRepository] = []
        let candidateURLs: [URL]
        if isGitRepository(root) {
            candidateURLs = [root]
        } else {
            let children = (try? FileManager.default.contentsOfDirectory(at: root, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])) ?? []
            candidateURLs = children.filter { child in
                (try? child.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true && isGitRepository(child)
            }
        }

        for child in candidateURLs {
            let existingID = localRepositories.first(where: { $0.path == child.path })?.id ?? UUID()
            let remoteURL = (try? runGitSync(["remote", "get-url", "origin"], in: child).trimmingCharacters(in: .whitespacesAndNewlines)) ?? ""
            let fullName = parseGitHubFullName(from: remoteURL) ?? child.lastPathComponent
            let repository = LocalRepository(id: existingID, fullName: fullName, path: child.path, remoteURL: remoteURL, updatedAt: Date())
            scanned.append(repository)
        }
        localRepositories = scanned.sorted { $0.updatedAt > $1.updatedAt }
        storage.save(localRepositories, key: "localRepositories")
        if let selectedLocalRepository,
           let refreshed = localRepositories.first(where: { $0.path == selectedLocalRepository.path }) {
            self.selectedLocalRepository = refreshed
        } else {
            selectedLocalRepository = localRepositories.first
        }
        if let selectedLocalRepository {
            loadCodeFiles(for: selectedLocalRepository)
        } else {
            codeFiles = []
            selectedCodeFile = nil
            codeText = ""
            gitStatusText = "未找到 Git 仓库，请选择包含 .git 的仓库目录或其上级工作区。"
            gitDiffText = ""
            gitSyncStateText = "未找到 Git 仓库"
            currentBranch = ""
            status = "未找到可用本地 Git 仓库"
        }
    }

    func selectLocalRepository(_ repository: LocalRepository) {
        guard isGitRepository(URL(fileURLWithPath: repository.path, isDirectory: true)) else {
            localRepositories.removeAll { $0.id == repository.id }
            storage.save(localRepositories, key: "localRepositories")
            selectedLocalRepository = localRepositories.first
            status = "该路径不是 Git 仓库，已从本地列表移除"
            return
        }
        selectedLocalRepository = repository
        loadCodeFiles(for: repository)
    }

    func loadCodeFiles(for repository: LocalRepository) {
        let root = URL(fileURLWithPath: repository.path, isDirectory: true)
        guard isGitRepository(root) else {
            codeFiles = []
            selectedCodeFile = nil
            codeText = ""
            gitStatusText = "该路径不是 Git 仓库，请重新选择本地仓库路径。"
            gitDiffText = ""
            gitSyncStateText = "本地仓库无效"
            currentBranch = ""
            status = "本地仓库无效：\(repository.path)"
            return
        }
        let skipDirectories: Set<String> = [".git", ".build", ".swiftpm", "node_modules", "target", "dist", "DerivedData"]
        let allowedExtensions: Set<String> = ["swift", "md", "json", "js", "ts", "html", "css", "rs", "toml", "yml", "yaml", "txt", "sh", "ps1"]
        let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey], options: [.skipsHiddenFiles])
        var files: [CodeFile] = []
        while let url = enumerator?.nextObject() as? URL, files.count < 240 {
            if (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true {
                if skipDirectories.contains(url.lastPathComponent) { enumerator?.skipDescendants() }
                continue
            }
            let ext = url.pathExtension.lowercased()
            guard allowedExtensions.contains(ext) || url.lastPathComponent == "Package.swift" || url.lastPathComponent == "README" else { continue }
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            guard size < 600_000 else { continue }
            let relative = String(url.path.dropFirst(root.path.count + 1))
            files.append(CodeFile(relativePath: relative, absolutePath: url.path))
        }
        codeFiles = files.sorted { $0.relativePath < $1.relativePath }
        if let first = codeFiles.first { selectCodeFile(first) }
        Task { await refreshGitStatus() }
    }

    func selectCodeFile(_ file: CodeFile) {
        selectedCodeFile = file
        do {
            codeText = try String(contentsOfFile: file.absolutePath, encoding: .utf8)
            status = "已打开 \(file.relativePath)"
        } catch {
            codeText = ""
            status = "文件读取失败：\(error.localizedDescription)"
        }
    }

    func saveSelectedCodeFile() {
        guard let file = selectedCodeFile else { return }
        do {
            try codeText.write(toFile: file.absolutePath, atomically: true, encoding: .utf8)
            Task { await refreshGitStatus() }
            status = "已保存 \(file.relativePath)"
        } catch {
            status = "保存失败：\(error.localizedDescription)"
        }
    }

    var filteredCodeFiles: [CodeFile] {
        let trimmed = codeSearch.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return codeFiles }
        return codeFiles.filter { $0.relativePath.lowercased().contains(trimmed) }
    }

    func refreshGitStatus() async {
        guard let local = selectedLocalRepository else { return }
        let directory = URL(fileURLWithPath: local.path)
        guard isGitRepository(directory) else {
            gitStatusText = "该路径不是 Git 仓库，请点击“刷新”重新扫描。"
            gitDiffText = ""
            currentBranch = ""
            return
        }
        do {
            currentBranch = try await currentGitBranch(in: directory)
            let branchStatus = try await runGit(["status", "--short", "--branch"], in: directory)
            let shortStatus = try await runGit(["status", "--short"], in: directory)
            let branchLine = branchStatus.split(separator: "\n", maxSplits: 1).first.map(String.init) ?? ""
            gitStatusText = shortStatus.isEmpty ? branchLine : branchStatus
            gitDiffText = try await runGit(["diff", "--stat"], in: directory)
            gitSyncStateText = gitStateSummary(branchLine: branchLine, shortStatus: shortStatus)
        } catch {
            gitStatusText = "Git 状态读取失败：\(error.localizedDescription)"
            gitSyncStateText = "Git 状态读取失败"
        }
    }

    private func runGitRepositoryCommand(repository: Repository, commandName: String, arguments: (URL) -> [String]) async {
        let root = URL(fileURLWithPath: workspacePath, isDirectory: true)
        let destination = root.appendingPathComponent(repository.name, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
            if FileManager.default.fileExists(atPath: destination.path) {
                status = "本地已存在：\(destination.path)"
            } else {
                status = "正在\(commandName)：\(repository.fullName)"
                _ = try await runGit(arguments(destination), in: root)
            }
            let local = LocalRepository(id: UUID(), fullName: repository.fullName, path: destination.path, remoteURL: repository.htmlURL, updatedAt: Date())
            localRepositories.removeAll { $0.path == local.path }
            localRepositories.insert(local, at: 0)
            storage.save(localRepositories, key: "localRepositories")
            selectLocalRepository(local)
            section = .code
            status = "\(commandName)完成：\(repository.fullName)"
        } catch {
            status = "\(commandName)失败：\(error.localizedDescription)"
        }
    }

    /// 获取继承用户 shell 环境的 git 进程环境变量（包含 PATH、SSH_AUTH_SOCK 等）
    private func gitEnvironment() -> [String: String] {
        var env = ProcessInfo.processInfo.environment
        // 确保 git 能找到 SSH key 和 credential helper
        if let home = NSHomeDirectory() as String? {
            env["HOME"] = home
        }
        // 设置 GIT_TERMINAL_PROMPT=0 禁止 git 弹出交互式密码输入
        env["GIT_TERMINAL_PROMPT"] = "0"
        // 设置 GIT_ASKPASS 为空，防止弹出 GUI 密码框
        env["GIT_ASKPASS"] = ""
        env["SSH_ASKPASS"] = ""
        // 设置 LANG 避免编码问题
        env["LANG"] = "en_US.UTF-8"
        return env
    }

    /// 判断参数是否为网络操作（需要代理的 git 命令）
    private func isNetworkGitCommand(_ arguments: [String]) -> Bool {
        let networkVerbs: Set<String> = ["clone", "fetch", "pull", "push", "ls-remote"]
        guard let verb = arguments.first else { return false }
        return networkVerbs.contains(verb)
    }

    /// 判断是否需要网络代理
    private func shouldUseProxy() -> Bool {
        guard proxySettings.enabled, let url = proxySettings.normalizedURL else { return false }
        return url.host != nil && url.port != nil
    }

    private func runGit(_ arguments: [String], in directory: URL, allowFailureContaining allowedText: String? = nil) async throws -> String {
        let timeoutSeconds: TimeInterval = 120 // 网络操作 2 分钟超时
        let localTimeoutSeconds: TimeInterval = 30  // 本地操作 30 秒超时

        // 在 actor 隔离的闭包外预先准备数据
        let isNetwork = isNetworkGitCommand(arguments)
        let timeout = isNetwork ? timeoutSeconds : localTimeoutSeconds
        let env = gitEnvironment()

        // 使用传统 Process + waitUntilExit 方式，避免 Sendable 闭包问题
        return try await Task.detached(priority: .userInitiated) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            process.arguments = arguments
            process.currentDirectoryURL = directory
            process.environment = env

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            try process.run()

            // 带超时的等待（在 detached task 中，可以使用同步 API）
            let deadline = Date().addingTimeInterval(timeout)
            while process.isRunning {
                if Date() > deadline {
                    process.terminate()
                    // 等待进程真正结束
                    process.waitUntilExit()
                    let errData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                    let errStr = String(data: errData, encoding: .utf8) ?? ""
                    let msg = isNetwork
                        ? "Git 网络操作超时（\(Int(timeout))秒）。\n请检查网络连接或代理设置。\n\(errStr)"
                        : "Git 本地操作超时（\(Int(timeout))秒）。\n\(errStr)"
                    throw NSError(domain: "Git", code: -1, userInfo: [NSLocalizedDescriptionKey: msg])
                }
                usleep(50_000) // 50ms
            }

            let stdoutData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let stderrData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
            let stderr = String(data: stderrData, encoding: .utf8) ?? ""
            let output = stderr.isEmpty ? stdout : (stdout.isEmpty ? stderr : stdout + "\n" + stderr)

            if process.terminationStatus == 0 || (allowedText.map { output.contains($0) } ?? false) {
                return output
            } else {
                let cmd = arguments.joined(separator: " ")
                let detail = output.isEmpty ? "git \(cmd) 执行失败（退出码: \(process.terminationStatus)）" : output
                throw NSError(domain: "Git", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: detail])
            }
        }.value
    }

    private func gitCommandSucceeds(_ arguments: [String], in directory: URL) async -> Bool {
        do {
            _ = try await runGit(arguments, in: directory)
            return true
        } catch {
            return false
        }
    }

    private func currentGitBranch(in directory: URL) async throws -> String {
        let branch = try await runGit(["branch", "--show-current"], in: directory).trimmingCharacters(in: .whitespacesAndNewlines)
        if !branch.isEmpty { return branch }
        let fallback = try await runGit(["rev-parse", "--abbrev-ref", "HEAD"], in: directory).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !fallback.isEmpty, fallback != "HEAD" else {
            throw NSError(domain: "Git", code: 1, userInfo: [NSLocalizedDescriptionKey: "无法解析当前 Git 分支，请确认仓库不处于 detached HEAD 状态。"])
        }
        return fallback
    }

    private func requireOriginRemote(in directory: URL) async throws -> String {
        let remote = try await runGit(["remote", "get-url", "origin"], in: directory).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !remote.isEmpty else {
            throw NSError(domain: "Git", code: 1, userInfo: [NSLocalizedDescriptionKey: "当前仓库没有配置 origin 远程地址，请先在 GitHub Desktop 或终端添加 remote。"])
        }
        return remote
    }

    private func hasUpstream(in directory: URL) async -> Bool {
        do {
            let upstream = try await runGit(["rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}"], in: directory)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return !upstream.isEmpty
        } catch {
            return false
        }
    }

    private func gitStateSummary(branchLine: String, shortStatus: String) -> String {
        if !shortStatus.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "有未提交变更"
        }
        if branchLine.contains("ahead") {
            return "有本地提交未推送"
        }
        if branchLine.contains("behind") {
            return "本地落后远端"
        }
        return "工作区干净"
    }

    private func isGitRepository(_ directory: URL) -> Bool {
        FileManager.default.fileExists(atPath: directory.appendingPathComponent(".git").path)
    }

    private func runGitSync(_ arguments: [String], in directory: URL) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = arguments
        process.currentDirectoryURL = directory
        process.environment = gitEnvironment()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        try process.run()
        process.waitUntilExit()
        let stdoutData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderr = String(data: stderrData, encoding: .utf8) ?? ""
        let output = stderr.isEmpty ? stdout : (stdout.isEmpty ? stderr : stdout + "\n" + stderr)
        if process.terminationStatus == 0 { return output }
        throw NSError(domain: "Git", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: output])
    }

    private func resolvedRemoteFullName(for local: LocalRepository) async throws -> String {
        if local.fullName.contains("/") { return local.fullName }
        return try await resolvedRemoteFullNameFromGit(in: URL(fileURLWithPath: local.path, isDirectory: true))
    }

    private func resolvedRemoteFullNameFromGit(in directory: URL) async throws -> String {
        let remoteURL = try await runGit(["remote", "get-url", "origin"], in: directory).trimmingCharacters(in: .whitespacesAndNewlines)
        if let fullName = parseGitHubFullName(from: remoteURL) { return fullName }
        throw NSError(domain: "Git", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "无法从 git remote origin 解析 GitHub 仓库地址，请确认远程地址是 github.com/owner/repo。"
        ])
    }

    private func isAuthenticationError(_ message: String) -> Bool {
        let lowercased = message.lowercased()
        return lowercased.contains("authentication failed") ||
            lowercased.contains("could not read username") ||
            lowercased.contains("could not read from remote") ||
            lowercased.contains("permission denied") ||
            lowercased.contains("repository not found") ||
            lowercased.contains("remote: not found")
    }

    private func isNonFastForwardError(_ message: String) -> Bool {
        let lowercased = message.lowercased()
        return lowercased.contains("non-fast-forward") ||
            lowercased.contains("fetch first") ||
            lowercased.contains("rejected") && lowercased.contains("behind")
    }

    private func parseGitHubFullName(from remoteURL: String) -> String? {
        let trimmed = remoteURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let patterns = [
            #"github\.com[:/]([^/\s:]+)/([^/\s]+?)(?:\.git)?$"#,
            #"https?://[^/]*github\.com/([^/\s]+)/([^/\s]+?)(?:\.git)?$"#
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
               match.numberOfRanges >= 3,
               let ownerRange = Range(match.range(at: 1), in: trimmed),
               let repoRange = Range(match.range(at: 2), in: trimmed) {
                return "\(trimmed[ownerRange])/\(trimmed[repoRange])"
            }
        }
        return nil
    }

    private func cleanupStaleGitLock(in directory: URL) throws {
        let lock = directory.appendingPathComponent(".git/index.lock")
        if FileManager.default.fileExists(atPath: lock.path) {
            try FileManager.default.removeItem(at: lock)
        }
    }

    private func friendlyGitSyncError(_ message: String) -> String {
        let lowercased = message.lowercased()

        // 认证相关错误
        if lowercased.contains("could not read from remote") || lowercased.contains("permission denied") || lowercased.contains("authentication failed") {
            return "GitHub 认证失败。请尝试以下方法：\n1. 在 OpenHub 中重新登录 GitHub\n2. 确认终端中 git 可以正常 push（运行 git push 测试）\n3. 如果是 SSH 方式，检查 SSH key 是否配置正确"
        }

        // 网络连接错误
        if lowercased.contains("could not resolve host") || lowercased.contains("name or service not known") {
            return "无法解析 github.com 域名。请检查 DNS 或网络连接。"
        }
        if lowercased.contains("connection refused") || lowercased.contains("connection reset") {
            return "连接 github.com 被拒绝或重置。可能需要配置代理或检查防火墙设置。"
        }
        if lowercased.contains("operation timed out") || lowercased.contains("超时") {
            return "连接 github.com 超时。请检查网络状况，或尝试在终端中先运行 git push 测试连通性。"
        }
        if lowercased.contains("443") || lowercased.contains("port 443") {
            return "连接 github.com:443 失败。本地改动已保存，但推送失败。\n请检查：\n1. 网络是否正常\n2. 是否需要配置代理\n3. 在终端中运行 git push origin 测试"
        }

        // 仓库访问错误
        if lowercased.contains("repository not found") || lowercased.contains("remote: not found") {
            return "GitHub 仓库不可访问。\n请确认：\n1. OAuth App 已获得目标仓库访问权限\n2. 本机 Git 凭据可以访问该仓库\n3. 私有仓库需要使用 repo scope 重新授权"
        }

        // 锁文件
        if lowercased.contains("index.lock") {
            return "Git 仓库存在锁文件，可能是上次操作中断导致。请稍后重试，或手动删除 .git/index.lock 文件。"
        }

        // 冲突相关
        if lowercased.contains("non-fast-forward") || lowercased.contains("fetch first") || lowercased.contains("rebase") || lowercased.contains("conflict") {
            return "远端有新的提交与本地的提交冲突。\n请手动处理：\n1. 在终端中进入仓库目录\n2. 运行 git pull --rebase 解决冲突\n3. 再回到 OpenHub 同步"
        }

        // 默认返回原始错误信息（帮助用户排查）
        let preview = message.count > 300 ? String(message.prefix(300)) + "..." : message
        return preview
    }

    /// 不再在 git 命令层面注入代理参数。
    /// 代理配置通过 git 全局配置或环境变量处理，避免干扰本地 git 操作。
    /// 如需使用代理访问 GitHub，请用户在终端中自行配置：
    ///   git config --global http.proxy http://127.0.0.1:xxxx
    ///   git config --global https.proxy http://127.0.0.1:xxxx
    private func gitArguments(_ arguments: [String]) -> [String] {
        return arguments
    }

    func logout() {
        let sessionID = githubSessionID
        if !sessionID.isEmpty {
            Task { await client.logoutGitHubAppSession(sessionID: sessionID) }
        }
        githubUser = nil
        userRepositories = []
        starredRepositories = []
        githubSessionID = ""
        githubAppAccessToken = ""
        keychain.delete(account: "github-session-id")
        keychain.delete(account: "github-app-access-token")
        keychain.delete(account: "github-fallback-token")
        keychain.delete(account: "github-token")
        status = "已退出 GitHub 登录"
    }

    func download(_ asset: ReleaseAsset, for repository: Repository) async {
        guard let sourceURL = selectedSource.resolvedURL(for: asset.browserDownloadURL) else {
            status = "下载源 URL 无效"
            return
        }
        let jobID = UUID()
        downloadJobs.insert(DownloadJob(id: jobID, appName: repository.displayName, assetName: asset.name, sourceName: selectedSource.name, originalURL: asset.browserDownloadURL, progress: 0, state: .downloading, savedPath: nil, partialFileURL: nil, bytesDownloaded: 0, message: "准备下载", cancel: { [weak self] in
            Task { @MainActor in self?.cancelDownload(jobID) }
        }, retry: { [weak self] in
            Task { await self?.retryDownload(asset: asset, repository: repository, oldJobID: jobID) }
        }), at: 0)
        do {
            status = "正在下载 \(asset.name)..."
            downloadProgress = 0.05
            let (tempURL, _) = try await downloadFile(from: sourceURL, jobID: jobID)
            let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("OpenHub", isDirectory: true)
            try FileManager.default.createDirectory(at: downloadsURL, withIntermediateDirectories: true)
            let destination = downloadsURL.appendingPathComponent(asset.name)
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.moveItem(at: tempURL, to: destination)
            downloadProgress = 1
            let checksum = try sha256(of: destination)
            let record = DownloadRecord(id: UUID(), appName: repository.displayName, assetName: asset.name, sourceName: selectedSource.name, originalURL: asset.browserDownloadURL, savedPath: destination.path, downloadedAt: Date(), checksum: checksum)
            downloads.insert(record, at: 0)
            storage.save(downloads, key: "downloads")
            updateDownloadJob(jobID, progress: 1, state: .completed, savedPath: destination.path, message: "下载完成，可打开安装")
            downloadTasks.removeValue(forKey: jobID)
            status = "下载完成：\(asset.name)"
        } catch {
            downloadProgress = 0
            downloadTasks.removeValue(forKey: jobID)
            if (error as NSError).code == NSURLErrorCancelled {
                updateDownloadJob(jobID, progress: 0, state: .cancelled, savedPath: nil, message: "用户已取消下载")
                status = "已取消下载：\(asset.name)"
            } else {
                let nsErr = error as NSError
                let completedBytes = downloadTasks[jobID]?.countOfBytesReceived ?? 0
                var partialURL: URL? = nil
                if completedBytes > 1024 {
                    let partialsDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
                        .appendingPathComponent("OpenHubPartialDownloads", isDirectory: true)
                    try? FileManager.default.createDirectory(at: partialsDir, withIntermediateDirectories: true)
                    partialURL = partialsDir.appendingPathComponent("\(jobID.uuidString).partial")
                }
                let failMsg = completedBytes > 1024
                    ? "下载失败（已下载 " + ByteCountFormatter.string(fromByteCount: completedBytes, countStyle: .file) + "，可右键重试）：" + error.localizedDescription
                    : "下载失败：" + error.localizedDescription
                updateDownloadJob(jobID, progress: jobProgress(jobID), state: .failed, savedPath: nil, partialFileURL: partialURL, bytesDownloaded: completedBytes, message: failMsg)
                status = "下载失败，建议切换 GitHub 原始源重试：\(error.localizedDescription)"
            }
        }
    }

    private func downloadFile(from url: URL, jobID: UUID, resumeFromBytes: Int64 = 0) async throws -> (URL, URLResponse) {
        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                var request = URLRequest(url: url)
                if resumeFromBytes > 0 {
                    request.setValue("bytes=\(resumeFromBytes)-", forHTTPHeaderField: "Range")
                    request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                }
                let task = URLSession.shared.downloadTask(with: request) { tempURL, response, error in
                    Task { @MainActor in self.downloadTasks.removeValue(forKey: jobID) }
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    guard let tempURL, let response else {
                        continuation.resume(throwing: NSError(domain: "OpenHub", code: -1, userInfo: [NSLocalizedDescriptionKey: "下载响应为空"]))
                        return
                    }
                    continuation.resume(returning: (tempURL, response))
                }
                downloadTasks[jobID] = task
                task.resume()
                Task {
                    while task.state == .running || task.state == .suspended {
                        let completed = task.countOfBytesReceived
                        let expected = task.countOfBytesExpectedToReceive
                        if completed > 0 {
                            let progress = expected > 0 ? min(Double(completed) / Double(expected), 0.98) : min(0.2 + Double(completed % 5_000_000) / 5_000_000 * 0.5, 0.85)
                            await MainActor.run {
                                self.updateDownloadJob(jobID, progress: progress, state: .downloading, savedPath: nil, message: "\(ByteCountFormatter.string(fromByteCount: completed, countStyle: .file)) / \(expected > 0 ? ByteCountFormatter.string(fromByteCount: expected, countStyle: .file) : "未知大小")")
                                self.downloadProgress = progress
                            }
                        }
                        try? await Task.sleep(nanoseconds: 250_000_000)
                    }
                }
            }
        } onCancel: {
            Task { @MainActor in self.cancelDownload(jobID) }
        }
    }

    private func updateDownloadJob(_ id: UUID, progress: Double, state: DownloadJob.State, savedPath: String?, partialFileURL: URL? = nil, bytesDownloaded: Int64 = 0, message: String) {
        guard let index = downloadJobs.firstIndex(where: { $0.id == id }) else { return }
        downloadJobs[index].progress = progress
        downloadJobs[index].state = state
        if let savedPath { downloadJobs[index].savedPath = savedPath }
        if let partialFileURL { downloadJobs[index].partialFileURL = partialFileURL }
        if bytesDownloaded > 0 || state == .failed { downloadJobs[index].bytesDownloaded = bytesDownloaded }
        downloadJobs[index].message = message
    }

    func cancelDownload(_ id: UUID) {
        downloadTasks[id]?.cancel()
        downloadTasks.removeValue(forKey: id)
        updateDownloadJob(id, progress: 0, state: .cancelled, savedPath: nil, message: "用户已取消下载")
    }

    func deleteDownloadJob(_ id: UUID) {
        cancelDownload(id)
        downloadJobs.removeAll { $0.id == id }
    }

    func deleteDownloadRecord(_ record: DownloadRecord, removeFile: Bool = false) {
        if removeFile {
            try? FileManager.default.removeItem(atPath: record.savedPath)
        }
        downloads.removeAll { $0.id == record.id }
        storage.save(downloads, key: "downloads")
        status = removeFile ? "已删除下载记录和本地文件" : "已删除下载记录"
    }

    private func jobProgress(_ jobID: UUID) -> Double {
        guard let index = downloadJobs.firstIndex(where: { $0.id == jobID }) else { return 0 }
        return downloadJobs[index].progress
    }

    func retryDownload(asset: ReleaseAsset, repository: Repository, oldJobID: UUID) async {
        guard let sourceURL = selectedSource.resolvedURL(for: asset.browserDownloadURL) else {
            status = "下载源 URL 无效"
            return
        }
        guard let oldJob = downloadJobs.first(where: { $0.id == oldJobID }) else { return }

        let newJobID = UUID()
        let resumeBytes = oldJob.bytesDownloaded > 1024 ? oldJob.bytesDownloaded : 0

        downloadJobs.insert(DownloadJob(id: newJobID, appName: repository.displayName, assetName: asset.name, sourceName: selectedSource.name, originalURL: asset.browserDownloadURL, progress: 0, state: .downloading, savedPath: nil, partialFileURL: nil, bytesDownloaded: 0, message: resumeBytes > 0 ? "断点续传中（已下载 " + ByteCountFormatter.string(fromByteCount: resumeBytes, countStyle: .file) + "）" : "重新下载中", cancel: { [weak self] in
            Task { @MainActor in self?.cancelDownload(newJobID) }
        }, retry: { [weak self] in
            Task { await self?.retryDownload(asset: asset, repository: repository, oldJobID: newJobID) }
        }), at: 0)

        do {
            status = "正在\(resumeBytes > 0 ? "续传" : "重新")下载 \(asset.name)..."
            downloadProgress = resumeBytes > 0 ? min(Double(resumeBytes) / Double(resumeBytes + 10_000_000), 0.9) : 0.05
            let (tempURL, _) = try await downloadFile(from: sourceURL, jobID: newJobID, resumeFromBytes: resumeBytes)
            let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("OpenHub", isDirectory: true)
            try FileManager.default.createDirectory(at: downloadsURL, withIntermediateDirectories: true)
            let destination = downloadsURL.appendingPathComponent(asset.name)
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.moveItem(at: tempURL, to: destination)
            downloadProgress = 1
            let checksum = try sha256(of: destination)
            let record = DownloadRecord(id: UUID(), appName: repository.displayName, assetName: asset.name, sourceName: selectedSource.name, originalURL: asset.browserDownloadURL, savedPath: destination.path, downloadedAt: Date(), checksum: checksum)
            downloads.insert(record, at: 0)
            storage.save(downloads, key: "downloads")
            updateDownloadJob(newJobID, progress: 1, state: .completed, savedPath: destination.path, message: "下载完成，可打开安装")
            downloadTasks.removeValue(forKey: newJobID)
            deleteDownloadJob(oldJobID)
            status = "下载完成：\(asset.name)"
        } catch {
            downloadProgress = 0
            downloadTasks.removeValue(forKey: newJobID)
            if (error as NSError).code == NSURLErrorCancelled {
                updateDownloadJob(newJobID, progress: 0, state: .cancelled, savedPath: nil, message: "用户已取消下载")
            } else {
                updateDownloadJob(newJobID, progress: 0, state: .failed, savedPath: nil, message: error.localizedDescription)
                status = "下载失败：\(error.localizedDescription)"
            }
        }
    }

    private func sha256(of url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func fallbackRepositories(for category: AppCategory) -> [Repository] {
        SampleData.repositories.map { repository in
            var copy = repository
            copy.category = category == .recommended ? repository.category : category
            copy.matchReason = category == .recommended ? repository.matchReason : "离线示例"
            return copy
        }
    }
}

struct LocalStorage {
    func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    func remove(keys: [String]) {
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}

struct KeychainStore {
    let service: String

    func save(_ value: String, account: String) throws {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData as String] = data
            addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw KeychainError(status: addStatus) }
        } else if status != errSecSuccess {
            throw KeychainError(status: status)
        }
    }

    func read(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}

struct KeychainError: LocalizedError {
    let status: OSStatus
    var errorDescription: String? { "Keychain error \(status)" }
}

enum SampleData {
    static let repositories: [Repository] = [
        Repository(id: 1, name: "IINA", fullName: "iina/iina", owner: "iina", description: "The modern video player for macOS.", stars: 39100, forks: 2500, language: "Swift", license: "GPL-3.0", htmlURL: "https://github.com/iina/iina", avatarURL: "https://avatars.githubusercontent.com/u/57877318?v=4", updatedAt: Date(), category: .media, localized: LocalizationCatalog.pack(for: "iina/iina", fallbackName: "IINA", fallbackDescription: "The modern video player for macOS."), matchReason: "离线示例"),
        Repository(id: 2, name: "UTM", fullName: "utmapp/UTM", owner: "utmapp", description: "Virtual machines for iOS and macOS.", stars: 28200, forks: 1400, language: "Swift", license: "Apache-2.0", htmlURL: "https://github.com/utmapp/UTM", avatarURL: "https://avatars.githubusercontent.com/u/74533645?v=4", updatedAt: Date(), category: .developer, localized: LocalizationCatalog.pack(for: "utmapp/UTM", fallbackName: "UTM", fallbackDescription: "Virtual machines for iOS and macOS."), matchReason: "离线示例"),
        Repository(id: 3, name: "Rectangle", fullName: "rxhanson/Rectangle", owner: "rxhanson", description: "Move and resize windows in macOS.", stars: 26800, forks: 820, language: "Swift", license: "MIT", htmlURL: "https://github.com/rxhanson/Rectangle", avatarURL: "https://avatars.githubusercontent.com/u/18639794?v=4", updatedAt: Date(), category: .productivity, localized: LocalizationCatalog.pack(for: "rxhanson/Rectangle", fallbackName: "Rectangle", fallbackDescription: "macOS 窗口管理工具。"), matchReason: "离线示例")
    ]
}

@main
struct OpenHubApp: App {
    @StateObject private var model = AppStoreModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .frame(minWidth: 1320, minHeight: 780)
                .task { model.bootstrap() }
                .onOpenURL { url in
                    model.handleOpenURL(url)
                }
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var model: AppStoreModel

    var body: some View {
        HStack(spacing: 0) {
            Sidebar()
                .frame(width: 260)
            Divider()
            VStack(spacing: 0) {
                TopBar()
                Divider()
                content
                StatusBar()
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
    }

    @ViewBuilder private var content: some View {
        switch model.section {
        case .catalog, .search:
            MainBrowserView()
        case .collections:
            RepositoryListView(repositories: model.favorites, title: model.text("favorites"), empty: EmptyStateConfig(title: model.text("emptyFavorites"), message: "把常用开源 app 加入收藏，换电脑或更新时更好找。", icon: "star", primaryTitle: model.text("goRecommended"), primaryAction: { model.navigate(to: .catalog) }))
        case .code:
            CodeWorkspaceView()
        case .downloads:
            DownloadsView()
        case .updates:
            UpdatesView()
        case .settings:
            SettingsView()
        case .account:
            AccountView()
        }
    }
}

struct Sidebar: View {
    @EnvironmentObject private var model: AppStoreModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("OpenHub")
                .font(.title2.bold())
                .padding(.horizontal, 18)
                .padding(.top, 18)
            Text(model.text("appSubtitle"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 18)
                .padding(.bottom, 14)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(spacing: 4) {
                        ForEach([AppSection.search]) { section in
                            SidebarButton(title: model.title(for: section), icon: section.icon, selected: model.section == section) {
                                model.navigate(to: section)
                            }
                        }
                    }

                    Divider().padding(.horizontal, 12)

                    Text(model.text("categories"))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 18)

                    LazyVStack(spacing: 2) {
                        ForEach(AppCategory.allCases) { category in
                            SidebarButton(title: model.title(for: category), icon: category.symbol, selected: model.section == .catalog && model.category == category) {
                                model.choose(category: category)
                            }
                        }
                    }

                    Divider().padding(.horizontal, 12)

                    VStack(spacing: 4) {
                        ForEach([AppSection.collections, .code, .downloads, .updates, .settings, .account]) { section in
                            SidebarButton(title: model.title(for: section), icon: section.icon, selected: model.section == section) {
                                model.navigate(to: section)
                            }
                        }
                    }
                }
                .padding(.bottom, 16)
            }
        }
        .frame(width: 260)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct SidebarButton: View {
    let title: String
    let icon: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .frame(width: 18)
                Text(title)
                    .lineLimit(1)
                Spacer()
            }
            .font(.system(size: 13, weight: selected ? .semibold : .regular))
            .foregroundStyle(selected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(selected ? Color.accentColor : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 10)
        }
        .buttonStyle(.plain)
    }
}

struct TopBar: View {
    @EnvironmentObject private var model: AppStoreModel
    @FocusState private var searchFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(model.text("searchPlaceholder"), text: $model.query)
                .textFieldStyle(.plain)
                .focused($searchFocused)
                .onSubmit { Task { await model.performSearch() } }
                .onChange(of: model.section) { _, newValue in
                    if newValue == .search { searchFocused = true }
                }

            Picker("下载源", selection: $model.selectedSourceID) {
                ForEach(model.sources.filter(\.enabled)) { source in
                    Text(source.name).tag(source.id)
                }
            }
            .labelsHidden()
            .frame(width: 170)

            Button {
                Task { await model.performSearch() }
            } label: {
                Label(model.text("search"), systemImage: "arrow.right")
            }
            .buttonStyle(.borderedProminent)
            .disabled(model.isLoading)

            Button {
                NSWorkspace.shared.open(URL(string: "https://github.com/new")!)
            } label: {
                Label(model.text("submitProject"), systemImage: "plus")
            }
        }
        .padding(16)
    }
}

struct MainBrowserView: View {
    @EnvironmentObject private var model: AppStoreModel

    var body: some View {
        HStack(spacing: 0) {
            RepositoryListView(
                repositories: model.visibleRepositories,
                title: model.section == .search ? model.text("searchResults") : model.title(for: model.category),
                empty: model.section == .search
                    ? EmptyStateConfig(title: "没有搜索结果", message: "试试更短的仓库名，或回到推荐项目继续浏览。", icon: "magnifyingglass", primaryTitle: model.text("viewRecommended"), primaryAction: { model.navigate(to: .catalog) })
                    : EmptyStateConfig(title: "推荐页暂时为空", message: "网络失败时会保留离线示例，也可以重新加载热门前 100。", icon: "sparkles", primaryTitle: model.text("refresh"), primaryAction: { Task { await model.loadDiscover(force: true) } })
            )
            .frame(width: 560)
            Divider()
            DetailView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct EmptyStateConfig {
    let title: String
    let message: String
    let icon: String
    let primaryTitle: String
    let primaryAction: () -> Void
}

struct RepositoryListView: View {
    @EnvironmentObject private var model: AppStoreModel
    let repositories: [Repository]
    let title: String
    let empty: EmptyStateConfig

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.title2.bold())
                    Text(model.section == .search ? model.text("searchSubtitle") : model.text("recommendedSubtitle"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if model.isLoading {
                    ProgressView().controlSize(.small)
                }
            }
            .frame(height: 58)
            .padding(.horizontal, 18)
            .padding(.top, 12)

            if repositories.isEmpty {
                AppEmptyState(config: empty)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(repositories) { repository in
                            RepositoryRow(repository: repository)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if model.section == .collections {
                                        NSWorkspace.shared.open(URL(string: repository.htmlURL)!)
                                    } else {
                                        model.select(repository)
                                    }
                                }
                                .onAppear { model.loadMoreDiscoverIfNeeded(current: repository) }
                        }
                        if model.section == .catalog && model.canLoadMoreDiscover {
                            HStack(spacing: 10) {
                                ProgressView().controlSize(.small)
                                Text(model.text("continueLoading"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct AppEmptyState: View {
    let config: EmptyStateConfig

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: config.icon)
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 76, height: 76)
                .background(Color(nsColor: .windowBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.black.opacity(0.08)))
            Text(config.title)
                .font(.headline)
            Text(config.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 310)
            Button(config.primaryTitle, action: config.primaryAction)
                .buttonStyle(.borderedProminent)
        }
        .frame(minHeight: 360)
        .padding(28)
    }
}

struct RepositoryRow: View {
    @EnvironmentObject private var model: AppStoreModel
    let repository: Repository

    var isSelected: Bool { model.selected?.fullName == repository.fullName }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ProjectIconView(repository: repository)
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(repository.displayName)
                        .font(.headline)
                    Spacer()
                    Text(model.title(for: repository.category))
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                }
                Text(repository.tagline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                HStack(spacing: 12) {
                    Label(shortNumber(repository.stars), systemImage: "star.fill")
                    Text(repository.license)
                    Text(repository.language)
                    Text(model.matchReason(for: repository))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(isSelected ? Color.accentColor.opacity(0.14) : Color(nsColor: .windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? Color.accentColor.opacity(0.35) : Color.black.opacity(0.08)))
    }
}

struct DetailView: View {
    @EnvironmentObject private var model: AppStoreModel

    var body: some View {
        if let repository = model.selected {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    DetailHeader(repository: repository)
                    RepositoryDocsPanel(repository: repository)
                    DownloadsPanel(repository: repository)
                    TrustPanel(repository: repository)
                    ReleaseNotesPanel()
                }
                .padding(24)
            }
        } else {
            AppEmptyState(config: EmptyStateConfig(title: "选择一个项目", message: "从左侧列表选择 app 后，这里会展示 Release、仓库文档和下载资源。", icon: "app.dashed", primaryTitle: "去推荐", primaryAction: { model.navigate(to: .catalog) }))
        }
    }
}

struct DetailHeader: View {
    @EnvironmentObject private var model: AppStoreModel
    let repository: Repository

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ProjectIconView(repository: repository, size: 72)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(repository.displayName)
                        .font(.largeTitle.bold())
                    Button {
                        Task { await model.toggleFavorite(repository) }
                    } label: {
                        Image(systemName: model.isFavorite(repository) ? "star.fill" : "star")
                    }
                    .buttonStyle(.borderless)
                }
                Text(repository.fullName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(repository.tagline)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Button {
                    NSWorkspace.shared.open(URL(string: repository.htmlURL)!)
                } label: {
                    Label("GitHub", systemImage: "safari")
                }
                .buttonStyle(.bordered)
                if model.githubUser?.login.lowercased() != repository.owner.lowercased() {
                    Button {
                        Task { await model.forkRepository(repository) }
                    } label: {
                        Label("Fork", systemImage: "tuningfork")
                    }
                    .buttonStyle(.bordered)
                }
                Button {
                    Task { await model.cloneRepository(repository) }
                } label: {
                    Label("克隆", systemImage: "arrow.down.doc")
                }
                .buttonStyle(.bordered)
                Text("★ \(shortNumber(repository.stars))")
                    .font(.headline)
            }
        }
    }
}

struct RepositoryDocsPanel: View {
    let repository: Repository

    var body: some View {
        if let pack = repository.localized {
            Panel(title: "仓库文档", icon: "doc.text.magnifyingglass") {
                VStack(alignment: .leading, spacing: 10) {
                    Text(pack.description)
                    HStack {
                        Label("来源：\(pack.source)", systemImage: "person.2")
                        Label("更新：\(pack.updatedAt)", systemImage: "calendar")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    if !pack.installNotes.isEmpty {
                        Text("安装说明：\(pack.installNotes)")
                            .font(.subheadline)
                    }
                    Button("查看原文") {
                        NSWorkspace.shared.open(URL(string: repository.htmlURL)!)
                    }
                    .buttonStyle(.link)
                }
            }
        }
    }
}

struct DownloadsPanel: View {
    @EnvironmentObject private var model: AppStoreModel
    let repository: Repository

    var body: some View {
        Panel(title: "下载资源", icon: "arrow.down.circle") {
            if let release = model.latestRelease {
                if release.assets.isEmpty {
                    Text("最新 Release 没有可下载资源。")
                        .foregroundStyle(.secondary)
                } else {
                    VStack(spacing: 10) {
                        ForEach(release.assets) { asset in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(asset.name).font(.headline)
                                    Text("\(asset.architecture) · \(asset.format) · \(asset.formattedSize) · 下载 \(asset.downloadCount) 次")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button {
                                    Task { await model.download(asset, for: repository) }
                                } label: {
                                    Label("下载", systemImage: "arrow.down")
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(12)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            } else {
                HStack {
                    ProgressView().controlSize(.small)
                    Text("正在加载最新 Release，或该项目没有公开 Release。")
                        .foregroundStyle(.secondary)
                }
            }
            Divider()
            HStack {
                Label("当前源：\(model.selectedSource.name)", systemImage: "bolt")
                Spacer()
                Text("加速源失败会提示切换原始源")
                    .foregroundStyle(.secondary)
            }
            .font(.caption)
        }
    }
}

struct TrustPanel: View {
    let repository: Repository

    var body: some View {
        Panel(title: "信任信息", icon: "checkmark.shield") {
            Grid(alignment: .leading, horizontalSpacing: 18, verticalSpacing: 12) {
                GridRow {
                    TrustBadge(title: "许可证", value: repository.license, color: .green)
                    TrustBadge(title: "来源", value: "GitHub Release", color: .blue)
                    TrustBadge(title: "维护状态", value: "最近活跃", color: .purple)
                }
                GridRow {
                    TrustBadge(title: "下载校验", value: "下载后生成 SHA256", color: .orange)
                    TrustBadge(title: "签名", value: "以项目说明为准", color: .gray)
                    TrustBadge(title: "作者", value: repository.owner, color: .teal)
                }
            }
        }
    }
}

struct ReleaseNotesPanel: View {
    @EnvironmentObject private var model: AppStoreModel

    var body: some View {
        Panel(title: "版本信息", icon: "clock.arrow.circlepath") {
            if let release = model.latestRelease {
                Text(release.name)
                    .font(.headline)
                Text(release.tagName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(release.body.isEmpty ? "该 Release 没有填写更新说明。" : release.body)
                    .font(.body)
                    .lineLimit(8)
                Button("打开 Release 页面") {
                    NSWorkspace.shared.open(URL(string: release.htmlURL)!)
                }
                .buttonStyle(.link)
            } else {
                Text("暂无 Release 信息。")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct DownloadsView: View {
    @EnvironmentObject private var model: AppStoreModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("下载记录")
                .font(.title2.bold())
                .frame(height: 36, alignment: .leading)
            if model.downloads.isEmpty && model.downloadJobs.isEmpty {
                AppEmptyState(config: EmptyStateConfig(title: "还没有下载记录", message: "下载 Release 资源后，这里会保存来源、路径和 SHA256。", icon: "arrow.down.circle", primaryTitle: "去搜索", primaryAction: { model.navigate(to: .search) }))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if !model.downloadJobs.isEmpty {
                            Text("当前下载")
                                .font(.headline)
                            ForEach(model.downloadJobs) { job in
                                DownloadJobRow(job: job)
                            }
                        }
                        if !model.downloads.isEmpty {
                            Text("历史记录")
                                .font(.headline)
                                .padding(.top, 8)
                            ForEach(model.downloads) { record in
                                DownloadRecordRow(record: record)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(24)
    }
}

struct DownloadJobRow: View {
    @EnvironmentObject private var model: AppStoreModel
    let job: DownloadJob

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: job.state == .completed ? "checkmark.circle.fill" : job.state == .failed ? "xmark.circle.fill" : "arrow.down.circle")
                .font(.title2)
                .foregroundStyle(job.state == .completed ? .green : job.state == .failed ? .red : .blue)
                .frame(width: 34)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(job.assetName)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(job.state.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text("\(job.appName) · \(job.sourceName) · \(job.message)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                ProgressView(value: job.progress)
            }
            if job.state == .downloading {
                Button("取消") {
                    job.cancel?()
                }
            }
            if job.state == .failed {
                Button("重新下载") {
                    job.retry?()
                }
                .buttonStyle(.borderedProminent)
            }
            if let path = job.savedPath, job.state == .completed {
                Button("安装") {
                    NSWorkspace.shared.open(URL(fileURLWithPath: path))
                }
                Button("文件夹") {
                    NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
                }
            }
            if job.state != .downloading {
                Button(role: .destructive) {
                    model.deleteDownloadJob(job.id)
                } label: {
                    Label("删除", systemImage: "trash")
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            if job.state == .failed {
                Button {
                    job.retry?()
                } label: {
                    Label(job.bytesDownloaded > 1024 ? "重新下载（断点续传）" : "重新下载", systemImage: "arrow.clockwise")
                }
                Divider()
            }
            if let path = job.savedPath, job.state == .completed {
                Button("打开文件") { NSWorkspace.shared.open(URL(fileURLWithPath: path)) }
                Button("在 Finder 中显示") { NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)]) }
                Divider()
            }
            Button(role: .destructive) {
                model.deleteDownloadJob(job.id)
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }
}

struct DownloadRecordRow: View {
    @EnvironmentObject private var model: AppStoreModel
    let record: DownloadRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 34)
            VStack(alignment: .leading, spacing: 5) {
                Text(record.assetName).font(.headline)
                Text("\(record.appName) · \(record.sourceName)")
                    .foregroundStyle(.secondary)
                Text(record.savedPath)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Button("安装") {
                NSWorkspace.shared.open(URL(fileURLWithPath: record.savedPath))
            }
            Button("文件夹") {
                NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: record.savedPath)])
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            Button("删除下载记录") {
                model.deleteDownloadRecord(record)
            }
            Button("删除记录和本地文件", role: .destructive) {
                model.deleteDownloadRecord(record, removeFile: true)
            }
        }
    }
}

struct UpdatesView: View {
    @EnvironmentObject private var model: AppStoreModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("更新")
                .font(.title2.bold())
                .frame(height: 36, alignment: .leading)
            AppEmptyState(config: EmptyStateConfig(title: "暂无更新提醒", message: "收藏项目后，后续版本会在这里展示 Release 更新。", icon: "clock.arrow.circlepath", primaryTitle: "查看收藏", primaryAction: { model.navigate(to: .collections) }))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(24)
    }
}

struct SettingsView: View {
    @EnvironmentObject private var model: AppStoreModel

    var body: some View {
        Form {
            Section("GitHub") {
                HStack {
                    Text(model.isLoggedIn ? "已通过 GitHub 登录" : "未登录")
                    Spacer()
                    Button {
                        model.startGitHubAppLogin()
                    } label: {
                        Label(model.isLoggedIn ? "重新登录" : "使用 GitHub OAuth 登录", systemImage: "person.crop.circle.badge.checkmark")
                    }
                }
                Text(model.text("tokenKeychain"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section(model.text("language")) {
                Picker(model.text("interfaceLanguage"), selection: $model.appLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                Text(model.text("localizationNote"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section(model.text("downloadSource")) {
                Picker(model.text("defaultDownloadSource"), selection: $model.selectedSourceID) {
                    ForEach(model.sources.filter(\.enabled)) { source in
                        Text(source.name).tag(source.id)
                    }
                }

                ForEach($model.sources) { $source in
                    VStack(alignment: .leading) {
                        Toggle(source.name, isOn: $source.enabled)
                        if source.id != "github-original" {
                            TextField("URL 模板，支持 {originalUrl}", text: $source.urlTemplate)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("代理设置") {
                Toggle("启用代理加速 GitHub API 和 git clone/push", isOn: $model.proxySettings.enabled)
                TextField("代理服务器，例如 http://127.0.0.1:7890 或 socks5://127.0.0.1:7890", text: $model.proxySettings.server)
                Text("代理会应用到 GitHub API 请求，以及 OpenHub 内执行的 git clone / git push。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("本地仓库") {
                HStack {
                    TextField("本地仓库路径", text: $model.workspacePath)
                    Button("选择路径") {
                        model.chooseWorkspacePath()
                    }
                }
                Text("用于克隆自己的仓库、浏览本地代码、保存修改并执行 git push。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("运行错误") {
                Text(model.runtimeErrors.isEmpty ? "暂无运行错误记录" : "已记录 \(model.runtimeErrors.count) 条运行错误")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack {
                    Button {
                        model.exportRuntimeErrors()
                    } label: {
                        Label("下载错误报告", systemImage: "square.and.arrow.down")
                    }
                    Button(role: .destructive) {
                        model.clearRuntimeErrors()
                    } label: {
                        Label("清空错误记录", systemImage: "trash")
                    }
                    .disabled(model.runtimeErrors.isEmpty)
                }
            }

            Section("缓存") {
                Text("清空本机配置、收藏列表、下载记录、本地仓库列表缓存、分类缓存、搜索结果、GitHub OAuth session id、GitHub access token 和 Keychain 登录信息。不会删除已下载文件或本地克隆仓库目录。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button(role: .destructive) {
                    model.clearAllCacheWithConfirmation()
                } label: {
                    Label("清空缓存", systemImage: "trash")
                }
            }

            Button {
                model.saveSettings()
            } label: {
                Label(model.text("saveSettings"), systemImage: "checkmark")
            }
            .buttonStyle(.borderedProminent)
        }
        .formStyle(.grouped)
        .padding(24)
    }
}

struct AccountView: View {
    @EnvironmentObject private var model: AppStoreModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(model.isLoggedIn ? "个人中心" : "GitHub 登录")
                    .font(.title2.bold())

                if let user = model.githubUser {
                    Panel(title: "GitHub 账号", icon: "person.crop.circle") {
                        HStack(alignment: .top, spacing: 14) {
                            AsyncImage(url: URL(string: user.avatarURL)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 58))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 68, height: 68)
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                            VStack(alignment: .leading, spacing: 7) {
                                Text(user.displayName)
                                    .font(.title3.bold())
                                Text("@\(user.login)")
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 14) {
                                    Label("\(user.publicRepos) 仓库", systemImage: "shippingbox")
                                    Label("\(user.followers) 关注者", systemImage: "person.2")
                                    Label("\(user.following) 正在关注", systemImage: "person.crop.circle.badge.checkmark")
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }

                            Spacer()
                            VStack(alignment: .trailing, spacing: 8) {
                                Button("打开 GitHub") {
                                    NSWorkspace.shared.open(URL(string: user.htmlURL)!)
                                }
                                Button("退出登录", role: .destructive) {
                                    model.logout()
                                }
                            }
                        }
                    }

                    Panel(title: "仓库", icon: "tablecells") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Picker("仓库类型", selection: $model.accountRepositoryTab) {
                                    ForEach(AccountRepositoryTab.allCases) { tab in
                                        Text(tab.rawValue).tag(tab)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 260)

                                Spacer()

                                Button {
                                    model.chooseWorkspacePath()
                                } label: {
                                    Label("本地路径", systemImage: "folder")
                                }
                                Button {
                                    Task { await model.refreshAccountData() }
                                } label: {
                                    Label("刷新", systemImage: "arrow.clockwise")
                                }
                                .disabled(model.isAccountLoading)
                            }

                            if model.accountRepositoryTab == .owned {
                                TextField("检索自己的仓库", text: $model.accountRepositoryQuery)
                                    .textFieldStyle(.roundedBorder)
                                RepositoryTable(
                                    repositories: model.filteredUserRepositories,
                                    emptyTitle: "暂无可展示仓库",
                                    showClone: true,
                                    canLoadMore: model.accountRepositoryQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && model.canLoadMoreUserRepositories,
                                    loadingTitle: "继续加载自己的仓库，每次 20 个..."
                                ) {
                                    Task { await model.loadMoreUserRepositories() }
                                }
                                    .frame(height: 420)
                            } else {
                                TextField("检索星标仓库", text: $model.starredRepositoryQuery)
                                    .textFieldStyle(.roundedBorder)
                                RepositoryTable(
                                    repositories: model.filteredStarredRepositories,
                                    emptyTitle: "暂无星标仓库",
                                    showClone: false,
                                    canLoadMore: model.starredRepositoryQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && model.canLoadMoreStarredRepositories,
                                    loadingTitle: "继续加载星标仓库，每次 20 个..."
                                ) {
                                    Task { await model.loadMoreStarredRepositories() }
                                }
                                    .frame(height: 420)
                            }
                        }
                    }
                } else {
                    Panel(title: "只支持 GitHub 账号登录", icon: "person.badge.key") {
                        VStack(alignment: .leading, spacing: 12) {
                            Button {
                                model.startGitHubAppLogin()
                            } label: {
                                Label("使用 GitHub OAuth 登录", systemImage: "person.crop.circle.badge.checkmark")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .disabled(model.isAccountLoading)

                            Text("登录会在当前 app 内打开 GitHub 授权窗口，授权完成后自动回到 OpenHub。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}

struct RepositoryTable: View {
    @EnvironmentObject private var model: AppStoreModel
    let repositories: [Repository]
    let emptyTitle: String
    var showClone = false
    var canLoadMore = false
    var loadingTitle = "继续加载..."
    var onLoadMore: (() -> Void)?

    var body: some View {
        if repositories.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "tray")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text(emptyTitle)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text("仓库")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("语言")
                        .frame(width: 86, alignment: .leading)
                    Text("Stars")
                        .frame(width: 74, alignment: .trailing)
                    Text("操作")
                        .frame(width: showClone ? 132 : 70, alignment: .center)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(nsColor: .controlBackgroundColor))

                Divider()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(repositories) { repository in
                            HStack(spacing: 12) {
                                ProjectIconView(repository: repository, size: 34)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(repository.fullName)
                                        .font(.subheadline.weight(.semibold))
                                        .lineLimit(1)
                                    Text(repository.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Text(repository.language.isEmpty ? "-" : repository.language)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 86, alignment: .leading)

                                Label(shortNumber(repository.stars), systemImage: "star.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 74, alignment: .trailing)

                                HStack(spacing: 8) {
                                    Button("打开") {
                                        NSWorkspace.shared.open(URL(string: repository.htmlURL)!)
                                    }
                                    .frame(width: 54)
                                    if showClone {
                                        Button("克隆") {
                                            Task { await model.cloneRepository(repository) }
                                        }
                                        .frame(width: 54)
                                    }
                                }
                                .frame(width: showClone ? 132 : 70, alignment: .center)
                            }
                            .padding(10)
                            .onAppear {
                                guard canLoadMore, !model.isAccountLoading, repository.fullName == repositories.last?.fullName else { return }
                                onLoadMore?()
                            }
                            Divider()
                        }

                        if canLoadMore {
                            HStack(spacing: 8) {
                                if model.isAccountLoading {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "arrow.down.circle")
                                }
                                Text(model.isAccountLoading ? loadingTitle : "向下滚动加载更多")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                        }
                    }
                }
            }
            .background(Color(nsColor: .windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.08)))
        }
    }
}

struct CodeWorkspaceView: View {
    @EnvironmentObject private var model: AppStoreModel

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("代码工作区")
                            .font(.title2.bold())
                        Text(model.workspacePath)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Button {
                        model.chooseWorkspacePath()
                    } label: {
                        Label("路径", systemImage: "folder")
                    }
                    Button {
                        model.scanLocalRepositories()
                    } label: {
                        Label("刷新", systemImage: "arrow.clockwise")
                    }
                }
                Picker("本地仓库", selection: Binding(
                    get: { model.selectedLocalRepository?.id },
                    set: { id in
                        if let repository = model.localRepositories.first(where: { $0.id == id }) {
                            model.selectLocalRepository(repository)
                        }
                    }
                )) {
                    Text("选择本地仓库").tag(Optional<UUID>.none)
                    ForEach(model.localRepositories) { repository in
                        Text(repository.fullName).tag(Optional(repository.id))
                    }
                }
                .labelsHidden()

                TextField("搜索文件", text: $model.codeSearch)
                    .textFieldStyle(.roundedBorder)

                List(model.filteredCodeFiles, selection: Binding(
                    get: { model.selectedCodeFile?.id },
                    set: { id in
                        if let file = model.codeFiles.first(where: { $0.id == id }) {
                            model.selectCodeFile(file)
                        }
                    }
                )) { file in
                    Text(file.relativePath)
                        .font(.caption)
                        .lineLimit(1)
                        .tag(file.id)
                }

                HStack {
                    Button(role: .destructive) {
                        model.deleteSelectedLocalRepository()
                    } label: {
                        Label("删除本地", systemImage: "trash")
                    }
                    .disabled(model.selectedLocalRepository == nil)

                    Button {
                        if let repository = model.selectedLocalRepository {
                            NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: repository.path)])
                        }
                    } label: {
                        Label("Finder", systemImage: "folder")
                    }
                    .disabled(model.selectedLocalRepository == nil)
                }
            }
            .padding(18)
            .frame(width: 340)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            VStack(spacing: 0) {
                HStack {
                    Text(model.selectedCodeFile?.relativePath ?? "选择文件")
                        .font(.headline)
                        .lineLimit(1)
                    if !model.currentBranch.isEmpty {
                        Text(model.currentBranch)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    Button {
                        Task { await model.refreshGitStatus() }
                    } label: {
                        Label("Git 状态", systemImage: "arrow.clockwise")
                    }
                    Button {
                        model.saveSelectedCodeFile()
                    } label: {
                        Label("保存", systemImage: "square.and.arrow.down")
                    }
                    .disabled(model.selectedCodeFile == nil)
                    Button {
                        Task { await model.syncSelectedLocalRepository() }
                    } label: {
                        Label("同步全部到 GitHub", systemImage: "arrow.up.circle")
                    }
                    .disabled(model.selectedLocalRepository == nil)
                }
                .padding(14)
                Divider()
                HighlightedCodeEditor(text: $model.codeText, fileName: model.selectedCodeFile?.relativePath ?? "")
                Divider()
                GitBottomPanel()
            }
        }
    }
}

struct GitBottomPanel: View {
    @EnvironmentObject private var model: AppStoreModel
    @State private var showDiagnostics = false
    @State private var diagnosticText = ""

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Label("Git 工作区", systemImage: "point.3.connected.trianglepath.dotted")
                    .font(.headline)
                Spacer()
                if model.isSyncingRepository || model.syncProgress > 0 {
                    HStack(spacing: 8) {
                        ProgressView(value: model.syncProgress)
                            .frame(width: 120)
                        Text(model.syncMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(model.gitSyncStateText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(model.gitSyncStateText == "工作区干净" ? .green : .orange)
                Button {
                    Task {
                        if let local = model.selectedLocalRepository {
                            diagnosticText = await model.diagnoseGitRemote(for: local)
                            showDiagnostics = true
                        }
                    }
                } label: {
                    Image(systemName: "stethoscope")
                        .font(.caption)
                }
                .help("诊断 Git 远程连接")
                .disabled(model.selectedLocalRepository == nil)
            }
            HStack(alignment: .top, spacing: 12) {
                GitInfoCard(title: "状态", text: model.gitStatusText.isEmpty ? "暂无未提交变更" : model.gitStatusText, color: .blue)
                GitInfoCard(title: "Diff", text: model.gitDiffText.isEmpty ? "暂无 diff" : model.gitDiffText, color: .purple)
                VStack(alignment: .leading, spacing: 8) {
                    Text("提交")
                        .font(.caption.weight(.semibold))
                    TextField("Commit message", text: $model.commitMessage)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        model.saveSelectedCodeFile()
                        Task { await model.syncSelectedLocalRepository() }
                    } label: {
                        Label("保存并同步全部改动", systemImage: "arrow.up.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(model.selectedLocalRepository == nil)
                }
                .padding(12)
                .frame(width: 260, height: 128, alignment: .topLeading)
                .background(Color(nsColor: .windowBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.08)))
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .sheet(isPresented: $showDiagnostics) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Git 远程诊断")
                        .font(.headline)
                    Spacer()
                    Button("关闭") { showDiagnostics = false }
                }
                ScrollView {
                    Text(diagnosticText)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(minHeight: 200, maxHeight: 400)
                .padding(12)
                .background(Color(nsColor: .textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Text("提示：如果诊断显示网络连通性失败，请在终端中运行 git push 测试，确认终端可以正常访问 GitHub。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(width: 520, height: 420)
        }
    }
}

struct GitInfoCard: View {
    let title: String
    let text: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle().fill(color).frame(width: 7, height: 7)
                Text(title)
                    .font(.caption.weight(.semibold))
                Spacer()
            }
            ScrollView {
                Text(text)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 128, maxHeight: 128, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.08)))
    }
}

struct HighlightedCodeEditor: NSViewRepresentable {
    @Binding var text: String
    let fileName: String

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, fileName: fileName)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = false
        let textView = NSTextView()
        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.allowsUndo = true
        textView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isHorizontallyResizable = true
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width]
        textView.delegate = context.coordinator
        scrollView.documentView = textView
        context.coordinator.textView = textView
        context.coordinator.apply(text: text, fileName: fileName)
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        context.coordinator.fileName = fileName
        context.coordinator.apply(text: text, fileName: fileName)
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        weak var textView: NSTextView?
        var fileName: String
        private var isApplying = false

        init(text: Binding<String>, fileName: String) {
            _text = text
            self.fileName = fileName
        }

        func textDidChange(_ notification: Notification) {
            guard !isApplying, let textView else { return }
            text = textView.string
            highlightCurrentText()
        }

        func apply(text: String, fileName: String) {
            guard let textView else { return }
            if textView.string != text {
                isApplying = true
                textView.string = text
                isApplying = false
            }
            highlightCurrentText()
        }

        private func highlightCurrentText() {
            guard let textView else { return }
            let selectedRanges = textView.selectedRanges
            let attributed = CodeHighlighter.highlight(textView.string, fileName: fileName)
            isApplying = true
            textView.textStorage?.setAttributedString(attributed)
            textView.selectedRanges = selectedRanges
            isApplying = false
        }
    }
}

enum CodeHighlighter {
    static func highlight(_ text: String, fileName: String) -> NSAttributedString {
        let baseFont = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        let result = NSMutableAttributedString(string: text, attributes: [
            .font: baseFont,
            .foregroundColor: NSColor.labelColor,
            .backgroundColor: NSColor.textBackgroundColor
        ])
        let fullRange = NSRange(location: 0, length: (text as NSString).length)
        apply(pattern: #""(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'"#, color: .systemGreen, in: result, range: fullRange)
        apply(pattern: #"//.*|#.*"#, color: .systemGray, in: result, range: fullRange)
        apply(pattern: #"\b([0-9]+|true|false|null|nil)\b"#, color: .systemOrange, in: result, range: fullRange)
        let ext = URL(fileURLWithPath: fileName).pathExtension.lowercased()
        let keywords: String
        switch ext {
        case "swift":
            keywords = "func|let|var|struct|class|enum|protocol|extension|import|return|guard|if|else|switch|case|for|while|do|catch|try|await|async|throws|private|public|final|static"
        case "js", "ts":
            keywords = "function|const|let|var|class|import|export|return|if|else|switch|case|for|while|await|async|try|catch|new|this|type|interface"
        case "rs":
            keywords = "fn|let|mut|struct|enum|impl|use|pub|crate|mod|match|if|else|loop|while|for|async|await|return|Result|Option"
        case "json":
            keywords = "true|false|null"
        default:
            keywords = "func|function|class|struct|import|return|if|else|for|while|let|var|const"
        }
        apply(pattern: "\\b(\(keywords))\\b", color: .systemBlue, font: .monospacedSystemFont(ofSize: 13, weight: .semibold), in: result, range: fullRange)
        return result
    }

    private static func apply(pattern: String, color: NSColor, font: NSFont? = nil, in result: NSMutableAttributedString, range: NSRange) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return }
        regex.enumerateMatches(in: result.string, options: [], range: range) { match, _, _ in
            guard let match else { return }
            result.addAttribute(.foregroundColor, value: color, range: match.range)
            if let font { result.addAttribute(.font, value: font, range: match.range) }
        }
    }
}

struct StatusBar: View {
    @EnvironmentObject private var model: AppStoreModel

    var body: some View {
        HStack {
            Text(model.status)
                .lineLimit(1)
            Spacer()
            if model.downloadProgress > 0 && model.downloadProgress < 1 {
                ProgressView(value: model.downloadProgress)
                    .frame(width: 140)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct Panel<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(nsColor: .windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.08)))
    }
}

struct TrustBadge: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.subheadline)
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ProjectIconView: View {
    let repository: Repository
    var size: CGFloat = 52

    var body: some View {
        AsyncImage(url: URL(string: repository.avatarURL)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                AppIconLetter(text: String(repository.displayName.prefix(1)), category: repository.category, size: size)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22))
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.22)
                .stroke(Color.black.opacity(0.08))
        )
    }
}

struct AppIconLetter: View {
    let text: String
    let category: AppCategory
    var size: CGFloat = 52

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(color.gradient)
            Text(text.uppercased())
                .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }

    private var color: Color {
        switch category {
        case .recommended, .hot: .blue
        case .developer, .terminal, .database: .teal
        case .productivity, .writing, .translation, .education: .indigo
        case .menuBar, .system, .files, .hardware: .orange
        case .ai, .design: .purple
        case .media, .games, .capture: .red
        case .security, .network, .downloader, .browser: .green
        }
    }
}

func shortNumber(_ value: Int) -> String {
    if value >= 1000 {
        return String(format: "%.1fk", Double(value) / 1000)
    }
    return "\(value)"
}
