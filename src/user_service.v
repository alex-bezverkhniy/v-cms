module main

import crypto.bcrypt
import time

pub fn (mut app App) get_users_count() ?int {
	res := sql app.db {
		select count from User
	}

	return res
}

// deprecated
pub fn (mut app App) get_all_users() ?[]User {
	res := sql app.db {
		select from User
	} or { []User{} }

	return res
}

pub fn (mut app App) get_all_users_query(order_by string, order_type string) ?[]User {
	o_by := if order_by == "" { "id"} else {order_by}
	o_type := if order_type == "" {"desc"} else {order_type}

	query := 'select id, full_name, username, password, salt, email, avatar, created_at, updated_at, is_registered, is_blocked, is_admin from `User` order by $o_by $o_type'
	app.debug('exec sql: $query')

	rows, _ := app.db.exec(query)

	app.debug('selected: ${rows} ')

	mut res := []User

	for row in rows {
		vals := row.vals

		id := vals[0].int()
		full_name := vals[1]
		username := vals[2]
		password := vals[3]
		salt := vals[4]
		email := vals[5]
		avatar := vals[6]
		created_at := time.unix(vals[7].int())
		updated_at := time.unix(vals[8].int())
		is_registered := vals[9] == '1'
		is_blocked := vals[10] == '1'
		is_admin := vals[11] == '1'

		u := User{
			id: id
			full_name: full_name
			username: username
			password: password
			salt: salt
			email: email
			avatar: avatar
			created_at: created_at
			updated_at: updated_at
			is_registered: is_registered
			is_blocked: is_blocked
			is_admin: is_admin
		}

		res << u
	}

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
