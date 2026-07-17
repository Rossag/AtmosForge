shader_type canvas_item;
render_mode unshaded;

uniform sampler2D water_texture :
	source_color,
	repeat_enable,
	filter_linear_mipmap;

uniform float horizontal_speed : hint_range(-0.05, 0.05) = 0.0;

uniform float primary_speed : hint_range(0.0, 2.0) = 0.15;
uniform float secondary_speed : hint_range(0.0, 2.0) = 0.09;

uniform float horizontal_motion : hint_range(0.0, 0.05) = 0.001;
uniform float vertical_motion : hint_range(0.0, 0.05) = 0.002;

uniform float wave_scale : hint_range(1.0, 30.0) = 8.0;
uniform float detail_scale : hint_range(1.0, 40.0) = 17.0;

// Slow vertical movement of the entire ocean.
uniform float heave_amount : hint_range(0.0, 0.08) = 0.018;
uniform float heave_speed : hint_range(0.0, 2.0) = 0.45;

// Slight horizon tilt so the motion is not perfectly mechanical.
uniform float roll_amount : hint_range(0.0, 0.05) = 0.006;
uniform float roll_speed : hint_range(0.0, 2.0) = 0.30;

uniform float texture_offset_x : hint_range(-0.5, 0.5) = 0.08;

uniform float brightness : hint_range(0.25, 2.0) = 0.88;
uniform float saturation : hint_range(0.0, 2.0) = 0.90;
uniform float opacity : hint_range(0.0, 1.0) = 1.0;


void fragment() {
	vec2 uv = UV;

	// Surface distortion becomes slightly stronger toward the foreground.
	float depth = smoothstep(
		0.46,
		1.0,
		uv.y
	);

	float primary_wave = sin(
		uv.x * wave_scale +
		TIME * primary_speed
	);

	float secondary_wave = sin(
		uv.x * detail_scale -
		TIME * secondary_speed +
		uv.y * 5.0
	);

	vec2 animated_uv = uv;

	// Move the whole ocean slowly up and down relative to the window.
	float heave =
		sin(TIME * heave_speed) *
		heave_amount;

	// Apply a tiny uneven tilt across the horizon.
	float roll =
		sin(TIME * roll_speed + 1.4) *
		roll_amount *
		(uv.x - 0.5);

	animated_uv.y += heave + roll;

	// Keep the baked reflection aligned beneath the moon.
	animated_uv.x += texture_offset_x;

	// Horizontal movement defaults to zero but remains available.
	animated_uv.x += TIME * horizontal_speed;

	// Fine surface movement.
	animated_uv.x +=
		secondary_wave *
		horizontal_motion *
		depth;

	animated_uv.y +=
		primary_wave *
		vertical_motion *
		depth;

	animated_uv.y +=
		secondary_wave *
		vertical_motion *
		0.35 *
		depth;

	vec4 water = texture(
		water_texture,
		animated_uv
	);

	// Retain the photographic texture while allowing scene-level grading.
	float luminance = dot(
		water.rgb,
		vec3(0.299, 0.587, 0.114)
	);

	water.rgb = mix(
		vec3(luminance),
		water.rgb,
		saturation
	);

	water.rgb *= brightness;

	COLOR = vec4(
		water.rgb,
		water.a * opacity
	);
}