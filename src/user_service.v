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
		email: u.email
		avatar: u.avatar	
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


pub fn (mut app App) update_user_by_id(id int, u User) ?User {	
	old_user := app.get_user_by_id(id) or {
		return error('Cannot update User: $err')
	}

	if old_user.id == 0 {
		return error('User not found')
	}
	

	mut hashed_password := old_user.password 
	if u.password != "" {
		hashed_password = bcrypt.generate_from_password(u.password.bytes(), bcrypt.min_cost) or {
			return error('Cannot update User: $err')
		}	
	}

	new_user := User {
		id: id
    	full_name: u.full_name
		username: u.username		
		password: hashed_password
		email: u.email
		avatar: u.avatar	
		updated_at:	time.now()
		is_registered: u.is_registered
		is_blocked: u.is_blocked
		is_admin: u.is_admin
	}

	app.debug('update user: $new_user')

	sql app.db {
		update User set full_name = new_user.full_name, username = new_user.username, password = hashed_password, updated_at = new_user.updated_at, email = new_user.email, avatar = new_user.avatar, is_registered = new_user.is_registered, is_blocked = new_user.is_blocked, is_admin = new_user.is_admin  where id == id
	} 

	res := sql app.db {
		select from User where username == u.username limit 1
	} or {
		return error('Cannot update User: $err')
	}

	return res
}
