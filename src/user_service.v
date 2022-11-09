module main

pub fn (mut app App) get_users_count() ?int {
	res := sql app.db {
		select count from User
	}

	return res
}
