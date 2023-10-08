# This script acts as a singleton.
# This functions as the simplest built in method to run events.
#
# In the future this will also hold the nodes and scene data for some other
# built in commands like show picture
extends Node

var event_data: Emvent
var event_cmd_index = 0

func _process(delta):
	if event_data != null:
		_process_event()

func _process_event():
	if event_cmd_index < event_data.commands.size():
		if event_data.commands[event_cmd_index].execute_command() > 0:
			event_cmd_index += 1
	else:
		# clear event_data when we're done
		event_data = null


func is_running() -> bool:
	if event_data == null:
		return false
	else:
		return true

func run_event(data: Emvent):
	# duplicate the data when passing over so we don't unintentionally
	# modify anything we didn't want to modify.
	event_data = data.duplicate(true)
	event_cmd_index = 0