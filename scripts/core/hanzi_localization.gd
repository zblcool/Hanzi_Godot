extends RefCounted

const HERO_EN := {
	"scholar": {
		"name": "Scholar",
		"title": "Ink Volley",
		"role_label": "Ranged control",
		"focus": "Collect radicals with steady pacing and bring fused glyphs online earlier.",
		"tags": ["Lock-on", "Volley", "Stable fusion"],
		"weapon": "Brush array / auto-targeting bolts",
		"description": "Build radicals safely and hold the field open through steady ink volleys.",
		"record_title": "A scholar who tests the scroll with words",
		"record_body": "He treats the remnant scroll like a page that still answers back. Instead of forcing one solution, he wins by writing the board open through patience, coverage, and steady glyph growth.",
		"record_excerpt": "Set down one stroke first, then see how the scroll answers.",
		"record_source": "Remnant Scroll Notes",
		"trait_label": "Blank Page Opening",
		"trait_description": "Without the burden of frontline melee, he is best at nurturing any route from the first radical until a phrase art is ready.",
		"active_skill_name": "Paperweight Array",
		"active_skill_description": "Mirroring the hanziHero web prototype, the scholar slams down a paper array ahead of him to push enemies back and leave a protective glyph zone that damages and slows.",
		"route_hint": "Secure the first formed glyph, then decide whether this run wants sustain, area control, or lock-on pressure. The scholar is strongest when one route gets written deep first.",
		"progression_cards": [
			{
				"title": "Open the Scroll",
				"description": "Without a fixed opener, follow the first drops into a stable clear or sustain line, then decide which glyph route this run should deepen.",
				"tags": ["明", "海", "休"]
			},
			{
				"title": "Midgame Continuation",
				"description": "Once the first glyph stands, add crowd control or target pressure to keep safe distance instead of spreading into every side route.",
				"tags": ["雷", "明", "海"]
			},
			{
				"title": "Inkstone Phrase",
				"description": "Refine the most reliable main route first so it can take over the midgame. The scholar prefers depth over even spread.",
				"tags": ["明月", "海啸", "休养"]
			}
		],
		"build_route_cards": [
			{
				"glyph": "守",
				"title": "Ink Ward",
				"subtitle": "Sustain / Hold",
				"description": "Mirroring the source web route picks, this lane leans toward Wood, Water, Field, and Moon so the run can stabilize around sustain, safer paper arrays, and hold-your-ground control.",
				"tags": ["木", "氵", "田", "月"],
				"source_relics": ["Jade Slip", "Ink Gourd"],
				"source_words": ["Sea of Forest", "Moonlit Orbit"]
			},
			{
				"glyph": "雷",
				"title": "Storm Lattice",
				"subtitle": "Volley / Control",
				"description": "This route tilts toward Rain, Field, Sun, and Water, extending the scholar's ranged tempo into steadier volleys and broader battlefield control.",
				"tags": ["雨", "田", "日", "氵"],
				"source_relics": ["Ink Bell", "Star Ladle"],
				"source_words": ["Storm Front", "Radiant Clarity"]
			}
		],
		"select_quotes": [
			"Set down one stroke first, then see how the scroll answers.",
			"The radicals will speak for themselves. I only need to write them down.",
			"This run wants a steady hand. Let the glyphs grow into pressure."
		]
	},
	"xia": {
		"name": "Xia",
		"title": "Longblade Assault",
		"role_label": "Melee breaker",
		"focus": "Push into the enemy tide and turn `刂` directly into weapon growth.",
		"tags": ["Point-blank", "Burst", "Blade growth"],
		"weapon": "Great blade / fan-shaped slash",
		"description": "Cut open the tide up close. Each `刂` makes the blade line hit harder.",
		"record_title": "One who writes the word xia by guarding others up close",
		"record_body": "He is not a backline planner. He steps into the crowd, wins space with close-range slashes, and turns the remnant scroll into a promise delivered face to face.",
		"record_excerpt": "What he says, he fulfills. What he promises, he sees through.",
		"record_source": "Records of the Grand Historian",
		"trait_label": "Close-Range Pressure",
		"trait_description": "Higher vitality and point-blank slashes make him ideal for standing in the center of the tide and converting `刂`, endurance, and shockwave routes into control.",
		"active_skill_name": "Severing Dash",
		"active_skill_description": "Mirroring the hanziHero web prototype, Xia dashes and cleaves along the facing direction, briefly ignoring harm while cutting every enemy on the path.",
		"route_hint": "First secure a glyph route that keeps melee space open, then use blade growth and shockwave skills to turn close-range risk into pressure.",
		"progression_cards": [
			{
				"title": "Open the Scroll",
				"description": "Because Xia starts with `亻 / 心`, look for `木` or `刂` early and form a first glyph that protects melee space or bursts the tide back.",
				"tags": ["休", "忍"]
			},
			{
				"title": "Build the Edge",
				"description": "Once the close-range pocket is stable, add waves, lightning, or flame routes so the risk of diving in becomes forward pressure.",
				"tags": ["海", "雷", "炎"]
			},
			{
				"title": "Inkstone Phrase",
				"description": "Use the inkstone first on the route that protects you or opens lanes for melee. Do not wait for every line to be complete.",
				"tags": ["休养", "忍心", "海啸"]
			}
		],
		"build_route_cards": [
			{
				"glyph": "游",
				"title": "Wayfarer Script",
				"subtitle": "Mobility / Active",
				"description": "This source route leans toward Human, Blade, Moon, and Heart so melee spacing, lane cuts, and active-skill cadence stay fluid while diving in.",
				"tags": ["亻", "刂", "月", "心"],
				"source_relics": ["Ancient Seal", "Star Ladle"],
				"source_words": ["Moonlit Orbit", "Hardened Resolve"]
			},
			{
				"glyph": "烈",
				"title": "Ember Edge",
				"subtitle": "Burst / Pressure",
				"description": "It favors Fire, Blade, and Heart, pushing the run toward burst, close-range pressure, and heavier front-loaded cuts.",
				"tags": ["火", "刂", "心", "炎 / 忍"],
				"source_relics": ["Ink Bell", "Ancient Seal"],
				"source_words": ["Hardened Resolve", "Radiant Clarity"]
			}
		],
		"select_quotes": [
			"Step closer. I will split this run open.",
			"The word xia does not hide in the back. First drive the crowd away.",
			"I will hold this scroll today. You just keep moving forward."
		]
	}
}
const RADICAL_EN := {
	"亻": {"name": "person radical", "description": "Combine with `木` into `休`, leaning toward sustain and recovery."},
	"木": {"name": "wood radical", "description": "Completes `休`, and two woods can also line up into `林` for a forward control lane."},
	"日": {"name": "sun radical", "description": "Combine with `月` into `明`, or stack a second `日` into `昌` for a straighter chase line."},
	"月": {"name": "moon radical", "description": "Advances the `明` route and pushes the weapon toward phrase arts sooner."},
	"石": {"name": "stone radical", "description": "Combine with `山` into `岩` for targeted impacts and short shock zones."},
	"山": {"name": "mountain radical", "description": "Completes `岩` and turns the nearest enemy cluster into a crushed impact zone."},
	"氵": {"name": "water radical", "description": "Combine with `每` into `海`, or with `心` into `沁` for a calmer healing-wave route."},
	"每": {"name": "every base", "description": "Completes `海` and helps refine it into stronger sea phrase arts."},
	"雨": {"name": "rain radical", "description": "Combine with `田` into `雷` for lock-on lightning and mid-field control."},
	"田": {"name": "field frame", "description": "Completes `雷` and later refines into a lightning-rain field."},
	"囗": {"name": "enclosure radical", "description": "Combine with `亻` into `囚` and write a prison field around the nearest cluster."},
	"心": {"name": "heart radical", "description": "Combine with `刂` into `忍`, or with `氵` into `沁` for forward healing waves."},
	"火": {"name": "fire radical", "description": "Two fires form `炎`, turning the area around you into a ring of flame shots."},
	"刂": {"name": "blade radical", "description": "Both sharpens your weapon and combines with `心` into `忍`."}
}
const RECIPE_EN := {
	"ming": {"title": "Sun-Moon Wheels", "description": "Strengthens your main attack rhythm and periodically releases twin pursuit wheels."},
	"chang": {"title": "Twin Suns", "description": "Periodically writes parallel sun wheels straight ahead, turning repeated suns into direct chase pressure."},
	"xiu": {"title": "Forest Rest", "description": "Heals over time and knocks back nearby enemies to stretch survivability."},
	"forest": {"title": "Grove Array", "description": "Periodically lays a forest-glyph lane forward, tangling enemies along one path."},
	"hai": {"title": "Sea Tide", "description": "Detonates ink-wave ripples on a timer to clear nearby swarms."},
	"lei": {"title": "Falling Thunder", "description": "Locks onto the nearest cluster and slams the mid-field with lightning."},
	"rock": {"title": "Falling Crag", "description": "Marks the nearest enemy cluster with an engraved impact and leaves a short shock zone."},
	"qiu": {"title": "Prison Array", "description": "Periodically drops a prison field around the nearest enemy cluster, pinning feet and dealing steady damage."},
	"ren": {"title": "Endurance Instinct", "description": "Below half health, gain attack speed, damage, and move speed together."},
	"qin": {"title": "Soothing Wave", "description": "Periodically sends a forward healing wave that slows and threads through the crowd."},
	"yan": {"title": "Flame Surge", "description": "Periodically sprays flame glyph volleys in all directions to burn open space."}
}
const WORD_EN := {
	"ming_guang": {"title": "Moonbright Verse", "description": "Twin wheels add a moon-chasing volley and lift the main weapon with them."},
	"chang_ming": {"title": "Radiant Prosper Wheel", "description": "Twin-sun volleys add bright follow-ups, and your main attacks periodically kick off a small light echo."},
	"xiu_yang": {"title": "Restful Phrase", "description": "Turns healing into stable sustain and raises the margin for mistakes."},
	"lin_hai": {"title": "Forest Sea Scroll", "description": "The grove lane branches sideways as well, writing a wider control corridor through the crowd."},
	"hai_xiao": {"title": "Sea Howl", "description": "Refines the tide into a fiercer ink wave with shorter cycles and larger reach."},
	"lei_yu": {"title": "Rain of Thunder", "description": "Lightning impacts spread into a rain field, turning burst into control."},
	"ren_xin": {"title": "Ruthless Heart", "description": "When endurance triggers, recover health and cut out periodic aftershocks."},
	"yan_chao": {"title": "Flame Surge Scroll", "description": "Makes flame volleys denser and faster, with scorching waves erupting on hit."}
}
const ENEMY_EN := {
	"basic": {"name": "Night Thrall", "title": "Frontline Pursuit", "summary": "The base melee glyph spirit that walks straight in and forces constant repositioning.", "warning": "No extra tell. The danger comes from numbers and body collisions.", "counter": "Use them early to build radicals, but do not let them seal off your retreat path."},
	"swift": {"name": "Swift Thrall", "title": "High-Speed Flank", "summary": "Moves faster and cuts into your side with more lateral motion.", "warning": "There is no obvious wind-up, but its path drifts and fills gaps quickly.", "counter": "Keep strafing and clear them first before they help surround you."},
	"tank": {"name": "Ink Armor", "title": "Heavy Frontline", "summary": "Tough, large, and built to slow your clear while buying time for backliners.", "warning": "It mostly pressures through raw durability instead of unique skills.", "counter": "Do not get glued to it. Bleed it with area damage while you remove the backline."},
	"archer": {"name": "Archer", "title": "Ranged Pressure", "summary": "Keeps its distance, strafes, and repeatedly fires projectiles from mid range.", "warning": "After a short wind-up in range, it fires a straight glyph arrow.", "counter": "Cut off its spacing first instead of taking a long duel from afar."},
	"assassin": {"name": "Assassin", "title": "Piercing Dash", "summary": "Slides at mid range to find an angle, then suddenly lunges in a straight line.", "warning": "A short purple warning line appears on the ground before the dash.", "counter": "Cut diagonally away as soon as the line appears. Do not retreat along it."},
	"cavalry": {"name": "Ink Cavalry", "title": "Heavy Charge", "summary": "Larger and heavier, it cuts across the arena with long straight charges.", "warning": "It draws a longer, wider route warning before charging and can briefly stun on hit.", "counter": "Step off the line first, then punish during the recovery after it rushes through."},
	"ritualist": {"name": "Ritualist", "title": "Ground Array Pressure", "summary": "Keeps distance and places glyph circles that slowly carve up safe space.", "warning": "Circular warnings appear under you or nearby before turning into danger zones.", "counter": "Do not greed damage. Clear your footing first, then keep dragging the pack."},
	"elite": {"name": "Elite", "title": "Rotating Skills", "summary": "Cycles explosions, volleys, flower spreads, and large charges to set the pace of mixed fights.", "warning": "Different skills have different warnings, especially the blast ring and charge.", "counter": "Track its rotation first so the second skill does not catch you while you clean the swarm."},
	"boss": {"name": "Scroll Lord", "title": "Remnant Boss", "summary": "Layers forbidden arrays, fan volleys, straight charges, and cross-shaped ruptures together.", "warning": "The large arrays and charges are clearly telegraphed, while other volleys arrive after short wind-ups.", "counter": "Survive the large skills first, then chase damage during the gaps between boss patterns."}
}
const SOUNDTRACK_EN := {
	"mosslightCanopy": {"title": "Mosslight Canopy", "mood": "16-bit Quiet Forest"},
	"fireflyFootpath": {"title": "Firefly Footpath", "mood": "16-bit Light Patrol"}
}
const CUE_EN := {
	"试阵预热": "Test Warmup",
	"待入曲": "Awaiting Cue",
	"巡游换曲": "Track Rotation",
	"卷主压阵": "Boss Pressure",
	"入卷铺陈": "Scroll Opening",
	"试阵开卷": "Test Entry",
	"残卷暂定": "Scroll Secured",
	"残卷回气": "Breathing Space",
	"大潮压境": "Major Tide",
	"字潮提速": "Tide Rising",
	"字境相变": "Realm Shift"
}


