extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")
const Meter = preload("res://rookframe/ui/components/data/vital_meter.gd")

static func build(page) -> void:
	var levels = page.section("Levels", "The caller chooses each level; the component computes no thresholds.")
	for item in [["Steady", Meter.Level.STEADY, 12.0], ["Wounded", Meter.Level.WOUNDED, 7.0], ["Critical", Meter.Level.CRITICAL, 2.0], ["Depleted", Meter.Level.DEPLETED, 0.0]]:
		page.note(levels, item[0])
		page.scene(Demo.path("data/vital_meter"), levels, {"caption": "HP", "value": item[2], "max_value": 12.0, "level": item[1]})
	var copy = page.section("Value text and track", "Custom value copy and a value-only meter without a track.")
	page.scene(Demo.path("data/vital_meter"), copy, {"caption": "Omens", "value": 2.0, "max_value": 3.0, "value_text": "2 of 3 remaining"})
	page.scene(Demo.path("data/vital_meter"), copy, {"caption": "Silver", "value": 140.0, "max_value": 140.0, "value_text": "140s", "show_track": false})
	var live = page.section("Live value", "Change the value; the level is set by this example.")
	var meter = page.scene(Demo.path("data/vital_meter"), live, {"caption": "HP", "value": 12.0, "max_value": 12.0})
	var controls = page.flow(live)
	var change := func(amount: float):
		meter.value = clampf(meter.value + amount, 0.0, meter.max_value)
		meter.level = Meter.Level.DEPLETED if meter.value <= 0.0 else Meter.Level.CRITICAL if meter.value <= 3.0 else Meter.Level.WOUNDED if meter.value < meter.max_value else Meter.Level.STEADY
	page.button(controls, "Take 1 damage", func(): change.call(-1.0))
	page.button(controls, "Heal 1", func(): change.call(1.0))
