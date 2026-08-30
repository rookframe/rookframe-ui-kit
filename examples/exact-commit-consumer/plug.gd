extends "res://addons/gd-plug/plug.gd"


func request_quit(exit_code := -1) -> bool:
	# gd-plug's asynchronous success signal omits the exit code on Godot 4.7.
	return super.request_quit(0 if exit_code == -1 else exit_code)


func _plugging() -> void:
	plug("rookframe/rookframe-ui-kit", {
		"commit": "1cb3b85f7cf26f95b8e187c0695b44494b18fea5",
		"include": ["rookframe/ui"],
	})
