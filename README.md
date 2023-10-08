# eMVent
An easily extendable, easy to use RPG Maker inspired event system for Godot.

**WARNING: This addon is currently in prerelease stage. Breaking changes are going to occur as features are fleshed out and added.**

Features:
- An easy to use event sheet editor that adapts to custom commands easily
- A 'one script one command' based extendable command system
- several non game specific commands included out of the box
- script template for new commands
- An included event runner singleton
- Several example events included

More are being worked on for future updates!

## Installation
To install the development version of the addon, download the repository as a zip file and copy the following folders to your project:
- `script_templates/`
- `addons/`

This will install all the required addon files alongside the script template for quickly creating new commands.

When version 2.0 is completed installation through the Godot AssetLib will be worked on, the addon is currently not functional enough to be released onto the asset library at this time, lacking a lot of functions I'd like to support.

## Creating a new command
New commands are created through creating a GDScript file and extending the `EmventCommand` class. From there choose the provided script template and create the script. The resulting script will have all the fields and functions you need setup and ready to modify. Read the provided comments for more info on what goes where and how things should be formatted.

## How events are run
Event commands are run in a one command per game tic manner. This provides a lot of benefits in that commands that wait on other operations can easily be programmed not to cease game operation. The way the event runner knows when to move on to the next command is by the return code of the command:

- `1` - proceed
- `0` - do not proceed

The built in Wait command is a good simple example of how to implement a command like this.


Certain commands, such as Comment or Label, have specific conditions programmed directly into the runner that allow them to be bypassed with 0 wasted frames. If one of these special commands are detected it will incremenet the command index until it reaches either a command not in it's list or the end of the event file. This should not in normal use cases cause any framerate issues.
