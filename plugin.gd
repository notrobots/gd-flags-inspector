@tool
class_name FlagsInspectorPlugin extends EditorPlugin

static var config: ConfigFile
var flags_inspector: FlagsInspector

func _enter_tree():
	if not Engine.is_editor_hint():
		return

	config = ConfigFile.new()
	config.load(get_script().resource_path.get_base_dir() + "/config.ini")
	flags_inspector = load(get_script().resource_path.get_base_dir() + "/scripts/FlagsInspector.gd").new()

	add_inspector_plugin(flags_inspector)

func _exit_tree():
	if not Engine.is_editor_hint():
		return

	remove_inspector_plugin(flags_inspector)
