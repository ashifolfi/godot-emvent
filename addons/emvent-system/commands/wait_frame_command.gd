@tool
class_name WaitEventCommand 
extends EmventCommand

# Place your parameters here formatted like so
@export var wait_time: int = 20

var timer = -1

func _init():
	# Friendly name of your command
	command_name = "Wait"
	# Short Description/Usage of your command
	command_desc = "Wait a specified amount of frames before continuing"

# used by the event editor to know what properties to display
func _get_parameters():
	return [
		["wait_time", "Number"]
	]

func execute_command():
	if timer == -1:
		# uninitialized timer
		timer = wait_time
	elif timer > 0:
		timer -= 1
	elif timer == 0:
		return 1
	
	# stay on this command until the timer is 0
	return 0

