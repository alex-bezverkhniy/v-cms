module main

import vweb

// Pages ////////////////////////////////////////

['/admin']
pub fn (mut app App) admin_index() vweb.Result {
    return $vweb.html()
}
