# meta-description: Base groundwork for a new event command
# meta-default: true
@tool
# Uncomment and change this class name for your command to show up!
# class_name NewEventCommand 
extends EmventCommand

# Place your properties here formatted like so
# @export var <name>: <type> = <default_value>

func _init():
	# Friendly name of your command
	cmd_name = "New Command"
	# Short Description/Usage of your command
	cmd_description = "A command that does things that are cool."
	# The category your command is shown under in the editor
	cmd_category = "Custom"

# used by the event editor to know what properties to display
func get_properties():
	# as you add propertie  add the info to this list
	# properties are formatted like so
	# ["<variable name>", "<type>"] (without the <>)
	return []

func execute_command():
	# Place your command logic here. This is what is used by the event runner
	return 1
