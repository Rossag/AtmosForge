shader_type canvas_item;
render_mode unshaded, blend_add;


uniform vec4 glow_color : source_color = vec4(
	1.0,
	0.42,
	0.12,
	0.32
);

uniform vec2 glow_position = vec2(0.635, 0.52);

uniform float radius : hint_range(0.0, 0.5) = 0.04;
uniform float softness : hint_range(0.01, 0.6) = 0.20;
uniform float intensity : hint_range(0.0, 2.0) = 0.65;

uniform float flicker_amount : hint_range(0.0, 0.2) = 0.012;
uniform float flicker_speed : hint_range(0.0, 10.0) = 1.4;

uniform float aspect_ratio = 1.7778;


void fragment() {
	vec2 difference = UV - glow_position;

	// Correct the circular glow for a 16:9 screen.
	difference.x *= aspect_ratio;

	float distance_from_lamp = length(difference);

	float outer_glow = 1.0 - smoothstep(
		radius,
		radius + softness,
		distance_from_lamp
	);

	float inner_glow = 1.0 - smoothstep(
		0.0,
		radius * 1.8,
		distance_from_lamp
	);

	// Two overlapping waves avoid a visibly repetitive flicker.
	float flicker =
		1.0 +
		sin(TIME * flicker_speed) * flicker_amount +
		sin(TIME * flicker_speed * 2.37 + 1.4)
			* flicker_amount * 0.35;

	float glow_strength = (
		outer_glow * 0.72 +
		inner_glow * 0.28
	) * intensity * flicker;

	COLOR = vec4(
		glow_color.rgb,
		glow_color.a * glow_strength
	);
}