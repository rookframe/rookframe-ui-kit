@tool
extends StyleBox
## The original menu cap layers rendered as one native Button style.
## No additional content, input Controls or accessibility nodes are needed.
var face: StyleBoxFlat
var shadow := StyleBoxTexture.new()
var depth := StyleBoxTexture.new()
var surface := StyleBoxTexture.new()
var adornment: Texture2D
var cap_depth: float
## Optional: above this cap height the rails stretch instead of the rim growing.
var art_height := 0.0
var shadow_drop: float
var ornament_size: Vector2
var ornament_travel: float
var reveal := 0.0
var tint := Color.WHITE

func configure(control: Button) -> void:
	for layer in [shadow, depth, surface]:
		layer.texture = control.get_theme_icon("cap")
		for side in [SIDE_LEFT, SIDE_RIGHT]:
			layer.set_texture_margin(side, control.get_theme_constant("patch_side"))
		for side in [SIDE_TOP, SIDE_BOTTOM]:
			layer.set_texture_margin(side, control.get_theme_constant("patch_rail"))
	shadow.modulate_color = control.get_theme_color("shadow_tint")
	depth.modulate_color = control.get_theme_color("edge_tint")
	adornment = control.get_theme_icon("adornment")
	cap_depth = control.get_theme_constant("cap_depth")
	art_height = control.get_theme_constant("art_height")
	shadow_drop = control.get_theme_constant("shadow_drop")
	ornament_size = Vector2(control.get_theme_constant("ornament_width"), control.get_theme_constant("ornament_height"))
	ornament_travel = control.get_theme_constant("ornament_travel")
	sync_margins()

func sync_margins() -> void:
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		var clearance := ornament_travel if side in [SIDE_LEFT, SIDE_RIGHT] and ornament_size.x > 0 else 0.0
		set_content_margin(side, face.get_margin(side) + clearance)
	surface.modulate_color = tint

func _draw(canvas: RID, rect: Rect2) -> void:
	# Generic action rows have no menu-specific outer margins. Keep the moving
	# finials inside this Button's allocation so adjacent actions cannot overlap.
	if ornament_size.x > 0:
		rect = rect.grow_individual(-ornament_travel, 0, -ornament_travel, 0)
	var cap_height := maxf(1, rect.size.y - cap_depth)
	var art_scale := cap_height / surface.texture.get_height()
	var natural_size := Vector2(rect.size.x / art_scale, surface.texture.get_height())
	if art_height > 0 and cap_height > art_height:
		# Tall tiles keep the casing's rim width; the nine-patch rails take the height.
		art_scale = art_height / surface.texture.get_height()
		natural_size = rect.size / art_scale
		natural_size.y = cap_height / art_scale
	# Scale the nine-patch as a whole, preserving the original end fittings.
	_draw_cap(canvas, shadow, rect.position + Vector2(0, shadow_drop), natural_size, art_scale)
	if reveal > 0 and ornament_size.x > 0:
		var extension := ornament_travel * reveal
		var y := (cap_height - ornament_size.y) / 2 - face.expand_margin_top
		adornment.draw_rect(canvas, Rect2(rect.position + Vector2(-extension, y), ornament_size), false, tint)
		adornment.draw_rect(canvas, Rect2(rect.position + Vector2(rect.size.x - ornament_size.x + extension, y), Vector2(-ornament_size.x, ornament_size.y)), false, tint)
	_draw_cap(canvas, depth, rect.position + Vector2(0, cap_depth), natural_size, art_scale)
	_draw_cap(canvas, surface, rect.position + Vector2(0, -face.expand_margin_top), natural_size, art_scale)

func _draw_cap(canvas: RID, layer: StyleBoxTexture, origin: Vector2, dimensions: Vector2, art_scale: float) -> void:
	RenderingServer.canvas_item_add_set_transform(canvas, Transform2D(0, Vector2.ONE * art_scale, 0, origin))
	layer.draw(canvas, Rect2(Vector2.ZERO, dimensions))
	RenderingServer.canvas_item_add_set_transform(canvas, Transform2D.IDENTITY)

func _get_draw_rect(rect: Rect2) -> Rect2:
	return rect.grow_individual(0, 0, 0, shadow_drop)
