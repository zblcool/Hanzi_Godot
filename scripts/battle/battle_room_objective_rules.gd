extends RefCounted


func blank_state() -> Dictionary:
	return {
		"id": "",
		"data": {},
		"total": 0,
		"remaining": 0,
		"gatekeeper_active": false,
		"gatekeeper_id": ""
	}


func is_active(state: Dictionary) -> bool:
	var objective_id: String = String(state.get("id", ""))
	var remaining: int = int(state.get("remaining", 0))
	var gatekeeper_active: bool = bool(state.get("gatekeeper_active", false))
	return not objective_id.is_empty() and (remaining > 0 or gatekeeper_active)


func begin_objective(objective: Dictionary) -> Dictionary:
	var objective_id: String = String(objective.get("id", ""))
	var pickups: Array[Dictionary] = pickup_definitions(objective)
	if objective_id.is_empty() or pickups.is_empty():
		return {}
	return {
		"state": {
			"id": objective_id,
			"data": objective,
			"total": pickups.size(),
			"remaining": pickups.size(),
			"gatekeeper_active": false,
			"gatekeeper_id": ""
		},
		"pickups": pickups
	}


func pickup_definitions(objective: Dictionary) -> Array[Dictionary]:
	var objective_id: String = String(objective.get("id", ""))
	var glyph: String = String(objective.get("glyph", "封"))
	var pickups: Array[Dictionary] = []
	var pickup_positions_variant: Variant = objective.get("pickup_positions", [])
	if pickup_positions_variant is Array:
		for position_variant in pickup_positions_variant:
			if not (position_variant is Vector3):
				continue
			var pickup_supply_id: String = "seal"
			var pickup_meta: Dictionary = {
				"room_objective_id": objective_id,
				"room_objective_glyph": glyph
			}
			if objective_id == "seal_gatekeeper":
				pickup_supply_id = "beacon"
				pickup_meta["pickup_label"] = glyph
				pickup_meta["pickup_tint"] = objective.get("seal_tint", Color(0.94, 0.44, 0.34, 1.0))
				pickup_meta["pickup_glow"] = objective.get("seal_glow", Color(1.0, 0.82, 0.66, 1.0))
			pickups.append({
				"world_position": position_variant,
				"supply_id": pickup_supply_id,
				"meta": pickup_meta
			})
	return pickups


func advance_on_pickup(state: Dictionary, pickup_objective_id: String) -> Dictionary:
	var objective_id: String = String(state.get("id", ""))
	if objective_id.is_empty() or pickup_objective_id.is_empty() or pickup_objective_id != objective_id:
		return {
			"handled": false,
			"state": state
		}

	var next_state: Dictionary = state.duplicate(true)
	if objective_id == "seal_gatekeeper":
		next_state["remaining"] = 0
		next_state["gatekeeper_active"] = true
		return {
			"handled": true,
			"mode": "gatekeeper",
			"state": next_state
		}

	var remaining: int = maxi(int(next_state.get("remaining", 0)) - 1, 0)
	next_state["remaining"] = remaining
	return {
		"handled": true,
		"mode": "remaining" if remaining > 0 else "complete",
		"state": next_state
	}


func with_gatekeeper_id(state: Dictionary, gatekeeper_id: String, gatekeeper_active: bool = true) -> Dictionary:
	var next_state: Dictionary = state.duplicate(true)
	next_state["gatekeeper_id"] = gatekeeper_id
	next_state["gatekeeper_active"] = gatekeeper_active
	return next_state


func clear_gatekeeper(state: Dictionary) -> Dictionary:
	var next_state: Dictionary = state.duplicate(true)
	next_state["gatekeeper_active"] = false
	next_state["gatekeeper_id"] = ""
	return next_state
