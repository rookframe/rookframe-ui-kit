extends SubViewport
## Draw once during tabletop loading: Compatibility compiles shaders on first use.
## The viewport is never displayed. Keep the warmed resources, stop all rendering.
var completed := false
@export var surface: StyleBox

func _ready() -> void:
	if surface == null:
		completed = true
		return
	$Leaf.configure(Rect2(0, 0, 128, 64), surface)
	$Leaf.pose(0.4)
	for i in range(3): await RenderingServer.frame_post_draw
	$Leaf.motion.render_target_update_mode = SubViewport.UPDATE_DISABLED
	$Leaf.source.render_target_update_mode = SubViewport.UPDATE_DISABLED
	render_target_update_mode = SubViewport.UPDATE_DISABLED
	completed = true
