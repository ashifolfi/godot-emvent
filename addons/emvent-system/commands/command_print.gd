@tool
class_name EmventCommandPrint extends EmventCommand

@export var contents: String

func _init():
	command_name = "Print"
	command_desc = "Prints a message to the console."

func _get_parameters():
	return [
		["contents", "String"]
	]

func execute_command():
	print(contents)
	return 1
