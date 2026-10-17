extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	for images_only in [true, false]:
		var section = page.section("Image files" if images_only else "Project files", "Selection displays the chosen path here; this preview does not load or change files.")
		var status = page.note(section, "No file selected.")
		var picker = page.scene(Demo.path("overlays/file_picker_dialog"), page, {"heading": "Choose a preview image" if images_only else "Browse project files", "description": "Select a file to inspect its path.", "initial_directory": "res://rookframe/ui/icons/", "allowed_extensions": PackedStringArray(["svg", "png"]) if images_only else PackedStringArray()})
		picker.file_selected.connect(func(path: String): status.text = "Selected: " + path)
		picker.cancelled.connect(func(): status.text = "File selection cancelled.")
		page.button(section, "Choose image" if images_only else "Browse files", func(): picker.open_picker())
