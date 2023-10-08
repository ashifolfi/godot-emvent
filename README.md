# eMVent
A highly extendable, easy to use RPG Maker inspired event system for Godot.

**WARNING: This addon is currently in the experimental phase. Thing will change rapidly as features are fleshed out and added.**

Features:
- An easy to use event sheet styled editor that adapts to custom commands easily
- A 'one script one command' based extendable command system for functions
- several non game specific commands included out of the box
- script template for new commands
- An included event runner singleton
- Several example events included
- Integration with the Godot Resource system

More are being worked on for future updates!

## Installation
To install the addon currently, download the repository as a zip file and copy the following folders to your project:
- `script-templates/`
- `addons/`

This will install all the required addon files alongside the script template for quickly creating new commands.

When version 2.0 is completed installation through the Godot AssetLib will be worked on, the addon is currently too early on to be published yet.

## Creating a new command
New commands are created through creating a GDScript file and extending the `EmventCommand` class. From there choose the provided script template and create the script. The resulting script will have all the fields and functions you need setup and ready to modify. Read the provided comments for more info on what goes where and how things should be formatted.

## How events are run
Event commands are run in a one event per game tic manner. A basic implementation of an event runner is shown below to demonstrate this better:
```gdscript
var event_data: Emvent
var ev_command_index = 0

func _process(_delta):
	process_event()

# This function is run every frame
func process_event() -> void:
	if event_command_index < event_data.commands.size():
		# a return of 0 indicates that this command should be processed again next frame
		# (i.e. a wait command or a command that is awaiting a signal to continue)
		if event_data.commands[event_command_index].execute_command() > 0:
			event_command_index += 1
```

The benefits of this system are that you can call for wait periods between dialog or animations without needing much extra logic, only needing to setup the command to not return greater than 0 until your timer ends.
