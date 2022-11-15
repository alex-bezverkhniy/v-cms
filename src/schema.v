module main

const types_map = {	
	'string': 'string',
	'string_date-time': 'time.Time',
	'integer': 'int',
	'number': 'f64',
	'boolean': 'bool'
}


struct PropertyDefinition {
mut:
	type_name string [json: 'type']
	ref string [json: "\$ref"]
	description string [json: description]
	comment string [json: "\$comment"]	
	format string [json: "format"]
}

struct TypeDefinition {
mut:
	type_name string [json: 'type']
	title string [json: title]
	additional_properties bool [json: additionalProperties]
	required []string [json: required]
	properties map[string]PropertyDefinition [json: properties]
}

struct Schema {
mut:
	definitions map[string]TypeDefinition [json: definitions]
}

fn (td TypeDefinition) get_unique_prop() string {
	for key, prop in td.properties {
		if prop.comment == "[unique]" {
			return key
		}
	}
	return ""
}