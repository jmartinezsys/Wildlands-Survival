shader_type canvas_item;
render_mode unshaded;

varying vec2 local_position;

void vertex() {
	local_position = VERTEX;
}

void fragment() {
	float wave_a = sin(local_position.x * 0.035 + local_position.y * 0.012 + TIME * 1.4);
	float wave_b = sin(local_position.y * 0.052 - local_position.x * 0.018 - TIME * 1.05);
	float ripple = smoothstep(0.42, 0.82, wave_a * 0.55 + wave_b * 0.45);
	vec3 deep_water = vec3(0.11, 0.34, 0.40);
	vec3 bright_water = vec3(0.29, 0.57, 0.61);
	vec3 foam = vec3(0.66, 0.81, 0.76);
	vec3 color = mix(deep_water, bright_water, ripple * 0.48);
	color = mix(color, foam, smoothstep(0.89, 0.99, wave_a * wave_b) * 0.22);
	COLOR = vec4(color, 0.93);
}
