CREATE TABLE IF NOT EXISTS github_sessions (
  session_id TEXT PRIMARY KEY,
  github_login TEXT,
  github_user_id INTEGER,
  access_token TEXT NOT NULL,
  token_type TEXT,
  scope TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  expires_at TEXT
);

CREATE INDEX IF NOT EXISTS idx_github_sessions_login ON github_sessions(github_login);
