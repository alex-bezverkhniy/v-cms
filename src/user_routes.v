module main

import vweb

['/api/users/count'; get]
pub fn (mut app App) users_count() vweb.Result {
	count := app.get_users_count() or { 0 }

	return app.json(count)
}
