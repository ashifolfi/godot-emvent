@tool
extends EditorPlugin

const MainView = preload("res://addons/emvent-system/editor/views/main_view.tscn")

var main_view_instance

func _enter_tree():
	# Initialization of the plugin goes here.
	
	# Create the main tab
	main_view_instance = MainView.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(main_view_instance)
	_make_visible(false)
	
	# add singleton
	add_autoload_singleton("EmventSystem", "res://addons/emvent-system/emvent_system.gd")

func _exit_tree():
	# destroy the main tab
	if main_view_instance:
		main_view_instance.queue_free()
	
	# remove singleton
	remove_autoload_singleton("EmventSystem")

func _handles(object):
	if object is Emvent:
		return true
	else:
		return false

func _make_visible(visible):
	if main_view_instance:
		main_view_instance.visible = visible

func _get_plugin_name():
	return "Event"

func _get_plugin_icon():
	return load("res://addons/emvent-system/res/EmventTab.svg")

func _has_main_screen():
	return true
