@tool
extends Window

@onready var cmd_list: ItemList = $MarginContainer/VBoxContainer/cmdList
@onready var cmd_info: RichTextLabel = $MarginContainer/VBoxContainer/cmdInfo

var info_template: String = "[b]{name}[/b]: {description}"
var cmd_info_list: Array[Dictionary]

signal selected_command

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: create a proper icon instead of using the editor callable icon
	var icon: Texture2D = load("res://addons/emvent-system/res/CommandIcon.svg")
	
	cmd_list.clear()
	
	# this is absolutely messy holy shit
	for _class in ProjectSettings.get_global_class_list():
		if _class["base"] != "EmventCommand":
			continue
		
		var script: GDScript = load(_class["path"])
		if !script:
			continue
		var script_instance = script.new()
		
		# we create a string from these to prevent godot from assigning by reference
		# so we can queue_free the instance when we're done
		cmd_list.add_item(String(script_instance.command_name), icon)
		
		var cmd_info_item = {
			"name": String(script_instance.command_name),
			"description": String(script_instance.command_desc),
			# This is passed back to the file view where the command list
			# will utilize it to create the new command entry
			"path": String(_class["path"])
		}
		cmd_info_list.append(cmd_info_item)

func _on_command_selected(idx) -> void:
	cmd_info.clear()
	cmd_info.append_text(info_template.format(cmd_info_list[idx]))

func _on_command_activated(idx) -> void:
	selected_command.emit(cmd_info_list[idx].path)
	
	# Destroy this window when we're done. we recreate it to refresh the list.
	hide()
	queue_free()

func _on_confirmed():
	if cmd_list.get_selected_items().size() == 0:
		return
	
	# we only allow selecting one so just use the first item
	_on_command_activated(cmd_list.get_selected_items()[0])
