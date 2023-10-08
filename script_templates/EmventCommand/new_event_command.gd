# meta-description: Base groundwork for a new event command
# meta-default: true
@tool
# Uncomment and change this class name for your command to show up!
# class_name NewEventCommand 
extends EmventCommand

# Place your parameters here formatted like so
# @export var <name>: <type> = <default_value>

func _init():
	# Friendly name of your command
	command_name = "New Command"
	# Short Description/Usage of your command
	command_desc = "A command that does things that are cool."

# used by the event editor to know what properties to display
func _get_parameters():
	# as you add parameters add the info to this list
	# parameters are formatted like so
	# ["<variable name>", "<type>"] (without the <>)
	return []

func execute_command():
	# Place your command logic here. This is what is used by the event runner
	return 1
