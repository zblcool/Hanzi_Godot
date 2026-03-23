extends Node

signal soundtrack_rotated(track_id: String)

const AUDIO_MIX_RATE := 32000.0
const AUDIO_BUFFER_LENGTH := 0.18
const AUDIO_MAX_FRAME_CHUNK := 768
const AUDIO_MASTER_GAIN := 0.38
const AUDIO_MAX_VOICES := 96
const MUSIC_SCHEDULE_AHEAD := 0.24
const MUSIC_START_DELAY := 0.08
const MUSIC_TRACK_ORDER := ["mosslightCanopy", "fireflyFootpath"]
const NOTE_OFFSETS := {
	"C": 0,
	"D": 2,
	"E": 4,
	"F": 5,
	"G": 7,
	"A": 9,
	"B": 11
}
const MUSIC_TRACK_SPECS := {
	"mosslightCanopy": {
		"bpm": 82.0,
		"loop_range": [2, 3],
		"channels": [
			{
				"waveform": "square",
				"volume": 0.024,
				"gate_steps": 1.1,
				"attack": 0.008,
				"release_mul": 1.12,
				"shimmer_semitones": 12.0,
				"shimmer_volume": 0.24,
				"pan": -0.16,
				"rows": [
					"E5 . B4 . C5 . B4 . A4 . B4 . C5 . B4 .",
					"G4 . A4 . B4 . C5 . B4 . A4 . G4 . E4 ."
				]
			},
			{
				"waveform": "triangle",
				"volume": 0.018,
				"gate_steps": 2.4,
				"attack": 0.012,
				"release_mul": 1.26,
				"pan": 0.18,
				"rows": [
					"E4 . G4 . . B4 . G4 . D5 . B4 . G4 . .",
					"C5 . G4 . . A4 . E4 . G4 . B4 . G4 . ."
				]
			},
			{
				"waveform": "triangle",
				"volume": 0.042,
				"gate_steps": 3.7,
				"attack": 0.006,
				"release_mul": 1.08,
				"pan": 0.0,
				"rows": [
					"E2 . . . C3 . . . A2 . . . B2 . . .",
					"G2 . . . D3 . . . E2 . . . B2 . . ."
				]
			}
		],
		"drums": [
			{
				"hit": "kick",
				"volume": 0.48,
				"rows": [
					"k . . . . . . . k . . . . . . .",
					"k . . . . . . . k . . . . . . ."
				]
			},
			{
				"hit": "hat",
				"volume": 0.4,
				"rows": [
					". . h . . . h . . . h . . . h .",
					". . h . . . h . . . h . . . h ."
				]
			},
			{
				"hit": "spark",
				"volume": 0.26,
				"rows": [
					". . . . . s . . . . . . . s . .",
					". . . . . s . . . . . . . s . ."
				]
			}
		]
	},
	"fireflyFootpath": {
		"bpm": 108.0,
		"loop_range": [2, 2],
		"channels": [
			{
				"waveform": "square",
				"volume": 0.026,
				"gate_steps": 1.08,
				"attack": 0.007,
				"release_mul": 1.08,
				"shimmer_semitones": 12.0,
				"shimmer_volume": 0.22,
				"pan": -0.12,
				"rows": [
					"G5 . B5 . D6 . B5 . A5 . G5 . E5 . D5 . E5 .",
					"G5 . A5 . B5 . D6 . B5 . G5 . A5 . B5 ."
				]
			},
			{
				"waveform": "triangle",
				"volume": 0.02,
				"gate_steps": 1.9,
				"attack": 0.01,
				"release_mul": 1.18,
				"pan": 0.2,
				"rows": [
					". D5 . G5 . D5 . B4 . C5 . E5 . C5 . A4",
					". D5 . F#5 . D5 . B4 . C5 . E5 . D5 . G4"
				]
			},
			{
				"waveform": "triangle",
				"volume": 0.046,
				"gate_steps": 3.4,
				"attack": 0.006,
				"release_mul": 1.06,
				"pan": 0.0,
				"rows": [
					"G2 . . . E2 . . . A2 . . . D2 . . .",
					"G2 . . . E2 . . . C3 . . . D3 . . ."
				]
			}
		],
		"drums": [
			{
				"hit": "kick",
				"volume": 0.56,
				"rows": [
					"k . . . k . . . k . . . k . . .",
					"k . . . k . . . k . . . k . . ."
				]
			},
			{
				"hit": "snare",
				"volume": 0.46,
				"rows": [
					". . . . s . . . . . . . s . . .",
					". . . . s . . . . . . . s . . ."
				]
			},
			{
				"hit": "hat",
				"volume": 0.42,
				"rows": [
					". h . h . h . h . h . h . h . h",
					". h . h . h . h . h . h . h . h"
				]
			}
		]
	}
}


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
var music_library: Dictionary = {}
var current_music_track_id: String = ""
var music_step_index := 0
var music_next_step_at := 0.0
var music_loops_completed := 0
var music_loop_target := 1


