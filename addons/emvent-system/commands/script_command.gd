@tool
class_name ScriptEventCommand extends EmventCommand

# Place your parameters here formatted like so
@export var expression: String = ""

func _init():
	cmd_name = "Script"
	cmd_description = "Runs the provided GDScript code in a barebones script object."
	cmd_category = "Utility"

# used by the event editor to know what properties to display
func get_properties():
	return [
		["expression", "MultilineString"]
	]

func execute_command():
	var script: GDScript = GDScript.new()
	script.source_code = "func eval(): \n" + expression.indent("	")
	script.reload()
	var ref = RefCounted.new()
	ref.set_script(script)
	ref.eval()
	
	return 1
