@tool
extends Theme
## Native Theme plus optional presentation for the shared component scenes.
## Templates author property overrides only; nodes and behavior are never replaced.
## The neutral RookframeTokens set lies beneath every source, so a token a theme
## leaves out resolves to its neutral default.
const NEUTRAL_TOKENS = preload("neutral_tokens.tres")
@export var native_theme: Theme:
	set(value):
		native_theme = value
		_rebuild()
@export var supplemental_themes: Array[Theme] = []:
	set(value):
		supplemental_themes = value
		_rebuild()
@export var presentations: Dictionary[String, PackedScene] = {}
@export var presentation_hooks: Dictionary[String, Script] = {}

func _init() -> void:
	_rebuild()

func _rebuild() -> void:
	clear()
	# Later sources replace earlier items, so authored tokens override neutral ones.
	for source in [NEUTRAL_TOKENS] + supplemental_themes + [native_theme]:
		if source == null:
			continue
		merge_with(source)
		for type in source.get_type_list():
			var base: StringName = source.get_type_variation_base(type)
			if not base.is_empty():
				set_type_variation(type, base)
	if native_theme != null:
		default_font = native_theme.default_font
		default_font_size = native_theme.default_font_size
		default_base_scale = native_theme.default_base_scale
