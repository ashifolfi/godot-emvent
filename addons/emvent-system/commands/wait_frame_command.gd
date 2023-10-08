@tool
class_name WaitEventCommand 
extends EmventCommand

# Place your parameters here formatted like so
@export var frame_count: int = 20

var timer = -1

func _init():
	cmd_name = "Wait"
	cmd_description = "Wait a specified amount of frames before continuing"
	cmd_category = "Utility"

# used by the event editor to know what properties to display
func get_properties():
	return [
		["frame_count", "Number"]
	]

func execute_command():
	if timer == -1:
		# uninitialized timer
		timer = frame_count
	elif timer > 0:
		timer -= 1
	elif timer == 0:
		return 1
	
	# stay on this command until the timer is 0
	return 0

