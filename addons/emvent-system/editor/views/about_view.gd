@tool
extends Panel

const AUTHORS = "res://addons/emvent-system/AUTHORS.txt"
const LICENSE = "res://addons/emvent-system/LICENSE.txt"

func _ready():
	# TODO: Move this to another place
	%Version.text = %Version.text.format({"v": "v1.0"})
	
	_populate_authors()
	_populate_license()

func _on_close_pressed() -> void:
	get_parent().close_requested.emit()

func _populate_authors() -> void:
	for child in %AuthorList.get_children():
		child.queue_free()
	
	var author_data: FileAccess = FileAccess.open(AUTHORS, FileAccess.READ)
	
	while not author_data.eof_reached():
		var line = author_data.get_line()
		
		var AuthorLabel = Label.new()
		AuthorLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		AuthorLabel.text = line
		
		%AuthorList.add_child(AuthorLabel)
	author_data.close()

func _populate_license() -> void:
	var license_data: FileAccess = FileAccess.open(LICENSE, FileAccess.READ)
	
	%LicenseText.clear()
	%LicenseText.push_mono()
	%LicenseText.append_text(license_data.get_as_text())
	%LicenseText.pop()
	
	license_data.close()
