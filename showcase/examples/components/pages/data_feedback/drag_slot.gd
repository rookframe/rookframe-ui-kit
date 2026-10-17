extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var section = page.section("Pick up and place", "Drag the compass, or activate its slot and then the empty target. Escape cancels carrying.")
	var context = load("res://rookframe/ui/components/data/transfer_context.gd").new()
	page.add_child(context)
	var status = page.note(section, "Ready to move the compass.")
	var slots = page.flow(section)
	var source = page.scene("res://rookframe/ui/components/data/drag_slot.tscn", slots, {"slot_id": "pack", "context": context, "payload": {"item": "Moonstone compass"}, "text": "Pick up compass", "accessibility_name": "Pick up compass from pack", "custom_minimum_size": Vector2(180, 64)})
	var target = page.scene("res://rookframe/ui/components/data/drag_slot.tscn", slots, {"slot_id": "belt", "context": context, "can_source": false, "text": "Place on belt", "accessibility_name": "Place compass on belt", "custom_minimum_size": Vector2(180, 64)})
	context.placement_validator = func(_source: String, target_id: String, _payload: Dictionary) -> Dictionary:
		return {"allowed": target_id == "belt", "reason": "Only the belt accepts the compass."}
	context.transfer_requested.connect(func(request: int, _source: String, _target: String, _payload: Dictionary):
		source.payload = {}
		source.text = "Pack is empty"
		target.text = "Compass on belt"
		context.resolve_transfer(request, true)
		status.text = "Compass moved to the belt.")
	page.button(section, "Reset slots", func():
		context.cancel_transfer(&"host")
		source.payload = {"item": "Moonstone compass"}
		source.text = "Pick up compass"
		target.text = "Place on belt"
		status.text = "Ready to move the compass.")
	var unavailable = page.section("Unavailable and read-only slots")
	var row = page.flow(unavailable)
	page.scene("res://rookframe/ui/components/data/drag_slot.tscn", row, {"slot_id": "disabled", "context": context, "disabled": true, "text": "Locked equipment slot", "custom_minimum_size": Vector2(180, 64)})
	page.scene("res://rookframe/ui/components/data/drag_slot.tscn", row, {"slot_id": "read-only", "context": context, "can_source": false, "can_target": false, "text": "Display-only relic", "custom_minimum_size": Vector2(180, 64)})
