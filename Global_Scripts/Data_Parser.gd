extends Node

const a_LOC_PATH = "res://Localization/Localization.csv"

func write_var_data(p_path, p_dic):
	var file = FileAccess.open(p_path, FileAccess.WRITE)
	file.store_var(p_dic)
	file.close()

func load_var_data(p_path):
	var file = FileAccess.open(p_path, FileAccess.READ)
	if file == null:
		return {}
	var data = file.get_var()
	file.close()
	
	return data

func write_loc_data(p_loc_ids):
	var file = FileAccess.open(a_LOC_PATH, FileAccess.WRITE)
	var header = TranslationServer.get_loaded_locales()
	header.insert(0, "id")
	file.store_csv_line(header)
	
	var locales = TranslationServer.get_loaded_locales()
	var loc_data = Debug.get_loc_data()
	for loc_id in p_loc_ids:
		var arr = PackedStringArray([loc_id])
		for locale in locales:
			var text = loc_data[loc_id][locale]
			var single_line = _parse_to_single_line(text)
			arr.push_back(single_line)
		file.store_csv_line(arr)
	
	file.close()

func load_loc_data():
	var file = FileAccess.open(a_LOC_PATH, FileAccess.READ)
	var locales = []
	var res = {}
	var idx = 0
	while !file.eof_reached():
		var line = file.get_csv_line()
		if line == PackedStringArray([""]):
			# Fix for empty line which is produced by 
			# FileAccess.store_csv_line -> Needs to be ignored
			continue
		
		if idx == 0:
			for i in range(1, line.size()):
				locales.push_back(line[i])
		else:
			var id = line[0]
			res[id] = {}
			for i in range(1, line.size()):
				var locale = locales[i - 1]
				res[id][locale] = line[i]
		
		idx += 1
	
	return res

func _parse_to_single_line(p_text):
	while p_text.find("\n") != -1:
		p_text = p_text.replace("\n", " ")
	
	return p_text

func load_ogg_stream(p_path):
	var file = FileAccess.open(p_path, FileAccess.READ)
	var bytes = file.get_buffer(file.get_length())
	var stream = AudioStreamOggVorbis.new()
	stream.set_data(bytes) # !BUG! Doesn't exist currently
	file.close()
	
	return stream

func load_wav_stream(p_path):
	var file = FileAccess.open(p_path, FileAccess.READ)
	var bytes = file.get_buffer(file.get_length())
	var stream = AudioStreamWAV.new()
	stream.set_data(bytes)
	file.close()
	
	return stream

func parse_variant(p_variant):
	var data = {}
	if p_variant == null:
		return data
	
	var type = typeof(p_variant)
	var value = p_variant
	if type == TYPE_OBJECT:
		value = parse_object(value)
	data["Type"] = type
	data["Value"] = value
	
	return data

func parse_object(p_object):
	var data = {}
	if p_object == null:
		return data
	
	data["Class"] = p_object.get_class()
	if p_object is RefCounted:
		data = _parse_ref_counted(p_object, data)
	else:
		push_warning("Parsing not implemented for ", p_object.get_class())
	
	return data

func _parse_ref_counted(p_object, p_data):
	if p_object is Resource:
		p_data = _parse_resource(p_object, p_data)
	else:
		push_warning("Parsing not implemented for ", p_object.get_class())
	
	return p_data

func _parse_resource(p_resource, p_data):
	p_data["Path"] = p_resource.get_path()
	
	if p_resource is Texture:
		p_data = _parse_texture(p_resource, p_data)
	elif p_resource is Material:
		p_data = _parse_material(p_resource, p_data)
	elif p_resource is Shape3D:
		p_data = _parse_shape_3D(p_resource, p_data)
	else:
		push_warning("Parsing not implemented for ", p_resource.get_class())
	
	return p_data

func _parse_texture(p_texture, p_data):
	if p_texture is CompressedTexture2D:
		p_data = _parse_compressed_texture_2D(p_texture, p_data)
	else:
		push_warning("Parsing not implemented for ", p_texture.get_class())
	
	return p_data

func _parse_compressed_texture_2D(p_texture, p_data):
	p_data["Load_Path"] = p_texture.get_load_path()
	
	return p_data

