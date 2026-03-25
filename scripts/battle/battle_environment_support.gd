extends RefCounted


func setup_environment(world_environment: WorldEnvironment) -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.82, 0.79, 0.7, 1.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.78, 0.82, 0.74, 1.0)
	environment.ambient_light_energy = 0.8
	environment.fog_enabled = true
	environment.fog_density = 0.012
	environment.fog_light_color = Color(0.8, 0.84, 0.78, 1.0)
	world_environment.environment = environment


func make_ground_material(
	shader: Shader,
	ground_surface_materials: Array,
	base_color: Color,
	ink_color: Color,
	paper_color: Color,
	ripple_strength: float,
	detail_mix: float,
	emission_strength: float,
	phase_offset: float
) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("base_color", base_color)
	material.set_shader_parameter("ink_color", ink_color)
	material.set_shader_parameter("paper_color", paper_color)
	material.set_shader_parameter("ripple_strength", ripple_strength)
	material.set_shader_parameter("detail_mix", detail_mix)
	material.set_shader_parameter("emission_strength", emission_strength)
	material.set_shader_parameter("phase_offset", phase_offset)
	material.set_shader_parameter("focus_position", Vector3.ZERO)
	material.set_shader_parameter("ambient_drift", Vector2(0.12, -0.08))
	material.set_shader_parameter("theme_glow_color", Color(0.72, 0.88, 0.78, 1.0))
	material.set_shader_parameter("theme_shadow_color", Color(0.16, 0.22, 0.2, 1.0))
	material.set_shader_parameter("ambient_visibility", 1.0)
	material.set_shader_parameter("phase_presence", 1.0)
	ground_surface_materials.append(material)
	return material


func update_ground_shader(
	ground_surface_materials: Array,
	player: Node3D,
	current_focus: Vector3,
	delta: float
) -> Vector3:
	if ground_surface_materials.is_empty() or not is_instance_valid(player):
		return current_focus

	var target_focus := Vector3(player.global_position.x, 0.0, player.global_position.z)
	var next_focus := target_focus if current_focus == Vector3.ZERO else current_focus.lerp(target_focus, clamp(delta * 1.7, 0.0, 1.0))
	for material_variant in ground_surface_materials:
		var material := material_variant as ShaderMaterial
		if material == null:
			continue
		material.set_shader_parameter("focus_position", next_focus)
	return next_focus


func base_fog_density(performance_mode: String, performance_fog_density: Dictionary) -> float:
	return float(performance_fog_density.get(performance_mode, performance_fog_density["balanced"]))


func apply_field_phase_theme_blend(
	world_environment: WorldEnvironment,
	ground_surface_materials: Array,
	backdrop_material_entries: Array,
	backdrop_mist_material: StandardMaterial3D,
	from_theme: Dictionary,
	to_theme: Dictionary,
	blend: float,
	fog_density_base: float
) -> float:
	if world_environment.environment == null:
		return 1.0

	var environment := world_environment.environment
	var background_from := Color(from_theme.get("environment_bg", environment.background_color))
	var background_to := Color(to_theme.get("environment_bg", environment.background_color))
	environment.background_color = background_from.lerp(background_to, blend)

	var ambient_from := Color(from_theme.get("environment_ambient", environment.ambient_light_color))
	var ambient_to := Color(to_theme.get("environment_ambient", environment.ambient_light_color))
	environment.ambient_light_color = ambient_from.lerp(ambient_to, blend)
	environment.ambient_light_energy = lerpf(0.78, 0.84, blend)

	var fog_from := Color(from_theme.get("environment_fog", environment.fog_light_color))
	var fog_to := Color(to_theme.get("environment_fog", environment.fog_light_color))
	environment.fog_light_color = fog_from.lerp(fog_to, blend)
	environment.fog_density = fog_density_base * lerpf(float(from_theme.get("fog_density_scale", 1.0)), float(to_theme.get("fog_density_scale", 1.0)), blend)

	var ambient_visibility := lerpf(float(from_theme.get("ambient_visibility", 1.0)), float(to_theme.get("ambient_visibility", 1.0)), blend)
	var drift_from := Vector2(from_theme.get("ambient_drift", Vector2(0.12, -0.08)))
	var drift_to := Vector2(to_theme.get("ambient_drift", Vector2(0.12, -0.08)))
	var glow_from := Color(from_theme.get("ground_glow", Color(0.72, 0.88, 0.78, 1.0)))
	var glow_to := Color(to_theme.get("ground_glow", Color(0.72, 0.88, 0.78, 1.0)))
	var shadow_from := Color(from_theme.get("ground_shadow", Color(0.16, 0.22, 0.2, 1.0)))
	var shadow_to := Color(to_theme.get("ground_shadow", Color(0.16, 0.22, 0.2, 1.0)))
	for material_variant in ground_surface_materials:
		var material := material_variant as ShaderMaterial
		if material == null:
			continue
		material.set_shader_parameter("ambient_drift", drift_from.lerp(drift_to, blend))
		material.set_shader_parameter("theme_glow_color", glow_from.lerp(glow_to, blend))
		material.set_shader_parameter("theme_shadow_color", shadow_from.lerp(shadow_to, blend))
		material.set_shader_parameter("ambient_visibility", ambient_visibility)
		material.set_shader_parameter("phase_presence", 1.0)

	apply_field_phase_backdrop_blend(backdrop_material_entries, backdrop_mist_material, from_theme, to_theme, blend)
	return ambient_visibility


