module main

import json

import vweb

// API
['/api/users/'; get]
pub fn (mut app App) all_users() vweb.Result {	
	res := app.get_all_users() or { []User{} }
	app.debug('all_users: $res')

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

['/api/users/count'; get]
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