func _parse_material(p_material, p_data):
	var next_pass = p_material.get_next_pass()
	p_data["Next_Pass"] = parse_object(next_pass)
	p_data["Render_Priority"] = p_material.get_render_priority()
	
	if p_material is ShaderMaterial:
		p_data = _parse_shader_material(p_material, p_data)
	else:
		push_warning("Parsing not implemented for ", p_material.get_class())
	
	return p_data

func _parse_shader_material(p_material, p_data):
	var shader = p_material.get_shader()
	if shader == null:
		return p_data
	
	var shader_path = shader.get_path()
	if shader_path.is_empty():
		push_warning("Shader must be a saved resource!")
	p_data["Shader"] = {}
	p_data["Shader"]["Path"] = shader_path
	
	p_data["Params"] = {}
	var uniform_list = shader.get_shader_uniform_list()
	for args in uniform_list:
		var name_ = args["name"]
		var value = p_material.get_shader_parameter(name_)
		p_data["Params"][name_] = parse_variant(value)
	
	return p_data

func _parse_shape_3D(p_shape, p_data):
	p_data["Custom_Solver_Bias"] = p_shape.get_custom_solver_bias()
	p_data["Margin"] = p_shape.get_margin()
	
	if p_shape is BoxShape3D:
		p_data = _parse_box_shape_3D(p_shape, p_data)
	elif p_shape is CapsuleShape3D:
		p_data = _parse_capsule_shape_3D(p_shape, p_data)
	else:
		push_warning("Parsing not implemented for ", p_shape.get_class())
	
	return p_data

func _parse_box_shape_3D(p_shape, p_data):
	p_data["Size"] = p_shape.get_size()
	
	return p_data

func _parse_capsule_shape_3D(p_shape, p_data):
	p_data["Height"] = p_shape.get_height()
	p_data["Radius"] = p_shape.get_radius()
	
	return p_data

func unparse_variant(p_data):
	var type = p_data["Type"]
	if type == TYPE_OBJECT:
		return unparse_object(p_data["Value"])
	else:
		return p_data["Value"]

func unparse_object(p_data):
	var object = null
	if p_data.is_empty():
		return object
	
	var class_ = p_data["Class"]
	match class_:
		"CompressedTexture2D": object = unparse_compressed_texture_2D(p_data)
		"ShaderMaterial": object = unparse_shader_material(p_data)
		"BoxShape3D": object = unparse_box_shape_3D(p_data)
		"CapsuleShape3D": object = unparse_capsule_shape_3D(p_data)
		_: push_warning("Unparsing not implemented for ", class_)
	
	return object

func unparse_compressed_texture_2D(p_data):
	var texture = _unparse_resource(p_data)
	texture.load(p_data["Load_Path"])
	
	return texture

func unparse_shader_material(p_data):
	var material = _unparse_resource(p_data)
	_load_data_material(material, p_data)
	
	var shader_path = p_data["Shader"]["Path"]
	if shader_path.is_empty():
		push_warning("Shader must be a saved resource!")
	else:
		var shader = load(shader_path)
		material.set_shader(shader)
	
	for param in p_data["Params"]:
		var args = p_data["Params"][param]
		var value = unparse_variant(args)
		material.set_shader_parameter(param, value)
	
	return material

func unparse_box_shape_3D(p_data):
	var shape = _unparse_resource(p_data)
	_load_data_shape(shape, p_data)
	shape.set_size(p_data["Size"])
	
	return shape

func unparse_capsule_shape_3D(p_data):
	var shape = _unparse_resource(p_data)
	_load_data_shape(shape, p_data)
	shape.set_height(p_data["Height"])
	shape.set_radius(p_data["Radius"])
	
	return shape

func _load_data_material(p_material, p_data):
	var next_pass = unparse_object(p_data["Next_Pass"])
	p_material.set_next_pass(next_pass)
	p_material.set_render_priority(p_data["Render_Priority"])

func _load_data_shape(p_shape, p_data):
	p_shape.set_custom_solver_bias(p_data["Custom_Solver_Bias"])
	p_shape.set_margin(p_data["Margin"])

func _unparse_resource(p_data):
	var path = p_data["Path"]
	var resource = null
	if path.is_empty():
		var class_ = p_data["Class"]
		resource = ClassDB.instantiate(class_)
	if !path.is_empty():
		resource = load(p_data["Path"])
	
	return resource
