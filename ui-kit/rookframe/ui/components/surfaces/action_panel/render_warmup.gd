extends SubViewport
## Draw once during tabletop loading: Compatibility compiles shaders on first use.
## The viewport is never displayed. Keep the warmed resources, stop all rendering.
var completed := false

func _ready() -> void:
	$Leaf.configure(Rect2(0, 0, 128, 64), preload("res://rookframe/ui/assets/action-panel/body.tres"))
	$Leaf.pose(0.4)
	for i in range(3): await RenderingServer.frame_post_draw
	$Leaf.motion.render_target_update_mode = SubViewport.UPDATE_DISABLED
	$Leaf.source.render_target_update_mode = SubViewport.UPDATE_DISABLED
	render_target_update_mode = SubViewport.UPDATE_DISABLED
	completed = true
