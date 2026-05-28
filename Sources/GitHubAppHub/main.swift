import SwiftUI
import Foundation
import AppKit
import CryptoKit
import Security

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
        case .downloads: "arrow.down.circle"
        case .updates: "clock.arrow.circlepath"
        case .settings: "gearshape"
        case .account: "person.crop.circle"
        }
    }
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
    private let decoder: JSONDecoder

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

    func userRepositories(token: String) async throws -> [Repository] {
        let data = try await request(URL(string: "https://api.github.com/user/repos?sort=updated&per_page=30")!, token: token)
        let items = try decoder.decode([RepositoryItem].self, from: data)
        return items.map(repository(from:))
    }

    func starredRepositories(token: String) async throws -> [Repository] {
        let data = try await request(URL(string: "https://api.github.com/user/starred?sort=updated&per_page=30")!, token: token)
        let items = try decoder.decode([RepositoryItem].self, from: data)
        return items.map(repository(from:))
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

    private func request(_ url: URL, token: String?) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("OpenHub-MVP", forHTTPHeaderField: "User-Agent")
        if let token, !token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw NSError(domain: "GitHub", code: http.statusCode, userInfo: [
                NSLocalizedDescriptionKey: "GitHub API 请求失败：HTTP \(http.statusCode)"
            ])
        }
        return data
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
final class AppStoreModel: ObservableObject {
    @Published var section: AppSection = .catalog
    @Published var category: AppCategory = .recommended
    @Published var query = ""
    @Published var discoverRepositories: [Repository] = SampleData.repositories
    @Published var searchRepositories: [Repository] = []
    @Published var selected: Repository? = SampleData.repositories.first
    @Published var latestRelease: Release?
    @Published var favorites: [Repository] = []
    @Published var downloads: [DownloadRecord] = []
    @Published var sources: [DownloadSource] = [
        DownloadSource(id: "github-original", name: "GitHub 原始源", type: "origin", enabled: true, urlTemplate: "{originalUrl}", priority: 0),
        DownloadSource(id: "custom-proxy", name: "自定义加速源", type: "proxy", enabled: false, urlTemplate: "https://example.com/{originalUrl}", priority: 50)
    ]
    @Published var selectedSourceID = "github-original"
    @Published var token = ""
    @Published var status = "准备就绪"
    @Published var isLoading = false
    @Published var downloadProgress: Double = 0
    @Published var hasLoadedDiscover = false
    @Published var discoverPage = 0
    @Published var canLoadMoreDiscover = true
    @Published var githubUser: GitHubUser?
    @Published var userRepositories: [Repository] = []
    @Published var starredRepositories: [Repository] = []
    @Published var isAccountLoading = false

    private let client = GitHubClient()
    private let storage = LocalStorage()
    private let keychain = KeychainStore(service: "io.openhub.macos")

    init() {
        favorites = storage.load([Repository].self, key: "favorites") ?? []
        downloads = storage.load([DownloadRecord].self, key: "downloads") ?? []
        sources = storage.load([DownloadSource].self, key: "sources") ?? sources
        selectedSourceID = storage.load(String.self, key: "selectedSourceID") ?? selectedSourceID
        token = keychain.read(account: "github-token") ?? storage.load(String.self, key: "token") ?? ""
    }

    var selectedSource: DownloadSource {
        sources.first(where: { $0.id == selectedSourceID }) ?? sources[0]
    }

    var visibleRepositories: [Repository] {
        switch section {
        case .catalog: discoverRepositories
        case .search: searchRepositories
        case .collections: favorites
        default: []
        }
    }

    var isLoggedIn: Bool { githubUser != nil }

    func bootstrap() {
        guard !hasLoadedDiscover else { return }
        hasLoadedDiscover = true
        Task { await loadDiscover(force: false) }
    }

