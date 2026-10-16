extends Control
## Production-resource consumers with synthetic host state, never production rules.
const UI := "res://rookframe/ui/"
const THEMES := ["theme/rookframe_theme.tres", "menu/MenuTheme.tres", "menu/cyberpunk/CyberpunkTheme.tres"]
const LANGUAGES := ["en", "ru", "ja", "zh_CN", "zh_TW", "ko", "ar", "he"]
const COPY := ["The archivist keeps a detailed record of every journey.", "Хранитель архива сохраняет подробные записи каждого путешествия и найденных предметов.", "記録係は旅の出来事と見つけた品物を詳しく記録します。", "档案管理员详细记录每次旅程和发现的物品。", "檔案管理員詳細記錄每次旅程和發現的物品。", "기록관은 모든 여행과 발견한 물건을 자세히 기록합니다.", "يحتفظ أمين الأرشيف بسجل مفصل لكل رحلة والأشياء المكتشفة.", "הארכיונאי שומר תיעוד מפורט של כל מסע ושל החפצים שנמצאו."]
var theme_index := 0
var language_index := 0
var text_scale := 1.0
var long_content := false
var reduced_motion := false
var tabs: TabContainer
var fields: Array = []
var pickers: Array = []
var collections: Array = []
var toasts: Array = []
var inspections: Array = []
var contexts: Array = []
var entries: Array[Dictionary] = []
var _language_labels: Array[Label] = []
var _serial := 0

func _ready() -> void:
	var layout := VBoxContainer.new()
	add_child(layout)
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var toolbar := HFlowContainer.new()
	layout.add_child(toolbar)
	for copy in ["Theme", "Language", "Text scale", "Long content", "Reduced motion"]:
		var button := _button(copy)
		toolbar.add_child(button)
		button.pressed.connect(_setting.bind(copy))
	tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(tabs)
	var native := _page("Native recipes")
	native.add_child(preload("native_recipes.gd").new())
	for title in ["Settings", "Details"]:
		var page := _page(title)
		_forms(page)
		_inspection(page)
	for i in 36: entries.append({"id": "record-%d" % i, "title": "Inventory item %d" % (i + 1), "subtitle": "A retained record", "phone_subtitle": "", "value": str(i + 1), "action": "Use item", "action_text": "Use"})
	for title in ["Inventory", "Assets"]:
		var page := _page(title)
		_collection(page, title)
		var actions := HBoxContainer.new()
		page.add_child(actions)
		_transfer(actions)
		_inspection(actions)
	var feedback := _page("Feedback")
	for title in ["Item updates", "Task updates"]:
		_feedback(feedback, title)
	var typography := _page("Language specimen")
	for role in ["Title", "Subtitle", "Heading", "Identity", "Body", "Label", "Value", "Meta"]:
		var label := _label(role, "Rookframe" + role)
		typography.add_child(label)
		_language_labels.append(label)
	var value := LineEdit.new()
	value.text = "assets/item-42.tres 123.45"
	value.text_direction = Control.TEXT_DIRECTION_LTR
	value.accessibility_name = "Path and numeric value"
	value.custom_minimum_size.y = 44
	typography.add_child(value)
	apply_presentation()

func _page(title: String) -> VBoxContainer:
	if title in ["Inventory", "Assets"]:
		var page := VBoxContainer.new()
		page.name = title
		tabs.add_child(page)
		return page
	var scroll := ScrollContainer.new()
	scroll.name = title
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tabs.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	return content

func _label(copy: String, role := "RookframeBody") -> Label:
	var label := Label.new()
	label.text = copy
	label.theme_type_variation = role
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _button(copy: String) -> Button:
	var button := Button.new()
	button.text = copy
	button.accessibility_name = copy
	button.custom_minimum_size = Vector2(44, 44)
	return button

