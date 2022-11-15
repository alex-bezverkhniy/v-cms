module main

const (
	default_page_size = 10
	
	operations = {
		'neq': '!=', 
		'eq': '=', 
		'gt': '>', 
		'lt': '<', 
		'ge': '>=', 
		'le': '<=', 
		'like':'like', 
		'in':'in'
	}
)

// Move to Utils
fn check_has_sql_injections(str string) bool {
	restricted_keywords := ['select', 'update', 'delete', 'set', 'truncate', 'drop']
	for w in restricted_keywords {
		if str.to_upper().contains(w.to_upper()) {
			return true
		}
	}
	return false
}