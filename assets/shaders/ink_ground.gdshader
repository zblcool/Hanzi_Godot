shader_type spatial;

render_mode cull_back, diffuse_burley, specular_disabled;

uniform vec4 base_color : source_color = vec4(0.08, 0.095, 0.11, 1.0);
uniform vec4 ink_color : source_color = vec4(0.46, 0.66, 0.68, 1.0);
uniform vec4 paper_color : source_color = vec4(0.18, 0.2, 0.18, 1.0);
uniform vec3 focus_position = vec3(0.0, 0.0, 0.0);
uniform vec2 ambient_drift = vec2(0.12, -0.08);
uniform vec4 theme_glow_color : source_color = vec4(0.72, 0.88, 0.78, 1.0);
uniform vec4 theme_shadow_color : source_color = vec4(0.16, 0.22, 0.2, 1.0);
uniform float ripple_strength : hint_range(0.0, 1.0) = 0.16;
uniform float detail_mix : hint_range(0.0, 1.0) = 0.28;
uniform float emission_strength : hint_range(0.0, 1.0) = 0.12;
uniform float ambient_visibility : hint_range(0.0, 2.0) = 1.0;
uniform float phase_presence : hint_range(0.0, 1.0) = 1.0;
uniform float phase_offset = 0.0;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = world_position.xz;
	vec2 ambient_p = p + ambient_drift * TIME * 2.4;
	float grain = sin(ambient_p.x * 7.8 + sin(ambient_p.y * 0.64 + phase_offset)) * sin(ambient_p.y * 5.9 - phase_offset * 1.2);
	grain = 0.5 + 0.5 * grain;
	float fiber = 0.5 + 0.5 * sin((ambient_p.x + ambient_p.y) * 3.4 + TIME * 0.08 + phase_offset);
	float grid_x = smoothstep(0.42, 0.5, abs(fract((ambient_p.x + phase_offset) * 0.18) - 0.5));
	float grid_y = smoothstep(0.42, 0.5, abs(fract((ambient_p.y - phase_offset) * 0.18) - 0.5));
	float dist = distance(p, focus_position.xz);
	float ambient_flow = 0.5 + 0.5 * sin((ambient_p.x - ambient_p.y) * 0.58 + TIME * 0.72 + phase_offset * 2.0);
	float ripple_wave = sin(dist * 5.4 - TIME * 4.1 + phase_offset * 2.0);
	float ripple_mask = 1.0 - smoothstep(1.0, 3.7, dist);
	float ripple = max(ripple_wave, 0.0) * ripple_mask;
	float shimmer = 0.5 + 0.5 * sin(dist * 1.6 - TIME * 1.4 + phase_offset);
	float line_mask = max(grid_x, grid_y) * 0.16;
	float swirl = 0.5 + 0.5 * sin((ambient_p.x * 0.46 + ambient_p.y * 0.28) + TIME * 0.36 + phase_offset * 2.6);
	float wash = (ambient_flow * 0.08 + swirl * 0.14 + line_mask * 0.22) * phase_presence;

	vec3 albedo = mix(base_color.rgb, paper_color.rgb, grain * 0.2 + fiber * 0.1);
	albedo = mix(albedo, ink_color.rgb, line_mask * 0.42 + ambient_flow * detail_mix * 0.07);
	albedo = mix(albedo, theme_shadow_color.rgb, wash);
	albedo += ink_color.rgb * ripple * ripple_strength * 0.68;
	albedo += theme_glow_color.rgb * (ambient_flow * 0.07 + ripple * ripple_strength * 0.86) * (0.26 + phase_presence * 0.38);
	albedo += paper_color.rgb * shimmer * ripple_strength * 0.03;

	ALBEDO = albedo;
	EMISSION = mix(ink_color.rgb, theme_glow_color.rgb, 0.52) * (
		line_mask * emission_strength * ambient_visibility +
		ambient_flow * detail_mix * 0.04 * ambient_visibility +
		ripple * ripple_strength * (0.62 + phase_presence * 0.42) +
		swirl * 0.08 * phase_presence
	);
	ROUGHNESS = 0.92 - grain * 0.08;
	METALLIC = 0.02;
}
