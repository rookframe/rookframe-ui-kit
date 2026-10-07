extends SceneTree
## Run in a fresh process after regeneration to verify saved font resources.
const FONT_ROOT := "res://rookframe/ui/assets/fonts/eb-garamond/"

func _initialize() -> void:
	var profiles: Array = JSON.parse_string(FileAccess.get_file_as_string("res://tools/silkbound-fonts/profiles.json"))
	for profile in profiles:
		var font_file: FontFile = load(FONT_ROOT + "prerendered/" + profile.name + ".res")
		assert(font_file.data == FileAccess.get_file_as_bytes(FONT_ROOT + profile.source))
		for weight in profile.weights:
			var font := FontVariation.new()
			font.base_font = font_file
			font.variation_opentype = {2003265652: float(weight)}
			var original := FontVariation.new()
			var dynamic := FontFile.new()
			assert(dynamic.load_dynamic_font(FONT_ROOT + profile.source) == OK)
			dynamic.hinting = TextServer.HINTING_NONE
			dynamic.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
			original.base_font = dynamic
			original.variation_opentype = {2003265652: float(weight)}
			for size in [14, 23, 40, 46]:
				var cache := -1
				for index in range(font_file.get_cache_count()):
					if font_file.get_variation_coordinates(index).get(2003265652, 400.0) == float(weight):
						cache = index
				assert(cache >= 0)
				var key := Vector2i(size, 0)
				var before: Array[PackedByteArray] = []
				for index in range(font_file.get_texture_count(cache, key)):
					before.append(font_file.get_texture_image(cache, key, index).get_data())
				# Greek and Japanese exercise characters outside the prerendered
				# set; 46 exercises an uncached size. Original shaping stays native.
				var words := "Seth / Омерзительный мертвец / office / Αθηνά / 日本語"
				var measured := font.get_string_size(words, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
				var expected := original.get_string_size(words, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
				assert(absf(measured.x - expected.x) <= 1.0)
				for index in range(before.size()):
					assert(before[index] == font_file.get_texture_image(cache, key, index).get_data())
		print("PASS ", profile.name, ": original data, shaping, fallback and atlas preservation")
	quit()
