module main

import json

import vweb


// API //////////////////////////////////////////
['/api/users/'; get]
pub fn (mut app App) all_users() vweb.Result {	
	res := app.get_all_users() or { []User{} }
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

// Pages ////////////////////////////////////////

['/admin/users']
pub fn (mut app App) admin_users() vweb.Result {
	users_list := app.get_all_users() or {[]User{}} 
    return $vweb.html()
}