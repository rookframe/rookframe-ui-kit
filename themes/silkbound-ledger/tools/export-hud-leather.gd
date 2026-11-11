extends SceneTree
## Derives the display-density HUD leather atlas from the approved action-panel atlas.
## Run from the repository root:
##   godot --headless --script themes/silkbound-ledger/tools/export-hud-leather.gd
## The pieces are the regions already used by assets/action-panel/{body,hud_badge,
## hud_identity,connector}.tres, resampled once at the 0.4 leaf density so stock
## StyleBoxTexture nine-patches draw them 1:1. Regions printed here are the ones
## referenced by assets/action-panel/hud/*.tres; keep them in sync.

const SCALE := 0.4
const GUTTER := 4
const BODY := Rect2i(54, 104, 1054, 244)
const BADGE := Rect2i(1163, 104, 322, 200)
const IDENTITY := Rect2i(54, 412, 1088, 202)
const STRAP := Rect2i(1245, 429, 117, 139)
# The legacy connector renderer draws 20px straps 5px inside the left edge and
# 7px inside the right edge, starting 7px above the upper leaf's bottom.
const STRAP_SIZE := Vector2i(20, 24)
const STRAP_LEFT := 5
const STRAP_RIGHT := 7
const STRAP_RISE := 7


func _initialize() -> void:
	var root := (get_script() as Script).resource_path.get_base_dir().path_join("..")
	var folder := root.path_join("rookframe/ui/assets/action-panel")
	var source := Image.load_from_file(folder.path_join("ai-generated-leather-atlas.png"))
	source.convert(Image.FORMAT_RGBA8)
	var body := _piece(source, BODY)
	var badge := _piece(source, BADGE)
	var identity := _piece(source, IDENTITY)
	var strap := source.get_region(STRAP)
	strap.resize(STRAP_SIZE.x, STRAP_SIZE.y, Image.INTERPOLATE_LANCZOS)
	# The attached panel carries its own straps below its bottom edge.
	var overhang := STRAP_SIZE.y - STRAP_RISE
	var attached := Image.create_empty(body.get_width(), body.get_height() + overhang, false, Image.FORMAT_RGBA8)
	attached.blit_rect(body, Rect2i(Vector2i.ZERO, body.get_size()), Vector2i.ZERO)
	for x in [STRAP_LEFT, body.get_width() - STRAP_SIZE.x - STRAP_RIGHT]:
		attached.blend_rect(strap, Rect2i(Vector2i.ZERO, STRAP_SIZE), Vector2i(x, body.get_height() - STRAP_RISE))
	var pieces := {"body": body, "attached": attached, "identity": identity, "badge": badge}
	var width := 0
	var height := GUTTER
	for piece: Image in pieces.values():
		width = maxi(width, piece.get_width() + GUTTER * 2)
		height += piece.get_height() + GUTTER
	var atlas := Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	var y := GUTTER
	for name in pieces:
		var piece: Image = pieces[name]
		atlas.blit_rect(piece, Rect2i(Vector2i.ZERO, piece.get_size()), Vector2i(GUTTER, y))
		print("%s: Rect2(%d, %d, %d, %d)" % [name, GUTTER, y, piece.get_width(), piece.get_height()])
		y += piece.get_height() + GUTTER
	print("attached overhang: ", overhang)
	var target := folder.path_join("ai-generated-hud-leather-atlas.png")
	atlas.save_png(target)
	print("sha256: ", FileAccess.get_sha256(target))
	quit()


func _piece(source: Image, region: Rect2i) -> Image:
	var piece := source.get_region(region)
	piece.resize(roundi(region.size.x * SCALE), roundi(region.size.y * SCALE), Image.INTERPOLATE_LANCZOS)
	return piece
