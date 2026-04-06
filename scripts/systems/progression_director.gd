extends RefCounted
class_name ProgressionDirector

const ContentDatabaseScript := preload("res://scripts/systems/content_database.gd")

var database := ContentDatabaseScript.new()

var level := 1
var experience := 0
var experience_target := 6
var pending_rewards := 0
var character_slots := 4

var active_route := ""
var rune_inventory: Dictionary = {}
var characters: Dictionary = {}
var unlocked_word_skills: Dictionary = {}


func _init() -> void:
	for rune_id in database.get_rune_ids():
		rune_inventory[rune_id] = 0


func add_experience(value: int) -> Array[String]:
	var messages: Array[String] = []
	experience += value
	while experience >= experience_target:
		experience -= experience_target
		level += 1
		pending_rewards += 1
		experience_target = int(round(experience_target * 1.28)) + 4
		messages.append("字力升到 Lv.%d，房间结算时可再选一个偏旁。" % level)
	return messages


func grant_room_reward() -> void:
	pending_rewards += 1


func has_pending_rewards() -> bool:
	return pending_rewards > 0


func needs_route_choice() -> bool:
	return active_route.is_empty()


func get_route_options() -> Array:
	var options: Array = []
	for route_name in database.get_route_names():
		var definition: Dictionary = database.get_route_def(route_name)
		options.append({
			"id": route_name,
			"glyph": str(definition.get("glyph", "路")),
			"title": route_name,
			"description": str(definition.get("description", "")),
			"detail": "偏向偏旁：%s" % _glyph_list_for_ids(definition.get("bias", []))
		})
	return options


func choose_route(route_name: String) -> Dictionary:
	active_route = route_name
	var definition: Dictionary = database.get_route_def(route_name)
	return {
		"messages": ["字路确立为「%s」：%s" % [route_name, str(definition.get("description", ""))]]
	}


func get_reward_options(rng: RandomNumberGenerator, count: int = 3) -> Array:
	var weighted_candidates: Array = []
	for rune_id in database.get_rune_ids():
		weighted_candidates.append({
			"id": rune_id,
			"weight": _get_rune_weight(rune_id)
		})

	var picked_ids: Array = _pick_weighted_ids(weighted_candidates, rng, count)
	var options: Array = []
	for rune_id in picked_ids:
		var definition: Dictionary = database.get_rune_def(rune_id)
		options.append({
			"id": rune_id,
			"glyph": str(definition.get("char", "字")),
			"title": str(definition.get("char", "")),
			"description": str(definition.get("theme", "")),
			"detail": _build_rune_detail(rune_id)
		})
	return options


func apply_reward_choice(rune_id: String) -> Dictionary:
	var result = {
		"messages": [],
		"summary": "",
		"rune_id": rune_id,
		"character_events": [],
		"word_skill_events": []
	}

	if pending_rewards > 0:
		pending_rewards -= 1

	var rune_definition: Dictionary = database.get_rune_def(rune_id)
	if rune_definition.is_empty():
		result["messages"].append("这次没有成功纳入新的偏旁。")
		result["summary"] = result["messages"][0]
		return result

	rune_inventory[rune_id] = int(rune_inventory.get(rune_id, 0)) + 1
	result["messages"].append("纳入偏旁「%s」：%s" % [str(rune_definition.get("char", rune_id)), str(rune_definition.get("theme", ""))])

	_resolve_character_progress(rune_id, result)
	_resolve_word_skills(result)

	if result["messages"].is_empty():
		result["messages"].append("字库略有充实，但这一笔还未引出新的字诀。")
	result["summary"] = str(result["messages"][result["messages"].size() - 1])
	return result