func _forms(page: Container) -> void:
	for kind in ["number", "copy"]:
		var field = load(UI + "components/forms/field.tscn").instantiate()
		page.add_child(field)
		field.label_text = "Capacity" if kind == "number" else "Read-only item ID"
		field.help_text = "The host validates this value."
		var group = load(UI + "components/forms/input_group.tscn").instantiate()
		field.get_input_slot().add_child(group)
		var editor: Control
		if kind == "number":
			editor = SpinBox.new()
			editor.max_value = 100
			var unit := _label("kg")
			unit.autowrap_mode = TextServer.AUTOWRAP_OFF
			group.get_trailing_slot().add_child(unit)
		else:
			editor = LineEdit.new()
			editor.text = "item-42"
			editor.editable = false
			var copy := _button("Copy")
			copy.pressed.connect(func(): DisplayServer.clipboard_set(editor.text))
			group.get_trailing_slot().add_child(copy)
		editor.custom_minimum_size.y = 44
		editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		group.get_input_slot().add_child(editor)
		field.set_target(editor)
		fields.append(field)
	var search = load(UI + "components/forms/search_field.tscn").instantiate()
	search.label_text = "Search items"
	search.value = "Retained query"
	page.add_child(search)
	var error := _button("Toggle error")
	error.pressed.connect(func():
		for field in fields: field.set_error("Value is unavailable" if field.error_text.is_empty() else ""))
	page.add_child(error)
	var picker = load(UI + "components/forms/multi_select_picker.tscn").instantiate()
	page.add_child(picker)
	var items: Array[Dictionary] = [{"id": "one", "title": "First item"}, {"id": "two", "title": "Second item"}, {"id": "locked", "title": "Locked selection", "disabled": true}]
	picker.set_items(items)
	picker.set_selected_ids(PackedStringArray(["locked"]))
	pickers.append(picker)

func _inspection(page: Container) -> void:
	var anchor := _button("Inspect item")
	page.add_child(anchor)
	var inspect = load(UI + "components/overlays/inspect_card.tscn").instantiate()
	page.add_child(inspect)
	inspect.get_preview_slot().add_child(_label("An item with a retained description."))
	inspect.get_body_slot().add_child(_label("An item with a retained description."))
	var action := _button("Use item")
	inspect.get_action_slot().add_child(action)
	action.pressed.connect(inspect.close)
	inspect.bind_anchor(anchor)
	anchor.pressed.connect(inspect.open_inspection)
	inspections.append(inspect)

func _collection(page: Container, title: String) -> void:
	var toolbar := HBoxContainer.new()
	page.add_child(toolbar)
	var search := LineEdit.new()
	search.placeholder_text = "Filter " + title
	search.accessibility_name = search.placeholder_text
	search.custom_minimum_size.y = 44
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(search)
	var collection = load(UI + "components/data/collection.tscn").instantiate()
	collection.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(collection)
	collection.configure(entries, "", title, str(entries.size()))
	collections.append(collection)
	search.text_changed.connect(func(query: String):
		var ids := PackedStringArray()
		for entry in entries:
			if query.is_empty() or entry.title.to_lower().contains(query.to_lower()): ids.append(entry.id)
		collection.set_visible_ids(ids))
	collection.get_footer_slot().add_child(_button("Host action"))
	var status = load(UI + "components/feedback/task_state.tscn").instantiate()
	status.title = "No matching items"
	status.description = "Clear the filter to show the inventory."
	status.hide()
	page.add_child(status)
	search.text_changed.connect(func(query: String):
		var matches := entries.any(func(entry: Dictionary): return query.is_empty() or entry.title.to_lower().contains(query.to_lower()))
		status.visible = not matches
		collection.visible = matches)
	var fail := _button("Show retrieval error")
	toolbar.add_child(fail)
	fail.pressed.connect(func():
		status.state = 3
		status.title = "Could not load items"
		collection.hide()
		status.show())
	var retry := _button("Retry")
	status.get_action_slot().add_child(retry)
	retry.pressed.connect(func():
		status.hide()
		collection.show())

