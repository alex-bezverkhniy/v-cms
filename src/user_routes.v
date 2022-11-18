module main

import json

import vweb


// API //////////////////////////////////////////
['/api/users/'; get]
pub fn (mut app App) all_users() vweb.Result {		
	app.debug('all_users query: ${app.query}')
	res := app.get_all_users_query(
		app.query['order_by'], 
		app.query['order_type'],
		app.query['filter_by'],
		app.query['filter_by_op'],
		app.query['filter_by_val'],
		app.query['page_size'].int(),
		app.query['page_num'].int(),
	) or { []User{} }
	app.debug('all_users: $res')

	return app.json(res)
}

['/api/users/:user_id'; get]
pub fn (mut app App) user_by_id(user_id int ) vweb.Result {	
	res := app.get_user_by_id(user_id) or { User{} }
	app.debug('user: $res')
	if res.id == 0 {
		return app.response_with_error('User not found', 404, error("User not found"))
	}
	return app.json(res)
}

['/api/users/'; post]
pub fn (mut app App) create_user() vweb.Result {	
	u := json.decode(User, app.req.data) or {
		return app.response_with_error('Failed to decode json, error: $err', 400, err)
	}
	

	res := app.create_new_user(u) or { 
		return app.response_with_error('Cannot create new User', 503, err)
	}

	return app.json(res)
}

['/api/users/:user_id'; put]
pub fn (mut app App) update_user(user_id int) vweb.Result {	
	old_user :=app.get_user_by_id(user_id) or {
		return app.response_with_error('User not found', 404, err)
	}

	if old_user.id == 0 {
		return app.response_with_error('User not found', 404, error("User not found"))
	}

	u := json.decode(User, app.req.data) or {
		return app.response_with_error('Failed to decode json, error: $err', 400, err)
	}
	

	res := app.update_user_by_id(user_id, u) or { 
		return app.response_with_error('Cannot create new User', 503, err)
	}

	return app.json(res)
}

['/api/count/users'; get]
pub fn (mut app App) users_count() vweb.Result {
	count := app.get_users_count() or { 0 }

	return app.json(count)
}

['/api/schema/users'; get]
pub fn (mut app App) users_schema() vweb.Result {
	s := app.schema.definitions['User']
	mut hydrated_props := map[string]PropertyDefinition{}

	hydrated_props['id'] = PropertyDefinition{
		type_name: 'integer',
		is_hidden: true
	}
	hydrated_props['created_at'] = PropertyDefinition{
		type_name: 'string',
		format: 'date-time'
		is_hidden: true
	}
	hydrated_props['updated_at'] = PropertyDefinition{
		type_name: 'string',
		format: 'date-time'
		is_hidden: true
	}
	hydrated_props['is_admin'] = PropertyDefinition{
		type_name: 'boolean',		
		is_hidden: true
	}
	for k, p in s.properties {
		hydrated_props[k] = p
	}

	hydrated_schema := TypeDefinition {
		...s,
		properties: hydrated_props,		
	}
	return app.json(hydrated_schema)
}

// Pages ////////////////////////////////////////

['/admin/users'; get]
pub fn (mut app App) admin_users() vweb.Result {
	users_list := app.get_all_users_query(
		app.query['order_by'], 
		app.query['order_type'],
		app.query['filter_by'],
		app.query['filter_by_op'],
		app.query['filter_by_val'],
		app.query['page_size'].int(),
		app.query['page_num'].int(),
	) or {[]User{}} 

	user_id := app.query['user_id']
	mut edit_user := User {}
	is_edit_user := user_id != ""

	if is_edit_user {
		id := user_id.int()
		edit_user = app.get_user_by_id(id) or {User{}} 
		app.debug('edit user: $edit_user')
	}
	order_by := app.query['order_by']
	order_type := if app.query['order_type'] == "asc" {"desc"} else {"asc"}
	filter_by := app.query['filter_by']
	filter_by_op := app.query['filter_by_op']
	filter_by_val := app.query['filter_by_val']
	page_size := if app.query['page_size'].int() == 0 {default_page_size} else {app.query['page_size'].int()}
	page_num := if app.query['page_num'].int() == 0 {1} else {app.query['page_num'].int()}
	total_rows := app.get_users_count() or {0}

    return $vweb.html()
}

['/admin/users'; post]
pub fn (mut app App) admin_edit_user() vweb.Result {

	id := app.form['id']
	full_name :=  app.form['full_name']
	username :=  app.form['username']
	password :=  app.form['password']
	email :=  app.form['email']
	is_registered := 'is_registered' in app.form
	is_blocked := 'is_blocked' in app.form
	is_admin := 'is_admin' in app.form
	user_id := id.int()

	//TODO: Validate fields

	user := User{
		id: user_id,
		full_name: full_name, 
		username: username, 
		password: password, 
		is_registered: is_registered, 
		is_blocked: is_blocked, 
		is_admin: is_admin, 
		email: email 
		}
	
	app.debug('user_id: $user_id')
	
	if user_id != 0 {
		app.info('update user')

		app.update_user_by_id(user_id, user) or {
			app.error('cannot update user: $user')
		}

	} else { 
		app.info('create new user: $user')

		app.create_new_user(user) or {
			app.error('cannot create new user')
		}
	}

    return app.redirect('/admin/users')
}
