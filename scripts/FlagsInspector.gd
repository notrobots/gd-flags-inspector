class_name FlagsInspector extends EditorInspectorPlugin

func _can_handle(object):
	return true

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if hint_type != PROPERTY_HINT_FLAGS or type != TYPE_INT:
		return false

	var values = hint_string.split(",", false)

	add_property_editor(name, load(get_script().resource_path.get_base_dir() + "/FlagsProperty.gd").new(values))

	return true
