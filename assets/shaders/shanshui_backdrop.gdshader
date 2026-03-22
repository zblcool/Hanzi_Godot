shader_type spatial;

render_mode blend_mix, depth_prepass_alpha, cull_disabled, unshaded;

uniform vec4 mountain_color : source_color = vec4(0.42, 0.36, 0.3, 0.75);
uniform vec4 mist_color : source_color = vec4(0.94, 0.88, 0.78, 0.32);
uniform vec4 paper_tint : source_color = vec4(0.96, 0.9, 0.78, 0.18);
uniform float alpha_strength : hint_range(0.0, 1.5) = 0.9;
uniform float phase_offset = 0.0;
uniform float ridge_height : hint_range(0.2, 0.9) = 0.55;

void fragment() {
	vec2 uv = UV;
	float ridge = ridge_height;
	ridge += sin(uv.x * 6.4 + phase_offset) * 0.12;
	ridge += sin(uv.x * 13.6 + phase_offset * 1.6) * 0.06;
	ridge += sin(uv.x * 23.0 - phase_offset * 0.8) * 0.03;

	float mountain_mask = 1.0 - smoothstep(ridge - 0.03, ridge + 0.06, uv.y);
	float shoulder = 1.0 - smoothstep(ridge - 0.2, ridge + 0.18, uv.y);
	float wash = 0.5 + 0.5 * sin((uv.x + uv.y * 0.4) * 10.0 + phase_offset * 2.3);
	float ink_lines = smoothstep(0.74, 0.98, 0.5 + 0.5 * sin(uv.x * 32.0 + uv.y * 9.0 + phase_offset * 3.2));
	float mist_band = (1.0 - smoothstep(0.14, 0.56, uv.y)) * (0.58 + 0.42 * sin(uv.x * 8.0 - TIME * 0.18 + phase_offset));

	vec3 color = mix(paper_tint.rgb, mountain_color.rgb, mountain_mask * (0.72 + wash * 0.18));
	color = mix(color, mist_color.rgb, mist_band * 0.52);
	color = mix(color, mountain_color.rgb * 0.78, ink_lines * shoulder * 0.34);

	float alpha = mountain_mask * alpha_strength;
	alpha += mist_band * mist_color.a;
	alpha *= 1.0 - smoothstep(0.88, 1.0, uv.y);
	alpha *= smoothstep(0.0, 0.04, uv.x) * (1.0 - smoothstep(0.96, 1.0, uv.x));

	ALBEDO = color;
	EMISSION = mist_color.rgb * mist_band * 0.1 + paper_tint.rgb * 0.03;
	ALPHA = clamp(alpha, 0.0, 1.0);
}
