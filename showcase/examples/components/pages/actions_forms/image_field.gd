extends RefCounted

static func build(page) -> void:
	var main = page.section("Replace a preview", "Replace cycles between bundled preview icons; no files are opened or stored.")
	var field = page.scene("res://rookframe/ui/components/forms/image_field.tscn", main, {"title": "Character portrait", "help_text": "Choose an image that clearly identifies this character.", "change_label": "Choose preview"})
	var status = page.note(main, "No preview selected.")
	var state := {"index": 0}
	field.replace_requested.connect(func():
		var names := ["person", "shield", "sigil"]
		var name: String = names[state.index % names.size()]
		field.set_preview(load("res://rookframe/ui/icons/" + name + ".svg"))
		field.set_error("")
		state.index += 1
		status.text = "Preview changed to " + name + "."
	)
	var controls = page.flow(main)
	page.button(controls, "Clear preview", func(): field.set_preview(null); status.text = "Preview removed.")
	page.button(controls, "Show admission error", func(): field.set_error("The image could not be admitted. Choose another preview."))
	var locked = page.section("Locked preview", "A disabled image field preserves its preview and supporting copy.")
	page.scene("res://rookframe/ui/components/forms/image_field.tscn", locked, {"title": "Campaign emblem", "preview": load("res://rookframe/ui/icons/shield.svg"), "help_text": "Only the campaign owner can replace this emblem.", "disabled": true})