static func is_english(language: String) -> bool:
	return language == "en"


static func _apply_patch(source: Dictionary, patch: Dictionary) -> Dictionary:
	var localized := source.duplicate(true)
	for key in patch.keys():
		localized[key] = patch[key]
	return localized


static func localized_hero_data(hero_id: String, language: String) -> Dictionary:
	var hero := Session.get_hero_data(hero_id).duplicate(true)
	if not is_english(language):
		return hero
	return _apply_patch(hero, HERO_EN.get(hero_id, {}))


static func localized_radical_data(radical: String, language: String) -> Dictionary:
	var radical_data := Session.get_radical_data(radical).duplicate(true)
	if not is_english(language):
		return radical_data
	return _apply_patch(radical_data, RADICAL_EN.get(radical, {}))


static func localized_recipe_data(recipe_id: String, language: String) -> Dictionary:
	var recipe := Session.get_recipe_data(recipe_id).duplicate(true)
	if not is_english(language):
		return recipe
	return _apply_patch(recipe, RECIPE_EN.get(recipe_id, {}))


static func localized_word_data(word_id: String, language: String) -> Dictionary:
	if word_id.is_empty():
		return {}
	var word := Session.get_word_data(word_id).duplicate(true)
	if not is_english(language):
		return word
	return _apply_patch(word, WORD_EN.get(word_id, {}))


