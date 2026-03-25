extends RefCounted


func _guidance_text(guidance_text: Callable, key: String, fallback_zh: String, fallback_en: String) -> String:
	return String(guidance_text.call(key, fallback_zh, fallback_en))


func _guidance_format(
	guidance_format: Callable,
	key: String,
	fallback_zh: String,
	fallback_en: String,
	values: Array = []
) -> String:
	return String(guidance_format.call(key, fallback_zh, fallback_en, values))


func present_phrase_discovery(
	hud,
	accent: Color,
	phrase_text: String,
	reward_copy: String,
	glyph: String,
	guidance_text: Callable,
	guidance_format: Callable,
	log_battle_event: Callable
) -> void:
	if hud != null:
		hud.show_banner(
			_guidance_format(
				guidance_format,
				"phrase_guardian_banner_format",
				"句阵守卫 · %s",
				"Sentence Guardian · %s",
				[phrase_text]
			),
			accent,
			1.7
		)
		hud.show_reveal(
			_guidance_text(guidance_text, "phrase_guardian_reveal_title", "守句现身", "Guarded Phrase"),
			phrase_text,
			_guidance_format(
				guidance_format,
				"phrase_guardian_reveal_body_format",
				"击败守句魁首，即可%s。",
				"Defeat the guardian to %s.",
				[reward_copy]
			),
			accent,
			glyph,
			2.8
		)
		hud.set_tip(
			_guidance_format(
				guidance_format,
				"phrase_guardian_tip_format",
				"这段房间里已经显出「%s」句阵。击败守句魁首后，就能%s。",
				"The guarded phrase `%s` has surfaced in this chamber. Defeat its guardian to %s.",
				[phrase_text, reward_copy]
			)
		)
	log_battle_event.call(
		_guidance_format(
			guidance_format,
			"phrase_guardian_log_format",
			"句阵守卫 · %s",
			"Phrase Guardian · %s",
			[phrase_text]
		),
		accent
	)


func present_phrase_reward(
	hud,
	accent: Color,
	phrase_text: String,
	reward_copy: String,
	glyph: String,
	guidance_text: Callable,
	guidance_format: Callable,
	log_battle_event: Callable
) -> void:
	if hud != null:
		hud.show_banner(
			_guidance_format(
				guidance_format,
				"phrase_revealed_banner_format",
				"句成异动 · %s",
				"Phrase Revealed · %s",
				[phrase_text]
			),
			accent,
			1.9
		)
		hud.show_reveal(
			_guidance_text(guidance_text, "phrase_revealed_reveal_title", "句成异动", "Verse Revealed"),
			phrase_text,
			_guidance_format(
				guidance_format,
				"phrase_revealed_reward_format",
				"奖励 · %s",
				"Reward · %s",
				[reward_copy]
			),
			accent,
			glyph,
			2.7
		)
		hud.set_tip(
			_guidance_format(
				guidance_format,
				"phrase_revealed_tip_format",
				"「%s」句阵已经显成，句阵赏赐会为你%s。",
				"The guarded phrase `%s` is now yours. The sentence reward will %s.",
				[phrase_text, reward_copy]
			)
		)
	log_battle_event.call(
		_guidance_format(
			guidance_format,
			"phrase_revealed_log_format",
			"句成异动 · %s · %s",
			"Phrase Revealed · %s · %s",
			[phrase_text, reward_copy]
		),
		accent
	)