func apply_field_phase_backdrop_blend(
	backdrop_material_entries: Array,
	backdrop_mist_material: StandardMaterial3D,
	from_theme: Dictionary,
	to_theme: Dictionary,
	blend: float
) -> void:
	for entry in backdrop_material_entries:
		var material_variant = entry.get("material", null)
		if not (material_variant is ShaderMaterial):
			continue
		var material := material_variant as ShaderMaterial
		var layer_index: int = int(entry.get("layer_index", 0))
		var layer_mix: float = clamp(0.58 - float(layer_index) * 0.09, 0.32, 0.58)
		var base_mountain := Color(entry.get("mountain", Color(0.4, 0.34, 0.27, 0.78)))
		var base_mist := Color(entry.get("mist", Color(0.9, 0.84, 0.74, 0.34)))
		var base_paper := Color(entry.get("paper", Color(0.94, 0.86, 0.72, 0.18)))
		var alpha_base: float = float(entry.get("alpha", 0.8))
		var mountain_from := base_mountain.lerp(Color(from_theme.get("backdrop_mountain", base_mountain)), layer_mix)
		var mountain_to := base_mountain.lerp(Color(to_theme.get("backdrop_mountain", base_mountain)), layer_mix)
		var mist_from := base_mist.lerp(Color(from_theme.get("backdrop_mist", base_mist)), layer_mix)
		var mist_to := base_mist.lerp(Color(to_theme.get("backdrop_mist", base_mist)), layer_mix)
		var paper_from := base_paper.lerp(Color(from_theme.get("backdrop_paper", base_paper)), layer_mix)
		var paper_to := base_paper.lerp(Color(to_theme.get("backdrop_paper", base_paper)), layer_mix)
		material.set_shader_parameter("mountain_color", mountain_from.lerp(mountain_to, blend))
		material.set_shader_parameter("mist_color", mist_from.lerp(mist_to, blend))
		material.set_shader_parameter("paper_tint", paper_from.lerp(paper_to, blend))
		material.set_shader_parameter(
			"alpha_strength",
			alpha_base * lerpf(float(from_theme.get("backdrop_alpha", 1.0)), float(to_theme.get("backdrop_alpha", 1.0)), blend)
		)

	if backdrop_mist_material != null:
		var mist_from := Color(from_theme.get("backdrop_mist", Color(0.95, 0.9, 0.82, 0.22)))
		var mist_to := Color(to_theme.get("backdrop_mist", Color(0.95, 0.9, 0.82, 0.22)))
		var paper_from := Color(from_theme.get("backdrop_paper", Color(0.95, 0.9, 0.82, 0.22)))
		var paper_to := Color(to_theme.get("backdrop_paper", Color(0.95, 0.9, 0.82, 0.22)))
		backdrop_mist_material.albedo_color = paper_from.lerp(paper_to, blend)
		backdrop_mist_material.emission = mist_from.lerp(mist_to, blend)
