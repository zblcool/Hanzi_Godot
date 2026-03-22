extends Node

const AUDIO_MIX_RATE := 32000.0
const AUDIO_BUFFER_LENGTH := 0.18
const AUDIO_MAX_FRAME_CHUNK := 768
const AUDIO_MASTER_GAIN := 0.38
const AUDIO_MAX_VOICES := 32


class SynthVoice:
	var waveform: String = "sine"
	var start_freq: float = 440.0
	var end_freq: float = 440.0
	var amplitude: float = 0.1
	var duration: float = 0.12
	var attack: float = 0.006
	var release: float = 0.08
	var pan: float = 0.0
	var delay: float = 0.0
	var elapsed: float = 0.0
	var phase: float = 0.0
	var noise_state: float = 11731.0

	func _init(config: Dictionary = {}) -> void:
		waveform = String(config.get("waveform", "sine"))
		start_freq = float(config.get("start_freq", 440.0))
		end_freq = float(config.get("end_freq", start_freq))
		amplitude = float(config.get("amplitude", 0.1))
		duration = maxf(float(config.get("duration", 0.12)), 0.02)
		attack = maxf(float(config.get("attack", 0.006)), 0.001)
		release = maxf(float(config.get("release", 0.08)), 0.001)
		pan = clampf(float(config.get("pan", 0.0)), -1.0, 1.0)
		delay = maxf(float(config.get("delay", 0.0)), 0.0)
		phase = float(config.get("phase", 0.0))
		noise_state = maxf(float(config.get("noise_state", 11731.0)), 1.0)

	func is_finished() -> bool:
		return delay <= 0.0 and elapsed >= duration

	func mix(sample_rate: float) -> Vector2:
		var delta := 1.0 / sample_rate
		if delay > 0.0:
			delay = maxf(delay - delta, 0.0)
			return Vector2.ZERO
		if elapsed >= duration:
			return Vector2.ZERO

		var progress := clampf(elapsed / maxf(duration, 0.001), 0.0, 1.0)
		var frequency := maxf(20.0, lerpf(start_freq, end_freq, progress))
		var envelope := 1.0
		if elapsed < attack:
			envelope *= elapsed / maxf(attack, 0.001)
		var release_start := maxf(duration - release, attack)
		if elapsed > release_start:
			envelope *= maxf(0.0, (duration - elapsed) / maxf(release, 0.001))

		var sample := 0.0
		match waveform:
			"triangle":
				phase = wrapf(phase + TAU * frequency * delta, 0.0, TAU)
				sample = asin(sin(phase)) * (2.0 / PI)
			"square":
				phase = wrapf(phase + TAU * frequency * delta, 0.0, TAU)
				sample = 1.0 if sin(phase) >= 0.0 else -1.0
			"saw":
				phase = wrapf(phase + TAU * frequency * delta, 0.0, TAU)
				sample = phase / PI - 1.0
			"noise":
				noise_state = fmod(noise_state * 16807.0, 2147483647.0)
				sample = noise_state / 1073741823.5 - 1.0
			_:
				phase = wrapf(phase + TAU * frequency * delta, 0.0, TAU)
				sample = sin(phase)

		elapsed += delta
		var value := sample * amplitude * envelope
		var clamped_pan := clampf(pan, -1.0, 1.0)
		var left_gain := sqrt(0.5 * (1.0 - clamped_pan))
		var right_gain := sqrt(0.5 * (1.0 + clamped_pan))
		return Vector2(value * left_gain, value * right_gain)


var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var audio_player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var active_voices: Array = []
var sound_timestamps: Dictionary = {}


func _ready() -> void:
	rng.randomize()
	_setup_audio_player()
	set_process(true)


func _process(_delta: float) -> void:
	_fill_audio_buffer()


