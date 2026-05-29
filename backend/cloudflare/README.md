# OpenHub Cloudflare Backend

This Cloudflare Worker provides a minimal OAuth backend for OpenHub GitHub App login. It keeps GitHub App secrets on Cloudflare instead of shipping them inside the desktop client.

## What It Uses

- Cloudflare Workers: HTTP endpoints
- Cloudflare KV: short-lived OAuth `state`
- Cloudflare D1: GitHub login sessions

## Endpoints

- Base URL: `https://openhub.moomer.ccwu.cc`
- `GET /health`
- `GET /auth/github/start`
- `GET /auth/github/callback`
- `GET /auth/session?session_id=...`
- `POST /auth/logout`

## Package Contents

- `src/worker.js`: Worker routes and GitHub OAuth exchange.
- `migrations/0001_sessions.sql`: D1 schema.
- `wrangler.jsonc`: Worker, KV, and D1 bindings.
- `package.json`: Wrangler scripts.
- `.dev.vars.example`: local development secret template.

## Security Notes

- Do not put `GITHUB_CLIENT_SECRET` or GitHub App private keys in the desktop client.
- This MVP stores GitHub access tokens in D1. Before public production use, add token encryption, stricter CORS, session expiration cleanup, and rate limiting.
- If you later use GitHub App installation tokens, keep the GitHub App private key only in Worker secrets.
