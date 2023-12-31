@tool
extends MarginContainer

var open_files: Array

@onready var tab_bar = $VBoxContainer/PanelContainer/VBoxContainer/TabBar
@onready var tab_box = $VBoxContainer/PanelContainer/VBoxContainer/TabHolder
@onready var dialog_fconf = $UnsavedFileConfirmationDialog

@onready var menu_file = $VBoxContainer/MenuBar/File
@onready var menu_help = $VBoxContainer/MenuBar/Help

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# only display a close button on the active tab
	tab_bar.tab_close_display_policy = tab_bar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY
	
	# File Menu
	menu_file.clear()
	menu_file.add_item("New Event", 0, KEY_MASK_CTRL|KEY_N)
	menu_file.add_item("Open Event", 1, KEY_MASK_CTRL|KEY_O)
	menu_file.add_separator("", 2)
	menu_file.add_item("Save", 3, KEY_MASK_CTRL|KEY_S)
	menu_file.add_item("Save As", 4, KEY_MASK_CTRL|KEY_MASK_SHIFT|KEY_S)
	
	# default to save and save as being disabled
	menu_file.set_item_disabled(3, true)
	menu_file.set_item_disabled(4, true)

func create_tab(evdata: Emvent, path: String = ""):
	var new_tab = load("res://addons/emvent-system/editor/views/event_file_view.tscn").instantiate()
	new_tab.passage = evdata
	
	if !path.is_empty():
		new_tab.path = path
	
	tab_box.add_child(new_tab)
	
	# set connections
	new_tab.file_modified.connect(_on_event_modified)
	new_tab.file_saved.connect(_on_event_saved)
	
	# set tab name
	tab_bar.add_tab(new_tab.passage.name)
	# refresh tabs and child element visibility
	_on_tab_bar_tab_changed(tab_bar.current_tab)
	_update_menu_status()

# Menu Bar functions
func _on_new_file() -> void:
	create_tab(Emvent.new())

func _on_event_saved() -> void:
	var event_data = tab_box.get_child(tab_bar.current_tab).passage
	tab_bar.set_tab_title(tab_bar.current_tab, event_data.name)

func _on_event_modified() -> void:
	var event_data = tab_box.get_child(tab_bar.current_tab).passage
	tab_bar.set_tab_title(tab_bar.current_tab, event_data.name + "(*)")

func _update_menu_status() -> void:
	if tab_box.get_child_count() == 0:
		menu_file.set_item_disabled(3, true)
		menu_file.set_item_disabled(4, true)
	else:
		menu_file.set_item_disabled(3, false)
		menu_file.set_item_disabled(4, false)

# Helper functions
func get_current_tab():
	if tab_box.get_child_count() <= 0:
		return
	
	return tab_box.get_child(tab_bar.current_tab)

# Connections
func _on_tab_bar_tab_changed(tab):
	tab_box.current_tab = tab

func _on_tab_bar_tab_close_pressed(tab):
	if tab_box.get_child(tab).is_modified:
		dialog_fconf.popup_centered()
		return
	
	var tab_element = tab_box.get_child(tab)
	tab_box.remove_child(tab_element)
	tab_element.queue_free()
	
	tab_bar.remove_tab(tab)
	_update_menu_status()

func _on_confirm_dialog_action(action: StringName) -> void:
	if action == "save":
		get_current_tab().save_passage()
	
	# HACK?: this closes the current tab instead of the requested tab.
	# this isn't much of an issue though as the close button only appears on
	# the currently active tab meaning this should always close the right one.
	
	var tab = get_current_tab()
	tab_box.remove_child(tab)
	tab.queue_free()
	
	tab_bar.remove_tab(tab_bar.current_tab)
	_update_menu_status()

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
		3: _save_file_pressed(get_current_tab().path.is_empty())
		4: _save_file_pressed(true)
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
		$ErrorWindow.dialog_text = "Selected file is not an Emvent Event Resource.\nSelect a different file"
		$ErrorWindow.popup_centered()