func _transfer(page: Container) -> void:
	var region := HBoxContainer.new()
	region.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_child(region)
	var context := RookframeTransferContext.new()
	region.add_child(context)
	contexts.append(context)
	var source = load(UI + "components/data/drag_slot.tscn").instantiate()
	source.slot_id = "bag"
	source.context = context
	source.text = "Pick up from bag"
	source.accessibility_name = source.text
	source.payload = {"item_id": "item-42", "amount": 1}
	region.add_child(source)
	var target = load(UI + "components/data/drag_slot.tscn").instantiate()
	target.slot_id = "equipment"
	target.context = context
	target.can_source = false
	target.text = "Place in equipment"
	target.accessibility_name = target.text
	region.add_child(target)
	context.placement_validator = func(_source: String, _target: String, payload: Dictionary): return {"allowed": payload.get("amount", 0) == 1, "reason": "Only one item fits"}
	context.transfer_requested.connect(func(id: int, _source: String, _target: String, _payload: Dictionary):
		# Synthetic synchronous host acceptance; data movement belongs here.
		target.text = "Equipped item-42"
		context.resolve_transfer(id, true))

func _feedback(page: Container, title: String) -> void:
	page.add_child(_label(title, "RookframeHeading"))
	var stack = load(UI + "components/feedback/toast_stack.tscn").instantiate()
	page.add_child(stack)
	toasts.append(stack)
	var push := _button("Push message")
	page.add_child(push)
	push.pressed.connect(func():
		_serial += 1
		stack.push({"id": str(_serial), "title": "Item saved", "description": COPY[language_index], "action_id": "undo", "action_label": "Undo"}))
	var flood := _button("Push 24 messages")
	page.add_child(flood)
	flood.pressed.connect(func():
		for i in 24:
			_serial += 1
			stack.push({"id": str(_serial), "title": "Message %d" % (i + 1), "duration_ms": 0}))
	var pause := _button("Pause timers")
	pause.toggle_mode = true
	pause.toggled.connect(func(value: bool): stack.timers_paused = value)
	page.add_child(pause)
	var clear := _button("Clear messages")
	clear.pressed.connect(stack.clear)
	page.add_child(clear)

func _setting(setting: String) -> void:
	match setting:
		"Theme": theme_index = (theme_index + 1) % 3
		"Language": language_index = (language_index + 1) % LANGUAGES.size()
		"Text scale": text_scale = 1.5 if text_scale == 1.0 else 1.0
		"Long content": long_content = not long_content
		"Reduced motion": reduced_motion = not reduced_motion
	apply_presentation()

func apply_presentation() -> void:
	var active: Theme = load(UI + THEMES[theme_index]).duplicate()
	var locale: String = LANGUAGES[language_index]
	var font: Font
	if locale in ["ja", "zh_CN", "zh_TW", "ko"]:
		font = load(UI + "theme/locales/" + locale + "_regular.tres")
	elif locale in ["ar", "he"]:
		var family := "Arabic" if locale == "ar" else "Hebrew"
		font = load("res://examples/ui-expansion/fonts/" + family + "-NotoSans" + family + "[wdth,wght].ttf")
	if font != null: active.default_font = font
	active.default_font_size = roundi(maxi(18, active.default_font_size) * text_scale)
	for type in active.get_type_list():
		for item in active.get_font_size_list(type): active.set_font_size(item, type, roundi(active.get_font_size(item, type) * text_scale))
		if font != null:
			for item in active.get_font_list(type): active.set_font(item, type, font)
	theme = active
	layout_direction = Control.LAYOUT_DIRECTION_RTL if locale in ["ar", "he"] else Control.LAYOUT_DIRECTION_LTR
	var copy: String = COPY[language_index].repeat(3 if long_content else 1)
	for label in _language_labels:
		label.text = copy + " 12345.67"
		label.language = locale
	for field in fields: field.help_text = copy
	for inspect in inspections:
		inspect.get_preview_slot().get_child(0).text = copy
		inspect.get_body_slot().get_child(0).text = copy
	for collection in collections: collection.reduced_motion = reduced_motion
