@tool
class_name CommentEventCommand 
extends EmventNoExecCommand

@export var contents: String = ""

func _init():
	cmd_name = "Comment"
	cmd_description = "Provides context or notes when viewing the event in the editor."
	cmd_category = "Utility"

# used by the event editor to know what properties to display
func get_properties():
	return [
		["contents", "MultilineString"]
	]
