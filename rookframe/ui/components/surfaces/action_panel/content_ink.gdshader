shader_type canvas_item;
render_mode unshaded;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
float grain(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float pools(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(grain(i), grain(i + vec2(1, 0)), f.x),
		mix(grain(i + vec2(0, 1)), grain(i + vec2(1, 1)), f.x), f.y);
}
void fragment() {
	vec2 p = FRAGCOORD.xy;
	float field = pools(p * 0.075) * 0.66 + pools(p * 0.23) * 0.25 + pools(p * 0.74) * 0.09;
	float wet = progress * 1.25 - 0.12;
	COLOR.rgb *= mix(0.58, 1.0, smoothstep(field, field + 0.18, wet));
	COLOR.a *= smoothstep(field - 0.035, field + 0.035, wet);
}
