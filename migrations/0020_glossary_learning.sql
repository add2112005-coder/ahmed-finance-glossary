CREATE TABLE IF NOT EXISTS glossary_users (
 id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, email TEXT NOT NULL UNIQUE COLLATE NOCASE,
 password_hash TEXT NOT NULL, role TEXT NOT NULL DEFAULT 'student' CHECK(role IN ('student','admin')),
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS glossary_sessions (
 token_hash TEXT PRIMARY KEY, user_id INTEGER NOT NULL REFERENCES glossary_users(id) ON DELETE CASCADE,
 expires_at TEXT NOT NULL, created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS glossary_categories (
 id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, description TEXT NOT NULL DEFAULT '',
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS glossary_terms (
 id INTEGER PRIMARY KEY AUTOINCREMENT, english TEXT NOT NULL, arabic TEXT NOT NULL DEFAULT '', definition_en TEXT NOT NULL DEFAULT '', definition_ar TEXT NOT NULL DEFAULT '',
 category_id INTEGER REFERENCES glossary_categories(id) ON DELETE SET NULL, difficulty TEXT NOT NULL DEFAULT 'Intermediate',
 quality_status TEXT NOT NULL DEFAULT 'needs_review' CHECK(quality_status IN ('approved','needs_review','flagged')),
 source TEXT NOT NULL DEFAULT 'seed', updated_at TEXT NOT NULL DEFAULT (datetime('now')),
 UNIQUE(english, category_id)
);
CREATE TABLE IF NOT EXISTS glossary_reviews (
 user_id INTEGER NOT NULL REFERENCES glossary_users(id) ON DELETE CASCADE,
 term_id INTEGER NOT NULL REFERENCES glossary_terms(id) ON DELETE CASCADE,
 due_at TEXT NOT NULL, interval_days REAL NOT NULL DEFAULT 0, ease REAL NOT NULL DEFAULT 2.5,
 repetitions INTEGER NOT NULL DEFAULT 0, correct_count INTEGER NOT NULL DEFAULT 0, wrong_count INTEGER NOT NULL DEFAULT 0,
 last_rating TEXT, updated_at TEXT NOT NULL DEFAULT (datetime('now')), PRIMARY KEY(user_id,term_id)
);
CREATE TABLE IF NOT EXISTS glossary_quiz_results (
 id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL REFERENCES glossary_users(id) ON DELETE CASCADE,
 category_id INTEGER REFERENCES glossary_categories(id) ON DELETE SET NULL, category_name TEXT NOT NULL,
 question_count INTEGER NOT NULL, correct_count INTEGER NOT NULL, score INTEGER NOT NULL, details_json TEXT NOT NULL DEFAULT '[]',
 created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_glossary_terms_category ON glossary_terms(category_id);
CREATE INDEX IF NOT EXISTS idx_glossary_reviews_due ON glossary_reviews(user_id,due_at);
CREATE INDEX IF NOT EXISTS idx_glossary_quiz_user ON glossary_quiz_results(user_id,created_at);
