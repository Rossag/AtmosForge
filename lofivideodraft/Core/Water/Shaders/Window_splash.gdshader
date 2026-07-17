shader_type canvas_item;
render_mode unshaded;

uniform vec4 splash_color : source_color =
	vec4(0.55, 0.75, 0.90, 0.32);

uniform float cycle_duration : hint_range(3.0, 30.0) = 12.0;
uniform float splash_duration : hint_range(0.2, 3.0) = 1.2;
uniform float splash_width : hint_range(0.01, 0.25) = 0.055;
uniform float splash_softness : hint_range(0.005, 0.15) = 0.035;
uniform float splash_height : hint_range(0.05, 0.8) = 0.32;
uniform float splash_position : hint_range(0.0, 1.0) = 0.68;
uniform float intensity : hint_range(0.0, 2.0) = 0.65;


float hash(float value) {
	return fract(sin(value * 127.1) * 43758.5453);
}


void fragment() {
	vec2 uv = UV;

	float cycle = floor(TIME / cycle_duration);
	float cycle_time = mod(TIME, cycle_duration);

	float random_delay = hash(cycle + 4.7) *
		(cycle_duration - splash_duration);

	float progress = clamp(
		(cycle_time - random_delay) / splash_duration,
		0.0,
		1.0
	);

	float active =
		step(random_delay, cycle_time) *
		step(cycle_time, random_delay + splash_duration);

	// Curved spray rising from the lower portion of the window.
	float centre_x =
		splash_position +
		(uv.y - 0.72) * 0.22;

	float curve =
		pow(abs(uv.x - centre_x), 1.35) * 1.7;

	float wave_y =
		0.78 -
		sin(progress * 3.14159) * splash_height +
		curve;

	float distance_to_splash = abs(uv.y - wave_y);

	float spray = 1.0 - smoothstep(
		splash_width,
		splash_width + splash_softness,
		distance_to_splash
	);

	// Keep the effect mainly in the lower half.
	float lower_mask = smoothstep(0.32, 0.72, uv.y);

	// Fade in quickly and dissolve gently.
	float fade =
		smoothstep(0.0, 0.16, progress) *
		(1.0 - smoothstep(0.48, 1.0, progress));

	float variation = mix(
		0.65,
		1.0,
		hash(cycle + 19.3)
	);

	float alpha =
		spray *
		lower_mask *
		fade *
		active *
		intensity *
		variation;

	COLOR = vec4(
		splash_color.rgb,
		alpha * splash_color.a
	);
}