func get_snapshot() -> Dictionary:
	var snapshot = {
		"level": level,
		"experience": experience,
		"experience_target": experience_target,
		"pending_rewards": pending_rewards,
		"route_name": active_route,
		"route_glyph": "文",
		"route_description": "",
		"runes": rune_inventory.duplicate(true),
		"characters": _get_character_entries(),
		"word_skills": _get_word_skill_entries(),
		"slots_used": characters.size(),
		"slots_total": character_slots,
		"max_health_bonus": 0.0,
		"move_speed_bonus": 0.0,
		"attack_damage_bonus": 0.0,
		"attack_rate_multiplier": 1.0,
		"projectile_speed_bonus": 0.0,
		"extra_projectiles": 0,
		"projectile_scale_bonus": 0.0,
		"damage_reduction": 0.0,
		"guard_level": 0,
		"guard_radius": 0.0,
		"guard_slow": 0.0,
		"guard_attack_bonus": 0.0,
		"guard_array_damage": 0.0,
		"rest_level": 0,
		"rest_heal_rate": 0.0,
		"rest_damage_reduction": 0.0,
		"rest_field_radius": 0.0,
		"rest_field_slow": 0.0,
		"move_level": 0,
		"slash_damage": 0.0,
		"slash_width": 34.0,
		"slash_threshold": 9999.0,
		"wave_level": 0,
		"wave_damage": 0.0,
		"wave_radius": 0.0,
		"wave_slow": 0.0,
		"wave_push": 0.0,
		"wave_cooldown": 999.0,
		"chant_level": 0,
		"echo_chance": 0.0,
		"echo_delay": 0.35,
		"echo_damage_multiplier": 0.65,
		"thunder_level": 0,
		"thunder_damage": 0.0,
		"thunder_radius": 0.0,
		"thunder_chain": 0,
		"thunder_cooldown": 999.0,
		"thunder_zone_duration": 0.0,
		"thunder_zone_damage": 0.0,
		"thunder_zone_slow": 0.0,
		"sprout_level": 0,
		"sprout_damage": 0.0,
		"sprout_radius": 0.0,
		"sprout_slow": 0.0,
		"sprout_cooldown": 999.0,
		"word_skills_lookup": {},
		"core_glyph": "文"
	}

	if not active_route.is_empty():
		var route_definition: Dictionary = database.get_route_def(active_route)
		snapshot["route_glyph"] = str(route_definition.get("glyph", "文"))
		snapshot["route_description"] = str(route_definition.get("description", ""))

	var fire_count = _get_rune_count("fire")
	var water_count = _get_rune_count("water")
	var rain_count = _get_rune_count("rain")
	var field_count = _get_rune_count("field")
	var person_count = _get_rune_count("person")
	var wood_count = _get_rune_count("wood")
	var mouth_count = _get_rune_count("mouth")
	var heart_count = _get_rune_count("heart")
	var mountain_count = _get_rune_count("mountain")
	var wind_count = _get_rune_count("wind")

	snapshot["attack_damage_bonus"] += fire_count * 4.0
	snapshot["max_health_bonus"] += water_count * 7.0
	snapshot["attack_rate_multiplier"] += rain_count * 0.05
	snapshot["projectile_scale_bonus"] += rain_count * 0.03
	snapshot["move_speed_bonus"] += person_count * 14.0
	snapshot["rest_heal_rate"] += wood_count * 0.25
	snapshot["extra_projectiles"] += int(floor(float(mouth_count) / 3.0))
	snapshot["echo_chance"] += heart_count * 0.03
	snapshot["max_health_bonus"] += heart_count * 3.0
	snapshot["damage_reduction"] += mountain_count * 0.03
	snapshot["max_health_bonus"] += mountain_count * 5.0
	snapshot["move_speed_bonus"] += wind_count * 18.0
	snapshot["projectile_speed_bonus"] += wind_count * 40.0
	snapshot["guard_radius"] += field_count * 5.0
	snapshot["thunder_radius"] += field_count * 3.0

	var supported_levels = {
		"rest": _get_character_level("rest"),
		"thunder": _get_character_level("thunder"),
		"sprout": _get_character_level("sprout"),
		"move": _get_character_level("move"),
		"wave": _get_character_level("wave"),
		"chant": _get_character_level("chant"),
		"guard": _get_character_level("guard"),
		"flame": _get_character_level("flame"),
		"array": _get_character_level("array"),
		"swift": _get_character_level("swift"),
		"solid": _get_character_level("solid"),
		"heavy_thunder": _get_character_level("heavy_thunder"),
		"blaze": _get_character_level("blaze")
	}

	var rest_level := int(supported_levels.get("rest", 0))
	if rest_level > 0:
		snapshot["rest_level"] = rest_level
		snapshot["rest_heal_rate"] += 1.8 + rest_level * 1.2
		snapshot["rest_damage_reduction"] += 0.05 + rest_level * 0.04
		if rest_level >= 3:
			snapshot["rest_field_radius"] = 84.0 + wood_count * 10.0
			snapshot["rest_field_slow"] = 0.24

	var thunder_level := int(supported_levels.get("thunder", 0))
	if thunder_level > 0:
		snapshot["thunder_level"] = thunder_level
		snapshot["thunder_damage"] = 22.0 + thunder_level * 12.0 + field_count * 3.0
		snapshot["thunder_radius"] += 48.0 + thunder_level * 16.0
		snapshot["thunder_cooldown"] = max(2.1, 5.8 - thunder_level * 0.9 - rain_count * 0.15)
		snapshot["thunder_chain"] = max(0, thunder_level - 1)
		if thunder_level >= 3:
			snapshot["thunder_zone_duration"] = 2.2 + field_count * 0.15
			snapshot["thunder_zone_damage"] = 10.0 + thunder_level * 4.0
			snapshot["thunder_zone_slow"] = 0.28

	var sprout_level := int(supported_levels.get("sprout", 0))
	if sprout_level > 0:
		snapshot["sprout_level"] = sprout_level
		snapshot["sprout_damage"] = 7.0 + sprout_level * 4.0 + wood_count * 1.2
		snapshot["sprout_radius"] = 38.0 + sprout_level * 14.0 + field_count * 4.0
		snapshot["sprout_slow"] = 0.12 + sprout_level * 0.08
		snapshot["sprout_cooldown"] = max(3.0, 7.0 - sprout_level * 1.0)

	var move_level := int(supported_levels.get("move", 0)) + int(supported_levels.get("swift", 0))
	if move_level > 0:
		snapshot["move_level"] = move_level
		snapshot["move_speed_bonus"] += 18.0 + move_level * 16.0
		snapshot["slash_damage"] = 12.0 + move_level * 8.5
		snapshot["slash_width"] = 34.0 + move_level * 3.0
		snapshot["slash_threshold"] = max(42.0, 92.0 - move_level * 10.0)

	var wave_level := int(supported_levels.get("wave", 0))
	if wave_level > 0:
		snapshot["wave_level"] = wave_level
		snapshot["wave_damage"] = 15.0 + wave_level * 8.0 + water_count * 2.0
		snapshot["wave_radius"] = 86.0 + wave_level * 28.0
		snapshot["wave_slow"] = 0.15 + wave_level * 0.08
		snapshot["wave_push"] = 180.0 + wave_level * 70.0
		snapshot["wave_cooldown"] = max(4.0, 7.4 - wave_level * 0.9)

	var chant_level := int(supported_levels.get("chant", 0))
	if chant_level > 0:
		snapshot["chant_level"] = chant_level
		snapshot["echo_chance"] += 0.12 + chant_level * 0.08
		snapshot["echo_delay"] = max(0.14, 0.36 - chant_level * 0.05)
		snapshot["echo_damage_multiplier"] += chant_level * 0.1

	var guard_level := int(supported_levels.get("guard", 0)) + int(supported_levels.get("solid", 0))
	if guard_level > 0:
		snapshot["guard_level"] = guard_level
		snapshot["guard_radius"] += 82.0 + guard_level * 18.0
		snapshot["guard_slow"] = 0.10 + min(0.18, guard_level * 0.04)
		snapshot["damage_reduction"] += 0.04 + guard_level * 0.03
		if guard_level >= 3:
			snapshot["guard_attack_bonus"] = 0.16 + max(0.0, float(guard_level - 3)) * 0.04

	var flame_level := int(supported_levels.get("flame", 0)) + int(supported_levels.get("blaze", 0))
	if flame_level > 0:
		snapshot["attack_damage_bonus"] += 6.0 + flame_level * 4.0
		snapshot["projectile_scale_bonus"] += flame_level * 0.04
		snapshot["projectile_speed_bonus"] += int(supported_levels.get("blaze", 0)) * 18.0

	var array_level := int(supported_levels.get("array", 0))
	if array_level > 0:
		snapshot["guard_radius"] += array_level * 8.0
		snapshot["thunder_radius"] += array_level * 8.0
		snapshot["sprout_radius"] += array_level * 6.0

	var heavy_thunder_level := int(supported_levels.get("heavy_thunder", 0))
	if heavy_thunder_level > 0:
		snapshot["thunder_level"] = max(int(snapshot.get("thunder_level", 0)), 3)
		snapshot["thunder_damage"] += heavy_thunder_level * 12.0
		snapshot["thunder_radius"] += heavy_thunder_level * 10.0
		snapshot["thunder_cooldown"] = max(1.7, float(snapshot.get("thunder_cooldown", 999.0)) - heavy_thunder_level * 0.22)

	var word_skill_lookup: Dictionary = {}
	for word_skill_id in unlocked_word_skills.keys():
		word_skill_lookup[word_skill_id] = true
	snapshot["word_skills_lookup"] = word_skill_lookup

	if word_skill_lookup.has("thunder_rain"):
		snapshot["thunder_damage"] += 10.0
		snapshot["thunder_zone_damage"] += 3.0
	if word_skill_lookup.has("wind_walk"):
		snapshot["move_level"] += 1
		snapshot["move_speed_bonus"] += 26.0
		snapshot["slash_damage"] += 14.0
		snapshot["slash_threshold"] = max(30.0, float(snapshot.get("slash_threshold", 9999.0)) * 0.72)
	if word_skill_lookup.has("heart_mind"):
		snapshot["echo_chance"] += 0.15
		snapshot["echo_damage_multiplier"] += 0.16
	if word_skill_lookup.has("guard_array"):
		snapshot["guard_radius"] += 24.0
		snapshot["guard_array_damage"] = 10.0 + field_count * 2.0
	if word_skill_lookup.has("flame_rain"):
		snapshot["attack_damage_bonus"] += 12.0
		snapshot["thunder_radius"] += 10.0
		snapshot["projectile_scale_bonus"] += 0.08

	snapshot["damage_reduction"] = clamp(float(snapshot.get("damage_reduction", 0.0)), 0.0, 0.7)
	snapshot["echo_chance"] = clamp(float(snapshot.get("echo_chance", 0.0)), 0.0, 0.8)

	var dominant_character: Dictionary = {}
	for entry in snapshot.get("characters", []):
		if dominant_character.is_empty() or int(entry.get("level", 0)) > int(dominant_character.get("level", 0)):
			dominant_character = entry
	if not dominant_character.is_empty():
		snapshot["core_glyph"] = str(dominant_character.get("char", str(snapshot.get("route_glyph", "文"))))
	else:
		snapshot["core_glyph"] = str(snapshot.get("route_glyph", "文"))

	return snapshot


