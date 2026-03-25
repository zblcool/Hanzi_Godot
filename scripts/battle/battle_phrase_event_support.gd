extends RefCounted


func build_phrase_events(chamber_order: Array, chamber_layouts: Dictionary) -> Array[Dictionary]:
	var phrase_events: Array[Dictionary] = []
	for chamber_id_variant in chamber_order:
		var chamber_id: String = String(chamber_id_variant)
		var chamber_variant: Variant = chamber_layouts.get(chamber_id, {})
		if not (chamber_variant is Dictionary):
			continue
		var chamber_data := chamber_variant as Dictionary
		var chamber_phrase_events_variant: Variant = chamber_data.get("phrase_events", [])
		if not (chamber_phrase_events_variant is Array):
			continue
		for event_variant in chamber_phrase_events_variant:
			if not (event_variant is Dictionary):
				continue
			var phrase_event: Dictionary = (event_variant as Dictionary).duplicate(true)
			phrase_event["chamber_id"] = chamber_id
			phrase_event["discovered"] = false
			phrase_event["guardian_spawned"] = false
			phrase_event["guardian_defeated"] = false
			phrase_event["reward_granted"] = false
			phrase_events.append(phrase_event)
	return phrase_events


func events_for_chamber(phrase_events: Array[Dictionary], current_chamber_id: String, chamber_id: String = "") -> Array[Dictionary]:
	var chamber_events: Array[Dictionary] = []
	var target_chamber: String = current_chamber_id if chamber_id.is_empty() else chamber_id
	for phrase_event in phrase_events:
		if String(phrase_event.get("chamber_id", "")) == target_chamber:
			chamber_events.append(phrase_event)
	return chamber_events


func find_event(phrase_events: Array[Dictionary], event_id: String) -> Dictionary:
	for phrase_event in phrase_events:
		if String(phrase_event.get("id", "")) == event_id:
			return phrase_event
	return {}


func display_text(phrase_event: Dictionary, english_mode: bool) -> String:
	return String(phrase_event.get("english_text" if english_mode else "text", phrase_event.get("text", "")))


func reward_copy(
	phrase_event: Dictionary,
	format_guidance: Callable,
	plain_guidance: Callable
) -> String:
	var reward_type: String = String(phrase_event.get("reward_type", "heal"))
	var reward_amount: int = int(round(float(phrase_event.get("reward_amount", 0.0))))
	match reward_type:
		"heal":
			return String(format_guidance.call(
				"phrase_reward_heal_format",
				"回复 %d 点气血",
				"restore %d vitality",
				[reward_amount]
			))
		"xp":
			return String(format_guidance.call(
				"phrase_reward_xp_format",
				"获得 %d 点字墨",
				"gain %d ink",
				[reward_amount]
			))
		"reveal":
			return String(plain_guidance.call(
				"phrase_reward_reveal",
				"扩开附近迷雾显形",
				"widen nearby fog reveal"
			))
		"radical":
			var reward_radical: String = String(phrase_event.get("reward_radical", "日"))
			return String(format_guidance.call(
				"phrase_reward_radical_format",
				"获得偏旁「%s」",
				"gain radical %s",
				[reward_radical]
			))
		_:
			return String(plain_guidance.call(
				"phrase_reward_default",
				"领取句阵赏赐",
				"claim the sentence reward"
			))
