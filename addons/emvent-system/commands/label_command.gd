@tool
class_name LabelEventCommand 
extends EmventNoExecCommand

@export var name: String = ""

func _init():
	cmd_name = "Label"
	cmd_description = "Defines a named position in the event tree that can be jumped to."
	cmd_category = "Flow Control"

# used by the event editor to know what properties to display
func get_properties():
	return [
		["name", "String"]
	]