func _resolve_character_progress(rune_id: String, result: Dictionary) -> void:
	var newly_unlocked: Array[String] = []
	for character_id in database.get_character_ids():
		if characters.has(character_id):
			continue
		if not _can_unlock_character(character_id):
			continue
		if characters.size() >= character_slots:
			result["messages"].append("合字槽已满，新的字诀暂时无法入列。")
			break
		_unlock_character(character_id, result)
		newly_unlocked.append(character_id)

	var upgradable: Array = []
	for character_id in characters.keys():
		var character_level = _get_character_level(character_id)
		if character_level >= 3:
			continue
		if _does_rune_support_character(rune_id, character_id):
			upgradable.append(character_id)

	upgradable.sort_custom(func(a: String, b: String) -> bool:
		return _get_character_priority(a) > _get_character_priority(b)
	)

	var upgrades_remaining = 2
	for character_id in upgradable:
		if upgrades_remaining <= 0:
			break
		if newly_unlocked.has(character_id):
			continue
		_level_character(character_id, result)
		upgrades_remaining -= 1


func _resolve_word_skills(result: Dictionary) -> void:
	for word_skill_id in database.get_word_skill_ids():
		if unlocked_word_skills.has(word_skill_id):
			continue
		var definition: Dictionary = database.get_word_skill_def(word_skill_id)
		if _is_word_skill_ready(definition):
			unlocked_word_skills[word_skill_id] = true
			result["word_skill_events"].append(word_skill_id)
			result["messages"].append("词技成形「%s」：%s" % [str(definition.get("word", word_skill_id)), str(definition.get("effect", ""))])


