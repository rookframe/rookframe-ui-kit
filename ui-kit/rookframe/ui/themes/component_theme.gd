@tool
extends Theme
## Native Theme plus optional presentation for the shared component scenes.
## Templates author property overrides only; nodes and behavior are never replaced.
## The neutral RookframeTokens set lies beneath every source, so a token a theme
## leaves out resolves to its neutral default. A base layer built from the
## resolved tokens supplies every stock control and kit variation the sources
## leave undefined; a type a source defines is that source's alone.
const NEUTRAL_TOKENS = preload("neutral_tokens.tres")
const TokenBase = preload("token_base.gd")
const Tokens = preload("design_tokens.gd")
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
	default_font = null
	default_font_size = -1
	default_base_scale = 0.0
	var authored := {}
	# Later sources replace earlier items, so authored tokens override neutral ones.
	for source in [NEUTRAL_TOKENS] + supplemental_themes + [native_theme]:
		if source == null:
			continue
		_merge(source)
		if source != NEUTRAL_TOKENS:
			for type in source.get_type_list():
				authored[type] = true
	# The tokens are complete now. The base layer never replaces an authored type,
	# so items a theme inherits from its own base types keep their source.
	var base := TokenBase.build(self)
	for type in base.get_type_list():
		if authored.has(type):
			continue
		for data_type in Theme.DATA_TYPE_MAX:
			for item in base.get_theme_item_list(data_type, type):
				set_theme_item(data_type, item, type, base.get_theme_item(data_type, item, type))
		var variation_base := base.get_type_variation_base(type)
		if not variation_base.is_empty():
			set_type_variation(type, variation_base)
	if native_theme != null:
		default_font = native_theme.default_font
		default_font_size = native_theme.default_font_size
		default_base_scale = native_theme.default_base_scale
	# Controls without a type role of their own read running text.
	var body := get_font(&"body", Tokens.TYPE)
	if not has_default_font() and body != ThemeDB.fallback_font:
		default_font = body
	if not has_default_font_size():
		default_font_size = get_font_size(&"body", Tokens.TYPE)

func _merge(source: Theme) -> void:
	merge_with(source)
	for type in source.get_type_list():
		var base: StringName = source.get_type_variation_base(type)
		if not base.is_empty():
			set_type_variation(type, base)
