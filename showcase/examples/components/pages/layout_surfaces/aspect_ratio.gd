extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	for cropped in [false, true]:
		var body = page.section("Square crop" if cropped else "Widescreen fit", "Resize the gallery: the media remains inside its selected ratio.")
		var bounds := Demo.region(body, 220)
		var ratio := AspectRatioContainer.new()
		ratio.ratio = 1.0 if cropped else 16.0 / 9.0
		ratio.stretch_mode = AspectRatioContainer.STRETCH_FIT
		bounds.add_child(ratio)
		ratio.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var art := TextureRect.new()
		art.texture = load("res://rookframe/ui/icons/compass_rose.svg")
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if cropped else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.clip_contents = true
		art.accessibility_name = "Map preview, square crop" if cropped else "Map preview, widescreen fit"
		ratio.add_child(art)