    func navigate(to section: AppSection) {
        self.section = section
        status = "已切换到\(section.rawValue)"
        switch section {
        case .catalog:
            if discoverRepositories.isEmpty || !hasLoadedDiscover {
                Task { await loadDiscover(force: false) }
            } else {
                selected = selected ?? discoverRepositories.first
            }
        case .search:
            status = query.isEmpty ? "输入仓库名可获得更精确排序" : "保留上次搜索：\(query)"
            selected = searchRepositories.first ?? selected
        case .collections:
            selected = favorites.first ?? selected
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
        if force {
            discoverPage = 0
            canLoadMoreDiscover = true
            discoverRepositories = []
        }
        guard canLoadMoreDiscover else { return }
        isLoading = true
        let nextPage = discoverPage + 1
        status = nextPage == 1 ? "正在加载 GitHub 热门前 20..." : "正在继续加载热门项目..."
        defer { isLoading = false }
        do {
            let result = try await client.discoverTop(category: category, page: nextPage, token: token)
            if nextPage == 1 {
                discoverRepositories = result.isEmpty ? SampleData.repositories : result
            } else {
                let existing = Set(discoverRepositories.map(\.fullName))
                discoverRepositories.append(contentsOf: result.filter { !existing.contains($0.fullName) })
            }
            discoverPage = nextPage
            canLoadMoreDiscover = discoverRepositories.count < 100 && !result.isEmpty && nextPage < 5
            selected = selected ?? discoverRepositories.first
            status = "已加载 \(discoverRepositories.count)/100 个 GitHub 热门项目"
            if nextPage == 1, let first = discoverRepositories.first { await loadRelease(for: first) }
        } catch {
            status = "热门项目加载失败，已显示离线示例：\(error.localizedDescription)"
            if discoverRepositories.isEmpty {
                discoverRepositories = SampleData.repositories
                selected = discoverRepositories.first
            }
            canLoadMoreDiscover = false
        }
    }

    func loadMoreDiscoverIfNeeded(current repository: Repository) {
        guard section == .catalog, canLoadMoreDiscover, !isLoading else { return }
        guard discoverRepositories.last?.fullName == repository.fullName else { return }
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
            let result = try await client.search(query: trimmed, token: token)
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
        Task { await loadDiscover(force: true) }
    }

    func select(_ repository: Repository) {
        selected = repository
        latestRelease = nil
        Task { await loadRelease(for: repository) }
    }

    func loadRelease(for repository: Repository) async {
        do {
            latestRelease = try await client.latestRelease(owner: repository.owner, repo: repository.name, token: token)
            status = latestRelease?.assets.isEmpty == true ? "最新 Release 没有可下载资源" : "已加载最新 Release"
        } catch {
            latestRelease = nil
            status = "未找到最新 Release，可打开 GitHub 查看"
        }
    }

    func toggleFavorite(_ repository: Repository) {
        if let index = favorites.firstIndex(where: { $0.fullName == repository.fullName }) {
            favorites.remove(at: index)
        } else {
            favorites.append(repository)
        }
        storage.save(favorites, key: "favorites")
    }

    func isFavorite(_ repository: Repository) -> Bool {
        favorites.contains(where: { $0.fullName == repository.fullName })
    }

    func saveSettings() {
        storage.save(sources, key: "sources")
        storage.save(selectedSourceID, key: "selectedSourceID")
        do {
            try keychain.save(token.trimmingCharacters(in: .whitespacesAndNewlines), account: "github-token")
        } catch {
            status = "Token 保存到 Keychain 失败：\(error.localizedDescription)"
            return
        }
        status = "设置已保存"
    }

    func loginWithGitHubToken() async {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            status = "请输入 GitHub Token 后登录"
            return
        }
        isAccountLoading = true
        status = "正在验证 GitHub 账号..."
        defer { isAccountLoading = false }
        do {
            githubUser = try await client.currentUser(token: trimmed)
            try keychain.save(trimmed, account: "github-token")
            status = "已登录 GitHub：\(githubUser?.login ?? "")"
            await refreshAccountData()
        } catch {
            githubUser = nil
            status = "GitHub 登录失败：\(error.localizedDescription)"
        }
    }

    func refreshAccountData() async {
        let trimmed = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isAccountLoading = true
        defer { isAccountLoading = false }
        do {
            async let repos = client.userRepositories(token: trimmed)
            async let starred = client.starredRepositories(token: trimmed)
            userRepositories = try await repos
            starredRepositories = try await starred
            status = "个人中心已更新"
        } catch {
            status = "个人中心加载失败：\(error.localizedDescription)"
        }
    }

    func logout() {
        githubUser = nil
        userRepositories = []
        starredRepositories = []
        token = ""
        keychain.delete(account: "github-token")
        status = "已退出 GitHub 登录"
    }

    func download(_ asset: ReleaseAsset, for repository: Repository) async {
        guard let sourceURL = selectedSource.resolvedURL(for: asset.browserDownloadURL) else {
            status = "下载源 URL 无效"
            return
        }
        do {
            status = "正在下载 \(asset.name)..."
            downloadProgress = 0.2
            let (tempURL, _) = try await URLSession.shared.download(from: sourceURL)
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
            status = "下载完成：\(asset.name)"
            NSWorkspace.shared.activateFileViewerSelecting([destination])
        } catch {
            downloadProgress = 0
            status = "下载失败，建议切换 GitHub 原始源重试：\(error.localizedDescription)"
        }
    }

    private func sha256(of url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
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
            RepositoryListView(repositories: model.favorites, title: "收藏", empty: EmptyStateConfig(title: "还没有收藏项目", message: "把常用开源 app 加入收藏，换电脑或更新时更好找。", icon: "star", primaryTitle: "去推荐", primaryAction: { model.navigate(to: .catalog) }))
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
            Text("GitHub 开源应用浏览器")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 18)
                .padding(.bottom, 14)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(spacing: 4) {
                        ForEach([AppSection.search]) { section in
                            SidebarButton(title: section.rawValue, icon: section.icon, selected: model.section == section) {
                                model.navigate(to: section)
                            }
                        }
                    }

                    Divider().padding(.horizontal, 12)

