@tool
extends PanelContainer

# Data
var passage: Emvent

# UI State stuff
var path: String = ""
var is_modified = false # true if changes are made without saving
var drag_index # The index of the entry being dragged currently

# UI Signals
signal file_modified
signal file_saved

# UI Elements
@onready var form_name_field = $VBoxContainer/HBoxContainer/LineEdit
@onready var command_list = $VBoxContainer/PanelContainer/ScrollContainer/ListHolder/CommandList
@onready var drag_overlay = $VBoxContainer/PanelContainer/ScrollContainer/ListHolder/DragOverlay

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
		command_edit_instance.drag_started.connect(_on_command_drag_begin)
	
	drag_overlay.visible = false

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

func move_command_entry(index, new_index):
	var cedit_instance = command_list.get_child(index)
	command_list.move_child(command_list.get_child(index), new_index)
	
	passage.commands.remove_at(index)
	passage.commands.insert(new_index, cedit_instance.command)
	
	is_modified = true
	file_modified.emit()

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
	command_edit_instance.drag_started.connect(_on_command_drag_begin)
	
	passage.commands.append(command_edit_instance.command)

func _on_command_move_requested(direction, index):
	if direction == "up":
		if index <= 0:
			return
		
		move_command_entry(index, index - 1)
	elif direction == "down":
		if index >= command_list.get_child_count():
			return
		
		move_command_entry(index, index + 1)

func _on_command_remove_requested(index):
	var cedit_instance = command_list.get_child(index)
	cedit_instance.queue_free()
	passage.commands.remove_at(index)
	
	is_modified = true
	file_modified.emit()

func _on_command_drag_begin(index):
	#print("Received drag event, starting drag")
	drag_overlay.visible = true
	drag_overlay.grab_click_focus()
	drag_index = index

func _on_drag_overlay_gui_event(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			var final_index
			for child in command_list.get_children():
				if child.position.y < event.position.y:
					continue
				elif child.position.y >= event.position.y:
					# we hit something! perform a further check of the
					# check if we're in snap distance to index-1 still
					var prev_child = command_list.get_child(child.get_index() - 1)
					if prev_child.position.y + (prev_child.size.y / 2) > event.position.y:
						final_index = prev_child.get_index()
					else:
						final_index = child.get_index()
					
					break
			# if we're still null then we're either above or below everything.
			# if we're above everything... we can't detect that. So just assume below.
			if final_index == null:
					final_index = command_list.get_child_count() - 1

			# if we're already at the point we're moving to don't bother moving
			# since it'd just be a waste of execution time
			if drag_index != final_index:
				move_command_entry(drag_index, final_index)
			
			drag_index = null
			drag_overlay.visible = false

func _on_command_modified():
	is_modified = true
	file_modified.emit()
