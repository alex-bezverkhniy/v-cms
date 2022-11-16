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

		println('generate new files:')
		generate_entities(schema, path, prefix)
		generate_services(schema, path, prefix)
		generate_routes(schema, path, prefix)
		generate_common(schema, path, prefix)
		generate_admin_pages(schema, '${path}/templates/admin', prefix)
 }

fn generate_entity_file(t_definition TypeDefinition, t_name string, f_path string) {
	type_name := t_name
	file_path := f_path
	mut type_definition := update_vlang_types(t_definition)
	content := $tmpl('templates/_generator/entity.v.txt')

	os.write_file(file_path, content) or {
		eprintln("cannot generate file: $file_path, error: $err")
	}
	println('$f_path - generated')
}

fn generate_entities(schema Schema, path string, prefix string) {
	for type_name, type_definition in schema.definitions {		
		generate_entity_file(type_definition, type_name, '$path/${prefix}_${type_name.to_lower()}_entities.v')
	}
} 

fn generate_service_file(t_definition TypeDefinition, t_name string, f_path string) {
	type_name := t_name
	file_path := f_path
	mut type_definition := update_vlang_types(t_definition)
	println('generate_service_file type_definition: $type_definition')
	type_list_name := type_definition.title.to_lower()	

	fields_list := type_definition.properties.keys()
	fields_list_str := '$fields_list'.replace("'", "").replace('[', '').replace(']', '')
	mut update_fields_list := type_definition.properties.keys()
	unique_field := type_definition.get_unique_prop()
	unique_col := 'o.${unique_field}'
	type_name_lo := t_name.to_lower()
	page_size_plsh := "\$page_size"
	page_num_plsh := "\${page_num - 1}"

	mut vals_list := []string{}
	mut i := 5
	println('type_definition: $type_definition')
	for k, prop in type_definition.properties {
		mut v := 'vals[$i]'
		if prop.type_name == "int" {			
			v = 'vals[$i].int()'
		} else if prop.type_name == "number" {
			v = 'vals[$i].f64()'
		} 
		println('add $k ${prop.type_name} - $v')
		vals_list << v		
		i++
	}

	for mut f in update_fields_list {
		f = 'new_o.$f'
	}


	content := $tmpl('templates/_generator/service.v.txt')

	os.write_file(file_path, content) or {
		eprintln("cannot generate file: $file_path, error: $err")
	}
	println('$f_path - generated')
}

fn generate_services(schema Schema, path string, prefix string) {
	for type_name, type_definition in schema.definitions {		
		generate_service_file(type_definition, type_name, '$path/${prefix}_${type_name.to_lower()}_services.v')
	}
} 

fn generate_route_file(t_definition TypeDefinition, t_name string, f_path string) {
	type_name := t_name
	file_path := f_path
	type_definition := update_vlang_types(t_definition)
	type_list_name := type_definition.title.to_lower()	
	type_name_lo := t_name.to_lower()
	vweb_plsh := '\$vweb'

	content := $tmpl('templates/_generator/route.v.txt')

	os.write_file(file_path, content) or {
		eprintln("cannot generate file: $file_path, error: $err")
	}
	println('$f_path - generated')
}

fn generate_routes(schema Schema, path string, prefix string) {
	for type_name, type_definition in schema.definitions {
		generate_route_file(type_definition, type_name, '$path/${prefix}_${type_name.to_lower()}_routes.v')
	}
} 

fn generate_common(sch Schema, path string, prefix string) {		
	schema := sch

	content := $tmpl('templates/_generator/common.v.txt')
	f_path := '$path/${prefix}_common.v'
	os.write_file(f_path, content) or {
		eprintln("cannot generate file: $f_path, error: $err")
	}
	println('$f_path - generated')
}

fn generate_admin_pages(schema Schema, path string, prefix string) {
	for type_name, type_definition in schema.definitions {
		generate_admin_page(type_definition, type_name, '$path/${type_definition.title.to_lower()}.html')
	}
} 

fn generate_admin_page(t_definition TypeDefinition, t_name string, f_path string) {
	include_header_plsh := '@include \'header.html\''
	include_footer_plsh := '@include \'footer.html\''
	total_rows_pslh := '\${total_rows}'
	for_plsh := '@for'
	end_plsh := '@end'
	if_plsh := '@if'
	else_plsh := '@else'
	order_by_plsh := '\${order_by}'
	order_type_plsh := '\$order_type'
	at_order_type_plsh := '@order_type'
	col_plsh := '\$col'
	key_plsh := '\$key'
	val_plsh := '\$val'
	i_plsh := '\${i'
	page_size_plsh := '\$page_size'
	page_num_plsh := '\$page_num'
	page_num2_plsh := '\${page_num'
	filter_by_val_plsh := '\$filter_by_val'
	item_plsh :=  '\${item'
	items_list_len_plsh := '\${items_list.len}'
	edit_item_plsh := '\${edit_item'

	type_name := t_name
	file_path := f_path
	type_definition := update_vlang_types(t_definition)
	type_list_name := type_definition.title.to_lower()	
	type_name_lo := t_name.to_lower()
	unique_field := type_definition.get_unique_prop()
	unique_item_plsh := '\${item.${unique_field}}'
	

	mut items_plsh := map[string]PropertyDefinition
	for k, prop in type_definition.properties {
		new_key := k.replace("_", " ")

		items_plsh[new_key] = PropertyDefinition {
			...prop
			placeholder: '\${edit_item.$k}'
		}
	}


	columns_item_list_plsh := '\${columns_${type_name_lo}_list}'

	content := $tmpl('templates/_generator/page.html.razor')

	os.write_file(file_path, content) or {
		eprintln("cannot generate file: $file_path, error: $err")
	}
	println('$f_path - generated')
}


fn update_vlang_types(t_definition TypeDefinition) TypeDefinition {
	mut type_definition := t_definition
		// Update with vlang types
		mut properties := map[string]PropertyDefinition{} 
		for k, mut prop in type_definition.properties {			
			type_key := if prop.format == "" { prop.type_name } else { '${prop.type_name}_${prop.format}' }
			new_key := if prop.ref == "" { k } else { '${k}_id' }
			type_name := if prop.ref == "" { types_map[type_key] } else { 'int' }
			properties[new_key] = PropertyDefinition{
				...prop
				type_name: type_name
			}			
		}
	return TypeDefinition{
		...t_definition
		properties: properties
	}
}