module main

pub fn (mut app App) get_users_count() ?int {
	res := sql app.db {
		select count from User
	}

	return res
}

pub fn (mut app App) get_all_users() ?[]User {
	res := sql app.db {
		select from User
	} or { []User{} }

	return res
}

pub fn (mut app App) create_new_user(u User) ?User {
	sql app.db {
		insert u into User
	} 

	res := sql app.db {
		select from User where username == u.username limit 1
	} or {
		return error('Cannot create new User')
	}

	return res
}
