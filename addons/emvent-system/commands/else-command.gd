@tool
class_name ElseEventCommand extends EmventNoExecCommand

func _init():
	cmd_name = "Else"
	cmd_description = "Signifies the start of code to run if an if condition returns false."
	cmd_category = "Flow Control"

# used by the event editor to know what properties to display
func get_properties():
	return []
