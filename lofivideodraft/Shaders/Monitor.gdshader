shader_type canvas_item;
render_mode unshaded;

uniform vec4 color_a : source_color = vec4(0.02, 0.08, 0.16, 1.0);
uniform vec4 color_b : source_color = vec4(0.20, 0.05, 0.32, 1.0);

uniform float speed : hint_range(0.0, 2.0) = 0.18;
uniform float glow_strength : hint_range(0.0, 1.0) = 0.35;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;

	float wave_a = sin((uv.x + TIME * speed) * 4.0);
	float wave_b = cos((uv.y - TIME * speed * 0.7) * 3.0);

	float blend = 0.5 + 0.25 * wave_a + 0.25 * wave_b;
	blend = clamp(blend, 0.0, 1.0);

	vec3 base = mix(color_a.rgb, color_b.rgb, blend);

	vec2 centre = vec2(0.5);
	float distance_from_centre = distance(uv, centre);
	float glow = 1.0 - smoothstep(0.15, 0.75, distance_from_centre);

	float noise = hash(floor(uv * 40.0));
	float sparkle = step(0.985, noise);
	sparkle *= 0.35 + 0.25 * sin(TIME * 0.8 + noise * 10.0);

	vec3 final_color = base;
	final_color += glow * glow_strength * vec3(0.08, 0.12, 0.22);
	final_color += sparkle * vec3(0.12, 0.18, 0.28);

	COLOR = vec4(final_color, 1.0);
}