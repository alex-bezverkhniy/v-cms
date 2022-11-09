module main

import time

struct User {
	id              int       [primary; sql: serial]
	full_name       string
	username        string    [unique]
	github_username string
	password        string
	salt            string
	created_at      time.Time
	updated_at      time.Time
	is_registered   bool
	is_blocked      bool
	is_admin        bool
	oauth_state     string    [skip]
mut:
	posts_count          int
	avatar               string
	email               string
	login_attempts       int
}