func play_attack(kind: String, intensity: float = 1.0) -> void:
	var power := clampf(intensity, 0.72, 1.6)
	match kind:
		"scholar_shot":
			if not _can_play(kind, 0.05):
				return
			_push_voice({"waveform": "triangle", "start_freq": 690.0, "end_freq": 420.0, "amplitude": 0.17 * power, "duration": 0.09, "release": 0.11, "pan": _small_pan()})
			_push_voice({"waveform": "sine", "start_freq": 980.0, "end_freq": 760.0, "amplitude": 0.08 * power, "duration": 0.07, "release": 0.09, "delay": 0.012, "pan": _small_pan()})
		"sword_slash":
			if not _can_play(kind, 0.08):
				return
			_push_voice({"waveform": "noise", "start_freq": 1200.0, "end_freq": 800.0, "amplitude": 0.055 * power, "duration": 0.05, "release": 0.06, "pan": _small_pan()})
			_push_voice({"waveform": "saw", "start_freq": 320.0, "end_freq": 175.0, "amplitude": 0.12 * power, "duration": 0.12, "release": 0.14, "pan": _small_pan()})
		"bright_volley":
			if not _can_play(kind, 0.08):
				return
			_push_voice({"waveform": "triangle", "start_freq": 620.0, "end_freq": 760.0, "amplitude": 0.12 * power, "duration": 0.11, "release": 0.15, "pan": _small_pan()})
			_push_voice({"waveform": "sine", "start_freq": 920.0, "end_freq": 1100.0, "amplitude": 0.055 * power, "duration": 0.08, "release": 0.11, "delay": 0.014, "pan": _small_pan()})
		"rest_wave":
			if not _can_play(kind, 0.14):
				return
			_push_voice({"waveform": "sine", "start_freq": 520.0, "end_freq": 700.0, "amplitude": 0.12 * power, "duration": 0.18, "release": 0.22})
			_push_voice({"waveform": "triangle", "start_freq": 780.0, "end_freq": 660.0, "amplitude": 0.07 * power, "duration": 0.14, "release": 0.18, "delay": 0.03, "pan": _small_pan()})
		"sea_wave":
			if not _can_play(kind, 0.12):
				return
			_push_voice({"waveform": "sine", "start_freq": 340.0, "end_freq": 250.0, "amplitude": 0.11 * power, "duration": 0.18, "release": 0.22})
			_push_voice({"waveform": "triangle", "start_freq": 520.0, "end_freq": 620.0, "amplitude": 0.055 * power, "duration": 0.12, "release": 0.16, "delay": 0.03, "pan": _small_pan()})
		"resolve_guard":
			if not _can_play(kind, 0.12):
				return
			_push_voice({"waveform": "noise", "start_freq": 760.0, "end_freq": 520.0, "amplitude": 0.05 * power, "duration": 0.06, "release": 0.08, "pan": _small_pan()})
			_push_voice({"waveform": "triangle", "start_freq": 250.0, "end_freq": 118.0, "amplitude": 0.13 * power, "duration": 0.16, "release": 0.2})
			_push_voice({"waveform": "sine", "start_freq": 460.0, "end_freq": 240.0, "amplitude": 0.055 * power, "duration": 0.12, "release": 0.16, "delay": 0.014, "pan": _small_pan()})
		"thunder_strike":
			if not _can_play(kind, 0.12):
				return
			_push_voice({"waveform": "noise", "start_freq": 520.0, "end_freq": 280.0, "amplitude": 0.06 * power, "duration": 0.07, "release": 0.09, "pan": _small_pan()})
			_push_voice({"waveform": "square", "start_freq": 190.0, "end_freq": 92.0, "amplitude": 0.13 * power, "duration": 0.18, "release": 0.2})
			_push_voice({"waveform": "triangle", "start_freq": 980.0, "end_freq": 430.0, "amplitude": 0.07 * power, "duration": 0.1, "release": 0.12, "delay": 0.01, "pan": _small_pan()})
		"flame_burst":
			if not _can_play(kind, 0.12):
				return
			_push_voice({"waveform": "noise", "start_freq": 880.0, "end_freq": 480.0, "amplitude": 0.055 * power, "duration": 0.08, "release": 0.1, "pan": _small_pan()})
			_push_voice({"waveform": "saw", "start_freq": 380.0, "end_freq": 142.0, "amplitude": 0.13 * power, "duration": 0.16, "release": 0.18})


