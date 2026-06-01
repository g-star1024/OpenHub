const categories = [
  ["recommended", "sparkles", "macos app stars:>500"],
  ["hot", "flame", "macos stars:>1000"],
  ["productivity", "briefcase", "macos productivity app"],
  ["developer", "hammer", "macos developer tool"],
  ["ai", "brain", "macos ai llm app"],
  ["system", "switch", "macos utility system"],
  ["menuBar", "menu", "macos menu bar app"],
  ["terminal", "terminal", "macos terminal cli"],
  ["network", "network", "macos proxy network"],
  ["downloader", "download", "macos download manager"],
  ["capture", "camera", "macos screenshot screen recorder"],
  ["design", "palette", "macos image design"],
  ["media", "play", "macos media player"],
  ["writing", "note", "macos notes markdown editor"],
  ["translation", "book", "macos reader translation"],
  ["files", "folder", "macos file manager"],
  ["security", "lock", "macos security privacy"],
  ["education", "graduation", "macos learning education"],
  ["database", "database", "macos database client"],
  ["browser", "browser", "browser extension macos"],
  ["games", "game", "macos game"],
  ["hardware", "cpu", "macos hardware driver"]
].map(([id, icon, query]) => ({ id, icon, query }));

const l10n = {
  zh: {
    appSubtitle: "GitHub 开源应用浏览器",
    search: "搜索",
    favorites: "收藏",
    downloads: "下载",
    updates: "更新",
    settings: "设置",
    account: "登录",
    accountCenter: "个人中心",
    categories: "分类",
    searchResults: "搜索结果",
    recommendedSubtitle: "GitHub 热门前 100，滚动浏览",
    searchSubtitle: "按仓库名精确度、stars 和更新时间排序",
    searchPlaceholder: "输入仓库名可精确排序，例如 iina、rectangle、utm",
    submitProject: "创建项目",
    repositoryDocs: "仓库文档",
    downloadAssets: "下载资源",
    trustInfo: "信任信息",
    releaseInfo: "版本信息",
    language: "语言",
    interfaceLanguage: "界面语言",
    githubToken: "GitHub OAuth 登录",
    tokenNote: "OpenHub 仅使用 GitHub OAuth 登录；session id 和访问令牌保存在当前 Windows 用户的 Tauri WebView 本地存储中。",
    downloadSource: "下载源",
    defaultDownloadSource: "默认下载源",
    saveSettings: "保存设置",
    openGitHub: "打开 GitHub",
    starOnGitHub: "同步 Star",
    unstarOnGitHub: "取消 Star",
    runtimeErrors: "运行错误",
    downloadErrors: "下载错误报告",
    clearErrors: "清空错误",
    clearCache: "清空缓存",
    cacheNote: "清空本机配置、收藏、下载记录、仓库列表缓存、分类缓存、搜索结果和 GitHub OAuth 登录信息；不会删除磁盘下载文件或本地克隆仓库。",
    accountTable: "仓库",
    loadMore: "滚动加载更多，每次 20 个",
    noRuntimeErrors: "暂无运行错误",
    noRelease: "暂无 Release 信息",
    emptyFavorites: "还没有收藏项目",
    emptyDownloads: "还没有下载记录",
    emptyUpdates: "暂无更新提醒",
    loginGitHub: "登录 GitHub",
    signOut: "退出登录",
    myRepos: "我的仓库",
    starredRepos: "星标仓库",
    loginHint: "登录会在当前 OpenHub 窗口中打开 GitHub 授权流程，授权完成后自动返回。",
    statusReady: "准备就绪",
    loading: "正在加载 GitHub 项目...",
    preloadDone: "分类内容预加载完成",
    downloadOpen: "已打开下载链接",
    category: {
      recommended: "推荐",
      hot: "热门",
      productivity: "效率办公",
      developer: "开发编程",
      ai: "AI 工具",
      system: "系统增强",
      menuBar: "菜单栏工具",
      terminal: "终端命令行",
      network: "网络代理",
      downloader: "下载工具",
      capture: "截图录屏",
      design: "图片设计",
      media: "音视频",
      writing: "笔记写作",
      translation: "阅读翻译",
      files: "文件管理",
      security: "安全隐私",
      education: "学习教育",
      database: "数据库",
      browser: "浏览器扩展",
      games: "游戏娱乐",
      hardware: "硬件外设"
    }
  },
  en: {
    appSubtitle: "GitHub open-source app browser",
    search: "Search",
    favorites: "Favorites",
    downloads: "Downloads",
    updates: "Updates",
    settings: "Settings",
    account: "Sign In",
    accountCenter: "Account",
    categories: "Categories",
    searchResults: "Search Results",
    recommendedSubtitle: "GitHub Top 100, scroll to browse",
    searchSubtitle: "Ranked by repository-name match, stars, and update time",
    searchPlaceholder: "Type a repository name, e.g. iina, rectangle, utm",
    submitProject: "Create Project",
    repositoryDocs: "Repository Docs",
    downloadAssets: "Downloads",
    trustInfo: "Trust",
    releaseInfo: "Release",
    language: "Language",
    interfaceLanguage: "Interface Language",
    githubToken: "GitHub OAuth Sign In",
    tokenNote: "OpenHub only uses GitHub OAuth sign-in. The session id and access token are stored in the local Tauri WebView storage for the current Windows user.",
    downloadSource: "Download Source",
    defaultDownloadSource: "Default Source",
    saveSettings: "Save Settings",
    openGitHub: "Open GitHub",
    starOnGitHub: "Sync Star",
    unstarOnGitHub: "Unstar",
    runtimeErrors: "Runtime Errors",
    downloadErrors: "Download Error Report",
    clearErrors: "Clear Errors",
    clearCache: "Clear Cache",
    cacheNote: "Clears local settings, favorites, downloads, repository list caches, category cache, search results, and GitHub OAuth sign-in data. Downloaded files and local clones are not deleted.",
    accountTable: "Repositories",
    loadMore: "Scroll to load 20 more",
    noRuntimeErrors: "No runtime errors",
    noRelease: "No release information",
    emptyFavorites: "No favorites yet",
    emptyDownloads: "No downloads yet",
    emptyUpdates: "No updates yet",
    loginGitHub: "Sign in with GitHub",
    signOut: "Sign Out",
    myRepos: "My Repositories",
    starredRepos: "Starred Repositories",
    loginHint: "Sign-in opens GitHub authorization in the current OpenHub window and returns automatically.",
    statusReady: "Ready",
    loading: "Loading GitHub projects...",
    preloadDone: "Category preload complete",
    downloadOpen: "Download link opened",
    category: {
      recommended: "Recommended",
      hot: "Popular",
      productivity: "Productivity",
      developer: "Developer Tools",
      ai: "AI Tools",
      system: "System Utilities",
      menuBar: "Menu Bar",
      terminal: "Terminal & CLI",
      network: "Network & Proxy",
      downloader: "Downloaders",
      capture: "Screen Capture",
      design: "Design",
      media: "Media",
      writing: "Notes & Writing",
      translation: "Reading & Translation",
      files: "File Management",
      security: "Security & Privacy",
      education: "Learning",
      database: "Databases",
      browser: "Browser Extensions",
      games: "Games",
      hardware: "Hardware"
    }
  }
};

