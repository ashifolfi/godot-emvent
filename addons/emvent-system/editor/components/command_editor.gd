extends PanelContainer

@export var command: EmventCommand

@onready var field_container = $Layout/FieldContainer
@onready var command_name = $Layout/ColorRect/HBoxContainer/CommandName

signal move_command
signal remove_command
signal command_modified

# Called when the node enters the scene tree for the first time.
func _ready():
	if command == null:
		push_warning("No command was provided before ready! Destroying element...")
		queue_free()
		return
	
	command_name.text = command.command_name
	_populate_field_container()

func _populate_field_container() -> void:
	for prop_info in command._get_parameters():
		var prop_layout = HBoxContainer.new()
		var prop_label = Label.new()
		var prop_widget
		
		prop_label.text = prop_info[0].capitalize() + ": "
		
		match prop_info[1]:
			"String": 
				prop_widget = _create_line_edit(prop_info[0])
			"MultilineString": 
				prop_widget = _create_multi_line_edit(prop_info[0])
			"Number":
				prop_widget = _create_int_spinbox(prop_info[0])
			_:
				prop_widget = Label.new()
				prop_widget.label_settings = LabelSettings.new()
				prop_widget.label_settings.font_color = Color.RED
				prop_widget.text = "Unknown Property Type"
		
		prop_layout.add_child(prop_label)
		prop_layout.add_child(prop_widget)
		field_container.add_child(prop_layout)

# Field Creation Functions
# TODO: improve the event sheet UI greatly
func _create_line_edit(property: String):
	var prop_lineedit = LineEdit.new()
	
	prop_lineedit.text = command.get(property)
	prop_lineedit.text_changed.connect(func(new_text): 
		command.set(property, new_text)
		command_modified.emit())
	prop_lineedit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	return prop_lineedit

func _create_multi_line_edit(property: String):
	var prop_textedit = TextEdit.new()
	
	prop_textedit.custom_minimum_size = Vector2(0, 64)
	prop_textedit.text = command.get(property)
	prop_textedit.text_changed.connect(func(): 
		command.set(property, prop_textedit.text)
		command_modified.emit())
	prop_textedit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	return prop_textedit

func _create_int_spinbox(property: String):
	var prop_layout = HBoxContainer.new()
	var prop_label = Label.new()
	var prop_spinbox = SpinBox.new()
	
	prop_label.text = property.capitalize() + ": "
	
	prop_spinbox.value = command.get(property)
	prop_spinbox.value_changed.connect(func(new_value): 
		command.set(property, new_value)
		command_modified.emit())
	prop_spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	return prop_spinbox


func _on_hide_btn_pressed():
	if field_container.visible:
		field_container.visible = false
		$Layout/ColorRect/HBoxContainer/hideBtn.text = "Show"
	else:
		field_container.visible = true
		$Layout/ColorRect/HBoxContainer/hideBtn.text = "Hide"

func _on_dwn_btn_pressed():
	move_command.emit("down", get_index())

func _on_up_btn_pressed():
	move_command.emit("up", get_index())

func _on_rem_btn_pressed():
	remove_command.emit(get_index())
