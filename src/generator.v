module main

import os
import json

const (
	err_var ='\$err'
)

fn cleanup(path string, prefix string) {
	f_list := os.ls(path) or {[]string{}}
	for f_name in f_list {
		if f_name.starts_with(prefix) {
			f_path := '${path}/${f_name}'
			// os.rm(f_path)
			println('$f_path - removed')
		}
	}
}

fn generate_all(path string, prefix string, cleanup_beore bool) {
		json_str := os.read_file('test/sample-schema.json') or {			
			panic('cannot read json schema: $err')
			return
		}
		
		if cleanup_beore {
			println('cleanup old files:')
			cleanup(path, prefix)
		}

		mut schema := json.decode(Schema, json_str) or {
			panic('cannot decode json schema: $err')			
			return
		}

		println('generate new files: ')
		generate_entities(mut schema, path, prefix)
		generate_services(mut schema, path, prefix)
		generate_routes(mut schema, path, prefix)
		generate_common(mut schema, path, prefix)
}

fn generate_entity_file(mut t_definition TypeDefinition, t_name string, f_path string) {
	type_name := t_name
	file_path := f_path
	type_definition := t_definition

	content := $tmpl('templates/_generator/entity.v.txt')

	os.write_file(file_path, content) or {
		eprintln("cannot generate file: $file_path, error: $err")
	}
	println('$f_path - generated')
}

fn generate_entities(mut schema Schema, path string, prefix string) {
	for type_name, mut type_definition in schema.definitions {		
		// Update with vlang types
		for _, mut prop in type_definition.properties {
			key := if prop.format == "" { prop.type_name } else { '${prop.type_name}_${prop.format}' }
			i := prop.ref.last_index('/') or {0}
			prop.type_name = if types_map[key] != "" { types_map[key] } else { prop.ref[(i+1)..prop.ref.len] or {""} }
		}
		generate_entity_file(mut type_definition, type_name, '$path/${prefix}_${type_name.to_lower()}_entities.v')
	}
} 

fn generate_service_file(mut t_definition TypeDefinition, t_name string, f_path string) {
	type_name := t_name
	file_path := f_path
	type_definition := t_definition
	fields_list := t_definition.properties.keys()
	mut update_fields_list := t_definition.properties.keys()
	unique_field := t_definition.get_unique_prop()
	unique_col := 'o.${unique_field}'
	type_name_lo := t_name.to_lower()

	for mut f in update_fields_list {
		f = 'new_o.$f'
	}


	content := $tmpl('templates/_generator/service.v.txt')

	os.write_file(file_path, content) or {
		eprintln("cannot generate file: $file_path, error: $err")
	}
	println('$f_path - generated')
}

fn generate_services(mut schema Schema, path string, prefix string) {
	for type_name, mut type_definition in schema.definitions {		
		// Update with vlang types
		for _, mut prop in type_definition.properties {
			key := if prop.format == "" { prop.type_name } else { '${prop.type_name}_${prop.format}' }
			i := prop.ref.last_index('/') or {0}
			prop.type_name = if types_map[key] != "" { types_map[key] } else { prop.ref[(i+1)..prop.ref.len] or {""} }
		}
		generate_service_file(mut type_definition, type_name, '$path/${prefix}_${type_name.to_lower()}_services.v')
	}
} 

fn generate_route_file(mut t_definition TypeDefinition, t_name string, f_path string) {
	type_name := t_name
	file_path := f_path
	type_definition := t_definition
	type_list_name := type_definition.title.to_lower()	
	type_name_lo := t_name.to_lower()

	content := $tmpl('templates/_generator/route.v.txt')

	os.write_file(file_path, content) or {
		eprintln("cannot generate file: $file_path, error: $err")
	}
	println('$f_path - generated')
}

fn generate_routes(mut schema Schema, path string, prefix string) {
	for type_name, mut type_definition in schema.definitions {		
		// Update with vlang types
		for _, mut prop in type_definition.properties {
			key := if prop.format == "" { prop.type_name } else { '${prop.type_name}_${prop.format}' }
			i := prop.ref.last_index('/') or {0}
			prop.type_name = if types_map[key] != "" { types_map[key] } else { prop.ref[(i+1)..prop.ref.len] or {""} }
		}
		generate_route_file(mut type_definition, type_name, '$path/${prefix}_${type_name.to_lower()}_routes.v')
	}
} 

fn generate_common(mut sch Schema, path string, prefix string) {		
	schema := sch

	content := $tmpl('templates/_generator/common.v.txt')
	f_path := '$path/${prefix}_common.v'
	os.write_file(f_path, content) or {
		eprintln("cannot generate file: $f_path, error: $err")
	}
	println('$f_path - generated')
}
