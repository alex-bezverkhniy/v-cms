module main

import crypto.bcrypt
import time

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
	hashed_password := bcrypt.generate_from_password(u.password.bytes(), bcrypt.min_cost) or {
		return error('Cannot create new User: $err')
	}

	new_user := User {
    	full_name: u.full_name
		username: u.username		
		password: hashed_password	
		created_at: time.now()
		updated_at:	time.now()
		salt: generate_salt()
		is_registered: u.is_registered
		is_blocked: u.is_blocked
		is_admin: u.is_admin
	}

	sql app.db {
		insert new_user into User
	} 

	res := sql app.db {
		select from User where username == u.username limit 1
	} or {
		return error('Cannot create new User: $err')
	}

	return res
}

pub fn (mut app App) get_user_by_id(id int) ?User {
	res := sql app.db {
		select from User where id == id limit 1
	} or { User{} }

	return res
}

//TODO
pub fn (mut app App) update_user(id int, u User) ?User {	
	hashed_password := bcrypt.generate_from_password(u.password.bytes(), bcrypt.min_cost) or {
		return error('Cannot create new User: $err')
	}

	new_user := User {
    	full_name: u.full_name
		username: u.username		
		password: hashed_password	
		created_at: time.now()
		updated_at:	time.now()
		salt: generate_salt()
		is_registered: u.is_registered
		is_blocked: u.is_blocked
		is_admin: u.is_admin
	}

	sql app.db {
		insert new_user into User
	} 

	res := sql app.db {
		select from User where username == u.username limit 1
	} or {
		return error('Cannot create new User: $err')
	}

	return res
}