func _ready() -> void:
	rng.randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_library = _build_music_library()
	_setup_audio_player()
	set_process(true)


func _process(_delta: float) -> void:
	_schedule_music()
	_fill_audio_buffer()


func set_music_track(track_id: String, restart: bool = false) -> void:
	var normalized_track_id := String(track_id).strip_edges()
	if normalized_track_id.is_empty() or not music_library.has(normalized_track_id):
		return
	if not restart and current_music_track_id == normalized_track_id:
		return
	current_music_track_id = normalized_track_id
	music_step_index = 0
	music_next_step_at = 0.0
	music_loops_completed = 0
	var track_variant: Variant = music_library.get(normalized_track_id, {})
	if track_variant is Dictionary:
		music_loop_target = _pick_music_loop_target(track_variant as Dictionary)
	else:
		music_loop_target = 1


func debug_music_state() -> Dictionary:
	return {
		"track_id": current_music_track_id,
		"step_index": music_step_index,
		"loops_completed": music_loops_completed,
		"loop_target": music_loop_target,
		"active_voices": active_voices.size(),
		"next_step_at": music_next_step_at
	}


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
		"ground_warning":
			if not _can_play(kind, 0.12):
				return
			_push_voice({"waveform": "triangle", "start_freq": 420.0, "end_freq": 560.0, "amplitude": 0.085 * power, "duration": 0.14, "release": 0.18})
			_push_voice({"waveform": "sine", "start_freq": 760.0, "end_freq": 980.0, "amplitude": 0.045 * power, "duration": 0.12, "release": 0.14, "delay": 0.024, "pan": _small_pan()})
		"ground_bloom":
			if not _can_play(kind, 0.12):
				return
			_push_voice({"waveform": "square", "start_freq": 210.0, "end_freq": 128.0, "amplitude": 0.13 * power, "duration": 0.16, "release": 0.18})
			_push_voice({"waveform": "noise", "start_freq": 620.0, "end_freq": 280.0, "amplitude": 0.045 * power, "duration": 0.08, "release": 0.1, "delay": 0.01, "pan": _small_pan()})
		"line_warning":
			if not _can_play(kind, 0.1):
				return
			_push_voice({"waveform": "saw", "start_freq": 250.0, "end_freq": 410.0, "amplitude": 0.1 * power, "duration": 0.12, "release": 0.14, "pan": _small_pan()})
			_push_voice({"waveform": "triangle", "start_freq": 600.0, "end_freq": 840.0, "amplitude": 0.05 * power, "duration": 0.1, "release": 0.12, "delay": 0.018, "pan": _small_pan()})
		"line_release":
			if not _can_play(kind, 0.1):
				return
			_push_voice({"waveform": "square", "start_freq": 165.0, "end_freq": 104.0, "amplitude": 0.12 * power, "duration": 0.15, "release": 0.18})
			_push_voice({"waveform": "noise", "start_freq": 560.0, "end_freq": 220.0, "amplitude": 0.05 * power, "duration": 0.06, "release": 0.08, "delay": 0.012, "pan": _small_pan()})
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


