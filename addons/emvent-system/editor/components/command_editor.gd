@tool
extends PanelContainer

@export var command: EmventCommand

@onready var field_container = $HBoxContainer/PanelContainer/Layout/FieldContainer
@onready var command_name = $HBoxContainer/PanelContainer/Layout/PanelContainer/HBoxContainer/CommandName
@onready var hide_btn: TextureButton = $HBoxContainer/PanelContainer/Layout/PanelContainer/HBoxContainer/hideBtn

signal move_command
signal remove_command
signal command_modified

# Called when the node enters the scene tree for the first time.
func _ready():
	if command == null:
		push_warning("No command was provided before ready! Destroying element...")
		queue_free()
		return
	
	# set editor icon textures
	hide_btn.texture_normal = get_theme_icon("GuiVisibilityVisible", "EditorIcons")
	hide_btn.texture_pressed = get_theme_icon("GuiVisibilityHidden", "EditorIcons")
	
	# populate right click menu
	$RCMenu.clear()
	$RCMenu.add_icon_item(get_theme_icon("ArrowUp", "EditorIcons"), "Move Up", 0)
	$RCMenu.add_icon_item(get_theme_icon("ArrowDown", "EditorIcons"), "Move Down", 1)
	$RCMenu.add_separator("", 2)
	$RCMenu.add_icon_item(get_theme_icon("Remove", "EditorIcons"), "Remove", 3)
	
	command_name.text = command.cmd_name
	
	_populate_field_container()
	field_container.visible = command.visible

func _populate_field_container() -> void:
	for prop_info in command.get_properties():
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

func _on_hide_btn_toggled(button_pressed):
	field_container.visible = !button_pressed
	command.visible = !button_pressed
	command_modified.emit()

func _on_panel_container_gui_input(event):
	# right click event opens a pop up with some actions
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			$RCMenu.position = event.global_position
			$RCMenu.popup()

func _on_rcmenu_index_pressed(index):
	match index:
		0: move_command.emit("up", get_index())
		1: move_command.emit("down", get_index())
		3: remove_command.emit(get_index())


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
	
	prop_textedit.custom_minimum_size = Vector2(0, 72)
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
