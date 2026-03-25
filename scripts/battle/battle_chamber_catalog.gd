extends RefCounted


func intro_override_chamber_id(battle_intro: Dictionary, chamber_layouts: Dictionary) -> String:
	if battle_intro.is_empty():
		return ""
	var preset_variant: Variant = battle_intro.get("start_preset", {})
	if not (preset_variant is Dictionary):
		return ""
	var preset := preset_variant as Dictionary
	var chamber_id: String = String(preset.get("start_chamber_id", ""))
	if chamber_id.is_empty() or not chamber_layouts.has(chamber_id):
		return ""
	return chamber_id


func current_chamber_data(current_chamber_id: String, chamber_layouts: Dictionary, chamber_order: Array) -> Dictionary:
	var chamber_variant: Variant = chamber_layouts.get(current_chamber_id, chamber_layouts.get(String(chamber_order[0]), {}))
	if chamber_variant is Dictionary:
		return chamber_variant as Dictionary
	return {}


func battle_chamber_entry(chamber_id: String, battle_chamber_content: Dictionary) -> Dictionary:
	var chamber_collection_variant: Variant = battle_chamber_content.get("chambers", {})
	if chamber_collection_variant is Dictionary:
		var chamber_variant: Variant = (chamber_collection_variant as Dictionary).get(chamber_id, {})
		if chamber_variant is Dictionary:
			return chamber_variant as Dictionary
	return {}


func battle_room_objective_entry(objective: Dictionary, current_chamber_id: String, battle_chamber_content: Dictionary) -> Dictionary:
	var chamber_entry: Dictionary = battle_chamber_entry(String(objective.get("chamber_id", current_chamber_id)), battle_chamber_content)
	var objective_collection_variant: Variant = chamber_entry.get("objectives", {})
	if objective_collection_variant is Dictionary:
		var objective_variant: Variant = (objective_collection_variant as Dictionary).get(String(objective.get("id", "")), {})
		if objective_variant is Dictionary:
			return objective_variant as Dictionary
	return {}


func battle_room_gatekeeper_entry(
	objective: Dictionary,
	gatekeeper: Dictionary,
	current_chamber_id: String,
	battle_chamber_content: Dictionary
) -> Dictionary:
	var objective_entry: Dictionary = battle_room_objective_entry(objective, current_chamber_id, battle_chamber_content)
	var gatekeeper_collection_variant: Variant = objective_entry.get("gatekeepers", {})
	if gatekeeper_collection_variant is Dictionary:
		var gatekeeper_variant: Variant = (gatekeeper_collection_variant as Dictionary).get(String(gatekeeper.get("id", "")), {})
		if gatekeeper_variant is Dictionary:
			return gatekeeper_variant as Dictionary
	return {}


func current_chamber_accent(
	current_chamber_id: String,
	chamber_layouts: Dictionary,
	chamber_order: Array,
	fallback: Color
) -> Color:
	var chamber_data: Dictionary = current_chamber_data(current_chamber_id, chamber_layouts, chamber_order)
	return Color(chamber_data.get("accent", fallback))


func current_chamber_glyph(current_chamber_id: String, chamber_layouts: Dictionary, chamber_order: Array, fallback: String = "界") -> String:
	var chamber_data: Dictionary = current_chamber_data(current_chamber_id, chamber_layouts, chamber_order)
	return String(chamber_data.get("glyph", fallback))


func available_chamber_exit_objectives(current_chamber_id: String, chamber_layouts: Dictionary, chamber_order: Array) -> Array[Dictionary]:
	var chamber_data: Dictionary = current_chamber_data(current_chamber_id, chamber_layouts, chamber_order)
	var objectives: Array[Dictionary] = []
	var objectives_variant: Variant = chamber_data.get("exit_objectives", [])
	if objectives_variant is Array:
		for objective_variant in objectives_variant:
			if objective_variant is Dictionary:
				var objective_copy: Dictionary = (objective_variant as Dictionary).duplicate(true)
				objective_copy["chamber_id"] = current_chamber_id
				objectives.append(objective_copy)
	if not objectives.is_empty():
		return objectives

	var objective_variant: Variant = chamber_data.get("exit_objective", {})
	if objective_variant is Dictionary:
		var objective_copy: Dictionary = (objective_variant as Dictionary).duplicate(true)
		objective_copy["chamber_id"] = current_chamber_id
		objectives.append(objective_copy)
	return objectives


func current_chamber_exit_objective(
	room_objective_data: Dictionary,
	current_chamber_id: String,
	chamber_layouts: Dictionary,
	chamber_order: Array
) -> Dictionary:
	if not room_objective_data.is_empty():
		return room_objective_data
	var available_objectives: Array[Dictionary] = available_chamber_exit_objectives(current_chamber_id, chamber_layouts, chamber_order)
	if not available_objectives.is_empty():
		return available_objectives[0]
	return {}


func pick_chamber_exit_objective(
	rng: RandomNumberGenerator,
	current_chamber_id: String,
	chamber_layouts: Dictionary,
	chamber_order: Array
) -> Dictionary:
	var candidates: Array[Dictionary] = available_chamber_exit_objectives(current_chamber_id, chamber_layouts, chamber_order)
	if candidates.is_empty():
		return {}
	return candidates[rng.randi_range(0, candidates.size() - 1)]


func current_chamber_break_beacon_position(current_chamber_id: String, chamber_layouts: Dictionary, chamber_order: Array) -> Vector3:
	var chamber_data: Dictionary = current_chamber_data(current_chamber_id, chamber_layouts, chamber_order)
	var beacon_position_variant: Variant = chamber_data.get("break_beacon_position", Vector3.ZERO)
	if beacon_position_variant is Vector3:
		return beacon_position_variant
	return Vector3.ZERO
