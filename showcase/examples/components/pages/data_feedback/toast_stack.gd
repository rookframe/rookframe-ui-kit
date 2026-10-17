extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var transient = page.section("Transient messages", "Add messages to see two visible notices and an arrival-order queue. Hover or focus pauses dismissal.")
	var actions = page.flow(transient)
	var status = page.note(transient, "No messages finished.")
	var stack = page.scene(Demo.path("feedback/toast_stack"), transient)
	stack.configure_limits(2, 4)
	var sequence := [0]
	for tone in ["info", "success", "error"]:
		page.button(actions, "Add " + tone, func():
			sequence[0] += 1
			var accepted: bool = stack.push({"id": "message-%d" % sequence[0], "title": {"info": "Route updated", "success": "Expedition saved", "error": "Connection interrupted"}[tone], "description": "Message %d" % sequence[0], "tone": StringName(tone), "duration_ms": 5000})
			status.text = "Message queued." if accepted else "The visible and waiting queues are full.")
	page.button(actions, "Clear messages", func(): stack.clear())
	stack.finished.connect(func(id: String, reason: StringName, _action: String): status.text = "%s finished: %s" % [id, reason])
	var recovery = page.section("Persistent action", "An action notice waits until you dismiss it or choose Undo.")
	var persistent = page.scene(Demo.path("feedback/toast_stack"), recovery)
	persistent.push({"id": "undo", "title": "Draft archived", "description": "Restore the draft with Undo.", "tone": &"success", "action_id": "undo_archive", "action_label": "Undo"})
	var result = page.note(recovery, "Draft archived in this preview.")
	persistent.finished.connect(func(_id: String, reason: StringName, _action: String): result.text = "Archive undone." if reason == &"action" else "Notice dismissed.")
	page.button(recovery, "Restore example", func():
		persistent.clear()
		persistent.push({"id": "undo", "title": "Draft archived", "action_id": "undo_archive", "action_label": "Undo"})
		result.text = "Draft archived in this preview.")