func _build_music_library() -> Dictionary:
	var parsed_library: Dictionary = {}
	for track_id_variant in MUSIC_TRACK_SPECS.keys():
		var track_id := String(track_id_variant)
		var track_spec_variant: Variant = MUSIC_TRACK_SPECS.get(track_id, {})
		if not (track_spec_variant is Dictionary):
			continue
		var track_spec := (track_spec_variant as Dictionary).duplicate(true)
		var parsed_channels: Array = []
		var parsed_drums: Array = []
		var parsed_track := {
			"bpm": float(track_spec.get("bpm", 90.0)),
			"loop_range": track_spec.get("loop_range", [1, 1]),
			"channels": parsed_channels,
			"drums": parsed_drums,
			"total_steps": 1
		}
		var total_steps := 1
		for channel_variant in track_spec.get("channels", []):
			if not (channel_variant is Dictionary):
				continue
			var channel := (channel_variant as Dictionary).duplicate(true)
			var notes := _parse_pattern(channel.get("rows", []))
			channel.erase("rows")
			channel["notes"] = notes
			total_steps = maxi(total_steps, notes.size())
			parsed_channels.append(channel)
		for drum_variant in track_spec.get("drums", []):
			if not (drum_variant is Dictionary):
				continue
			var drum := (drum_variant as Dictionary).duplicate(true)
			var pattern := _parse_pattern(drum.get("rows", []))
			drum.erase("rows")
			drum["pattern"] = pattern
			total_steps = maxi(total_steps, pattern.size())
			parsed_drums.append(drum)
		parsed_track["step_duration"] = 60.0 / maxf(float(parsed_track.get("bpm", 90.0)), 1.0) / 4.0
		parsed_track["total_steps"] = total_steps
		parsed_library[track_id] = parsed_track
	return parsed_library


func _pick_music_loop_target(track: Dictionary) -> int:
	var loop_range_variant: Variant = track.get("loop_range", [1, 1])
	if not (loop_range_variant is Array):
		return 1
	var loop_range := loop_range_variant as Array
	if loop_range.size() < 2:
		return 1
	var min_loops := maxi(1, int(loop_range[0]))
	var max_loops := maxi(min_loops, int(loop_range[1]))
	return rng.randi_range(min_loops, max_loops)


func _choose_next_music_track(previous_id: String) -> String:
	var candidates: Array[String] = []
	if MUSIC_TRACK_ORDER.size() > 1 and not previous_id.is_empty() and rng.randf() < 0.72:
		for track_id_variant in MUSIC_TRACK_ORDER:
			var track_id := String(track_id_variant)
			if track_id != previous_id and music_library.has(track_id):
				candidates.append(track_id)
	if candidates.is_empty():
		for track_id_variant in MUSIC_TRACK_ORDER:
			var track_id := String(track_id_variant)
			if music_library.has(track_id):
				candidates.append(track_id)
	if candidates.is_empty():
		return ""
	return candidates[rng.randi_range(0, candidates.size() - 1)]


func _parse_pattern(rows_variant: Variant) -> Array:
	var tokens: Array = []
	if not (rows_variant is Array):
		return tokens
	for row_variant in rows_variant:
		var row := String(row_variant).strip_edges()
		if row.is_empty():
			continue
		for token in row.split(" ", false):
			var cleaned := String(token).strip_edges()
			if cleaned.is_empty():
				continue
			tokens.append("" if cleaned == "." else cleaned)
	return tokens


func _schedule_music() -> void:
	if current_music_track_id.is_empty():
		return
	var track_variant: Variant = music_library.get(current_music_track_id, {})
	if not (track_variant is Dictionary):
		return
	var track := track_variant as Dictionary
	var total_steps := maxi(int(track.get("total_steps", 1)), 1)
	var step_duration := maxf(float(track.get("step_duration", 0.15)), 0.02)
	var now := Time.get_ticks_usec() * 0.000001
	if music_next_step_at <= 0.0:
		music_next_step_at = now + MUSIC_START_DELAY
	while music_next_step_at < now + MUSIC_SCHEDULE_AHEAD:
		var delay := maxf(music_next_step_at - now, 0.0)
		_schedule_music_step(track, music_step_index, delay, step_duration)
		music_step_index += 1
		if music_step_index >= total_steps:
			music_step_index = 0
			music_loops_completed += 1
			if music_loops_completed >= music_loop_target:
				var next_track_id := _choose_next_music_track(current_music_track_id)
				if not next_track_id.is_empty():
					set_music_track(next_track_id, true)
					soundtrack_rotated.emit(next_track_id)
				return
		music_next_step_at += step_duration


func _schedule_music_step(track: Dictionary, step_index: int, delay: float, step_duration: float) -> void:
	for channel_variant in track.get("channels", []):
		if not (channel_variant is Dictionary):
			continue
		var channel := channel_variant as Dictionary
		var notes_variant: Variant = channel.get("notes", [])
		if not (notes_variant is Array):
			continue
		var notes := notes_variant as Array
		if notes.is_empty():
			continue
		var note := String(notes[step_index % notes.size()])
		if note.is_empty():
			continue
		_schedule_music_tone(channel, note, delay, step_duration)
	for drum_variant in track.get("drums", []):
		if not (drum_variant is Dictionary):
			continue
		var drum := drum_variant as Dictionary
		var pattern_variant: Variant = drum.get("pattern", [])
		if not (pattern_variant is Array):
			continue
		var pattern := pattern_variant as Array
		if pattern.is_empty():
			continue
		var hit := String(pattern[step_index % pattern.size()])
		if hit.is_empty():
			continue
		_schedule_music_drum(String(drum.get("hit", hit)), delay, float(drum.get("volume", 1.0)))


