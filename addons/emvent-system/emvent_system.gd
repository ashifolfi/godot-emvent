# This script acts as a singleton.
# This functions as the simplest built in method to run events.
#
# In the future this will also hold the nodes and scene data for some other
# built in commands like show picture
extends Node

var event_data: Emvent
var event_cmd_index = 0

func _physics_process(_delta):
	if event_data != null:
		_process_event()

func _process_event():
	# special condition for jump commands
	if event_data.commands[event_cmd_index] is JumpEventCommand:
		for i in range(0, event_data.commands.size()):
			var command = event_data.commands[i]
			
			if (command is LabelEventCommand 
			and command.name == event_data.commands[event_cmd_index].label):
				event_cmd_index = i
				# TODO: do we want to wait one frame after a jump or start execution immediately?
				return
		
		# if we make it out of the for loop then something went wrong
		push_error("Event Execution Error: Attempted to jump to label that doesn't exist!")
		event_data = null
		return
	
	# skip over no execution commands without wasting tics
	while event_data.commands[event_cmd_index] is EmventNoExecCommand:
		event_cmd_index += 1
		if event_cmd_index >= event_data.commands.size():
			event_data = null
			return
	
	if event_data.commands[event_cmd_index].execute_command() > 0:
		event_cmd_index += 1
	
	if event_cmd_index >= event_data.commands.size():
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
