extends "res://addons/gd-plug/plug.gd"

func _plugging() -> void:
	# GdUnit4 v6.2.1 is development-only and is never installed by Kit consumers.
	plug("godot-gdunit-labs/gdUnit4", {"commit": "08ffc7c65b61b1b2edd545616061a99973c13ce1", "include": ["addons/gdUnit4"]})