func _get_rune_weight(rune_id: String) -> float:
	var weight = 1.0
	if not active_route.is_empty():
		var route_def: Dictionary = database.get_route_def(active_route)
		var bias: Array = route_def.get("bias", [])
		if bias.has(rune_id):
			weight += 2.8

	var current_count = _get_rune_count(rune_id)
	weight += max(0.0, 1.2 - current_count * 0.2)

	for character_id in database.get_character_ids():
		var definition: Dictionary = database.get_character_def(character_id)
		if definition.is_empty():
			continue
		var sources: Array = _get_definition_sources(definition)
		if sources.is_empty():
			continue
		if characters.has(character_id):
			if _does_rune_support_character(rune_id, character_id) and _get_character_level(character_id) < 3:
				weight += 1.25
			continue

		var missing_sources = 0
		var matched_source = false
		for source_id in sources:
			if str(source_id) == rune_id:
				matched_source = true
			if not _has_source(str(source_id)):
				missing_sources += 1
		if matched_source and missing_sources <= 1:
			weight += 2.2
		elif matched_source:
			weight += 0.8

	for word_skill_id in database.get_word_skill_ids():
		if unlocked_word_skills.has(word_skill_id):
			continue
		var definition: Dictionary = database.get_word_skill_def(word_skill_id)
		var requirements: Dictionary = definition.get("requirements", {})
		var secondary_sources: Array = requirements.get("secondary_source", [])
		if secondary_sources.has(rune_id) or secondary_sources.has("scroll_%s" % rune_id):
			var main_char = str(definition.get("main_char", ""))
			if _get_character_level(main_char) >= int(requirements.get("main_level", 3)) - 1:
				weight += 1.5

	return weight


