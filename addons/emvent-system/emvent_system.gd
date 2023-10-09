# This script acts as a singleton.
# This functions as the simplest built in method to run events.
#
# In the future this will also hold the nodes and scene data for some other
# built in commands like show picture
extends Node

var event_data: Emvent
var event_cmd_index = 0
var event_if_stack = 0 # counts the amount of endif we're looking for

func _physics_process(_delta):
	if event_data != null:
		_process_event()

func _process_event():
	# ew ew ew ew ew ew ew ew
	while true:
		if event_cmd_index >= event_data.commands.size():
			event_data = null
			break
		
		# special condition for jump commands
		if event_data.commands[event_cmd_index] is JumpEventCommand:
			for i in range(0, event_data.commands.size()):
				var command = event_data.commands[i]
				
				if (command is LabelEventCommand 
				and command.name == event_data.commands[event_cmd_index].label):
					event_cmd_index = i
					break
			continue
		
		# if we do hit an else then assume our if was successful
		if event_data.commands[event_cmd_index] is ElseEventCommand:
			while !(event_data.commands[event_cmd_index] is EndIfEventCommand):
				event_cmd_index += 1
			event_cmd_index += 1
			continue
		
		if event_data.commands[event_cmd_index] is EmventNoExecCommand:
			event_cmd_index += 1
			continue
		
		if event_data.commands[event_cmd_index] is IfEventCommand:
			var result = event_data.commands[event_cmd_index].execute_command()
			if result > 0:
				if result == 1:
					# execute as normal. if we hit an else we'll automatically skip
					event_cmd_index += 1
					continue
				elif result == 2:
					# look ahead for an else or endif then skip one past that
					while !(event_data.commands[event_cmd_index] is EndIfEventCommand
					or event_data.commands[event_cmd_index] is ElseEventCommand):
						event_cmd_index += 1
					event_cmd_index += 1
					continue
			else:
				break

		if event_data.commands[event_cmd_index].execute_command() > 0:
			event_cmd_index += 1
		else:
			break

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
