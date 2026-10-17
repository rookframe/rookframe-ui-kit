extends Control
## Presentation-only leather face. Authored controls remain in their original slots.
const MARGIN := Vector2(70, 50)
var leaf_size := Vector2.ONE
var angle := 174.0
var _skin: StyleBox
var _configured_size := Vector2.ZERO
var _last_progress := -1.0
@onready var source: SubViewport = $Source
@onready var motion: SubViewport = $Motion
@onready var camera: Camera3D = $Motion/Camera
@onready var hinge: Node3D = $Motion/Hinge
@onready var face: MeshInstance3D = $Motion/Hinge/Face

func _ready() -> void:
	face.material_override.albedo_texture = source.get_texture()
	$Clip/Image.texture = motion.get_texture()

func configure(rect: Rect2, skin: StyleBox) -> void:
	position = rect.position
	leaf_size = rect.size
	size = leaf_size
	if _configured_size == leaf_size and _skin == skin: return
	_configured_size = leaf_size
	_skin = skin
	_last_progress = -1.0
	var canvas := leaf_size + MARGIN * 2
	source.size = Vector2i(leaf_size * 2).max(Vector2i.ONE)
	$Source/Skin.size = leaf_size / 0.4
	$Source/Skin.add_theme_stylebox_override("panel", skin)
	source.render_target_update_mode = SubViewport.UPDATE_ONCE
	motion.size = Vector2i(canvas * 2).max(Vector2i.ONE)
	$Clip.position = Vector2(-MARGIN.x, 0)
	$Clip.size = leaf_size + Vector2(MARGIN.x * 2, MARGIN.y)
	$Clip/Image.position = Vector2(0, -MARGIN.y)
	$Clip/Image.size = canvas
	$Clip/Shadow.position = Vector2(0, -MARGIN.y)
	$Clip/Shadow.size = canvas
	camera.fov = rad_to_deg(2.0 * atan((canvas.y / 2.0) / 1200.0))
	hinge.position.y = leaf_size.y / 2.0
	face.mesh.size = leaf_size
	face.position.y = -leaf_size.y / 2.0
	$Motion/Hinge/Edge.mesh.size = Vector3(maxf(1, leaf_size.x - 3), maxf(1, leaf_size.y - 4), 1.4)
	$Motion/Hinge/Edge.position.y = -leaf_size.y / 2.0

func pose(progress: float) -> void:
	if is_equal_approx(progress, _last_progress): return
	_last_progress = progress
	# The positive rotation folds away from the camera, behind the support above.
	# Unlatch behind the header, accelerate down, then swing past vertical and settle.
	if progress < 0.16:
		angle = lerpf(174.0, 92.0, pow(progress / 0.16, 1.7))
	elif progress < 0.64:
		angle = lerpf(92.0, -14.0, pow((progress - 0.16) / 0.48, 1.65))
	elif progress < 0.82:
		angle = lerpf(-14.0, 5.0, smoothstep(0.64, 0.82, progress))
	else:
		angle = lerpf(5.0, 0.0, smoothstep(0.82, 1.0, progress))
	hinge.rotation_degrees.x = angle
	$Clip/Image.self_modulate.a = 1.0
	var exposure := (1.0 - smoothstep(65.0, 90.0, angle)) * (1.0 - smoothstep(0.82, 1.0, progress))
	$Clip/Shadow.visible = $Clip/Shadow.material != null and exposure > 0.001
	motion.render_target_update_mode = SubViewport.UPDATE_ONCE if progress == 0.0 else SubViewport.UPDATE_ALWAYS if progress < 1.0 else SubViewport.UPDATE_DISABLED
	if $Clip/Shadow.material == null: return
	# Same projected-corner shadow as the HUD; never a stationary rectangle.
	var corners := [Vector2.ZERO, Vector2(leaf_size.x, 0), leaf_size, Vector2(0, leaf_size.y)]
	for i in range(4):
		$Clip/Shadow.material.set_shader_parameter("corner_%d" % i, project(corners[i]) + MARGIN + Vector2(0, 4))
	$Clip/Shadow.material.set_shader_parameter("softness", 5.0 + absf(sin(deg_to_rad(angle))) * 10.0)
	$Clip/Shadow.material.set_shader_parameter("opacity", exposure * 0.32)

func project(point: Vector2) -> Vector2:
	return camera.unproject_position(hinge.to_global(Vector3(point.x - leaf_size.x / 2.0, -point.y, 1))) * 0.5 - MARGIN


func _enter_tree() -> void:
	preload("res://rookframe/ui/_internal/presentation/binding.gd").attach(self)
