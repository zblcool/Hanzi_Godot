extends RefCounted

const PRESSURE_ENEMIES := ["archer", "assassin", "cavalry", "ritualist"]


func build_supply_drops(
	enemy_type: String,
	kills: int,
	rng: RandomNumberGenerator,
	health_potion_drop_meter: float,
	active_utility_pickups: int,
	active_fury_pickups: int,
	active_potion_pickups: int,
	reward_supply_active: bool,
	scroll_echo_active: bool,
	config: Dictionary
) -> Dictionary:
	var drops: Dictionary = {
		"paper": 0.0,
		"ink": 0.0,
		"seal": 0.0,
		"magnet": 0.0,
		"fury": 0.0,
		"potion": 0.0
	}

	match enemy_type:
		"swift":
			if rng.randf() < 0.12:
				_add_supply_drop(drops, "paper", 2.0)
		"tank":
			if rng.randf() < 0.28:
				_add_supply_drop(drops, "ink", 15.0)
		"archer":
			if rng.randf() < 0.24:
				_add_supply_drop(drops, "paper", 3.0)
		"assassin":
			if rng.randf() < 0.18:
				_add_supply_drop(drops, "paper", 3.0)
			if rng.randf() < 0.12:
				_add_supply_drop(drops, "seal", 1.0)
		"cavalry":
			if rng.randf() < 0.26:
				_add_supply_drop(drops, "paper", 4.0)
			if rng.randf() < 0.2:
				_add_supply_drop(drops, "seal", 1.0)
		"ritualist":
			if rng.randf() < 0.24:
				_add_supply_drop(drops, "paper", 3.0)
			if rng.randf() < 0.16:
				_add_supply_drop(drops, "ink", 14.0)
		"elite":
			_add_supply_drop(drops, "paper", 6.0)
			_add_supply_drop(drops, "seal", 1.0)
			_add_supply_drop(drops, "ink", 22.0)
		"boss":
			_add_supply_drop(drops, "paper", 10.0)
			_add_supply_drop(drops, "seal", 2.0)
			_add_supply_drop(drops, "ink", 34.0)
		_:
			if rng.randf() < 0.1:
				_add_supply_drop(drops, "paper", 2.0)

	if kills > 0 and kills % 12 == 0:
		_add_supply_drop(drops, "paper", 3.0)
	if kills > 0 and kills % 21 == 0:
		_add_supply_drop(drops, "ink", 16.0)

	_apply_chamber_modifier_supply_drops(
		drops,
		enemy_type,
		rng,
		reward_supply_active,
		scroll_echo_active,
		active_fury_pickups,
		int(config.get("enemy_utility_active_limit", 2)),
		float(config.get("scroll_echo_fury_drop_duration", 8.0)),
		float(config.get("scroll_echo_pressure_paper_chance", 0.3)),
		float(config.get("scroll_echo_basic_paper_chance", 0.12))
	)
	_add_enemy_utility_drop(
		drops,
		enemy_type,
		rng,
		active_utility_pickups,
		int(config.get("enemy_utility_active_limit", 2))
	)
	var next_health_potion_drop_meter: float = _resolve_health_potion_drop_meter(
		drops,
		rng,
		health_potion_drop_meter,
		active_potion_pickups,
		int(config.get("enemy_potion_active_limit", 2)),
		float(config.get("health_potion_drop_meter_step", 0.05)),
		float(config.get("health_potion_heal_ratio", 0.3))
	)
	return {
		"drops": drops,
		"health_potion_drop_meter": next_health_potion_drop_meter
	}


func _apply_chamber_modifier_supply_drops(
	drops: Dictionary,
	enemy_type: String,
	rng: RandomNumberGenerator,
	reward_supply_active: bool,
	scroll_echo_active: bool,
	active_fury_pickups: int,
	enemy_utility_active_limit: int,
	scroll_echo_fury_drop_duration: float,
	scroll_echo_pressure_paper_chance: float,
	scroll_echo_basic_paper_chance: float
) -> void:
	if reward_supply_active:
		match enemy_type:
			"elite":
				_add_supply_drop(drops, "paper", 2.0)
				_add_supply_drop(drops, "seal", 1.0)
			"boss":
				_add_supply_drop(drops, "paper", 4.0)
				_add_supply_drop(drops, "seal", 1.0)
			_:
				if rng.randf() < 0.16:
					_add_supply_drop(drops, "paper", 1.0)

	if not scroll_echo_active or enemy_type == "boss":
		return

	var pressure_enemy: bool = PRESSURE_ENEMIES.has(enemy_type)
	if enemy_type == "elite":
		_add_supply_drop(drops, "paper", 2.0)
		if active_fury_pickups < enemy_utility_active_limit and float(drops.get("fury", 0.0)) <= 0.0:
			_add_supply_drop(drops, "fury", scroll_echo_fury_drop_duration)
		return

	if pressure_enemy:
		if rng.randf() < scroll_echo_pressure_paper_chance:
			_add_supply_drop(drops, "paper", 2.0)
	elif rng.randf() < scroll_echo_basic_paper_chance:
		_add_supply_drop(drops, "paper", 1.0)


func _add_enemy_utility_drop(
	drops: Dictionary,
	enemy_type: String,
	rng: RandomNumberGenerator,
	active_utility_pickups: int,
	enemy_utility_active_limit: int
) -> void:
	if enemy_type == "boss":
		_add_supply_drop(drops, "magnet", 1.0)
		_add_supply_drop(drops, "fury", 10.0)
		return

	if active_utility_pickups >= enemy_utility_active_limit:
		return

	var pickup_id: String = "magnet" if rng.randf() < 0.5 else "fury"
	var pickup_amount: float = 1.0 if pickup_id == "magnet" else 10.0
	if enemy_type == "elite":
		if rng.randf() < 0.7:
			_add_supply_drop(drops, pickup_id, pickup_amount)
		return

	if rng.randf() < 0.035:
		_add_supply_drop(drops, pickup_id, pickup_amount)


func _resolve_health_potion_drop_meter(
	drops: Dictionary,
	rng: RandomNumberGenerator,
	health_potion_drop_meter: float,
	active_potion_pickups: int,
	enemy_potion_active_limit: int,
	health_potion_drop_meter_step: float,
	health_potion_heal_ratio: float
) -> float:
	if active_potion_pickups >= enemy_potion_active_limit:
		return health_potion_drop_meter

	var next_health_potion_drop_meter: float = minf(1.0, health_potion_drop_meter + health_potion_drop_meter_step)
	if rng.randf() >= next_health_potion_drop_meter:
		return next_health_potion_drop_meter

	_add_supply_drop(drops, "potion", health_potion_heal_ratio)
	return maxf(0.0, next_health_potion_drop_meter - 1.0)


func _add_supply_drop(drops: Dictionary, supply_id: String, amount: float) -> void:
	drops[supply_id] = float(drops.get(supply_id, 0.0)) + amount
