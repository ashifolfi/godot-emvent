@tool
extends MarginContainer

# TODO: this file is messy and unorganized

var open_files: Dictionary

@onready var tab_bar = $VBoxContainer/PanelContainer/VBoxContainer/TabBar
@onready var tab_box = $VBoxContainer/PanelContainer/VBoxContainer/TabHolder
@onready var dialog_fconf = $UnsavedFileConfirmationDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# only display a close button on the active tab
	tab_bar.tab_close_display_policy = tab_bar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY

func create_tab(evdata: Emvent, path: String = ""):
	var new_tab = load("res://addons/emvent-system/editor/views/event_file_view.tscn").instantiate()
	new_tab.passage = evdata
	
	if !path.is_empty():
		new_tab.path = path
	
	tab_box.add_child(new_tab)
	
	# set connections
	new_tab.file_modified.connect(_on_passage_modified)
	new_tab.file_saved.connect(_on_passage_saved)
	
	# set tab name
	tab_bar.add_tab(new_tab.passage.name)
	# refresh tabs and child element visibility
	_on_tab_bar_tab_changed(tab_bar.current_tab)

# Menu Bar functions
func _on_new_file() -> void:
	create_tab(Emvent.new())

func _on_passage_saved() -> void:
	var passage = tab_box.get_child(tab_bar.current_tab).passage
	tab_bar.set_tab_title(tab_bar.current_tab, passage.name)

func _on_passage_modified() -> void:
	var passage = tab_box.get_child(tab_bar.current_tab).passage
	tab_bar.set_tab_title(tab_bar.current_tab, passage.name + "(*)")

# Helper functions
func get_current_tab():
	if tab_box.get_child_count() <= 0:
		return
	
	return tab_box.get_child(tab_bar.current_tab)

# Connections
func _on_tab_bar_tab_changed(tab):
	for child in tab_box.get_children():
		child.visible = false
	
	if tab_box.get_child(tab):
		tab_box.get_child(tab).visible = true

func _on_tab_bar_tab_close_pressed(tab):
	if tab_box.get_child(tab).is_modified:
		dialog_fconf.popup_centered()
		return
	
	print("Closing tab...")
	
	var tab_element = tab_box.get_child(tab)
	tab_box.remove_child(tab_element)
	tab_element.queue_free()
	
	tab_bar.remove_tab(tab)

func _on_confirm_dialog_action(action: StringName) -> void:
	if action == "save":
		print("Saving Event...")
		get_current_tab().save_passage()
	
	# HACK: this closes the current tab instead of the requested tab.
	# this isn't much of an issue though as the close button only appears on
	# the currently active tab meaning this should always close the right one.
	print("Closing tab...")
	
	var tab = get_current_tab()
	tab_box.remove_child(tab)
	tab.queue_free()
	
	tab_bar.remove_tab(tab_bar.current_tab)

func _save_file_pressed(save_as: bool = false):
	if save_as or get_current_tab().path.is_empty():
		$SaveFileDialog.popup_centered()
		return
	get_current_tab().save_passage()

func _save_dialog_file_selected(path):
	print(path)
	get_current_tab().path = path
	get_current_tab().save_passage()

func _on_file_menu_index_pressed(index):
	match index:
		0: _on_new_file()
		1: $OpenFileDialog.popup_centered()
		2: _save_file_pressed(get_current_tab().path.is_empty())
		3: _save_file_pressed(true)
		_: print("Not Implemented.")

func _on_help_menu_index_pressed(index):
	match index:
		0: pass
		1: $AboutWindow.popup_centered()

func _on_about_window_close_requested():
	$AboutWindow.hide()

func _on_open_file_selected(path):
	# Load the resource from the path
	var res_data = load(path)
	
	if res_data is Emvent:
		create_tab(res_data, path)
	else:
		print("Is not event data")
