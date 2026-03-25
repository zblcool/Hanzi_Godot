extends RefCounted


func is_big_wave(wave_index: int, big_wave_interval: int) -> bool:
	return wave_index > 0 and wave_index % big_wave_interval == 0


func enemy_cap(
	threat_level: int,
	base_enemy_cap: int,
	max_regular_enemy_cap: int,
	big_wave_enemy_cap: int,
	big_wave: bool,
	boss_active: bool,
	boss_enemy_cap: int = 24
) -> int:
	var cap: int = base_enemy_cap + maxi(threat_level - 1, 0) * 2
	cap = mini(cap, big_wave_enemy_cap if big_wave else max_regular_enemy_cap)
	if boss_active:
		cap = mini(cap, boss_enemy_cap)
	return cap


func spawn_batch_size(threat_level: int, elapsed_time: float, big_wave: bool) -> int:
	var batch: int = 1
	if threat_level >= 3:
		batch += 1
	if elapsed_time > 90.0:
		batch += 1
	if big_wave:
		batch += 2
	return batch


func current_spawn_interval(elapsed_time: float, big_wave: bool, boss_active: bool) -> float:
	var interval: float = maxf(0.46, 1.35 - elapsed_time * 0.012)
	if big_wave:
		interval *= 0.72
	if boss_active:
		interval *= 1.12
	return maxf(interval, 0.3)


func pick_enemy_type(rng: RandomNumberGenerator, elapsed_time: float) -> String:
	var roll: float = rng.randf()
	if elapsed_time < 18.0:
		return "basic" if roll < 0.72 else "swift"
	if elapsed_time < 36.0:
		if roll < 0.38:
			return "basic"
		if roll < 0.62:
			return "swift"
		if roll < 0.82:
			return "tank"
		return "archer"
	if elapsed_time < 64.0:
		if roll < 0.24:
			return "basic"
		if roll < 0.42:
			return "swift"
		if roll < 0.58:
			return "tank"
		if roll < 0.74:
			return "archer"
		if roll < 0.89:
			return "assassin"
		return "ritualist"
	if elapsed_time < 95.0:
		if roll < 0.16:
			return "basic"
		if roll < 0.3:
			return "swift"
		if roll < 0.44:
			return "tank"
		if roll < 0.58:
			return "archer"
		if roll < 0.73:
			return "assassin"
		if roll < 0.88:
			return "ritualist"
		return "cavalry"
	if roll < 0.12:
		return "basic"
	if roll < 0.23:
		return "swift"
	if roll < 0.35:
		return "tank"
	if roll < 0.49:
		return "archer"
	if roll < 0.64:
		return "assassin"
	if roll < 0.78:
		return "ritualist"
	if roll < 0.93:
		return "cavalry"
	return "elite"


func boss_spawn_index_for_elapsed(time_value: float, boss_spawn_times: Array) -> int:
	var next_index: int = 0
	for spawn_time_variant in boss_spawn_times:
		var spawn_time: float = float(spawn_time_variant)
		if time_value >= spawn_time:
			next_index += 1
	return next_index
