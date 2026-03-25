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


func present_gatekeeper_waiting(
	hud,
	objective_name: String,
	gatekeeper_name: String,
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
				"room_objective_gatekeeper_banner_format",
				"%s  守关现身",
				"%s  Gatekeeper waiting",
				[objective_name]
			),
			accent,
			1.9
		)
		hud.show_reveal(
			_guidance_text(
				guidance_text,
				"room_objective_gatekeeper_reveal_title",
				"封门守魁",
				"Seal Warden"
			),
			gatekeeper_name,
			_guidance_format(
				guidance_format,
				"room_objective_gatekeeper_reveal_body_format",
				"击败%s后，卷间奖印才会真正解封。",
				"Defeat %s to unseal the reward beacon.",
				[gatekeeper_name]
			),
			accent,
			glyph,
			2.8
		)
		hud.set_tip(status_text)
	log_battle_event.call(
		_guidance_format(
			guidance_format,
			"room_objective_gatekeeper_log_format",
			"%s · %s拦路",
			"%s · %s emerges",
			[objective_name, gatekeeper_name]
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


func build_gatekeeper_spawn_plan(objective: Dictionary, beacon_position: Vector3, elapsed_time: float) -> Dictionary:
	var gatekeeper_variant: Variant = objective.get("gatekeeper", {})
	if not (gatekeeper_variant is Dictionary):
		return {}
	var gatekeeper := gatekeeper_variant as Dictionary
	var gatekeeper_id := String(gatekeeper.get("id", ""))
	if gatekeeper_id.is_empty():
		gatekeeper_id = "%s_gatekeeper" % String(objective.get("id", "room_objective"))
	var spawn_direction := Vector3.ZERO - beacon_position
	spawn_direction.y = 0.0
	if spawn_direction.length_squared() <= 0.001:
		spawn_direction = Vector3.BACK
	else:
		spawn_direction = spawn_direction.normalized()
	var spawn_position := beacon_position + spawn_direction * 3.8
	spawn_position.y = 0.0
	return {
		"id": gatekeeper_id,
		"type": String(gatekeeper.get("type", "elite")),
		"position": spawn_position,
		"power_scale": 1.1 + elapsed_time / 76.0,
		"glyph": String(gatekeeper.get("glyph", "魁")),
		"tint": Color(gatekeeper.get("tint", Color(0.82, 0.54, 0.34, 1.0))),
		"health_scale": maxf(float(gatekeeper.get("health_scale", 1.0)), 0.35)
	}


func build_gatekeeper_callout(
	gatekeeper_copy: Dictionary,
	enemy_name: String,
	accent: Color,
	guidance_format: Callable
) -> Dictionary:
	var taunt := String(gatekeeper_copy.get("taunt", ""))
	if taunt.is_empty():
		return {}
	return {
		"title": _guidance_format(
			guidance_format,
			"room_objective_gatekeeper_callout_title_format",
			"%s拦路",
			"%s Challenges You",
			[enemy_name]
		),
		"text": taunt,
		"accent": accent,
		"log_prefix": _guidance_format(
			guidance_format,
			"room_objective_gatekeeper_callout_source_format",
			"%s：",
			"%s: ",
			[enemy_name]
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
