extends RefCounted
class_name ContentDatabase

const DATA_PATH := "res://docs/字词升级路线.json"

const ROUTE_DEFS := {
	"墨守": {
		"glyph": "守",
		"description": "阵地、防御与回复更稳定。",
		"bias": ["wood", "field", "mountain", "heart", "water"]
	},
	"雷阵": {
		"glyph": "雷",
		"description": "区域、落点与连锁更容易成型。",
		"bias": ["rain", "field", "water", "wind"]
	},
	"游侠": {
		"glyph": "行",
		"description": "机动、追击与回响更容易滚起来。",
		"bias": ["person", "wind", "heart", "mouth"]
	},
	"烈笔": {
		"glyph": "炎",
		"description": "爆发、燃烧与压场更容易成型。",
		"bias": ["fire", "wind", "rain"]
	}
}

var raw_data: Dictionary = {}
var rune_defs: Dictionary = {}
var rune_ids: Array[String] = []
var character_defs: Dictionary = {}
var character_ids: Array[String] = []
var word_skill_defs: Dictionary = {}
var word_skill_ids: Array[String] = []
var route_names: Array[String] = ["墨守", "雷阵", "游侠", "烈笔"]


func _init() -> void:
	_load_data()


func get_rune_ids() -> Array[String]:
	return rune_ids.duplicate()


func get_character_ids() -> Array[String]:
	return character_ids.duplicate()


func get_word_skill_ids() -> Array[String]:
	return word_skill_ids.duplicate()


func get_route_names() -> Array[String]:
	return route_names.duplicate()


func get_rune_def(rune_id: String) -> Dictionary:
	return rune_defs.get(rune_id, {}).duplicate(true)


func get_character_def(character_id: String) -> Dictionary:
	return character_defs.get(character_id, {}).duplicate(true)


func get_word_skill_def(word_skill_id: String) -> Dictionary:
	return word_skill_defs.get(word_skill_id, {}).duplicate(true)


func get_route_def(route_name: String) -> Dictionary:
	return ROUTE_DEFS.get(route_name, {}).duplicate(true)


func get_character_defs_in_order() -> Array:
	var defs: Array = []
	for character_id in character_ids:
		defs.append(get_character_def(character_id))
	return defs


func _load_data() -> void:
	if not FileAccess.file_exists(DATA_PATH):
		push_warning("Missing gameplay data JSON at %s" % DATA_PATH)
		return

	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("Unable to open gameplay data JSON at %s" % DATA_PATH)
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Gameplay data JSON did not parse into a Dictionary.")
		return

	raw_data = parsed
	_register_runes()
	_register_characters("structural_chars", "structural")
	_register_characters("advanced_chars", "advanced")
	_register_word_skills()


func _register_runes() -> void:
	var runes: Array = raw_data.get("runes", [])
	for rune_variant in runes:
		if typeof(rune_variant) != TYPE_DICTIONARY:
			continue
		var rune: Dictionary = rune_variant
		var rune_id: String = str(rune.get("id", ""))
		if rune_id.is_empty():
			continue
		rune_defs[rune_id] = rune.duplicate(true)
		rune_ids.append(rune_id)


func _register_characters(source_key: String, category: String) -> void:
	var characters: Array = raw_data.get(source_key, [])
	for character_variant in characters:
		if typeof(character_variant) != TYPE_DICTIONARY:
			continue
		var definition: Dictionary = character_variant.duplicate(true)
		var character_id: String = str(definition.get("id", ""))
		if character_id.is_empty():
			continue
		definition["category"] = category
		character_defs[character_id] = definition
		character_ids.append(character_id)


func _register_word_skills() -> void:
	var word_skills: Array = raw_data.get("word_skills", [])
	for word_skill_variant in word_skills:
		if typeof(word_skill_variant) != TYPE_DICTIONARY:
			continue
		var definition: Dictionary = word_skill_variant.duplicate(true)
		var word_skill_id: String = str(definition.get("id", ""))
		if word_skill_id.is_empty():
			continue
		word_skill_defs[word_skill_id] = definition
		word_skill_ids.append(word_skill_id)
