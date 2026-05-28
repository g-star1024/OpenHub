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
    submitProject: "提交项目",
    repositoryDocs: "仓库文档",
    downloadAssets: "下载资源",
    trustInfo: "信任信息",
    releaseInfo: "版本信息",
    language: "语言",
    interfaceLanguage: "界面语言",
    githubToken: "Personal Access Token，可选",
    tokenNote: "Token 保存在当前 Windows 用户的 Tauri WebView 本地存储中。",
    downloadSource: "下载源",
    defaultDownloadSource: "默认下载源",
    saveSettings: "保存设置",
    openGitHub: "打开 GitHub",
    noRelease: "暂无 Release 信息",
    emptyFavorites: "还没有收藏项目",
    emptyDownloads: "还没有下载记录",
    emptyUpdates: "暂无更新提醒",
    loginGitHub: "登录 GitHub",
    signOut: "退出登录",
    myRepos: "我的仓库",
    starredRepos: "星标仓库",
    createToken: "创建 Token",
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
    submitProject: "Submit",
    repositoryDocs: "Repository Docs",
    downloadAssets: "Downloads",
    trustInfo: "Trust",
    releaseInfo: "Release",
    language: "Language",
    interfaceLanguage: "Interface Language",
    githubToken: "Personal Access Token, optional",
    tokenNote: "Token is stored in the local Tauri WebView storage for the current Windows user.",
    downloadSource: "Download Source",
    defaultDownloadSource: "Default Source",
    saveSettings: "Save Settings",
    openGitHub: "Open GitHub",
    noRelease: "No release information",
    emptyFavorites: "No favorites yet",
    emptyDownloads: "No downloads yet",
    emptyUpdates: "No updates yet",
    loginGitHub: "Sign in with GitHub",
    signOut: "Sign Out",
    myRepos: "My Repositories",
    starredRepos: "Starred Repositories",
    createToken: "Create Token",
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

const state = {
  view: "catalog",
  category: "recommended",
  language: localStorage.getItem("openhub.language") || "system",
  token: localStorage.getItem("openhub.token") || "",
  selectedSource: localStorage.getItem("openhub.source") || "github",
  reposByCategory: new Map([["recommended", sampleRepos]]),
  pagesByCategory: new Map(),
  canLoadMore: new Map(categories.map((item) => [item.id, true])),
  favorites: loadJson("openhub.favorites", []),
  downloads: loadJson("openhub.downloads", []),
  user: loadJson("openhub.user", null),
  userRepos: [],
  starredRepos: [],
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
}

function authHeaders() {
  const headers = {
    Accept: "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28"
  };
  if (state.token.trim()) headers.Authorization = `Bearer ${state.token.trim()}`;
  return headers;
}

async function github(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: { ...authHeaders(), ...(options.headers || {}) }
  });
  if (!response.ok && response.status !== 204) throw new Error(`GitHub HTTP ${response.status}`);
  if (response.status === 204) return null;
  return response.json();
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
    if (!state.reposByCategory.get(categoryId)?.length) state.reposByCategory.set(categoryId, sampleRepos);
    state.canLoadMore.set(categoryId, false);
    setStatus(error.message);
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
    } catch {
      if (!state.reposByCategory.get(category.id)?.length) state.reposByCategory.set(category.id, sampleRepos);
      state.canLoadMore.set(category.id, false);
    }
  }
  setStatus(t("preloadDone"));
  render();
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
  } catch {
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

  if (!state.token.trim()) return;
  try {
    await github(`https://api.github.com/user/starred/${repo.owner}/${repo.name}`, {
      method: exists ? "DELETE" : "PUT"
    });
    setStatus(exists ? "Unstarred on GitHub" : "Starred on GitHub");
  } catch (error) {
    setStatus(`GitHub Star failed: ${error.message}`);
  }
}

async function login() {
  state.token = document.querySelector("#tokenInput")?.value.trim() || state.token;
  if (!state.token) return;
  try {
    state.user = await github("https://api.github.com/user");
    state.userRepos = (await github("https://api.github.com/user/repos?sort=updated&per_page=30")).map(normalizeRepo);
    state.starredRepos = (await github("https://api.github.com/user/starred?sort=updated&per_page=30")).map(normalizeRepo);
    localStorage.setItem("openhub.token", state.token);
    saveJson("openhub.user", state.user);
    state.view = "account";
    render();
  } catch (error) {
    setStatus(error.message);
  }
}

function signOut() {
  state.user = null;
  state.userRepos = [];
  state.starredRepos = [];
  state.token = "";
  localStorage.removeItem("openhub.token");
  localStorage.removeItem("openhub.user");
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
          <label class="field">${t("githubToken")}<input id="tokenInput" type="password" value="${escapeHtml(state.token)}" /></label>
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
            <label class="field">GitHub Personal Access Token<input id="tokenInput" type="password" value="${escapeHtml(state.token)}" /></label>
            <button id="loginButton" class="primary">${t("loginGitHub")}</button>
            <button id="createTokenButton">${t("createToken")}</button>
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
      <section class="panel"><h3>${t("myRepos")}</h3>${compactRepos(state.userRepos)}</section>
      <section class="panel"><h3>${t("starredRepos")}</h3>${compactRepos(state.starredRepos)}</section>
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

function compactRepos(repos) {
  if (!repos.length) return `<p class="muted">Empty</p>`;
  return repos.slice(0, 12).map((repo) => `<div class="account-row"><div><strong>${escapeHtml(repo.fullName)}</strong><p class="muted">${escapeHtml(repo.description)}</p></div><span>★ ${shortNumber(repo.stars)}</span></div>`).join("");
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
      state.selected = repo;
      render();
      loadRelease(repo);
    }
    return;
  }

  const openButton = event.target.closest("[data-open]");
  if (openButton) openUrl(openButton.dataset.open);

  const favButton = event.target.closest("[data-favorite]");
  if (favButton && state.selected) toggleFavorite(state.selected);

  const downloadButton = event.target.closest("[data-download]");
  if (downloadButton && state.latestRelease && state.selected) {
    const asset = state.latestRelease.assets.find((item) => item.name === downloadButton.dataset.download);
    if (asset) downloadAsset(asset, state.selected);
  }

  if (event.target.id === "loadMoreButton") loadCategory(state.category);
  if (event.target.id === "loginButton") login();
  if (event.target.id === "signOutButton") signOut();
  if (event.target.id === "createTokenButton") openUrl("https://github.com/settings/tokens");
  if (event.target.id === "saveSettingsButton") {
    state.token = document.querySelector("#tokenInput")?.value.trim() || "";
    state.language = document.querySelector("#languageSelect")?.value || state.language;
    state.selectedSource = document.querySelector("#settingsSourceSelect")?.value || state.selectedSource;
    localStorage.setItem("openhub.token", state.token);
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
});

render();
setStatus(t("statusReady"));
loadCategory("recommended").then(preloadCategories);
