extends Node2D

# Test script for an event runner
var state: int = 0

@onready var label_status: Label = $Control/VBoxContainer/HBoxContainer/StatusMessage
@onready var label_filepath: Label = $Control/VBoxContainer/HBoxContainer2/FilePath
@onready var label_log: RichTextLabel = $Control/VBoxContainer/Panel/RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	state = 0
	
	$Control/ErrorBox.confirmed.connect(_on_open_button_pressed)
	$Control/ErrorBox.close_requested.connect(_on_open_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		0:
			label_status.text = "No Event"
			$Control/VBoxContainer/OpenButton.disabled = false
		1:
			label_status.text = "Running Event"
			$Control/VBoxContainer/OpenButton.disabled = true
			
			if !EmventSystem.is_running():
				state = 2
		2:
			label_status.text = "Finished Event"
			$Control/VBoxContainer/OpenButton.disabled = false


func show_error(message):
	$Control/ErrorBox.dialog_text = message
	$Control/ErrorBox.popup_centered()

func _on_open_button_pressed():
	$Control/FileDialog.popup_centered()

func _on_file_dialog_file_selected(path):
	var res_data = load(path)
	
	if res_data is Emvent:
		label_filepath.text = path
		EmventSystem.run_event(load(path))
		state = 1
	else:
		show_error("Couldn't load the file.\nNot an Emvnt Event type Resource.")
