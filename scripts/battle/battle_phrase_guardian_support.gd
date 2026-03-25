extends RefCounted


func can_spawn_guardian(phrase_event: Dictionary, player_ready: bool) -> bool:
	return not bool(phrase_event.get("guardian_spawned", false)) \
		and not bool(phrase_event.get("guardian_defeated", false)) \
		and player_ready


func build_guardian_spawn_plan(
	phrase_event: Dictionary,
	elapsed_time: float,
	english_mode: bool,
	default_guardian_name: String
) -> Dictionary:
	return {
		"position": phrase_event.get("guardian_position", Vector3.ZERO),
		"type": String(phrase_event.get("guardian_type", "elite")),
		"power_scale": 1.05 + elapsed_time / 78.0,
		"name": String(
			phrase_event.get(
				"english_guardian_name" if english_mode else "guardian_name",
				default_guardian_name
			)
		),
		"glyph": String(phrase_event.get("guardian_glyph", "句")),
		"tint": Color(phrase_event.get("guardian_tint", phrase_event.get("tint", Color(0.72, 0.2, 0.34, 1.0)))),
		"health_scale": maxf(float(phrase_event.get("guardian_health_scale", 0.92)), 0.35),
		"event_id": String(phrase_event.get("id", "")),
		"effect_radius": 3.8,
		"effect_tint": Color(phrase_event.get("guardian_tint", phrase_event.get("tint", Color(0.76, 0.86, 1.0, 1.0)))),
		"effect_glyph": String(phrase_event.get("guardian_glyph", "句"))
	}


func mark_guardian_spawned(phrase_event: Dictionary) -> void:
	phrase_event["guardian_spawned"] = true


func mark_guardian_defeated(phrase_event: Dictionary) -> void:
	phrase_event["guardian_defeated"] = true
	phrase_event["guardian_spawned"] = false


func build_reward_resolution(phrase_event: Dictionary, fallback_radical: String) -> Dictionary:
	if bool(phrase_event.get("reward_granted", false)):
		return {}
	phrase_event["reward_granted"] = true

	var reward_type: String = String(phrase_event.get("reward_type", "heal"))
	var reward_amount: float = float(phrase_event.get("reward_amount", 0.0))
	return {
		"reward_type": reward_type,
		"reward_amount": reward_amount,
		"reward_radical": String(phrase_event.get("reward_radical", fallback_radical)),
		"accent": Color(phrase_event.get("tint", Color(0.76, 0.86, 1.0, 1.0))),
		"phrase_position": phrase_event.get("position", Vector3.ZERO),
		"phrase_glyph": String(phrase_event.get("glyph", phrase_event.get("guardian_glyph", "句")))
	}
