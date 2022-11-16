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

	if os.args.contains('gen') {
		println("generate:")

		generate_all('src', 'generated', true)

		return
	}

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

	app.handle_static('src/static', true)
	app.create_tables()
	// app.create_generated_tables()
	
	app.setup_logger()

	return app
}

// TODO: generate this func
// fn (mut app App) create_generated_tables() {
// 	// sql app.db {
// 	// 	create table Post
// 	// 	create table Author
// 	// }
// }

fn (mut app App) create_tables() {
	sql app.db {
		create table User
	}
}

fn (mut app App) setup_logger() {
	create_directory_if_not_exists('logs')
	
	app.logger.set_level(.debug)

	app.logger.set_full_logpath('./logs/log_${time.now().ymmdd()}.log')
	app.logger.log_to_console_too()
}

pub fn (mut app App) warn(msg string) {
	app.logger.warn(msg)

	app.logger.flush()
}

pub fn (mut app App) info(msg string) {
	app.logger.info(msg)

	app.logger.flush()
}

pub fn (mut app App) debug(msg string) {
	app.logger.debug(msg)

	app.logger.flush()
}