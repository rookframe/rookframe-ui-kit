extends RefCounted
## Shared synthetic records and bounded example hosts; no component behavior.
const CORE := "res://rookframe/ui/components/"

static func path(relative: String) -> String:
	return CORE + relative + ".tscn"

static func bounded(parent: Node, height: float = 340.0) -> Control:
	var host := Control.new()
	host.custom_minimum_size.y = height
	host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(host)
	return host

static func fill(control: Control) -> void:
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

static func records(count: int = 12, with_actions: bool = false) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for index in count:
		var entry := {"id": "item-%d" % index, "title": ["Moonstone compass", "Field journal", "Lantern of the northern observatory"][index % 3] + " %d" % (index + 1), "subtitle": "Explorer equipment", "value": "%d kg" % (index + 1), "hint": "A travelling companion for the expedition.", "hint_title": "Equipment details"}
		if with_actions:
			entry.merge({"action": "Equip item %d" % (index + 1), "action_text": "Equip", "action_disabled": index == 2})
		entries.append(entry)
	return entries

static func miniatures() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for index in 10:
		entries.append({"id": "mini-%d" % index, "title": ["Archivist", "Pathfinder", "Sentinel"][index % 3] + " %d" % (index + 1), "package": "Northern expedition", "available": index != 3})
	return entries

static func preview(_entry: Dictionary, target: Control) -> void:
	var art := TextureRect.new()
	art.texture = load("res://rookframe/ui/icons/person.svg")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	target.add_child(art)
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