                    Text("分类")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 18)

                    LazyVStack(spacing: 2) {
                        ForEach(AppCategory.allCases) { category in
                            SidebarButton(title: category.rawValue, icon: category.symbol, selected: model.section == .catalog && model.category == category) {
                                model.choose(category: category)
                            }
                        }
                    }

                    Divider().padding(.horizontal, 12)

                    VStack(spacing: 4) {
                        ForEach([AppSection.collections, .downloads, .updates, .settings, .account]) { section in
                            SidebarButton(title: section == .account && model.isLoggedIn ? "个人中心" : section.rawValue, icon: section.icon, selected: model.section == section) {
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
            TextField("输入仓库名可精确排序，例如 iina、rectangle、utm", text: $model.query)
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
                Label("搜索", systemImage: "arrow.right")
            }
            .buttonStyle(.borderedProminent)
            .disabled(model.isLoading)

            Button {
                NSWorkspace.shared.open(URL(string: "https://github.com/new")!)
            } label: {
                Label("提交项目", systemImage: "plus")
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
                title: model.section == .search ? "搜索结果" : model.category.rawValue,
                empty: model.section == .search
                    ? EmptyStateConfig(title: "没有搜索结果", message: "试试更短的仓库名，或回到推荐项目继续浏览。", icon: "magnifyingglass", primaryTitle: "查看推荐", primaryAction: { model.navigate(to: .catalog) })
                    : EmptyStateConfig(title: "推荐页暂时为空", message: "网络失败时会保留离线示例，也可以重新加载热门前 100。", icon: "sparkles", primaryTitle: "重新加载", primaryAction: { Task { await model.loadDiscover(force: true) } })
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
                    Text(model.section == .search ? "按仓库名精确度、stars 和更新时间排序" : "GitHub 热门前 100，滚动浏览")
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
                                .onTapGesture { model.select(repository) }
                                .onAppear { model.loadMoreDiscoverIfNeeded(current: repository) }
                        }
                        if model.section == .catalog && model.canLoadMoreDiscover {
                            HStack(spacing: 10) {
                                ProgressView().controlSize(.small)
                                Text("继续加载热门项目...")
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
                    Text(repository.category.rawValue)
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
                    Text(repository.matchReason)
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
                        model.toggleFavorite(repository)
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
            if model.downloads.isEmpty {
                AppEmptyState(config: EmptyStateConfig(title: "还没有下载记录", message: "下载 Release 资源后，这里会保存来源、路径和 SHA256。", icon: "arrow.down.circle", primaryTitle: "去搜索", primaryAction: { model.navigate(to: .search) }))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(model.downloads) { record in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(record.assetName).font(.headline)
                        Text("\(record.appName) · \(record.sourceName)")
                            .foregroundStyle(.secondary)
                        Text(record.savedPath)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .contextMenu {
                        Button("在 Finder 中显示") {
                            NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: record.savedPath)])
                        }
                    }
                }
            }
        }
        .padding(24)
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
                SecureField("Personal Access Token，可选", text: $model.token)
                Text("Token 会保存在本机 macOS Keychain，不写入普通配置文件。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("下载源") {
                Picker("默认下载源", selection: $model.selectedSourceID) {
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

            Section("本地化") {
                Text("当前支持简体中文界面和基础仓库文档展示。仓库文档不会覆盖项目原始 README、Release 或许可证。")
                    .foregroundStyle(.secondary)
            }

            Button {
                model.saveSettings()
            } label: {
                Label("保存设置", systemImage: "checkmark")
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

                    HStack {
                        Text("我的仓库")
                            .font(.headline)
                        Spacer()
                        Button {
                            Task { await model.refreshAccountData() }
                        } label: {
                            Label("刷新", systemImage: "arrow.clockwise")
                        }
                        .disabled(model.isAccountLoading)
                    }

                    RepositoryCompactList(repositories: model.userRepositories, emptyTitle: "暂无可展示仓库")

                    Text("星标仓库")
                        .font(.headline)
                    RepositoryCompactList(repositories: model.starredRepositories, emptyTitle: "暂无星标仓库")
                } else {
                    Panel(title: "只支持 GitHub 账号登录", icon: "person.badge.key") {
                        VStack(alignment: .leading, spacing: 12) {
                            SecureField("GitHub Personal Access Token", text: $model.token)
                                .textFieldStyle(.roundedBorder)
                            Text("使用 GitHub Token 登录，用于读取你的账号、仓库和星标仓库。Token 会保存在 macOS Keychain。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Button {
                                    Task { await model.loginWithGitHubToken() }
                                } label: {
                                    Label("登录 GitHub", systemImage: "person.crop.circle.badge.checkmark")
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(model.isAccountLoading)

                                Button("创建 Token") {
                                    NSWorkspace.shared.open(URL(string: "https://github.com/settings/tokens")!)
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}

struct RepositoryCompactList: View {
    let repositories: [Repository]
    let emptyTitle: String

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
            VStack(spacing: 8) {
                ForEach(repositories.prefix(12)) { repository in
                    HStack(spacing: 10) {
                        ProjectIconView(repository: repository, size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(repository.fullName)
                                .font(.subheadline.weight(.semibold))
                            Text(repository.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Label(shortNumber(repository.stars), systemImage: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(10)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
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
