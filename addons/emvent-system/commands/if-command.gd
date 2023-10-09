@tool
class_name IfEventCommand
extends EmventCommand

@export var condition: String = ""

func _init():
	cmd_name = "If"
	cmd_description = "To be paired with an accompanying Else/EndIf Command, If evaluates a condition and executes or jumps depending on the output"
	cmd_category = "Flow Control"

# used by the event editor to know what properties to display
func get_properties():
	return [
		["condition", "String"]
	]

func execute_command():
	# y'know I'd love to use expression but it literally doesn't work here
	# so we're using a full ass gdscript refcounted object :]
	var script: GDScript = GDScript.new()
	script.source_code = "func eval(): \n" +"	return (" + condition + ")"
	script.reload()
	var ref = RefCounted.new()
	ref.set_script(script)

	if ref.eval():
		return 1 # continue execution normally,
		# notifying the runner to skip any code coming after an else if an EndIf hasn't been hit
	else:
		return 2 # tells the runner to look for an EndIf or Else before continuing execution

