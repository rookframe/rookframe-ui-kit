shader_type canvas_item;
uniform float top_offset = 0.0;
uniform float strip_height = 20.0;
void vertex() {
	// Keep the lower attachment level while the leather follows the raised leaf.
	float along = clamp(VERTEX.y / max(strip_height, 1.0), 0.0, 1.0);
	VERTEX.x += top_offset * (1.0 - along);
}
