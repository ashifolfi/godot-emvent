@tool
extends AcceptDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ok_button_text = "Save"
	confirmed.connect(_on_ok_pressed)
	
	add_button("Don't Save", true, "nosave")
	add_cancel_button("Cancel")
	
	# connect to our _on_custom_action so that we can hide on any button press
	custom_action.connect(_on_custom_action)
	
	dialog_text = "You have unsaved changes.\nWould you like to save them?"
	title = "Unsaved Changes"

# really stupid but this allows us to have 2 buttons that share a ton of code do their thing
func _on_ok_pressed() -> void:
	custom_action.emit("save")

func _on_custom_action(action: StringName) -> void:
	hide()
