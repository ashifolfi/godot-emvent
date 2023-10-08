@tool
class_name JumpEventCommand 
extends EmventNoExecCommand

@export var label: String = ""

func _init():
	cmd_name = "Jump"
	cmd_description = "Jumps to a specific label in the event tree"
	cmd_category = "Flow Control"

# used by the event editor to know what properties to display
func get_properties():
	return [
		["label", "String"]
	]
