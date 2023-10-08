extends RefCounted

var version = {
	"major": 2,
	"minor": 0,
	"patch": 0
}

func get_version_string() -> String:
	return "Emvent v{major}.{minor}.{patch}".format(version)
