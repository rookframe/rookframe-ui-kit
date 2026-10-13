extends SceneTree
## Bake exported glyphs into stock FontFile resources. No runtime generator.
const FONT_ROOT := "res://rookframe/ui/assets/fonts/eb-garamond/"

func _initialize() -> void:
	var arguments := OS.get_cmdline_user_args()
	assert(arguments.size() == 2)
	var source_directory := arguments[0]
	var output_directory := arguments[1]
	DirAccess.make_dir_recursive_absolute(output_directory)
	var profiles: Array = JSON.parse_string(FileAccess.get_file_as_string(source_directory.path_join("profiles.json")))
	for profile in profiles:
		var font_file := FontFile.new()
		assert(font_file.load_dynamic_font(FONT_ROOT + profile.source) == OK)
		font_file.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
		font_file.hinting = TextServer.HINTING_NONE
		for weight in profile.weights:
			var font := FontVariation.new()
			font.base_font = font_file
			font.variation_opentype = {2003265652: float(weight)}
			font.get_string_size("Ag", HORIZONTAL_ALIGNMENT_LEFT, -1, 20)
			var cache := -1
			for index in range(font_file.get_cache_count()):
				if font_file.get_variation_coordinates(index).get(2003265652, 400.0) == float(weight):
					cache = index
			assert(cache >= 0)
			for size in profile.sizes:
				font.get_string_size("Ag", HORIZONTAL_ALIGNMENT_LEFT, -1, int(size))
				var key := Vector2i(int(size), 0)
				# Preserve the source face metrics and shaping data.
				font_file.clear_glyphs(cache, key)
				font_file.clear_textures(cache, key)
				var prefix := source_directory.path_join(profile.name + "-" + str(int(weight)) + "-" + str(int(size)))
				var records: Array = JSON.parse_string(FileAccess.get_file_as_string(prefix + ".json"))
				var page := 0
				while FileAccess.file_exists(prefix + "-" + str(page) + ".png"):
					var bitmap := Image.load_from_file(prefix + "-" + str(page) + ".png")
					bitmap.convert(Image.FORMAT_LA8)
					font_file.set_texture_image(cache, key, page, bitmap)
					# Occupied shelves protect cached pages when the original
					# dynamic font rasterizes an uncached character later.
					font_file.set_texture_offsets(cache, key, page, PackedInt32Array([bitmap.get_width(), 0, 0, bitmap.get_height()]))
					page += 1
				for glyph in records:
					var id := int(glyph.glyph)
					font_file.set_glyph_advance(cache, int(size), id, Vector2(glyph.advance, size))
					font_file.set_glyph_texture_idx(cache, key, id, int(glyph.page))
					font_file.set_glyph_uv_rect(cache, key, id, Rect2(glyph.x, glyph.y, glyph.width, glyph.height))
					font_file.set_glyph_size(cache, key, id, Vector2(glyph.width, glyph.height))
					font_file.set_glyph_offset(cache, key, id, Vector2(-glyph.left, -glyph.top))
		var output := output_directory.path_join(profile.name + ".res")
		assert(ResourceSaver.save(font_file, output, ResourceSaver.FLAG_COMPRESS) == OK)
		print(output, ": ", FileAccess.open(output, FileAccess.READ).get_length(), " bytes")
	quit()
