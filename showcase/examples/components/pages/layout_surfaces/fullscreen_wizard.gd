extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	var body = page.section("Interactive task", "Move through the steps to compare pending, current and completed progress states. Restart retains this one frame.")
	var bounds := Demo.region(body, 440)
	bounds.clip_contents = true
	var wizard = Demo.component(page, "components/surfaces/fullscreen_wizard.tscn", bounds, {"reduced_motion": page.reduced_motion})
	wizard.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var steps: Array[String] = ["Identity", "Details", "Review"]
	wizard.configure("ROOKFRAME", "Prepare a character", steps, {"subtitle": "Local example", "close": "Close preview", "restart": "Restart"})
	var context = Demo.stack(wizard.get_context_slot())
	page.note(context, "Character")
	page.note(context, "Mira")
	var stage = Demo.stack(wizard.get_stage_slot())
	var title = page.note(stage, "Choose an identity")
	var state := {"step": 0}
	var status = page.note(body, "Step 1 of 3")
	var refresh = func():
		wizard.set_step(state.step)
		title.text = ["Choose an identity", "Add the details", "Ready to begin"][state.step]
		wizard.set_primary("Finish" if state.step == 2 else "Continue", false)
		status.text = "Step %d of 3" % (state.step + 1)
	wizard.primary_requested.connect(func():
		if state.step < 2:
			state.step += 1
			refresh.call()
		else:
			status.text = "Finished · local example only"
			wizard.set_primary("Finished", true))
	wizard.back_requested.connect(func():
		state.step = maxi(0, state.step - 1)
		refresh.call())
	wizard.restart_requested.connect(func():
		state.step = 0
		refresh.call())
	wizard.close_requested.connect(func():
		wizard.hide()
		status.text = "Preview closed")
	page.button(body, "Reopen preview", func(): wizard.show())
	refresh.call()
	var unavailable = page.section("Waiting for required input", "The primary action stays unavailable until the consumer enables it.")
	var waiting_bounds := Demo.region(unavailable, 330)
	waiting_bounds.clip_contents = true
	var waiting = Demo.component(page, "components/surfaces/fullscreen_wizard.tscn", waiting_bounds, {"reduced_motion": true})
	waiting.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	waiting.configure("ROOKFRAME", "Prepare a character", steps, {"subtitle": "Required input"})
	page.note(Demo.stack(waiting.get_context_slot()), "Identity")
	page.note(Demo.stack(waiting.get_stage_slot()), "A name is required.")
	waiting.set_primary("Continue", true)
	waiting.set_back_enabled(false)
	waiting.close_requested.connect(func(): waiting.hide())
