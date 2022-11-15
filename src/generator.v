module main

import os

fn generate_file(mut t_definition TypeDefinition, t_name string, f_path string) {
	type_name := t_name
	file_path := f_path
	type_definition := t_definition
	// println('generate file: $file_path, for type: $type_name')
	// println('tag: ${type_definition.properties}')
	content := $tmpl('templates/_generator/entities.v.txt')

	os.write_file(file_path, content) or {
		eprintln("cannot generate file: $file_path, error: $err")
	}
	println('$f_path - generated')
}

fn generate_entities(mut schema Schema, path string) {
	for type_name, mut type_definition in schema.definitions {		
		// Update with vlang types
		for _, mut prop in type_definition.properties {
			key := if prop.format == "" { prop.type_name } else { '${prop.type_name}_${prop.format}' }
			i := prop.ref.last_index('/') or {0}
			prop.type_name = if types_map[key] != "" { types_map[key] } else { prop.ref[(i+1)..prop.ref.len] or {""} }
		}
		generate_file(mut type_definition, type_name, '$path/${type_name.to_lower()}_entities.v')
	}
} 