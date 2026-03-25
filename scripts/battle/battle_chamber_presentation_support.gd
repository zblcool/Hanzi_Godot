extends RefCounted


func preview_threat_ids(next_wave: int) -> Array[String]:
	if next_wave >= 5:
		return ["elite", "cavalry", "ritualist"]
	if next_wave >= 4:
		return ["cavalry", "ritualist", "assassin"]
	if next_wave >= 3:
		return ["assassin", "ritualist", "archer"]
	if next_wave >= 2:
		return ["archer", "tank", "swift"]
	return ["swift", "basic"]


func preview_threat_names(next_wave: int, localized_enemy_data: Callable) -> Array[String]:
	var names: Array[String] = []
	for enemy_id in preview_threat_ids(next_wave):
		var enemy_data: Dictionary = localized_enemy_data.call(enemy_id)
		names.append(String(enemy_data.get("name", enemy_id)))
	return names


func preview_pressure_copy(next_wave: int, is_big_wave: bool, guidance_text: Callable) -> String:
	if is_big_wave:
		return String(guidance_text.call(
			"chamber_pressure_big_wave",
			"刷怪速度和场上字灵上限都会一起抬高。",
			"Enemy cap and spawn rate both rise together."
		))
	match next_wave:
		2:
			return String(guidance_text.call(
				"chamber_pressure_wave_2",
				"弓手会开始混进字潮，远程牵制变多。",
				"Ranged pressure starts mixing into the tide."
			))
		3:
			return String(guidance_text.call(
				"chamber_pressure_wave_3",
				"突刺和地阵会开始叠在一起施压。",
				"Dashes and ground arrays start overlapping."
			))
		4:
			return String(guidance_text.call(
				"chamber_pressure_wave_4",
				"冲锋线会开始切穿混编字潮。",
				"Charge lines start cutting through mixed waves."
			))
		_:
			return String(guidance_text.call(
				"chamber_pressure_wave_default",
				"魁首会更常压阵，混编节奏会更硬。",
				"Elites begin anchoring the pack more often."
			))


func preview_lines(
	next_chamber_id: String,
	next_wave: int,
	english_mode: bool,
	big_wave: bool,
	localized_field_phase_theme: Callable,
	field_phase_theme_for_wave: Callable,
	localized_chamber_name: Callable,
	battle_interlude_text: Callable,
	battle_interlude_format: Callable,
	guidance_text: Callable,
	localized_enemy_data: Callable
) -> Array[String]:
	var localized_next_theme: Dictionary = localized_field_phase_theme.call(field_phase_theme_for_wave.call(next_wave))
	var next_theme_name := String(localized_next_theme.get("name", "Inkfield" if english_mode else "字境"))
	var next_chamber_name := String(localized_chamber_name.call(next_chamber_id))
	var threat_joiner := ", " if english_mode else " / "
	var threat_mix := threat_joiner.join(PackedStringArray(preview_threat_names(next_wave, localized_enemy_data)))
	var wave_suffix := ""
	if big_wave:
		wave_suffix = String(battle_interlude_text.call("preview_wave_major_suffix", " · 大潮压境", " · Major Surge"))
	return [
		String(battle_interlude_format.call("preview_line_chamber_format", "下一房间 · %s", "Chamber · %s", [next_chamber_name])),
		String(battle_interlude_format.call("preview_line_wave_format", "下一波 · 第 %d 波%s", "Next Wave · %d%s", [next_wave, wave_suffix])),
		String(battle_interlude_format.call("preview_line_realm_format", "字境 · %s", "Realm · %s", [next_theme_name])),
		String(battle_interlude_format.call("preview_line_pressure_format", "压境重点 · %s", "Pressure · %s", [preview_pressure_copy(next_wave, big_wave, guidance_text)])),
		String(battle_interlude_format.call("preview_line_threat_mix_format", "威胁混编 · %s", "Threat Mix · %s", [threat_mix]))
	]


func interlude_title(current_scroll_label: String, battle_interlude_text: Callable) -> String:
	return "%s · %s" % [
		current_scroll_label,
		String(battle_interlude_text.call("chamber_interlude_suffix", "卷间抉择", "Between Chambers"))
	]


func transition_title(next_chamber_id: String, localized_chamber_name: Callable, battle_interlude_format: Callable) -> String:
	var next_chamber_name := String(localized_chamber_name.call(next_chamber_id))
	return String(battle_interlude_format.call(
		"transition_title_format",
		"房间已清 · %s",
		"Chamber Cleared · %s",
		[next_chamber_name]
	))


func transition_body(next_chamber_id: String, localized_chamber_name: Callable, battle_interlude_format: Callable) -> String:
	var next_chamber_name := String(localized_chamber_name.call(next_chamber_id))
	return String(battle_interlude_format.call(
		"transition_body_format",
		"这次卷间抉择已经定下，下一段会进入「%s」。真正续卷后，迷雾显形、场景布置和下一波压境都会按新房间重新铺开。\n\n先再看一眼下一段预览，准备好后再续卷入深层。",
		"Your between-chambers choice is sealed. %s is next, and entering it will reset the fog, field props, and pressure layout around a fresh chamber state.\n\nCheck the final preview below, then continue deeper when ready.",
		[next_chamber_name]
	))
