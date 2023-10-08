@tool
class_name EmventCommandPrint extends EmventCommand

@export var contents: String

func _init():
	cmd_name = "Print"
	cmd_description = "Prints a message to the console."
	cmd_category = "Utility"

func get_properties():
	return [
		["contents", "String"]
	]

func execute_command():
	print(contents)
	return 1
