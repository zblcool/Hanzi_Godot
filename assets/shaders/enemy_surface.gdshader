shader_type spatial;

render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.72, 0.22, 0.18, 1.0);
uniform vec4 accent_color : source_color = vec4(0.9, 0.54, 0.36, 1.0);
uniform float glow_strength : hint_range(0.0, 2.0) = 0.32;
uniform float flash_strength : hint_range(0.0, 1.0) = 0.0;
uniform float windup_strength : hint_range(0.0, 1.0) = 0.0;
uniform float dash_strength : hint_range(0.0, 1.0) = 0.0;
uniform float phase_offset = 0.0;
uniform float mark_scale : hint_range(2.0, 18.0) = 7.0;
uniform float roughness_strength : hint_range(0.0, 1.0) = 0.82;
uniform float metallic_strength : hint_range(0.0, 1.0) = 0.05;

varying vec3 local_position;

void vertex() {
	local_position = VERTEX;
}

void fragment() {
	float stripe = sin((local_position.y * 1.7 + UV.x * 6.0 + phase_offset) * mark_scale + TIME * 1.35);
	float crack = sin((local_position.x - local_position.z + phase_offset * 0.8) * mark_scale * 1.45);
	float rune = smoothstep(0.18, 0.9, 0.5 + 0.5 * stripe * crack);
	float weave = 0.5 + 0.5 * sin((local_position.x + local_position.z) * 5.4 + TIME * 0.8 + phase_offset);
	float fresnel = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 2.7);

	vec3 albedo = mix(base_color.rgb * 0.78, base_color.rgb, 0.46 + weave * 0.38);
	albedo = mix(albedo, accent_color.rgb, rune * 0.24 + fresnel * 0.16);
	albedo += accent_color.rgb * windup_strength * (0.14 + rune * 0.18);
	albedo += accent_color.rgb * dash_strength * (0.2 + fresnel * 0.26);
	albedo = mix(albedo, vec3(1.0, 0.91, 0.78), flash_strength * 0.74);

	ALBEDO = albedo;
	EMISSION = accent_color.rgb * (glow_strength * (0.24 + rune * 0.52 + fresnel * 0.36) + windup_strength * 0.24 + dash_strength * 0.34) + vec3(flash_strength * 0.42);
	ROUGHNESS = max(0.08, roughness_strength - dash_strength * 0.12 - flash_strength * 0.08);
	METALLIC = metallic_strength + rune * 0.04;
}
