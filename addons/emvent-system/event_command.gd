class_name EmventCommand extends Resource

## Human Readable/Friendly name of the command
var cmd_name = "Command"
## A summary of the use of the command or what it does
var cmd_description = "The base class for all Passage Commands, only exists to be extended."
## The category this command is stored in
var cmd_category = "Custom"

## Used by the editor to maintain command collapse state
@export var visible: bool = true

## Returns a list where each element is an array containing the name and field type of the parameter
func get_properties():
	return {}

## The code that's ran when the event is processed by the runner
func execute_command():
	pass
