extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	var body = page.section("Lifecycle transitions", "The resource owns semantic state. These local controls exercise open, minimized and closed states.")
	var state = load("res://rookframe/ui/components/surfaces/managed_surface_state.gd").new()
	state.surface_id = "session-notes"
	state.task_instance_id = "notes-draft"
	var status = page.note(body, "Docked · visible · unfocused")
	var show_state = func():
		status.text = "%s · %s · %s" % [str(state.placement_name()).capitalize(), "visible" if state.is_visible() else "closed" if state.closed else "minimized", "focused" if state.focused else "unfocused"]
	var on_changed = func(_snapshot): show_state.call()
	state.state_changed.connect(on_changed)
	page.tree_exiting.connect(func(): state.state_changed.disconnect(on_changed))
	var controls = page.flow(body)
	page.button(controls, "Float", func(): state.set_placement(1))
	page.button(controls, "Dock", func(): state.set_placement(0))
	page.button(controls, "Minimize", func(): state.minimize_surface())
	page.button(controls, "Restore", func(): state.restore_surface())
	page.button(controls, "Close", func(): state.close_surface())
	page.button(controls, "Open", func(): state.open_surface())
	var persistence = page.section("Snapshot and restore", "Save a local snapshot, change the lifecycle above, then restore the recorded state.")
	var saved := {"snapshot": state.state_snapshot()}
	var summary = page.note(persistence, "Saved: docked · open")
	var actions = page.flow(persistence)
	page.button(actions, "Save snapshot", func():
		saved.snapshot = state.state_snapshot()
		summary.text = "Saved: %s · %s" % [saved.snapshot.placement, "closed" if saved.snapshot.closed else "minimized" if saved.snapshot.minimized else "open"])
	page.button(actions, "Restore snapshot", func(): state.restore_snapshot(saved.snapshot))
