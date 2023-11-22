class_name FlagsProperty extends EditorProperty

static var value_regex: RegEx:
	get:
		if not value_regex:
			value_regex = RegEx.new()
			value_regex.compile("^(\\w+)(:\\d+)?$")

		return value_regex

# Flags
# <String, int>
var flags: Dictionary
var ui_main: VBoxContainer = VBoxContainer.new()
var ui_flags: VBoxContainer = VBoxContainer.new()
var ui_summary: Button = Button.new()
var cfg_value_display: String = FlagsInspectorPlugin.config.get_value("config", "value_display", "none")
var cfg_value_tooltip: String = FlagsInspectorPlugin.config.get_value("config", "value_tooltip", "none")
var cfg_value_space: bool = FlagsInspectorPlugin.config.get_value("config", "value_space", false)
var cfg_summary: String = FlagsInspectorPlugin.config.get_value("config", "summary", "dec")
var current_value: int = 0
var updating = false

static func create_array(name: StringName, flags: Dictionary):
	var values = ",".join(flags.keys().map(func(k): return "%s:%s" % [k, flags[k]]))

	return {
		"name": name,
		"type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": "%d/%d:%s" % [TYPE_INT, PROPERTY_HINT_FLAGS, values]
	}

static func create(name: StringName, flags: Dictionary):
	var values = ",".join(flags.keys().map(func(k): return "%s:%s" % [k, flags[k]]))

	return {
		"name": name,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": values
	}

func _init(values: Variant):
	if values is Dictionary:
		self.flags = values
	elif values is Array or values is PackedStringArray:
		for value in values:
			var value_match = value_regex.search(value)

			if value_match:
				var _name = value_match.get_string(1)
				var _value = value_match.get_string(2)

				_value = int(_value.trim_prefix(":"))
				flags[_name] = _value
			else:
				printerr("Couldn't parse flag '%s'. Flags must be formatted as 'Name' or 'Name:Value'" % [value])

	ui_summary.pressed.connect(func(): ui_flags.visible = not ui_flags.visible)
	ui_main.add_child(ui_summary)
	ui_main.add_child(ui_flags)
	add_child(ui_main)
	add_focusable(ui_main)
	refresh_flags()
	refresh_summary()

func _bin(n):
	var bin = ""

	while n > 0:
		bin = str(n&1) + bin
		n = n >> 1

	return bin

func _update_property():
	var new_value = get_edited_object()[get_edited_property()]

	if not new_value:
		new_value = 0

	if (new_value == current_value):
		return

	updating = true
	current_value = new_value
	refresh_flags()
	refresh_summary()
	updating = false

func refresh_summary():
	match cfg_summary:
		"none": pass
		"dec":
			ui_summary.text = "Dec: %s" % [current_value]
		"bin":
			ui_summary.text = "Bin: %s" % [_bin(current_value)]
		"all":
			ui_summary.text = "Dec: %s\nBin: %s" % [current_value, _bin(current_value)]

func refresh_flags():
	for child in ui_flags.get_children():
		ui_flags.remove_child(child)
		child.queue_free()

	for flag in flags:
		var ui_flag = CheckBox.new() as CheckBox
		var _name = flag
		var _value = flags[flag]

		if current_value & _value:
			ui_flag.button_pressed = true

		ui_flag.toggled.connect(func(value):
			if updating:
				return

			if value:
				current_value |= _value
			else:
				current_value &= ~_value

			refresh_flags()
			refresh_summary()
			emit_changed(get_edited_property(), current_value)
		)

		match cfg_value_display:
			"none":
				ui_flag.text = _name
			"bin":
				ui_flag.text = ("%s: %s" if cfg_value_space else "%s:%s") % [_name, _bin(_value)]
			"dec":
				ui_flag.text = ("%s: %s" if cfg_value_space else "%s:%s") % [_name, _value]
			"bit":
				ui_flag.text = ("%s: %s" if cfg_value_space else "%s:%s") % [_name, _bin(_value).length()]
			"all": pass

		match cfg_value_tooltip:
			"none": pass
			"bin":
				ui_flag.tooltip_text = _bin(_value)
			"dec":
				ui_flag.tooltip_text = str(_value)
			"bit":
				ui_flag.tooltip_text = str(_bin(_value).length())
			"all":
				ui_flag.tooltip_text = "dec: %s\nbin: %s\nbit: %s" % [_value, _bin(_value), _bin(_value).length()]

		ui_flags.add_child(ui_flag)
