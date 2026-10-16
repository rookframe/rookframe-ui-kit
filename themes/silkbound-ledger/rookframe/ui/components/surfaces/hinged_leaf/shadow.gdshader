shader_type canvas_item;
render_mode unshaded;

uniform vec2 corner_0;
uniform vec2 corner_1;
uniform vec2 corner_2;
uniform vec2 corner_3;
uniform float softness = 4.0;
uniform float opacity = 0.0;
varying vec2 local_position;

void vertex() {
	local_position = VERTEX;
}

float outside_edge(vec2 point, vec2 start, vec2 end) {
	vec2 edge = end - start;
	vec2 offset = point - start;
	return (edge.y * offset.x - edge.x * offset.y) / max(length(edge), 0.001);
}

void fragment() {
	float distance_to_edge = max(
		max(outside_edge(local_position, corner_0, corner_1), outside_edge(local_position, corner_1, corner_2)),
		max(outside_edge(local_position, corner_2, corner_3), outside_edge(local_position, corner_3, corner_0)));
	float coverage = 1.0 - smoothstep(-softness, softness, distance_to_edge);
	COLOR = vec4(vec3(0.0), COLOR.a * opacity * coverage);
}
