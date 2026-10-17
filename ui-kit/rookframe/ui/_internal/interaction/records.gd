extends RefCounted
## Shared record validation and retention; selection belongs to each component.
static func valid(entries: Array[Dictionary]) -> bool:
	var ids: Dictionary = {}
	for entry in entries:
		if not entry.get("id") is String or entry.id.is_empty() or ids.has(entry.id):
			push_error("Collection: records require unique nonempty String IDs")
			return false
		ids[entry.id] = true
	return true

static func reconcile(entries: Array[Dictionary], previous: Array[Dictionary], rows: Array, parent: Node, create: Callable) -> Array:
	var retained: Dictionary = {}
	for index in mini(previous.size(), rows.size()): retained[previous[index].id] = rows[index]
	var next: Array = []
	for index in entries.size():
		var id: String = entries[index].id
		var row: Control
		if retained.has(id):
			row = retained[id]
			retained.erase(id)
		else:
			row = create.call(id)
			parent.add_child(row)
		parent.move_child(row, index)
		next.append(row)
	for row in retained.values():
		parent.remove_child(row)
		row.queue_free()
	return next

static func focused_index(rows: Array, focused: Control) -> int:
	if focused == null: return -1
	for index in rows.size():
		if rows[index] == focused or rows[index].is_ancestor_of(focused): return index
	return -1

static func page_for(index: int, pages: Array[Vector2i]) -> int:
	for page in pages.size():
		if index >= pages[page].x and index < pages[page].y: return page
	return 0
