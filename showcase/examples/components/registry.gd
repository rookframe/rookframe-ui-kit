extends RefCounted
## Showcase navigation metadata. The installed catalogue remains the public API.
const CATEGORIES := ["Actions", "Forms & selection", "Navigation", "Layout", "Surfaces", "Data display", "Feedback & overlays"]
const MANIFESTS := ["layout_surfaces", "actions_forms", "data_feedback"]

static func entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for manifest in MANIFESTS:
		var path := "res://examples/components/manifests/%s.json" % manifest
		if not FileAccess.file_exists(path):
			continue
		var records = JSON.parse_string(FileAccess.get_file_as_string(path))
		if not records is Array:
			push_error("Invalid component page manifest: " + path)
			continue
		for record in records:
			result.append(record)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var first := CATEGORIES.find(a.category)
		var second := CATEGORIES.find(b.category)
		return a.title.naturalnocasecmp_to(b.title) < 0 if first == second else first < second)
	return result

static func matches(entry: Dictionary, query: String) -> bool:
	var haystack := "%s %s %s %s" % [entry.title, entry.category, entry.description, " ".join(entry.get("keywords", []))]
	for word in query.to_lower().split(" ", false):
		if not word in haystack.to_lower():
			return false
	return true
