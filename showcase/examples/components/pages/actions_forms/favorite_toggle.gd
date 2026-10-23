extends RefCounted

const SCENE := "res://rookframe/ui/components/forms/favorite_toggle.tscn"

static func build(page) -> void:
	var main = page.section("Favorite entries", "A native CheckBox with no visible text. The caller names each toggle and keeps favorites.")
	var status = page.note(main, "No favorites changed.")
	for entry in ["Zweihänder", "Field journal", "Lantern"]:
		var row := HBoxContainer.new()
		main.add_child(row)
		var toggle = page.scene(SCENE, row, {"accessibility_name": "Favorite: " + entry, "tooltip_text": "Favorite: " + entry, "button_pressed": entry == "Lantern"})
		page.note(row, entry)
		toggle.toggled.connect(func(on: bool): status.text = ("Added " if on else "Removed ") + entry)
	var unavailable = page.section("Disabled", "Unavailable favorites keep their checked and unchecked states.")
	var row = page.flow(unavailable)
	for checked in [false, true]:
		page.scene(SCENE, row, {"accessibility_name": "Favorite unavailable", "tooltip_text": "Favorite unavailable", "button_pressed": checked, "disabled": true})
