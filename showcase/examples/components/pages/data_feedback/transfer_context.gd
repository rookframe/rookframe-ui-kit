extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var region = page.section("Transfer lifecycle", "Pick up, request placement, then resolve the pending request with Accept or Reject. No network request is made.")
	var context = load("res://rookframe/ui/components/data/transfer_context.gd").new()
	region.add_child(context)
	var status = page.note(region, "State: idle")
	var slots = page.flow(region)
	page.scene("res://rookframe/ui/components/data/drag_slot.tscn", slots, {"slot_id": "source", "context": context, "payload": {"item": "Field journal"}, "text": "Pick up journal", "custom_minimum_size": Vector2(170, 64)})
	page.scene("res://rookframe/ui/components/data/drag_slot.tscn", slots, {"slot_id": "target", "context": context, "can_source": false, "text": "Place in satchel", "custom_minimum_size": Vector2(170, 64)})
	page.scene("res://rookframe/ui/components/data/drag_slot.tscn", slots, {"slot_id": "full", "context": context, "can_source": false, "text": "Full compartment", "custom_minimum_size": Vector2(170, 64)})
	context.placement_validator = func(_source: String, target: String, _payload: Dictionary) -> Dictionary:
		return {"allowed": target == "target", "reason": "The compartment is full." if target == "full" else ""}
	var request := [0]
	context.state_changed.connect(func(state: StringName): status.text = "State: " + str(state))
	context.transfer_requested.connect(func(id: int, _source: String, _target: String, _payload: Dictionary):
		request[0] = id
		status.text = "State: pending · Request %d awaits the host result." % id)
	var results = page.section("Resolve or cancel", "A rejected request returns to carrying; cancellation cannot revoke an already pending request.")
	var actions = page.flow(results)
	page.button(actions, "Accept request", func():
		if context.resolve_transfer(request[0], true): status.text = "Accepted. State: idle"
		else: status.text = "No pending request to accept.")
	page.button(actions, "Reject request", func():
		if context.resolve_transfer(request[0], false, "The satchel changed. Try another destination."): status.text = "Rejected. State: carrying"
		else: status.text = "No pending request to reject.")
	page.button(actions, "Cancel carrying", func():
		if not context.cancel_transfer(): status.text = "Cancellation is unavailable while idle or pending.")
