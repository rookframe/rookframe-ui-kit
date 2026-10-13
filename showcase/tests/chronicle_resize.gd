extends SceneTree
## Render regression: growing a Chronicle must not stretch its rolls or grain.
## Run with a graphical renderer: godot --path . --script tests/chronicle_resize.gd
const Fantasy = preload("res://rookframe/ui/menu/MenuTheme.tres")
const Surface = preload("res://rookframe/ui/chronicle/ChronicleSurface.tscn")
var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("verify")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)


func verify() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Chronicle pixel checks require a graphical renderer.")
		quit(1)
		return
	var viewport := SubViewport.new()
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var panel := Surface.instantiate()
	panel.theme = Fantasy
	viewport.add_child(panel)
	for compact in [false, true]:
		panel.theme_type_variation = &"chronicle_surface__compact" if compact else &"chronicle_surface"
		for width in [320, 640]:
			var reference: Image
			for height in [452, 613, 1403, 224 if compact else 240]:
				viewport.size = Vector2i(width, height)
				panel.size = Vector2(width, height)
				for frame in range(3):
					await process_frame
				RenderingServer.force_draw(false)
				var rendered := viewport.get_texture().get_image()
				check(panel.size == Vector2(width, height), "Surface ignored its requested size")
				if reference == null:
					reference = rendered
				else:
					check(_same_region(reference, rendered, Rect2i(0, 0, width, 96), Vector2i.ZERO), "Top roll changed with height")
					check(_same_region(reference, rendered, Rect2i(0, 356, width, 96), Vector2i(0, height - 96)), "Bottom roll changed with height")
					if height > 452:
						check(_same_region(reference, rendered, Rect2i(0, 160, width, 48), Vector2i(0, 160)), "Paper grain or edge wear stretched with height")
				for y in range(96, height - 96):
					check(rendered.get_pixel(width / 2, y).a > 0.98, "Transparent seam crossed the reading field at row %d" % y)
	viewport.queue_free()
	await process_frame
	print("CHRONICLE_RESIZE ", "PASS" if failures.is_empty() else failures)
	quit(0 if failures.is_empty() else 1)


func _same_region(reference: Image, rendered: Image, region: Rect2i, destination: Vector2i) -> bool:
	return reference.get_region(region).get_data() == rendered.get_region(Rect2i(destination, region.size)).get_data()