func _pick_weighted_ids(candidates: Array, rng: RandomNumberGenerator, count: int) -> Array:
	var pool: Array = candidates.duplicate(true)
	var picked: Array = []

	while picked.size() < count and not pool.is_empty():
		var total_weight = 0.0
		for entry in pool:
			total_weight += max(0.01, float(entry.get("weight", 1.0)))

		var roll = rng.randf_range(0.0, total_weight)
		var cursor = 0.0
		var chosen_index = 0
		for index in range(pool.size()):
			cursor += max(0.01, float(pool[index].get("weight", 1.0)))
			if roll <= cursor:
				chosen_index = index
				break

		var chosen: Dictionary = pool[chosen_index]
		picked.append(str(chosen.get("id", "")))
		pool.remove_at(chosen_index)

	return picked


func _build_rune_detail(rune_id: String) -> String:
	var hints: Array[String] = []
	for character_id in database.get_character_ids():
		var definition: Dictionary = database.get_character_def(character_id)
		if definition.is_empty():
			continue
		var sources: Array = _get_definition_sources(definition)
		if not sources.has(rune_id):
			continue
		hints.append(str(definition.get("char", character_id)))
		if hints.size() >= 3:
			break
	if hints.is_empty():
		return "会立刻强化基础战斗手感。"
	return "可推动：%s" % " / ".join(hints)


func _unlock_character(character_id: String, result: Dictionary) -> void:
	var definition: Dictionary = database.get_character_def(character_id)
	if definition.is_empty():
		return

	var character_data = {
		"level": 1,
		"path": str(definition.get("path", "")),
		"char": str(definition.get("char", "字")),
		"category": str(definition.get("category", "advanced"))
	}
	characters[character_id] = character_data
	result["character_events"].append({
		"id": character_id,
		"event": "unlock",
		"level": 1
	})

	var prefix = "字诀"
	if str(definition.get("category", "")) == "structural":
		prefix = "合字"
	result["messages"].append("%s成形「%s」Lv.1：%s" % [prefix, str(definition.get("char", character_id)), str(definition.get("role", ""))])


func _level_character(character_id: String, result: Dictionary) -> void:
	if not characters.has(character_id):
		return

	var current_level = _get_character_level(character_id)
	if current_level >= 3:
		return

	var next_level = current_level + 1
	characters[character_id]["level"] = next_level
	result["character_events"].append({
		"id": character_id,
		"event": "level_up",
		"level": next_level
	})

	var definition: Dictionary = database.get_character_def(character_id)
	var levels: Dictionary = definition.get("levels", {})
	var description = str(levels.get(str(next_level), str(definition.get("role", ""))))
	result["messages"].append("「%s」提升到 Lv.%d：%s" % [str(definition.get("char", character_id)), next_level, description])


func _can_unlock_character(character_id: String) -> bool:
	var definition: Dictionary = database.get_character_def(character_id)
	if definition.is_empty():
		return false

	var category = str(definition.get("category", "advanced"))
	if category == "structural":
		for source_id in definition.get("compose_from", []):
			if not _has_source(str(source_id)):
				return false
		return true

	if character_id == "solid":
		for source_id in definition.get("advance_from", []):
			if _get_source_level(str(source_id)) >= 2:
				return true
		return false

	for source_id in definition.get("advance_from", []):
		if not _has_source(str(source_id)):
			return false
		if database.character_defs.has(str(source_id)) and _get_source_level(str(source_id)) < 2:
			return false
	return true