static func localized_enemy_data(enemy_id: String, language: String) -> Dictionary:
	var enemy := Session.get_enemy_data(enemy_id).duplicate(true)
	if not is_english(language):
		return enemy
	return _apply_patch(enemy, ENEMY_EN.get(enemy_id, {}))


static func localized_soundtrack_entry(track_id: String, language: String, source_library: Dictionary) -> Dictionary:
	var entry: Dictionary = {}
	var entry_variant: Variant = source_library.get(track_id, {})
	if entry_variant is Dictionary:
		entry = (entry_variant as Dictionary).duplicate(true)
	if not is_english(language):
		return entry
	return _apply_patch(entry, SOUNDTRACK_EN.get(track_id, {}))


static func localized_soundtrack_cue(cue: String, language: String) -> String:
	if not is_english(language):
		return cue
	return String(CUE_EN.get(cue, cue))


static func localized_intro_title(start_wave: int, fallback: String, language: String) -> String:
	if not is_english(language):
		return fallback
	match start_wave:
		10:
			return "Scroll X · Test Run"
		20:
			return "Scroll XX · Abyss Stress Test"
		_:
			return "Scroll I · Inkfall"


static func localized_intro_tip(start_wave: int, fallback: String, language: String) -> String:
	if not is_english(language):
		return fallback
	match start_wave:
		10:
			return "Start with a midgame build already in motion and focus on mixed waves, warnings, and HUD pacing."
		20:
			return "Enter directly inside Abyss Sanctum with a fuller late build and use this run to inspect final-room spacing, major surges, and HUD rhythm under pressure."
		_:
			return "Secure the first radical and form your opening glyph as quickly as possible."
