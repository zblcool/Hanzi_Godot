extends RefCounted


func pick_interlude_radical(rng: RandomNumberGenerator, radical_order: Array) -> String:
	var picks: Array[String] = pick_interlude_radicals(rng, radical_order, 1)
	return String(picks[0]) if not picks.is_empty() else "日"


func pick_interlude_radicals(rng: RandomNumberGenerator, radical_order: Array, count: int = 2) -> Array[String]:
	var candidates: Array[String] = []
	for radical_variant in radical_order:
		var radical: String = String(radical_variant)
		if radical.is_empty():
			continue
		candidates.append(radical)
	if candidates.is_empty():
		return ["日"]

	var requested_count: int = maxi(1, count)
	var picks: Array[String] = []
	var pool: Array[String] = candidates.duplicate()
	while picks.size() < requested_count and not pool.is_empty():
		var pick_index: int = rng.randi_range(0, pool.size() - 1)
		picks.append(String(pool[pick_index]))
		pool.remove_at(pick_index)
	while picks.size() < requested_count:
		picks.append(String(picks[0]))
	return picks


func next_chamber_id_after_interlude(current_chamber_id: String, chamber_order: Array) -> String:
	var current_index: int = chamber_order.find(current_chamber_id)
	if current_index == -1:
		return String(chamber_order[0])
	return String(chamber_order[mini(current_index + 1, chamber_order.size() - 1)])


func chamber_id_for_completed_bosses(completed_bosses: int, chamber_order: Array) -> String:
	var chamber_index: int = mini(maxi(completed_bosses, 0), chamber_order.size() - 1)
	return String(chamber_order[chamber_index])


func build_draft_lean_data(
	lean_id: String,
	radicals: Array[String],
	label_zh: String,
	label_en: String,
	completed_bosses: int
) -> Dictionary:
	var unique_radicals: Array[String] = _dedupe_radicals(radicals)
	if unique_radicals.is_empty():
		return {}
	return {
		"id": lean_id,
		"radicals": unique_radicals,
		"label": label_zh,
		"english_label": label_en,
		"expires_after_bosses": completed_bosses + 1
	}


func extract_draft_lean_radicals(interlude_draft_lean_data: Dictionary) -> Array[String]:
	var radicals: Array[String] = []
	var radicals_variant: Variant = interlude_draft_lean_data.get("radicals", [])
	if radicals_variant is Array:
		for radical_variant in radicals_variant:
			var radical: String = String(radical_variant)
			if radical.is_empty() or radicals.has(radical):
				continue
			radicals.append(radical)
	return radicals


func draft_lean_text(interlude_draft_lean_data: Dictionary, explicit_radicals: Array[String] = []) -> String:
	var lean_radicals: Array[String] = explicit_radicals if not explicit_radicals.is_empty() else extract_draft_lean_radicals(interlude_draft_lean_data)
	if lean_radicals.is_empty():
		return ""
	return " / ".join(lean_radicals)


func draft_lean_bonus(
	interlude_draft_lean_data: Dictionary,
	radical: String,
	focused_bonus: float,
	base_bonus: float
) -> float:
	var lean_radicals: Array[String] = extract_draft_lean_radicals(interlude_draft_lean_data)
	if lean_radicals.is_empty() or not lean_radicals.has(radical):
		return 0.0
	return focused_bonus if lean_radicals.size() <= 2 else base_bonus


func append_draft_lean_copy(
	headline: String,
	radical: String,
	interlude_draft_lean_data: Dictionary,
	focused_bonus: float,
	base_bonus: float,
	english_mode: bool
) -> String:
	if draft_lean_bonus(interlude_draft_lean_data, radical, focused_bonus, base_bonus) <= 0.0:
		return headline
	var lean_text: String = draft_lean_text(interlude_draft_lean_data)
	if lean_text.is_empty():
		return headline
	return (
		"%s Chamber lean: %s."
		if english_mode
		else "%s 卷间余势：%s。"
	) % [headline, lean_text]


func build_chamber_carry_snapshot(chamber_modifier_id: String, interlude_draft_lean_data: Dictionary) -> Dictionary:
	var snapshot: Dictionary = {}
	if not chamber_modifier_id.is_empty():
		snapshot["modifier_id"] = chamber_modifier_id
	var lean_radicals: Array[String] = extract_draft_lean_radicals(interlude_draft_lean_data)
	if not lean_radicals.is_empty():
		snapshot["draft_radicals"] = lean_radicals
	return snapshot


func _dedupe_radicals(radicals: Array[String]) -> Array[String]:
	var unique_radicals: Array[String] = []
	for radical_variant in radicals:
		var radical: String = String(radical_variant)
		if radical.is_empty() or unique_radicals.has(radical):
			continue
		unique_radicals.append(radical)
	return unique_radicals