func _schedule_music_tone(channel: Dictionary, note: String, delay: float, step_duration: float) -> void:
	var frequency := _note_to_frequency(note)
	if frequency <= 0.0:
		return
	var duration := maxf(step_duration * float(channel.get("gate_steps", 1.0)), step_duration * 0.8)
	var amplitude := float(channel.get("volume", 0.02))
	var pan := clampf(float(channel.get("pan", 0.0)), -1.0, 1.0)
	_push_voice({
		"waveform": String(channel.get("waveform", "square")),
		"start_freq": frequency,
		"end_freq": frequency * 0.998,
		"amplitude": amplitude,
		"duration": duration,
		"attack": float(channel.get("attack", 0.008)),
		"release": maxf(duration * float(channel.get("release_mul", 1.08)), duration * 0.7),
		"delay": delay,
		"pan": pan
	})
	var shimmer_semitones := float(channel.get("shimmer_semitones", 0.0))
	if absf(shimmer_semitones) < 0.001:
		return
	var shimmer_frequency := _transpose_frequency(frequency, shimmer_semitones)
	_push_voice({
		"waveform": "triangle",
		"start_freq": shimmer_frequency,
		"end_freq": shimmer_frequency * 0.999,
		"amplitude": amplitude * float(channel.get("shimmer_volume", 0.22)),
		"duration": duration * 0.9,
		"attack": 0.01,
		"release": duration,
		"delay": delay,
		"pan": clampf(pan * 0.6, -1.0, 1.0)
	})


func _schedule_music_drum(hit: String, delay: float, volume: float = 1.0) -> void:
	match hit:
		"kick":
			_push_voice({"waveform": "triangle", "start_freq": 112.0, "end_freq": 52.0, "amplitude": 0.024 * volume, "duration": 0.12, "attack": 0.004, "release": 0.14, "delay": delay})
			_push_voice({"waveform": "noise", "start_freq": 180.0, "end_freq": 120.0, "amplitude": 0.0042 * volume, "duration": 0.03, "attack": 0.003, "release": 0.03, "delay": delay})
		"snare":
			_push_voice({"waveform": "noise", "start_freq": 900.0, "end_freq": 520.0, "amplitude": 0.0085 * volume, "duration": 0.06, "attack": 0.003, "release": 0.06, "delay": delay, "pan": _small_pan()})
			_push_voice({"waveform": "triangle", "start_freq": 220.0, "end_freq": 166.0, "amplitude": 0.008 * volume, "duration": 0.06, "attack": 0.004, "release": 0.08, "delay": delay})
		"spark":
			_push_voice({"waveform": "noise", "start_freq": 1800.0, "end_freq": 1200.0, "amplitude": 0.0048 * volume, "duration": 0.04, "attack": 0.003, "release": 0.04, "delay": delay, "pan": _small_pan()})
		_:
			_push_voice({"waveform": "noise", "start_freq": 2200.0, "end_freq": 1600.0, "amplitude": 0.006 * volume, "duration": 0.035, "attack": 0.002, "release": 0.035, "delay": delay, "pan": _small_pan()})


func _note_to_frequency(note_token: String) -> float:
	var note := String(note_token).strip_edges()
	if note.is_empty():
		return -1.0
	var letter := note.substr(0, 1)
	var octave_text := note.substr(1, note.length() - 1)
	var accidental := ""
	if octave_text.begins_with("#") or octave_text.begins_with("b"):
		accidental = octave_text.substr(0, 1)
		octave_text = octave_text.substr(1, octave_text.length() - 1)
	if octave_text.is_empty() or not NOTE_OFFSETS.has(letter):
		return -1.0
	var octave := int(octave_text)
	var accidental_offset := 1 if accidental == "#" else (-1 if accidental == "b" else 0)
	var semitone := int(NOTE_OFFSETS.get(letter, 0)) + accidental_offset
	var midi := (octave + 1) * 12 + semitone
	return 440.0 * pow(2.0, float(midi - 69) / 12.0)


func _transpose_frequency(frequency: float, semitones: float) -> float:
	return frequency * pow(2.0, semitones / 12.0)


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
