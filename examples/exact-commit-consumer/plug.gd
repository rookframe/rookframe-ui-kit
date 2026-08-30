extends "res://addons/gd-plug/plug.gd"


func request_quit(exit_code := -1) -> bool:
	# gd-plug's asynchronous success signal omits the exit code on Godot 4.7.
	return super.request_quit(0 if exit_code == -1 else exit_code)


func _plugging() -> void:
	plug("rookframe/rookframe-ui-kit", {
		"commit": "5f4ccbfaff195c59f8385582ca57c8020ea77164",
		"include": ["rookframe/ui"],
	})
