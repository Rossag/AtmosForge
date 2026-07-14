shader_type canvas_item;
render_mode unshaded;

uniform vec4 steam_color : source_color = vec4(0.85, 0.9, 1.0, 1.0);

uniform float speed : hint_range(0.0, 3.0) = 0.25;
uniform float density : hint_range(1.0, 8.0) = 2.0;
uniform float strength : hint_range(0.0, 1.0) = 0.12;
uniform float sway : hint_range(0.0, 1.0) = 0.18;
uniform float softness : hint_range(0.01, 0.5) = 0.16;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);

	f = f * f * (3.0 - 2.0 * f);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	return mix(
		mix(a, b, f.x),
		mix(c, d, f.x),
		f.y
	);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;

	for (int i = 0; i < 4; i++) {
		value += noise(p) * amplitude;
		p *= 2.0;
		amplitude *= 0.5;
	}

	return value;
}

void fragment() {
	vec2 uv = UV;

	// Move upward.
	float rising_y = uv.y + TIME * speed;

	// Gentle side-to-side movement.
	float horizontal_sway =
		sin(rising_y * 7.0 + TIME * 0.7) * sway;

	vec2 steam_uv = vec2(
		uv.x + horizontal_sway,
		rising_y
	);

	float cloud = fbm(steam_uv * vec2(density, density * 1.4));

	// Keep steam concentrated near the centre.
	float centre_mask = 1.0 - smoothstep(
		0.08,
		0.5,
		abs(uv.x - 0.5)
	);

	// Fade out toward the top.
	float top_fade = smoothstep(0.0, 0.25, uv.y);

	// Fade near the sides and create soft wisps.
	float steam_shape = smoothstep(
		0.48 - softness,
		0.48 + softness,
		cloud
	);

	float alpha =
		steam_shape *
		centre_mask *
		top_fade *
		strength;

	COLOR = vec4(
		steam_color.rgb,
		alpha * steam_color.a
	);
}