const sampleRepos = [
  repoFromSample("iina/iina", "IINA", "The modern video player for macOS.", "Swift", "GPL-3.0", 39100, "media"),
  repoFromSample("utmapp/UTM", "UTM", "Virtual machines for iOS and macOS.", "Swift", "Apache-2.0", 28200, "developer"),
  repoFromSample("rxhanson/Rectangle", "Rectangle", "Move and resize windows in macOS.", "Swift", "MIT", 26800, "productivity")
];

const authBackendBaseURL = "https://openhub.moomer.ccwu.cc";

const state = {
  view: "catalog",
  category: "recommended",
  language: localStorage.getItem("openhub.language") || "system",
  githubSessionId: localStorage.getItem("openhub.githubSessionId") || "",
  githubAccessToken: localStorage.getItem("openhub.githubAccessToken") || "",
  selectedSource: localStorage.getItem("openhub.source") || "github",
  reposByCategory: new Map([["recommended", sampleRepos]]),
  pagesByCategory: new Map(),
  canLoadMore: new Map(categories.map((item) => [item.id, true])),
  favorites: loadJson("openhub.favorites", []),
  downloads: loadJson("openhub.downloads", []),
  runtimeErrors: loadJson("openhub.runtimeErrors", []),
  user: loadJson("openhub.user", null),
  userRepos: [],
  starredRepos: [],
  userReposPage: 0,
  starredReposPage: 0,
  canLoadMoreUserRepos: true,
  canLoadMoreStarredRepos: true,
  accountTab: localStorage.getItem("openhub.accountTab") || "owned",
  searchResults: [],
  query: "",
  selected: sampleRepos[0],
  latestRelease: null,
  loading: false
};

const sources = [
  { id: "github", name: "GitHub 原始源", url: "{originalUrl}" },
  { id: "proxy", name: "自定义加速源", url: "https://example.com/{originalUrl}" }
];

const el = {
  categoryList: document.querySelector("#categoryList"),
  repoList: document.querySelector("#repoList"),
  detail: document.querySelector("#detailContent"),
  listTitle: document.querySelector("#listTitle"),
  listSubtitle: document.querySelector("#listSubtitle"),
  loading: document.querySelector("#loadingIndicator"),
  status: document.querySelector("#statusText"),
  searchInput: document.querySelector("#searchInput"),
  searchButton: document.querySelector("#searchButton"),
  sourceSelect: document.querySelector("#sourceSelect"),
  accountNavText: document.querySelector("#accountNavText")
};

function lang() {
  if (state.language === "system") {
    return navigator.language.toLowerCase().startsWith("zh") ? "zh" : "en";
  }
  return state.language;
}

function t(key) {
  return key.split(".").reduce((value, part) => value?.[part], l10n[lang()]) || key;
}

function categoryName(id) {
  return t(`category.${id}`);
}

function setStatus(message) {
  el.status.textContent = message;
  if (/失败|错误|error|failed|exception|HTTP/i.test(String(message))) {
    recordRuntimeError(message, "status");
  }
}

function authHeaders() {
  const headers = {
    Accept: "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28"
  };
  if (state.githubAccessToken.trim()) headers.Authorization = `Bearer ${state.githubAccessToken.trim()}`;
  return headers;
}

async function github(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: { ...authHeaders(), ...(options.headers || {}) }
  });
  if (!response.ok && response.status !== 204) throw new Error(`GitHub HTTP ${response.status}: ${url}`);
  if (response.status === 204) return null;
  return response.json();
}

