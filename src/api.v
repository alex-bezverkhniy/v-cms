module main

import vweb

struct ErrorMessage {
	code int
	message string
}

fn (mut app App) response_with_error(msg string, code int, err IError) vweb.Result {
	err_msg := ErrorMessage {
		code,
		msg
	}
	eprintln('ERROR $err')
	app.set_status(code, '')
	return app.json(err_msg)
}