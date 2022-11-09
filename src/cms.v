module main

import vweb
import log
import sqlite
import time
import os

const (
	http_port          = 8080
)

struct App {
	vweb.Context
	started_at i64 [vweb_global]
pub mut:
	db sqlite.DB
mut:
	version       string        [vweb_global]
	logger        log.Log       [vweb_global]
}

fn C.sqlite3_config(int)

fn main() {
	C.sqlite3_config(3)

	if os.args.contains('ci_run') {
		return
	}

	vweb.run(new_app(), http_port)
}

fn new_app() &App {
	mut app := &App{
		db: sqlite.connect('cms.sqlite') or { panic(err) }
		started_at: time.now().unix
	}

	app.create_tables()

	return app
}

fn (mut app App) create_tables() {
	sql app.db {
		create table User
	}
}