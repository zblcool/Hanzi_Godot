extends RefCounted


func _guidance_text(guidance_text: Callable, key: String, fallback_zh: String, fallback_en: String) -> String:
	return String(guidance_text.call(key, fallback_zh, fallback_en))


func _guidance_format(
	guidance_format: Callable,
	key: String,
	fallback_zh: String,
	fallback_en: String,
	values: Array = []
) -> String:
	return String(guidance_format.call(key, fallback_zh, fallback_en, values))


func _objective_enemy_variant(objective: Dictionary) -> Dictionary:
	var mode := String(objective.get("mode", ""))
	var enemy_key := "target" if mode == "hunt" else "gatekeeper"
	var enemy_variant: Variant = objective.get(enemy_key, {})
	if enemy_variant is Dictionary:
		return enemy_variant as Dictionary
	return {}


func build_break_beacon_spawn_meta() -> Dictionary:
	return {
		"chamber_break_beacon": true,
		"chamber_break_beacon_glyph": "奖"
	}


func present_break_beacon(
	hud,
	accent: Color,
	chamber_name: String,
	guidance_text: Callable,
	log_battle_event: Callable
) -> void:
	if hud != null:
		hud.show_banner(
			_guidance_text(guidance_text, "reward_beacon_banner", "卷间奖印显形", "Reward Beacon Raised"),
			accent,
			1.8
		)
		hud.show_reveal(
			_guidance_text(guidance_text, "reward_beacon_reveal_title", "卷间奖印", "Reward Beacon"),
			chamber_name,
			_guidance_text(
				guidance_text,
				"reward_beacon_reveal_body",
				"卷间抉择已经显在附近。先走到这枚奖印前，才能真正定下下一条路。",
				"The chamber break is nearby now. Reach the reward beacon to resolve one between-chambers choice."
			),
			accent,
			"奖",
			2.5
		)
		hud.set_tip(
			_guidance_text(
				guidance_text,
				"reward_beacon_tip",
				"卷间奖印已经亮起。先亲自走到奖印前，卷间抉择才会真正打开。",
				"The chamber reward beacon is now active. Walk to it before the next chamber choice can resolve."
			)
		)
	log_battle_event.call(
		_guidance_text(
			guidance_text,
			"reward_beacon_log",
			"卷间奖印 · 靠近后再定下一路",
			"Reward Beacon · Reach the chamber prize"
		),
		accent
	)


func present_objective_start(
	hud,
	objective_name: String,
	status_text: String,
	accent: Color,
	glyph: String,
	guidance_text: Callable,
	guidance_format: Callable,
	log_battle_event: Callable
) -> void:
	if hud != null:
		hud.show_banner(
			_guidance_format(
				guidance_format,
				"room_objective_banner_format",
				"房间目标  %s",
				"Room Objective  %s",
				[objective_name]
			),
			accent,
			1.9
		)
		hud.show_reveal(
			_guidance_text(guidance_text, "room_objective_reveal_title", "房间目标", "Room Objective"),
			objective_name,
			status_text,
			accent,
			glyph,
			2.6
		)
		hud.set_tip(status_text)
	log_battle_event.call(
		_guidance_format(
			guidance_format,
			"room_objective_log_format",
			"房间目标 · %s",
			"Room Objective · %s",
			[objective_name]
		),
		accent
	)


func present_objective_enemy_waiting(
	hud,
	objective_mode: String,
	objective_name: String,
	objective_enemy_name: String,
	status_text: String,
	accent: Color,
	glyph: String,
	guidance_text: Callable,
	guidance_format: Callable,
	log_battle_event: Callable
) -> void:
	var is_hunt := objective_mode == "hunt"
	if hud != null:
		hud.show_banner(
			_guidance_format(
				guidance_format,
				"room_objective_priority_target_banner_format" if is_hunt else "room_objective_gatekeeper_banner_format",
				"%s  首魁现身" if is_hunt else "%s  守关现身",
				"%s  Priority target marked" if is_hunt else "%s  Gatekeeper waiting",
				[objective_name]
			),
			accent,
			1.9
		)
		hud.show_reveal(
			_guidance_text(
				guidance_text,
				"room_objective_priority_target_reveal_title" if is_hunt else "room_objective_gatekeeper_reveal_title",
				"缉卷首魁" if is_hunt else "封门守魁",
				"Priority Target" if is_hunt else "Seal Warden"
			),
			objective_enemy_name,
			_guidance_format(
				guidance_format,
				"room_objective_priority_target_reveal_body_format" if is_hunt else "room_objective_gatekeeper_reveal_body_format",
				"击败%s后，卷间奖印才会真正显形。" if is_hunt else "击败%s后，卷间奖印才会真正解封。",
				"Defeat %s to raise the reward beacon." if is_hunt else "Defeat %s to unseal the reward beacon.",
				[objective_enemy_name]
			),
			accent,
			glyph,
			2.8
		)
		hud.set_tip(status_text)
	log_battle_event.call(
		_guidance_format(
			guidance_format,
			"room_objective_priority_target_log_format" if is_hunt else "room_objective_gatekeeper_log_format",
			"%s · %s现身" if is_hunt else "%s · %s拦路",
			"%s · %s marked" if is_hunt else "%s · %s emerges",
			[objective_name, objective_enemy_name]
		),
		accent
	)