func play_enemy_hit(enemy_type: String, hit_radius: float) -> void:
	if not _can_play("enemy_hit", 0.03):
		return
	var weight := clampf(hit_radius / 1.2, 0.7, 1.5)
	var power := weight
	if enemy_type == "elite":
		power *= 1.08
	elif enemy_type == "boss":
		power *= 1.2
	_push_voice({"waveform": "triangle", "start_freq": 120.0 / weight + rng.randf_range(0.0, 12.0), "end_freq": 54.0 / weight, "amplitude": 0.16 * power, "duration": 0.08, "release": 0.12, "pan": _small_pan()})
	_push_voice({"waveform": "noise", "start_freq": 220.0, "end_freq": 180.0, "amplitude": 0.05 * power, "duration": 0.04, "release": 0.05, "pan": _small_pan()})


func play_enemy_defeat(enemy_type: String) -> void:
	match enemy_type:
		"elite":
			if not _can_play("elite_break", 0.18):
				return
			_push_voice({"waveform": "triangle", "start_freq": 250.0, "end_freq": 118.0, "amplitude": 0.16, "duration": 0.18, "release": 0.22})
			_push_voice({"waveform": "sine", "start_freq": 480.0, "end_freq": 260.0, "amplitude": 0.07, "duration": 0.16, "release": 0.18, "delay": 0.02, "pan": _small_pan()})
		"boss":
			play_cue("boss_defeat", 1.08)


func play_pickup(supply_id: String, amount: float = 0.0) -> void:
	var power := 1.0
	var base_frequency := 1080.0
	match supply_id:
		"seal":
			base_frequency = 920.0
			power = 1.1
		"fury":
			base_frequency = 1200.0
			power = 1.08
		"brush":
			base_frequency = 1140.0
			power = 1.02
		"ink":
			base_frequency = 980.0
		"potion":
			base_frequency = 960.0
			power = 1.06
		_:
			base_frequency = 1080.0
	power *= clampf(0.9 + absf(amount) * 0.015, 0.9, 1.22)
	if not _can_play("pickup_%s" % supply_id, 0.05):
		return
	_push_voice({"waveform": "triangle", "start_freq": base_frequency, "end_freq": base_frequency * 0.92, "amplitude": 0.11 * power, "duration": 0.11, "release": 0.16, "pan": _small_pan()})
	_push_voice({"waveform": "sine", "start_freq": base_frequency * 1.34, "end_freq": base_frequency * 1.2, "amplitude": 0.06 * power, "duration": 0.09, "release": 0.12, "delay": 0.03, "pan": _small_pan()})


func play_player_hurt(severity: float = 1.0) -> void:
	if not _can_play("player_hurt", 0.08):
		return
	var power := clampf(0.9 + severity * 2.8, 0.9, 1.45)
	_push_voice({"waveform": "noise", "start_freq": 480.0, "end_freq": 220.0, "amplitude": 0.05 * power, "duration": 0.05, "release": 0.07, "pan": _small_pan()})
	_push_voice({"waveform": "saw", "start_freq": 240.0, "end_freq": 110.0, "amplitude": 0.12 * power, "duration": 0.16, "release": 0.18})


