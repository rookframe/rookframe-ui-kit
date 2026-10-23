extends RefCounted
## In-place material choice beside an edited object, plus the bare ArcTrack.

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")
const Action = preload("res://rookframe/ui/components/actions/button.gd")
const ICONS := "res://rookframe/ui/icons/"
const CATEGORIES := [
	["favorites", "Favourites", "sigil"], ["masonry", "Masonry", "layers"],
	["timber", "Timber", "character/staff"], ["ground", "Ground", "world"], ["empty", "Thatch", "home"],
]
# id, title, categories, base colour, tile (rendered 3D) or flat swatch.
const MATERIALS := [
	["slate", "Slate", ["favorites", "masonry"], Color(0.24, 0.26, 0.3), true],
	["yellow_brick", "Yellow brick", ["favorites", "masonry"], Color(0.78, 0.66, 0.42), false],
	["rubble", "Rubble wall", ["masonry"], Color(0.42, 0.4, 0.37), false],
	["ashlar", "Ashlar", ["masonry"], Color(0.62, 0.6, 0.55), true],
	["cobble", "Cobble", ["masonry", "ground"], Color(0.55, 0.56, 0.5), false],
	["plaster", "Lime plaster", ["masonry"], Color(0.86, 0.84, 0.78), false],
	["oak", "Oak boards", ["favorites", "timber"], Color(0.45, 0.28, 0.16), true],
	["walnut", "Walnut beam", ["timber"], Color(0.3, 0.19, 0.12), true],
	["pine", "Pine planks", ["timber"], Color(0.7, 0.53, 0.32), false],
	["mud", "Packed earth", ["ground"], Color(0.38, 0.3, 0.22), false],
	["grass", "Turf", ["ground"], Color(0.3, 0.42, 0.22), true],
	["flag", "Flagstone", ["ground"], Color(0.5, 0.5, 0.47), true],
	["sand", "Sand", ["ground"], Color(0.8, 0.72, 0.52), false],
	["gravel", "Gravel", ["ground"], Color(0.47, 0.45, 0.42), false],
	["moss", "Mossy stone", ["ground"], Color(0.34, 0.4, 0.3), false],
	["paint", "Plain paint", ["favorites"], Color(0.36, 0.32, 0.29), false],
]

static func build(page) -> void:
	var previews := _previews(page)
	_picker(page, previews)
	_track(page)

static func _picker(page, previews: Dictionary) -> void:
	var body = page.section("Material picker", "Click the scene to open the picker there. Categories sit on the inner track and materials on the outer one; flat swatches and rendered tiles share the track. Arrow keys move along and between tracks, the wheel scrolls, Escape or a click outside closes. Near an edge the rings mirror and shift to stay on screen.")
	var stage := Demo.region(body, 640)
	stage.mouse_filter = Control.MOUSE_FILTER_STOP
	stage.clip_contents = true
	var ground := ColorRect.new()
	# A stand-in for the game scene behind the HUD.
	ground.color = Color(0.29, 0.36, 0.24)
	ground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ground.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage.add_child(ground)
	var status = page.note(body, "No picker signal yet.")
	var picker = Demo.component(page, "components/navigation/arc_picker.tscn", stage, {"reduced_motion": page.reduced_motion})
	var categories: Array[Dictionary] = []
	for row in CATEGORIES:
		categories.append({"id": row[0], "title": row[1], "icon": load(ICONS + row[2] + ".svg")})
	var entries: Array[Dictionary] = []
	for row in MATERIALS:
		entries.append({"id": row[0], "title": row[1], "categories": row[2], "preview": previews[row[0]], "disabled": row[0] == "sand", "tone": row[3].darkened(0.35)})
	picker.configure(categories, entries, "yellow_brick", {"empty": "No thatch materials yet"})
	picker.category_changed.connect(func(id: String): status.text = "category_changed: " + id)
	picker.highlight_changed.connect(func(entry: Dictionary): status.text = "highlight_changed: " + entry.get("title", "(none)"))
	picker.choose_requested.connect(func(entry: Dictionary):
		status.text = "choose_requested: " + entry.title
		ground.color = entry.get("tone", ground.color))
	picker.cancel_requested.connect(func(): status.text = "cancel_requested")
	stage.gui_input.connect(func(event: InputEvent):
		var press := event as InputEventMouseButton
		if press != null and press.pressed and press.button_index == MOUSE_BUTTON_LEFT and not picker.is_open():
			picker.open_at(press.position))
	var open := func(): picker.open_at(stage.size * Vector2(0.5, 0.62))
	stage.resized.connect(func(): open.call_deferred(), CONNECT_ONE_SHOT)
	var actions = page.flow(body)
	page.button(actions, "Open centred", open)
	page.button(actions, "Open at top-right", func(): picker.open_at(Vector2(stage.size.x - 24, 24)))
	page.button(actions, "Close", func(): picker.close())

static func _track(page) -> void:
	var body = page.section("Arc track", "The layout-only track with ordinary stacked Buttons. Eight entries overflow the sweep: arrowheads mark the scrollable ends, and the wheel or Left/Right scroll.")
	var stage := Demo.region(body, 260)
	var rail = Demo.component(page, "components/navigation/arc_track.tscn", stage, {
		"pivot": Vector2(260, 250), "radius": 200.0, "start_angle": 200.0, "end_angle": 300.0, "spacing": 10.0,
	})
	var status = page.note(body, "First entry: 0")
	rail.scrolled.connect(func(first: int): status.text = "First entry: %d" % first)
	for icon in ["bolt", "swords", "sigil", "pack", "list", "people", "shield", "dice"]:
		Demo.component(page, "components/actions/button.tscn", rail, {
			"icon": load(ICONS + icon + ".svg"), "accessibility_name": icon.capitalize(), "tooltip_text": icon.capitalize(),
		})

# Hosts supply previews; flat ones are textures, tiles are rendered from a mesh.
static func _previews(page) -> Dictionary:
	var result := {}
	for row in MATERIALS:
		var swatch := NoiseTexture2D.new()
		swatch.width = 128
		swatch.height = 128
		swatch.seamless = true
		var noise := FastNoiseLite.new()
		noise.seed = hash(row[0])
		noise.frequency = 0.05 if row[4] else 0.09
		noise.fractal_octaves = 3
		swatch.noise = noise
		var ramp := Gradient.new()
		ramp.set_color(0, row[3].darkened(0.4))
		ramp.set_color(1, row[3].lightened(0.25))
		swatch.color_ramp = ramp
		result[row[0]] = _tile(page, swatch) if row[4] else swatch
	return result

static func _tile(page, surface: Texture2D) -> Texture2D:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(128, 128)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	var slab := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.0, 0.1, 1.0)
	var material := StandardMaterial3D.new()
	material.albedo_texture = surface
	mesh.material = material
	slab.mesh = mesh
	slab.rotation_degrees.y = 45.0
	viewport.add_child(slab)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, 30, 0)
	viewport.add_child(light)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 1.6
	camera.position = Vector3(0, 1.2, 1.2)
	camera.rotation_degrees.x = -45.0
	viewport.add_child(camera)
	page.add_child(viewport)
	# Rerender once the noise has generated.
	surface.changed.connect(func(): viewport.render_target_update_mode = SubViewport.UPDATE_ONCE)
	return viewport.get_texture()
