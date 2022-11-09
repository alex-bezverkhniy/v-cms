module main

import os
import rand

fn create_directory_if_not_exists(path string) {
	if !os.exists(path) {
		os.mkdir(path) or { panic('cannot create $path directory') }
	}
}

pub fn generate_salt() string {
	return rand.i64().str()
}