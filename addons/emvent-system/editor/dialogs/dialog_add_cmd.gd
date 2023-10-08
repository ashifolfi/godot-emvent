@tool
extends Window

@onready var cmd_tree: Tree = $MarginContainer/VBoxContainer/cmdListT
@onready var cmd_info: RichTextLabel = $MarginContainer/VBoxContainer/cmdInfo

var info_template: String = "[b]{name}[/b]: {description}"
var cmd_info_list: Dictionary

signal selected_command

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: create a proper icon instead of using the editor callable icon
	var icon: Texture2D = load("res://addons/emvent-system/res/CommandIcon.svg")
	
	cmd_tree.clear()
	
	var root_item = cmd_tree.create_item()
	var category_items: Dictionary = {}
	cmd_tree.hide_root = true
	
	# TODO: possibly move this elsewhere?
	for _class in ProjectSettings.get_global_class_list():
		if _class["class"] == "EmventNoExecCommand":
			continue # don't grab the noexeccommand class actually
		if (_class["base"] != "EmventCommand" 
		and _class["base"] != "EmventNoExecCommand"):
			continue
		
		var script: GDScript = load(_class["path"])
		if !script:
			continue
		var script_instance = script.new()
		
		# check for an existing category item, create one if there isn't
		var parent
		if category_items.has(String(script_instance.cmd_category)):
			parent = category_items[String(script_instance.cmd_category)]
		else:
			parent = cmd_tree.create_item(root_item)
			parent.set_text(0, String(script_instance.cmd_category))
			
			category_items[String(script_instance.cmd_category)] = parent
		
		# we create a string from these to prevent godot from assigning by reference
		var item = cmd_tree.create_item(parent)
		item.set_text(0, String(script_instance.cmd_name))
		item.set_icon(0, icon)
		
		var cmd_info_item = {
			"name": String(script_instance.cmd_name),
			"description": String(script_instance.cmd_description),
			# This is passed back to the file view where the command list
			# will utilize it to create the new command entry
			"path": String(_class["path"])
		}
		cmd_info_list[String(script_instance.cmd_name) + "Command"] = cmd_info_item

func _on_cmd_list_t_item_selected():
	var sel_item = cmd_tree.get_selected()
	
	cmd_info.clear()
	# check if what was selected is a command with valid info
	if cmd_info_list.has(sel_item.get_text(0) + "Command"):
		cmd_info.append_text(
			info_template.format(cmd_info_list[sel_item.get_text(0) + "Command"])
		)

func _on_cmd_list_t_item_activated():
	var sel_item = cmd_tree.get_selected()
	
	# check if what was selected is a command with valid info
	if cmd_info_list.has(sel_item.get_text(0) + "Command"):
		selected_command.emit(cmd_info_list[sel_item.get_text(0) + "Command"].path)
		
		# Destroy this window when we're done. we recreate it to refresh the list.
		hide()
		queue_free()

func _on_confirmed():
	var sel_item = cmd_tree.get_selected()
	# check if what was selected is a command with valid info
	if !cmd_info_list.has(sel_item.get_text(0) + "Command"):
		return
	
	_on_cmd_list_t_item_activated()
