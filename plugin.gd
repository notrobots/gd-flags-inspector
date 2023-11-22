@tool
class_name FlagsInspectorPlugin extends EditorPlugin

static var config: ConfigFile

var flags_inspector

func _enter_tree():
	config = ConfigFile.new()
	config.load(get_script().resource_path.get_base_dir() + "/config.ini")
	flags_inspector = FlagsInspector.new()

	add_inspector_plugin(flags_inspector)

func _exit_tree():
	remove_inspector_plugin(flags_inspector)
