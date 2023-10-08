class_name EmventCommand extends Resource

## Human Readable/Friendly name of the command
var command_name = "Command"
## A summary of the use of the command or what it does
var command_desc = "The base class for all Passage Commands, only exists to be extended."

## Returns a list where each element is an array containing the name and field type of the parameter
func _get_parameters():
	return {}

## The code that's ran when the event is processed by the runner
func execute_command():
	pass
