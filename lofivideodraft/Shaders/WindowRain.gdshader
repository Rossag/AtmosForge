shader_type canvas_item;
render_mode unshaded;

uniform vec4 rain_color : source_color = vec4(0.65, 0.78, 1.0, 1.0);

uniform float intensity : hint_range(0.0, 2.0) = 1.32;
uniform float speed : hint_range(1.0, 6.0) = 3.75;
uniform float density : hint_range(4.0, 80.0) = 50.0;
uniform float slant : hint_range(-0.5, 0.5) = 0.08;

uniform float streak_width : hint_range(0.005, 0.15) = 0.025;
uniform float streak_length : hint_range(0.02, 0.8) = 0.28;


float hash(float value) {
	return fract(sin(value * 127.1) * 43758.5453123);
}


float rain_layer(
	vec2 uv,
	float layer_density,
	float layer_speed,
	float seed
) {
	// Slant the rain slightly.
	uv.x += uv.y * slant;

	// Divide the area into vertical rain columns.
	vec2 grid_uv = uv * vec2(layer_density, layer_density * 0.55);

	float column = floor(grid_uv.x);
	float column_random = hash(column + seed);

	// Move each column down at a slightly different speed.
	grid_uv.y -= TIME * layer_speed * (0.75 + column_random * 0.5);
	grid_uv.y += column_random * 20.0;

	float row = floor(grid_uv.y);
	vec2 cell_uv = fract(grid_uv);

	// Give each streak a slightly different horizontal position.
	float streak_position = hash(
		column * 19.17 +
		row * 7.13 +
		seed
	);

	streak_position = mix(0.15, 0.85, streak_position);

	float horizontal_distance = abs(cell_uv.x - streak_position);

	// Thin vertical line.
	float streak = 1.0 - smoothstep(
		streak_width,
		streak_width * 2.2,
		horizontal_distance
	);

	// Fade the streak along its length.
	float trail = 1.0 - smoothstep(
		0.0,
		streak_length,
		cell_uv.y
	);

	// Remove some drops so the pattern is less uniform.
	float visibility = step(
		0.34,
		hash(column * 5.71 + row * 11.93 + seed)
	);

	return streak * trail * visibility;
}


void fragment() {
	vec2 uv = UV;

	float distant_rain = rain_layer(
		uv,
		density * 0.65,
		speed * 0.75,
		3.0
	);

	float middle_rain = rain_layer(
		uv + vec2(0.17, 0.0),
		density,
		speed,
		17.0
	);

	float close_rain = rain_layer(
		uv + vec2(0.43, 0.0),
		density * 1.35,
		speed * 1.3,
		41.0
	);

	float rain =
		distant_rain * 0.35 +
		middle_rain * 0.6 +
		close_rain * 0.8;

	float alpha = clamp(rain * intensity, 0.0, 0.75);

	COLOR = vec4(
		rain_color.rgb,
		alpha * rain_color.a
	);
}