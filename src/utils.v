module main

import os

fn create_directory_if_not_exists(path string) {
	if !os.exists(path) {
		os.mkdir(path) or { panic('cannot create $path directory') }
	}
}