func play_cue(kind: String, intensity: float = 1.0) -> void:
	var power := clampf(intensity, 0.8, 1.4)
	match kind:
		"run_start":
			if not _can_play(kind, 0.4):
				return
			_push_voice({"waveform": "triangle", "start_freq": 300.0, "end_freq": 420.0, "amplitude": 0.12 * power, "duration": 0.22, "release": 0.26})
			_push_voice({"waveform": "sine", "start_freq": 520.0, "end_freq": 690.0, "amplitude": 0.07 * power, "duration": 0.18, "release": 0.22, "delay": 0.03})
		"wave_step":
			if not _can_play(kind, 0.18):
				return
			_push_voice({"waveform": "triangle", "start_freq": 380.0, "end_freq": 520.0, "amplitude": 0.1 * power, "duration": 0.12, "release": 0.16})
			_push_voice({"waveform": "sine", "start_freq": 640.0, "end_freq": 780.0, "amplitude": 0.055 * power, "duration": 0.08, "release": 0.11, "delay": 0.014})
		"wave_major":
			if not _can_play(kind, 0.3):
				return
			_push_voice({"waveform": "square", "start_freq": 182.0, "end_freq": 108.0, "amplitude": 0.12 * power, "duration": 0.2, "release": 0.24})
			_push_voice({"waveform": "triangle", "start_freq": 420.0, "end_freq": 660.0, "amplitude": 0.08 * power, "duration": 0.14, "release": 0.18, "delay": 0.02})
		"realm_shift":
			if not _can_play(kind, 0.5):
				return
			_push_voice({"waveform": "sine", "start_freq": 360.0, "end_freq": 520.0, "amplitude": 0.09 * power, "duration": 0.28, "release": 0.34})
			_push_voice({"waveform": "triangle", "start_freq": 720.0, "end_freq": 980.0, "amplitude": 0.05 * power, "duration": 0.2, "release": 0.24, "delay": 0.04, "pan": _small_pan()})
		"boss_appear":
			if not _can_play(kind, 0.8):
				return
			_push_voice({"waveform": "saw", "start_freq": 260.0, "end_freq": 120.0, "amplitude": 0.16 * power, "duration": 0.24, "release": 0.3})
			_push_voice({"waveform": "square", "start_freq": 460.0, "end_freq": 220.0, "amplitude": 0.08 * power, "duration": 0.18, "release": 0.22, "delay": 0.03})
			_push_voice({"waveform": "noise", "start_freq": 420.0, "end_freq": 210.0, "amplitude": 0.04 * power, "duration": 0.08, "release": 0.1, "delay": 0.02})
		"boss_defeat":
			if not _can_play(kind, 0.8):
				return
			_push_voice({"waveform": "triangle", "start_freq": 240.0, "end_freq": 460.0, "amplitude": 0.13 * power, "duration": 0.28, "release": 0.34})
			_push_voice({"waveform": "sine", "start_freq": 520.0, "end_freq": 860.0, "amplitude": 0.08 * power, "duration": 0.22, "release": 0.26, "delay": 0.04})


func _setup_audio_player() -> void:
	audio_player = AudioStreamPlayer.new()
	audio_player.name = "BattleAudioPlayer"
	audio_player.volume_db = -10.0
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = AUDIO_MIX_RATE
	stream.buffer_length = AUDIO_BUFFER_LENGTH
	audio_player.stream = stream
	add_child(audio_player)
	audio_player.play()
	playback = audio_player.get_stream_playback() as AudioStreamGeneratorPlayback


func _fill_audio_buffer() -> void:
	if audio_player == null or playback == null:
		if audio_player != null:
			playback = audio_player.get_stream_playback() as AudioStreamGeneratorPlayback
		if playback == null:
			return

	var frames_available := mini(playback.get_frames_available(), AUDIO_MAX_FRAME_CHUNK)
	if frames_available <= 0:
		return

	var frames := PackedVector2Array()
	frames.resize(frames_available)
	for frame_index in range(frames_available):
		var mixed := Vector2.ZERO
		for voice in active_voices:
			if voice is SynthVoice:
				mixed += voice.mix(AUDIO_MIX_RATE)
		mixed *= AUDIO_MASTER_GAIN
		frames[frame_index] = Vector2(clampf(mixed.x, -0.92, 0.92), clampf(mixed.y, -0.92, 0.92))

	playback.push_buffer(frames)
	_prune_finished_voices()


func _push_voice(config: Dictionary) -> void:
	if active_voices.size() >= AUDIO_MAX_VOICES:
		active_voices.pop_front()
	config["phase"] = config.get("phase", rng.randf_range(0.0, TAU))
	config["noise_state"] = config.get("noise_state", rng.randi_range(2048, 65535))
	active_voices.append(SynthVoice.new(config))


func _prune_finished_voices() -> void:
	var remaining: Array = []
	for voice in active_voices:
		if voice is SynthVoice and not voice.is_finished():
			remaining.append(voice)
	active_voices = remaining


func _can_play(tag: String, cooldown: float) -> bool:
	var now := Time.get_ticks_msec() * 0.001
	var previous := float(sound_timestamps.get(tag, -INF))
	if now - previous < cooldown:
		return false
	sound_timestamps[tag] = now
	return true


func _small_pan() -> float:
	return rng.randf_range(-0.22, 0.22)