func _is_word_skill_ready(definition: Dictionary) -> bool:
	var main_char = str(definition.get("main_char", ""))
	if main_char.is_empty():
		return false

	var requirements: Dictionary = definition.get("requirements", {})
	var required_level = int(requirements.get("main_level", 3))
	if _get_character_level(main_char) < required_level:
		return false

	var secondary_sources: Array = requirements.get("secondary_source", [])
	if secondary_sources.is_empty():
		return true

	for source_id_variant in secondary_sources:
		var source_id = str(source_id_variant)
		if _has_source(source_id):
			return true
		if source_id.begins_with("scroll_"):
			var rune_id = source_id.trim_prefix("scroll_")
			if _get_rune_count(rune_id) > 0:
				return true
		if source_id.begins_with("event_"):
			var event_id = source_id.trim_prefix("event_")
			if _get_rune_count(event_id) > 0:
				return true
		if source_id.begins_with("relic_"):
			var relic_id = source_id.trim_prefix("relic_")
			if _get_character_level(relic_id) > 0 or _get_rune_count(relic_id) > 0:
				return true
	return false


func _get_definition_sources(definition: Dictionary) -> Array:
	if str(definition.get("category", "advanced")) == "structural":
		return definition.get("compose_from", [])
	return definition.get("advance_from", [])


func _does_rune_support_character(rune_id: String, character_id: String) -> bool:
	var definition: Dictionary = database.get_character_def(character_id)
	if definition.is_empty():
		return false
	var sources: Array = _get_definition_sources(definition)
	if sources.has(rune_id):
		return true

	var path = str(definition.get("path", ""))
	if not path.is_empty() and active_route == path:
		var route_def: Dictionary = database.get_route_def(active_route)
		if route_def.get("bias", []).has(rune_id):
			return true
	return false


func _get_character_priority(character_id: String) -> float:
	var definition: Dictionary = database.get_character_def(character_id)
	if definition.is_empty():
		return 0.0

	var priority = float(_get_character_level(character_id))
	if str(definition.get("path", "")) == active_route:
		priority += 3.0
	if str(definition.get("category", "")) == "structural":
		priority += 1.2
	return priority


func _has_source(source_id: String) -> bool:
	if rune_inventory.has(source_id):
		return _get_rune_count(source_id) > 0
	return _get_character_level(source_id) > 0


func _get_source_level(source_id: String) -> int:
	if rune_inventory.has(source_id):
		return _get_rune_count(source_id)
	return _get_character_level(source_id)


func _get_rune_count(rune_id: String) -> int:
	return int(rune_inventory.get(rune_id, 0))


func _get_character_level(character_id: String) -> int:
	if not characters.has(character_id):
		return 0
	return int(characters[character_id].get("level", 0))


func _get_character_entries() -> Array:
	var entries: Array = []
	for character_id in characters.keys():
		var definition: Dictionary = database.get_character_def(character_id)
		if definition.is_empty():
			continue
		entries.append({
			"id": character_id,
			"char": str(definition.get("char", character_id)),
			"name": str(definition.get("char", character_id)),
			"level": _get_character_level(character_id),
			"path": str(definition.get("path", "")),
			"role": str(definition.get("role", "")),
			"category": str(definition.get("category", "advanced"))
		})

	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("level", 0)) == int(b.get("level", 0)):
			return str(a.get("id", "")) < str(b.get("id", ""))
		return int(a.get("level", 0)) > int(b.get("level", 0))
	)
	return entries


func _get_word_skill_entries() -> Array:
	var entries: Array = []
	for word_skill_id in unlocked_word_skills.keys():
		var definition: Dictionary = database.get_word_skill_def(word_skill_id)
		if definition.is_empty():
			continue
		entries.append({
			"id": word_skill_id,
			"word": str(definition.get("word", word_skill_id)),
			"effect": str(definition.get("effect", ""))
		})

	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return str(a.get("word", "")) < str(b.get("word", ""))
	)
	return entries


func _glyph_list_for_ids(ids: Array) -> String:
	var glyphs: Array[String] = []
	for source_id_variant in ids:
		var source_id = str(source_id_variant)
		var rune_def: Dictionary = database.get_rune_def(source_id)
		if rune_def.is_empty():
			continue
		glyphs.append(str(rune_def.get("char", source_id)))
	return " ".join(glyphs)