function recordRuntimeError(message, source = "runtime") {
  const text = String(message?.message || message || "Unknown error");
  const last = state.runtimeErrors[0];
  if (last && last.message === text && Date.now() - new Date(last.time).getTime() < 1000) return;
  state.runtimeErrors.unshift({
    time: new Date().toISOString(),
    source,
    view: state.view,
    message: text
  });
  state.runtimeErrors = state.runtimeErrors.slice(0, 200);
  saveJson("openhub.runtimeErrors", state.runtimeErrors);
}

function downloadRuntimeErrors() {
  const payload = {
    app: "OpenHub Windows",
    exportedAt: new Date().toISOString(),
    userAgent: navigator.userAgent,
    view: state.view,
    selectedRepository: state.selected?.fullName || null,
    errors: state.runtimeErrors
  };
  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `openhub-runtime-errors-${new Date().toISOString().replace(/[:.]/g, "-")}.json`;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

function clearRuntimeErrors() {
  state.runtimeErrors = [];
  saveJson("openhub.runtimeErrors", state.runtimeErrors);
  render();
}

function cleanText(value, limit = 260) {
  if (!value) return lang() === "zh" ? "该仓库暂无可读简介，请打开 GitHub 查看项目文档。" : "No readable description yet. Open GitHub for details.";
  const text = String(value).replace(/\\n|\\t|\n|\t/g, " ").replace(/\s+/g, " ").trim();
  if (text.length > limit || /"releases"|\{|\[Fixed\]/i.test(text)) {
    return lang() === "zh" ? "该仓库暂无可读简介，请打开 GitHub 查看项目文档。" : "No readable description yet. Open GitHub for details.";
  }
  return text;
}

function inferCategory(repo) {
  const text = `${repo.name || ""} ${repo.description || ""} ${repo.language || ""}`.toLowerCase();
  if (text.includes("menu bar") || text.includes("menubar")) return "menuBar";
  if (text.includes("ai") || text.includes("llm") || text.includes("chatgpt")) return "ai";
  if (text.includes("terminal") || text.includes("cli")) return "terminal";
  if (text.includes("download")) return "downloader";
  if (text.includes("screenshot") || text.includes("record")) return "capture";
  if (text.includes("player") || text.includes("media") || text.includes("video")) return "media";
  if (text.includes("security") || text.includes("privacy") || text.includes("password")) return "security";
  if (text.includes("database") || text.includes("sql")) return "database";
  if (text.includes("developer") || text.includes("git") || text.includes("code")) return "developer";
  if (text.includes("file") || text.includes("finder")) return "files";
  return "productivity";
}

function normalizeRepo(item, categoryId = null, reason = "GitHub") {
  return {
    id: item.id,
    name: item.name,
    fullName: item.full_name,
    owner: item.owner?.login || "",
    description: cleanText(item.description),
    stars: item.stargazers_count || 0,
    forks: item.forks_count || 0,
    language: item.language || "Unknown",
    license: item.license?.spdx_id || "Unknown",
    htmlUrl: item.html_url,
    avatarUrl: item.owner?.avatar_url || "",
    updatedAt: item.updated_at || "",
    category: categoryId || inferCategory(item),
    matchReason: reason
  };
}

function repoFromSample(fullName, name, description, language, license, stars, category) {
  const owner = fullName.split("/")[0];
  return {
    id: Math.floor(Math.random() * 1000000),
    name,
    fullName,
    owner,
    description,
    stars,
    forks: 0,
    language,
    license,
    htmlUrl: `https://github.com/${fullName}`,
    avatarUrl: "",
    updatedAt: new Date().toISOString(),
    category,
    matchReason: "Offline"
  };
}

async function searchRepos(query, page = 1, perPage = 20, categoryId = null) {
  const params = new URLSearchParams({
    q: query,
    sort: "stars",
    order: "desc",
    page: String(page),
    per_page: String(perPage)
  });
  const result = await github(`https://api.github.com/search/repositories?${params}`);
  return (result.items || []).map((item) => normalizeRepo(item, categoryId, categoryId ? categoryName(categoryId) : "GitHub"));
}

async function loadCategory(categoryId, force = false) {
  if (state.loading) return;
  const category = categories.find((item) => item.id === categoryId);
  if (!category) return;
  if (force) {
    state.pagesByCategory.set(categoryId, 0);
    state.canLoadMore.set(categoryId, true);
  }
  if (!state.canLoadMore.get(categoryId)) return;

  state.loading = true;
  renderLoading();
  setStatus(t("loading"));
  const nextPage = (state.pagesByCategory.get(categoryId) || 0) + 1;
  try {
    const queries = categoryId === "recommended"
      ? ["macos app stars:>500", "macos tool stars:>500", "desktop app macos stars:>300"]
      : [category.query];
    const repos = [];
    for (const query of queries) {
      if (repos.length >= 20) break;
      repos.push(...await searchRepos(query, nextPage, 20, categoryId));
    }
    const unique = dedupe(repos).slice(0, 20);
    const current = force || nextPage === 1 ? [] : (state.reposByCategory.get(categoryId) || []);
    const merged = dedupe([...current, ...unique]).slice(0, 100);
    state.reposByCategory.set(categoryId, merged.length ? merged : sampleRepos);
    state.pagesByCategory.set(categoryId, nextPage);
    state.canLoadMore.set(categoryId, merged.length < 100 && unique.length > 0 && nextPage < 5);
    if (state.category === categoryId && state.view === "catalog") {
      state.selected = state.selected || merged[0];
    }
    setStatus(`${merged.length}/100`);
  } catch (error) {
    recordRuntimeError(error, "load-category");
    if (!state.reposByCategory.get(categoryId)?.length) state.reposByCategory.set(categoryId, sampleRepos);
    state.pagesByCategory.set(categoryId, nextPage === 1 ? 0 : nextPage - 1);
    state.canLoadMore.set(categoryId, nextPage === 1);
    setStatus(loadCategoryFailureMessage(error));
  } finally {
    state.loading = false;
    render();
  }
}

async function preloadCategories() {
  for (const category of categories) {
    if (state.pagesByCategory.get(category.id)) continue;
    try {
      const repos = await searchRepos(category.query, 1, 20, category.id);
      state.reposByCategory.set(category.id, repos.length ? repos : sampleRepos);
      state.pagesByCategory.set(category.id, 1);
      state.canLoadMore.set(category.id, repos.length > 0);
    } catch (error) {
      recordRuntimeError(error, "preload-category");
      if (!state.reposByCategory.get(category.id)?.length) state.reposByCategory.set(category.id, sampleRepos);
      state.pagesByCategory.set(category.id, 0);
      state.canLoadMore.set(category.id, true);
    }
  }
  setStatus(t("preloadDone"));
  render();
}

function loadCategoryFailureMessage(error) {
  const message = String(error?.message || error || "").toLowerCase();
  if (message.includes("rate limit") || message.includes("403")) {
    return state.githubAccessToken.trim()
      ? "GitHub 请求暂时受限，已显示离线示例。请稍后重试或检查当前登录授权。"
      : "GitHub 匿名请求已达限额，已显示离线示例。登录 GitHub 后可提高加载额度。";
  }
  if (message.includes("401") || message.includes("bad credentials")) {
    return "GitHub 登录状态已过期，已显示离线示例。请重新登录后再加载。";
  }
  return "热门项目暂时加载失败，已显示离线示例。请检查网络后重试。";
}

async function performSearch() {
  const query = el.searchInput.value.trim();
  if (!query) {
    state.view = "search";
    render();
    return;
  }
  state.view = "search";
  state.query = query;
  state.loading = true;
  renderLoading();
  try {
    const repos = await searchRepos(`${query} in:name,description,readme`, 1, 100);
    state.searchResults = rerank(repos, query);
    state.selected = state.searchResults[0] || state.selected;
    if (state.selected) loadRelease(state.selected);
    setStatus(`${state.searchResults.length}`);
  } catch (error) {
    recordRuntimeError(error, "search");
    setStatus(error.message);
  } finally {
    state.loading = false;
    render();
  }
}

function rerank(repos, query) {
  const q = query.toLowerCase();
  return repos.map((repo) => {
    const name = repo.name.toLowerCase();
    const full = repo.fullName.toLowerCase();
    const owner = repo.owner.toLowerCase();
    const description = repo.description.toLowerCase();
    let score = Math.min(repo.stars / 100, 200);
    if (name === q) score += 1000;
    else if (name.startsWith(q)) score += 800;
    else if (name.includes(q)) score += 600;
    if (full === q) score += 550;
    if (owner === q) score += 300;
    if (description.includes(q)) score += 150;
    return { ...repo, score };
  }).sort((a, b) => b.score - a.score || b.stars - a.stars);
}

async function loadRelease(repo) {
  try {
    const release = await github(`https://api.github.com/repos/${repo.owner}/${repo.name}/releases/latest`);
    state.latestRelease = release;
  } catch (error) {
    recordRuntimeError(error, "release");
    state.latestRelease = null;
  }
  renderDetail();
}

async function toggleFavorite(repo) {
  const exists = state.favorites.some((item) => item.fullName === repo.fullName);
  state.favorites = exists
    ? state.favorites.filter((item) => item.fullName !== repo.fullName)
    : [repo, ...state.favorites];
  saveJson("openhub.favorites", state.favorites);
  render();

  if (!state.githubAccessToken.trim()) return;
  try {
    await github(`https://api.github.com/user/starred/${repo.owner}/${repo.name}`, {
      method: exists ? "DELETE" : "PUT"
    });
    setStatus(exists ? "Unstarred on GitHub" : "Starred on GitHub");
  } catch (error) {
    recordRuntimeError(error, "star");
    setStatus(`GitHub Star failed: ${error.message}`);
  }
}

function startGitHubAppLogin() {
  const returnURL = new URL(window.location.href);
  returnURL.search = "";
  returnURL.hash = "";
  const authURL = new URL(`${authBackendBaseURL}/auth/github/start`);
  authURL.searchParams.set("redirect_uri", returnURL.toString());
  setStatus("正在打开 GitHub OAuth 授权...");
  window.location.href = authURL.toString();
}

async function completeGitHubAppLogin(sessionId) {
  if (!sessionId) return;
  try {
    const session = await fetchJson(`${authBackendBaseURL}/auth/session?session_id=${encodeURIComponent(sessionId)}`);
    state.githubSessionId = session.sessionId;
    state.githubAccessToken = session.accessToken;
    localStorage.setItem("openhub.githubSessionId", state.githubSessionId);
    localStorage.setItem("openhub.githubAccessToken", state.githubAccessToken);
    state.user = await github("https://api.github.com/user");
    await refreshAccountData();
    saveJson("openhub.user", state.user);
    state.view = "account";
    setStatus(`GitHub OAuth 登录成功：${state.user.login}`);
    const cleanURL = new URL(window.location.href);
    cleanURL.searchParams.delete("session_id");
    cleanURL.searchParams.delete("login");
    cleanURL.searchParams.delete("error");
    history.replaceState(null, "", cleanURL.toString());
    render();
  } catch (error) {
    recordRuntimeError(error, "login");
    setStatus(`GitHub OAuth 登录失败：${error.message}`);
  }
}

async function fetchJson(url, options = {}) {
  const response = await fetch(url, options);
  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(data.message || data.error || `HTTP ${response.status}`);
  return data;
}

async function refreshAccountData() {
  if (!state.githubAccessToken.trim()) return;
  state.userReposPage = 1;
  state.starredReposPage = 1;
  state.userRepos = (await github("https://api.github.com/user/repos?sort=updated&per_page=20&page=1")).map(normalizeRepo);
  state.starredRepos = (await github("https://api.github.com/user/starred?sort=updated&per_page=20&page=1")).map(normalizeRepo);
  state.canLoadMoreUserRepos = state.userRepos.length >= 20;
  state.canLoadMoreStarredRepos = state.starredRepos.length >= 20;
}

async function loadMoreAccountRepos(kind) {
  if (!state.githubAccessToken.trim() || state.loading) return;
  const isStarred = kind === "starred";
  const nextPage = (isStarred ? state.starredReposPage : state.userReposPage) + 1;
  const url = isStarred
    ? `https://api.github.com/user/starred?sort=updated&per_page=20&page=${nextPage}`
    : `https://api.github.com/user/repos?sort=updated&per_page=20&page=${nextPage}`;
  try {
    state.loading = true;
    render();
    const repos = (await github(url)).map(normalizeRepo);
    if (isStarred) {
      state.starredRepos = dedupe([...state.starredRepos, ...repos]);
      state.starredReposPage = nextPage;
      state.canLoadMoreStarredRepos = repos.length >= 20;
    } else {
      state.userRepos = dedupe([...state.userRepos, ...repos]);
      state.userReposPage = nextPage;
      state.canLoadMoreUserRepos = repos.length >= 20;
    }
    render();
  } catch (error) {
    recordRuntimeError(error, "account-load-more");
    setStatus(error.message);
  } finally {
    state.loading = false;
    render();
  }
}

function signOut() {
  state.user = null;
  state.userRepos = [];
  state.starredRepos = [];
  if (state.githubSessionId) {
    fetch(`${authBackendBaseURL}/auth/logout`, {
      method: "POST",
      headers: { Authorization: `Bearer ${state.githubSessionId}` }
    }).catch((error) => recordRuntimeError(error, "logout"));
  }
  state.githubSessionId = "";
  state.githubAccessToken = "";
  localStorage.removeItem("openhub.githubSessionId");
  localStorage.removeItem("openhub.githubAccessToken");
  localStorage.removeItem("openhub.user");
  render();
}

function clearAllCache() {
  if (!confirm(`${t("clearCache")}?\n\n${t("cacheNote")}`)) return;
  for (const key of Object.keys(localStorage)) {
    if (key.startsWith("openhub.")) localStorage.removeItem(key);
  }
  state.view = "settings";
  state.category = "recommended";
  state.language = "system";
  state.githubSessionId = "";
  state.githubAccessToken = "";
  state.selectedSource = "github";
  state.reposByCategory = new Map([["recommended", sampleRepos]]);
  state.pagesByCategory = new Map();
  state.canLoadMore = new Map(categories.map((item) => [item.id, true]));
  state.favorites = [];
  state.downloads = [];
  state.runtimeErrors = [];
  state.user = null;
  state.userRepos = [];
  state.starredRepos = [];
  state.searchResults = [];
  state.query = "";
  state.selected = sampleRepos[0];
  state.latestRelease = null;
  state.userReposPage = 0;
  state.starredReposPage = 0;
  state.canLoadMoreUserRepos = true;
  state.canLoadMoreStarredRepos = true;
  state.accountTab = "owned";
  setStatus("缓存已清空");
  render();
}

function openUrl(url) {
  window.open(url, "_blank", "noopener,noreferrer");
}

function downloadAsset(asset, repo) {
  const source = sources.find((item) => item.id === state.selectedSource) || sources[0];
  const url = source.url.replace("{originalUrl}", asset.browser_download_url);
  state.downloads.unshift({
    repo: repo.fullName,
    name: asset.name,
    url,
    source: source.name,
    time: new Date().toISOString()
  });
  saveJson("openhub.downloads", state.downloads);
  openUrl(url);
  setStatus(t("downloadOpen"));
  render();
}

function render() {
  document.documentElement.lang = lang() === "zh" ? "zh-CN" : "en";
  document.querySelectorAll("[data-i18n]").forEach((node) => node.textContent = t(node.dataset.i18n));
  document.querySelectorAll("[data-i18n-placeholder]").forEach((node) => node.placeholder = t(node.dataset.i18nPlaceholder));
  el.accountNavText.textContent = state.user ? t("accountCenter") : t("account");

  renderSources();
  renderCategories();
  renderNav();
  renderList();
  renderDetail();
  renderLoading();
}

function renderSources() {
  el.sourceSelect.innerHTML = sources.map((source) => `<option value="${source.id}">${escapeHtml(source.name)}</option>`).join("");
  el.sourceSelect.value = state.selectedSource;
}

function renderCategories() {
  el.categoryList.innerHTML = categories.map((category) => `
    <button class="nav-item ${state.view === "catalog" && state.category === category.id ? "active" : ""}" data-category="${category.id}">
      <span>${category.icon.slice(0, 1).toUpperCase()}</span>
      <strong>${escapeHtml(categoryName(category.id))}</strong>
    </button>
  `).join("");
}

function renderNav() {
  document.querySelectorAll("[data-view]").forEach((button) => {
    button.classList.toggle("active", button.dataset.view === state.view);
  });
}

function currentRepos() {
  if (state.view === "search") return state.searchResults;
  if (state.view === "favorites") return state.favorites;
  if (state.view === "catalog") return state.reposByCategory.get(state.category) || sampleRepos;
  return [];
}

function renderList() {
  const repos = currentRepos();
  if (state.view === "search") {
    el.listTitle.textContent = t("searchResults");
    el.listSubtitle.textContent = t("searchSubtitle");
  } else if (state.view === "favorites") {
    el.listTitle.textContent = t("favorites");
    el.listSubtitle.textContent = t("emptyFavorites");
  } else {
    el.listTitle.textContent = categoryName(state.category);
    el.listSubtitle.textContent = t("recommendedSubtitle");
  }

  if (["settings", "account", "downloads", "updates"].includes(state.view)) {
    el.repoList.innerHTML = renderUtilityView();
    return;
  }

  if (!repos.length) {
    el.repoList.innerHTML = `<div class="empty"><div>${state.view === "favorites" ? t("emptyFavorites") : t("searchResults")}</div></div>`;
    return;
  }

  el.repoList.innerHTML = repos.map((repo) => repoCard(repo)).join("");
  if (state.view === "catalog" && state.canLoadMore.get(state.category)) {
    el.repoList.insertAdjacentHTML("beforeend", `<button id="loadMoreButton" class="primary">${t("recommendedSubtitle")}</button>`);
  }
}

function repoCard(repo) {
  const active = state.selected?.fullName === repo.fullName ? "active" : "";
  const img = repo.avatarUrl
    ? `<img class="repo-icon" src="${escapeHtml(repo.avatarUrl)}" alt="" />`
    : `<div class="repo-icon">${escapeHtml(repo.name.slice(0, 1).toUpperCase())}</div>`;
  return `
    <article class="repo-card ${active}" data-repo="${escapeHtml(repo.fullName)}">
      ${img}
      <div>
        <div class="repo-title-row">
          <h3>${escapeHtml(repo.name)}</h3>
          <span class="tag">${escapeHtml(categoryName(repo.category))}</span>
        </div>
        <p class="repo-desc">${escapeHtml(repo.description)}</p>
        <div class="repo-meta">
          <span>★ ${shortNumber(repo.stars)}</span>
          <span>${escapeHtml(repo.license)}</span>
          <span>${escapeHtml(repo.language)}</span>
        </div>
      </div>
    </article>
  `;
}

function renderDetail() {
  if (["settings", "account", "downloads", "updates"].includes(state.view)) {
    el.detail.innerHTML = "";
    return;
  }
  const repo = state.selected;
  if (!repo) {
    el.detail.innerHTML = `<div class="empty">${t("searchResults")}</div>`;
    return;
  }
  const favorite = state.favorites.some((item) => item.fullName === repo.fullName);
  const release = state.latestRelease;
  const assets = release?.assets?.length
    ? release.assets.map((asset) => `
      <div class="asset-row">
        <div>
          <strong>${escapeHtml(asset.name)}</strong>
          <p class="muted">${formatBytes(asset.size)} · ${asset.download_count || 0}</p>
        </div>
        <button class="primary" data-download="${escapeHtml(asset.name)}">${t("downloads")}</button>
      </div>
    `).join("")
    : `<p class="muted">${t("noRelease")}</p>`;

  el.detail.innerHTML = `
    <div class="detail-header">
      ${repo.avatarUrl ? `<img class="repo-icon" src="${escapeHtml(repo.avatarUrl)}" alt="" />` : `<div class="repo-icon">${escapeHtml(repo.name.slice(0, 1))}</div>`}
      <div>
        <h2>${escapeHtml(repo.name)}</h2>
        <p>${escapeHtml(repo.fullName)}</p>
        <p>${escapeHtml(repo.description)}</p>
      </div>
      <div>
        <button data-favorite="${escapeHtml(repo.fullName)}">${favorite ? "★" : "☆"}</button>
        <button data-open="${escapeHtml(repo.htmlUrl)}">${t("openGitHub")}</button>
      </div>
    </div>
    <section class="panel">
      <h3>${t("repositoryDocs")}</h3>
      <p>${escapeHtml(repo.description)}</p>
    </section>
    <section class="panel">
      <h3>${t("downloadAssets")}</h3>
      ${assets}
    </section>
    <section class="panel">
      <h3>${t("trustInfo")}</h3>
      <p class="muted">${escapeHtml(repo.license)} · GitHub Release · ${escapeHtml(repo.owner)}</p>
    </section>
    <section class="panel">
      <h3>${t("releaseInfo")}</h3>
      <p>${escapeHtml(cleanText(release?.body || "", 720))}</p>
    </section>
  `;
}

function renderUtilityView() {
  if (state.view === "settings") {
    return `
      <div class="settings-form">
        <section class="panel">
          <h3>GitHub</h3>
          <p class="muted">${state.user ? `${t("accountCenter")}: @${escapeHtml(state.user.login)}` : t("loginHint")}</p>
          <button id="githubAppLoginButton" class="primary">${state.user ? t("loginGitHub") : t("loginGitHub")}</button>
          <p class="muted">${t("tokenNote")}</p>
        </section>
        <section class="panel">
          <h3>${t("language")}</h3>
          <label class="field">${t("interfaceLanguage")}
            <select id="languageSelect">
              <option value="system">跟随系统 / System</option>
              <option value="zh">简体中文</option>
              <option value="en">English</option>
            </select>
          </label>
        </section>
        <section class="panel">
          <h3>${t("downloadSource")}</h3>
          <label class="field">${t("defaultDownloadSource")}<select id="settingsSourceSelect">${sources.map((source) => `<option value="${source.id}">${escapeHtml(source.name)}</option>`).join("")}</select></label>
        </section>
        <section class="panel">
          <h3>${t("runtimeErrors")}</h3>
          <p class="muted">${state.runtimeErrors.length ? `${state.runtimeErrors.length} errors recorded` : t("noRuntimeErrors")}</p>
          <button id="downloadErrorsButton">${t("downloadErrors")}</button>
          <button id="clearErrorsButton">${t("clearErrors")}</button>
        </section>
        <section class="panel">
          <h3>${t("clearCache")}</h3>
          <p class="muted">${t("cacheNote")}</p>
          <button id="clearCacheButton">${t("clearCache")}</button>
        </section>
        <button id="saveSettingsButton" class="primary">${t("saveSettings")}</button>
      </div>
    `;
  }
  if (state.view === "account") {
    if (!state.user) {
      return `
        <div class="account-form">
          <section class="panel">
            <h3>${t("loginGitHub")}</h3>
            <p class="muted">${t("loginHint")}</p>
            <button id="githubAppLoginButton" class="primary">${t("loginGitHub")}</button>
          </section>
        </div>
      `;
    }
    return `
      <section class="panel">
        <h3>${escapeHtml(state.user.name || state.user.login)}</h3>
        <p class="muted">@${escapeHtml(state.user.login)}</p>
        <button data-open="${escapeHtml(state.user.html_url)}">${t("openGitHub")}</button>
        <button id="signOutButton">${t("signOut")}</button>
      </section>
      <section class="panel">
        <div class="account-panel-head">
          <h3>${t("accountTable")}</h3>
          <div class="segmented">
            <button class="${state.accountTab === "owned" ? "active" : ""}" data-account-tab="owned">${t("myRepos")}</button>
            <button class="${state.accountTab === "starred" ? "active" : ""}" data-account-tab="starred">${t("starredRepos")}</button>
          </div>
        </div>
        ${accountTable(state.accountTab === "starred" ? state.starredRepos : state.userRepos, state.accountTab)}
        ${accountLoadMoreHint()}
      </section>
    `;
  }
  if (state.view === "downloads") {
    return state.downloads.length
      ? state.downloads.map((item) => `<div class="download-row"><div><strong>${escapeHtml(item.name)}</strong><p class="muted">${escapeHtml(item.repo)} · ${escapeHtml(item.source)}</p></div><button data-open="${escapeHtml(item.url)}">${t("openGitHub")}</button></div>`).join("")
      : `<div class="empty">${t("emptyDownloads")}</div>`;
  }
  if (state.view === "updates") return `<div class="empty">${t("emptyUpdates")}</div>`;
  return "";
}

function accountTable(repos, kind) {
  if (!repos.length) return `<p class="muted">Empty</p>`;
  return `
    <div class="repo-table">
      <div class="repo-table-row repo-table-head"><span>Repository</span><span>Language</span><span>Stars</span><span>Action</span></div>
      ${repos.map((repo) => `
        <div class="repo-table-row">
          <span><strong>${escapeHtml(repo.fullName)}</strong><small>${escapeHtml(repo.description)}</small></span>
          <span>${escapeHtml(repo.language || "-")}</span>
          <span>★ ${shortNumber(repo.stars)}</span>
          <span class="table-actions"><button data-open="${escapeHtml(repo.htmlUrl)}">${t("openGitHub")}</button></span>
        </div>
      `).join("")}
    </div>
  `;
}

function accountLoadMoreHint() {
  const canLoad = state.accountTab === "starred" ? state.canLoadMoreStarredRepos : state.canLoadMoreUserRepos;
  if (!canLoad) return "";
  return `<div class="load-more-account" data-account-load-sentinel="${state.accountTab}">${state.loading ? t("loading") : t("loadMore")}</div>`;
}

function renderLoading() {
  el.loading.classList.toggle("hidden", !state.loading);
}

function dedupe(repos) {
  const seen = new Set();
  return repos.filter((repo) => {
    if (seen.has(repo.fullName)) return false;
    seen.add(repo.fullName);
    return true;
  });
}

function loadJson(key, fallback) {
  try {
    return JSON.parse(localStorage.getItem(key)) ?? fallback;
  } catch {
    return fallback;
  }
}

function saveJson(key, value) {
  localStorage.setItem(key, JSON.stringify(value));
}

function escapeHtml(value) {
  return String(value ?? "").replace(/[&<>"']/g, (char) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    "\"": "&quot;",
    "'": "&#039;"
  }[char]));
}

function shortNumber(value) {
  return value >= 1000 ? `${(value / 1000).toFixed(1)}k` : String(value);
}

function formatBytes(value = 0) {
  if (!value) return "0 B";
  const units = ["B", "KB", "MB", "GB"];
  const index = Math.min(Math.floor(Math.log(value) / Math.log(1024)), units.length - 1);
  return `${(value / Math.pow(1024, index)).toFixed(index ? 1 : 0)} ${units[index]}`;
}

document.addEventListener("click", async (event) => {
  const openButton = event.target.closest("[data-open]");
  if (openButton) {
    openUrl(openButton.dataset.open);
    return;
  }

  const favButton = event.target.closest("[data-favorite]");
  if (favButton) {
    const repo = currentRepos().find((item) => item.fullName === favButton.dataset.favorite) || state.selected;
    if (repo) await toggleFavorite(repo);
    return;
  }

  const categoryButton = event.target.closest("[data-category]");
  if (categoryButton) {
    state.view = "catalog";
    state.category = categoryButton.dataset.category;
    state.selected = (state.reposByCategory.get(state.category) || sampleRepos)[0];
    render();
    if (!state.pagesByCategory.get(state.category)) await loadCategory(state.category);
    return;
  }

  const viewButton = event.target.closest("[data-view]");
  if (viewButton) {
    state.view = viewButton.dataset.view;
    if (state.view === "search") el.searchInput.focus();
    render();
    return;
  }

  const repoCardNode = event.target.closest("[data-repo]");
  if (repoCardNode) {
    const repo = currentRepos().find((item) => item.fullName === repoCardNode.dataset.repo);
    if (repo) {
      if (state.view === "favorites") {
        openUrl(repo.htmlUrl);
        return;
      }
      state.selected = repo;
      render();
      loadRelease(repo);
    }
    return;
  }

  const downloadButton = event.target.closest("[data-download]");
  if (downloadButton && state.latestRelease && state.selected) {
    const asset = state.latestRelease.assets.find((item) => item.name === downloadButton.dataset.download);
    if (asset) downloadAsset(asset, state.selected);
  }

  if (event.target.id === "loadMoreButton") loadCategory(state.category);
  if (event.target.id === "githubAppLoginButton") startGitHubAppLogin();
  if (event.target.id === "signOutButton") signOut();
  if (event.target.id === "downloadErrorsButton") downloadRuntimeErrors();
  if (event.target.id === "clearErrorsButton") clearRuntimeErrors();
  if (event.target.id === "clearCacheButton") clearAllCache();
  const accountTabButton = event.target.closest("[data-account-tab]");
  if (accountTabButton) {
    state.accountTab = accountTabButton.dataset.accountTab;
    localStorage.setItem("openhub.accountTab", state.accountTab);
    render();
    return;
  }
  if (event.target.id === "saveSettingsButton") {
    state.language = document.querySelector("#languageSelect")?.value || state.language;
    state.selectedSource = document.querySelector("#settingsSourceSelect")?.value || state.selectedSource;
    localStorage.setItem("openhub.language", state.language);
    localStorage.setItem("openhub.source", state.selectedSource);
    setStatus(t("saveSettings"));
    render();
  }
});

el.searchButton.addEventListener("click", performSearch);
el.searchInput.addEventListener("keydown", (event) => {
  if (event.key === "Enter") performSearch();
});
el.sourceSelect.addEventListener("change", () => {
  state.selectedSource = el.sourceSelect.value;
  localStorage.setItem("openhub.source", state.selectedSource);
});
document.querySelector("#submitButton").addEventListener("click", () => openUrl("https://github.com/new"));
el.repoList.addEventListener("scroll", () => {
  const nearBottom = el.repoList.scrollTop + el.repoList.clientHeight > el.repoList.scrollHeight - 120;
  if (state.view === "catalog" && nearBottom && state.canLoadMore.get(state.category) && !state.loading) {
    loadCategory(state.category);
  }
  if (state.view === "account" && state.user && nearBottom && !state.loading) {
    const canLoad = state.accountTab === "starred" ? state.canLoadMoreStarredRepos : state.canLoadMoreUserRepos;
    if (canLoad) loadMoreAccountRepos(state.accountTab);
  }
});

async function restoreGitHubAppLogin() {
  const params = new URLSearchParams(window.location.search);
  const sessionId = params.get("session_id") || state.githubSessionId;
  const error = params.get("error");
  if (error) {
    setStatus(`GitHub OAuth 登录失败：${error}`);
    return;
  }
  if (!sessionId) return;
  await completeGitHubAppLogin(sessionId);
}

render();
setStatus(t("statusReady"));
restoreGitHubAppLogin().finally(() => loadCategory("recommended").then(preloadCategories));

window.addEventListener("error", (event) => {
  recordRuntimeError(`${event.message} at ${event.filename}:${event.lineno}:${event.colno}`, "window-error");
});

window.addEventListener("unhandledrejection", (event) => {
  recordRuntimeError(event.reason || "Unhandled promise rejection", "unhandled-rejection");
});
