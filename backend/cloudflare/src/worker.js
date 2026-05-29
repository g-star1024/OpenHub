const GITHUB_AUTHORIZE_URL = "https://github.com/login/oauth/authorize";
const GITHUB_TOKEN_URL = "https://github.com/login/oauth/access_token";
const GITHUB_USER_URL = "https://api.github.com/user";

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const corsHeaders = cors();

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    try {
      if (url.pathname === "/health") {
        return json({ ok: true, app: env.GITHUB_APP_NAME, appId: env.GITHUB_APP_ID }, corsHeaders);
      }

      if (url.pathname === "/auth/github/start") {
        return startGithubAuth(url, env, corsHeaders);
      }

      if (url.pathname === "/auth/github/callback") {
        return handleGithubCallback(url, env, corsHeaders);
      }

      if (url.pathname === "/auth/session") {
        return getSession(request, env, corsHeaders);
      }

      if (url.pathname === "/auth/logout" && request.method === "POST") {
        return logout(request, env, corsHeaders);
      }

      return json({ error: "not_found" }, corsHeaders, 404);
    } catch (error) {
      return json({ error: "server_error", message: error.message }, corsHeaders, 500);
    }
  }
};

async function startGithubAuth(url, env, headers) {
  const state = crypto.randomUUID();
  const redirect = url.searchParams.get("redirect_uri") || env.APP_REDIRECT_URI;
  await env.OPENHUB_KV.put(`oauth_state:${state}`, JSON.stringify({ redirect }), { expirationTtl: 600 });

  const authURL = new URL(GITHUB_AUTHORIZE_URL);
  authURL.searchParams.set("client_id", env.GITHUB_CLIENT_ID);
  authURL.searchParams.set("state", state);
  return Response.redirect(authURL.toString(), 302);
}

async function handleGithubCallback(url, env, headers) {
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  if (!code || !state) return json({ error: "missing_code_or_state" }, headers, 400);

  const stateRaw = await env.OPENHUB_KV.get(`oauth_state:${state}`);
  if (!stateRaw) return json({ error: "invalid_or_expired_state" }, headers, 400);
  await env.OPENHUB_KV.delete(`oauth_state:${state}`);
  const stateData = JSON.parse(stateRaw);

  const tokenResponse = await fetch(GITHUB_TOKEN_URL, {
    method: "POST",
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "User-Agent": `OpenHub GitHub App ${env.GITHUB_APP_ID}`
    },
    body: JSON.stringify({
      client_id: env.GITHUB_CLIENT_ID,
      client_secret: env.GITHUB_CLIENT_SECRET,
      code
    })
  });
  const token = await tokenResponse.json();
  if (!tokenResponse.ok || token.error) {
    return json({ error: "github_token_exchange_failed", detail: token }, headers, 400);
  }

  const userResponse = await fetch(GITHUB_USER_URL, {
    headers: {
      "Accept": "application/vnd.github+json",
      "Authorization": `Bearer ${token.access_token}`,
      "User-Agent": `OpenHub GitHub App ${env.GITHUB_APP_ID}`,
      "X-GitHub-Api-Version": "2022-11-28"
    }
  });
  const user = await userResponse.json();
  if (!userResponse.ok) {
    return json({ error: "github_user_failed", detail: user }, headers, 400);
  }

  const sessionId = crypto.randomUUID();
  const now = new Date().toISOString();
  await env.OPENHUB_DB.prepare(
    `INSERT INTO github_sessions
      (session_id, github_login, github_user_id, access_token, token_type, scope, created_at, updated_at, expires_at)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`
  ).bind(
    sessionId,
    user.login,
    user.id,
    token.access_token,
    token.token_type || "bearer",
    token.scope || "",
    now,
    now,
    token.expires_in ? new Date(Date.now() + token.expires_in * 1000).toISOString() : null
  ).run();

  const appRedirect = new URL(stateData.redirect || "openhub://auth/callback");
  appRedirect.searchParams.set("session_id", sessionId);
  appRedirect.searchParams.set("login", user.login);
  return Response.redirect(appRedirect.toString(), 302);
}

async function getSession(request, env, headers) {
  const auth = request.headers.get("Authorization") || "";
  const sessionId = auth.startsWith("Bearer ") ? auth.slice(7) : new URL(request.url).searchParams.get("session_id");
  if (!sessionId) return json({ error: "missing_session" }, headers, 401);

  const row = await env.OPENHUB_DB.prepare(
    "SELECT session_id, github_login, github_user_id, access_token, token_type, scope, expires_at FROM github_sessions WHERE session_id = ?"
  ).bind(sessionId).first();
  if (!row) return json({ error: "session_not_found" }, headers, 404);
  return json({
    sessionId: row.session_id,
    login: row.github_login,
    userId: row.github_user_id,
    accessToken: row.access_token,
    tokenType: row.token_type,
    scope: row.scope,
    expiresAt: row.expires_at
  }, headers);
}

async function logout(request, env, headers) {
  const auth = request.headers.get("Authorization") || "";
  const sessionId = auth.startsWith("Bearer ") ? auth.slice(7) : null;
  if (!sessionId) return json({ error: "missing_session" }, headers, 401);
  await env.OPENHUB_DB.prepare("DELETE FROM github_sessions WHERE session_id = ?").bind(sessionId).run();
  return json({ ok: true }, headers);
}

function json(value, headers, status = 200) {
  return new Response(JSON.stringify(value, null, 2), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      ...headers
    }
  });
}

function cors() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization"
  };
}
