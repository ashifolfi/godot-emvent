@tool
class_name EndIfEventCommand
extends EmventNoExecCommand

func _init():
	cmd_name = "EndIf"
	cmd_description = "Signifies the end of a branch sequence."
	cmd_category = "Flow Control"

# used by the event editor to know what properties to display
func get_properties():
	return []