func present_remaining_seals(
	hud,
	objective_name: String,
	remaining: int,
	status_text: String,
	accent: Color,
	guidance_format: Callable,
	log_battle_event: Callable
) -> void:
	if hud != null:
		hud.show_banner(
			_guidance_format(
				guidance_format,
				"room_objective_seals_remaining_banner_format",
				"%s  还差 %d 枚",
				"%s  %d seals remain",
				[objective_name, remaining]
			),
			accent,
			1.45
		)
		hud.set_tip(status_text)
	log_battle_event.call(
		_guidance_format(
			guidance_format,
			"room_objective_seals_remaining_log_format",
			"%s · 尚余 %d 枚封印",
			"%s · %d seals remain",
			[objective_name, remaining]
		),
		accent
	)


func build_objective_enemy_spawn_plan(objective: Dictionary, beacon_position: Vector3, elapsed_time: float) -> Dictionary:
	var objective_mode := String(objective.get("mode", ""))
	var enemy_data := _objective_enemy_variant(objective)
	if enemy_data.is_empty():
		return {}
	var objective_enemy_id := String(enemy_data.get("id", ""))
	if objective_enemy_id.is_empty():
		objective_enemy_id = "%s_enemy" % String(objective.get("id", "room_objective"))
	var spawn_direction := Vector3.ZERO - beacon_position
	spawn_direction.y = 0.0
	if spawn_direction.length_squared() <= 0.001:
		spawn_direction = Vector3.BACK
	else:
		spawn_direction = spawn_direction.normalized()
	var spawn_distance := 4.3 if objective_mode == "hunt" else 3.8
	var spawn_position := beacon_position + spawn_direction * spawn_distance
	spawn_position.y = 0.0
	return {
		"id": objective_enemy_id,
		"type": String(enemy_data.get("type", "elite")),
		"position": spawn_position,
		"power_scale": 1.18 + elapsed_time / 74.0 if objective_mode == "hunt" else 1.1 + elapsed_time / 76.0,
		"glyph": String(enemy_data.get("glyph", "魁")),
		"tint": Color(enemy_data.get("tint", Color(0.82, 0.54, 0.34, 1.0))),
		"health_scale": maxf(float(enemy_data.get("health_scale", 1.0)), 0.35)
	}


func build_objective_enemy_callout(
	objective_mode: String,
	objective_enemy_copy: Dictionary,
	objective_enemy_name: String,
	accent: Color,
	guidance_format: Callable
) -> Dictionary:
	var is_hunt := objective_mode == "hunt"
	var taunt := String(objective_enemy_copy.get("taunt", ""))
	if taunt.is_empty():
		return {}
	return {
		"title": _guidance_format(
			guidance_format,
			"room_objective_priority_target_callout_title_format" if is_hunt else "room_objective_gatekeeper_callout_title_format",
			"%s现身" if is_hunt else "%s拦路",
			"%s Marked" if is_hunt else "%s Challenges You",
			[objective_enemy_name]
		),
		"text": taunt,
		"accent": accent,
		"log_prefix": _guidance_format(
			guidance_format,
			"room_objective_priority_target_callout_source_format" if is_hunt else "room_objective_gatekeeper_callout_source_format",
			"%s：",
			"%s: ",
			[objective_enemy_name]
		),
		"duration": 3.0
	}


func present_objective_complete(
	hud,
	objective_name: String,
	accent: Color,
	guidance_text: Callable,
	guidance_format: Callable,
	log_battle_event: Callable
) -> void:
	if hud != null:
		hud.show_banner(
			_guidance_format(
				guidance_format,
				"room_objective_complete_banner_format",
				"%s  奖印显形",
				"%s  Reward beacon raised",
				[objective_name]
			),
			accent,
			1.7
		)
		hud.set_tip(
			_guidance_text(
				guidance_text,
				"reward_beacon_tip",
				"卷间奖印已经亮起。先亲自走到奖印前，卷间抉择才会真正打开。",
				"The chamber reward beacon is now active. Walk to it before the next chamber choice can resolve."
			)
		)
	log_battle_event.call(
		_guidance_format(
			guidance_format,
			"room_objective_complete_log_format",
			"%s完成 · 奖印显形",
			"%s complete · Reward beacon raised",
			[objective_name]
		),
		accent
	)
