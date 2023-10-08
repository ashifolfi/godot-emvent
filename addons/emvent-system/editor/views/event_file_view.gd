@tool
extends PanelContainer

# Data
var passage: Emvent

# UI State stuff
var path: String = ""
var is_modified = false # true if changes are made without saving

# UI Signals
signal file_modified
signal file_saved

# UI Elements
@onready var form_name_field = $VBoxContainer/HBoxContainer/LineEdit
@onready var command_list = $VBoxContainer/HBoxContainer2/PanelContainer/VBoxContainer

func _ready():
	# make sure we always have a valid file
	if !passage:
		passage = Emvent.new()
	
	form_name_field.text = passage.name
	
	# load all the existing passage command nodes into the editor as editable nodes
	for command in passage.commands:
		var command_edit_instance = load("res://addons/emvent-system/editor/components/command_editor.tscn").instantiate()
		command_edit_instance.command = command
		command_list.add_child(command_edit_instance)
		
		command_edit_instance.command_modified.connect(_on_command_modified)
		command_edit_instance.move_command.connect(_on_command_move_requested)
		command_edit_instance.remove_command.connect(_on_command_remove_requested)

func save_passage():
	var error = ResourceSaver.save(passage, path, ResourceSaver.FLAG_NONE)
	# TODO: there might be a better way to do this
	if error != OK:
		var err_msg = "An unknown error occured!"
		match error:
			ERR_FILE_BAD_PATH: err_msg = "Bad file path."
			ERR_FILE_CANT_WRITE: err_msg = "Cannot write to the specified file."
			ERR_FILE_ALREADY_IN_USE: err_msg = "File is currently being used."
		
		$SaveErrorBox.title = "Failed to save file"
		$SaveErrorBox.dialog_text = "An Error Occured:\n{error}".format({"error": err_msg})
		$SaveErrorBox.popup_centered()
		push_error("An Error Occured While Saving:\n{error}".format({"error": err_msg}))
	
	is_modified = false
	file_saved.emit()

# connections
func _on_passage_name_change(new_name):
	if new_name == "":
		new_name = "Untitled Passage"
	
	passage.name = new_name
	
	is_modified = true
	file_modified.emit()

func _on_add_command_pressed():
	var dialog_addcmd = load("res://addons/emvent-system/editor/dialogs/dialog_add_cmd.tscn").instantiate()
	add_child(dialog_addcmd)
	
	dialog_addcmd.popup_centered()
	dialog_addcmd.selected_command.connect(_on_command_selected)

func _on_command_selected(command_info):
	var script: GDScript = load(command_info)
	
	var command_edit_instance = load("res://addons/emvent-system/editor/components/command_editor.tscn").instantiate()
	command_edit_instance.command = script.new()
	command_list.add_child(command_edit_instance)
	
	command_edit_instance.command_modified.connect(_on_command_modified)
	command_edit_instance.move_command.connect(_on_command_move_requested)
	command_edit_instance.remove_command.connect(_on_command_remove_requested)
	
	passage.commands.append(command_edit_instance.command)

func _on_command_move_requested(direction, index):
	if direction == "up":
		if index <= 0:
			return
		
		var cedit_instance = command_list.get_child(index)
		command_list.move_child(command_list.get_child(index), index - 1)
		
		passage.commands.remove_at(index)
		passage.commands.insert(index - 1, cedit_instance.command)
	elif direction == "down":
		if index >= command_list.get_child_count():
			return
		
		var cedit_instance = command_list.get_child(index)
		command_list.move_child(command_list.get_child(index), index + 1)
		
		passage.commands.remove_at(index)
		passage.commands.insert(index + 1, cedit_instance.command)
	
	is_modified = true

func _on_command_remove_requested(index):
	var cedit_instance = command_list.get_child(index)
	cedit_instance.queue_free()
	passage.commands.remove_at(index)
	
	is_modified = true

func _on_command_modified():
	is_modified = true
