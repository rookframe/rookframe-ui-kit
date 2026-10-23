extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")
const Meter = preload("res://rookframe/ui/components/data/vital_meter.gd")

static func build(page) -> void:
	for compact in [false, true]:
		var main = page.section("Compact" if compact else "Normal", "Portrait, name and detail are one native button. Activation hands off to the caller.")
		var status = page.note(main, "No identity activated.")
		var row = page.flow(main)
		var plate = page.scene(Demo.path("data/identity_plate"), row, {"title": "Wanderer", "detail": "Pilgrim of the coast", "initials": "WA", "compact": compact})
		page.scene(Demo.path("data/vital_meter"), plate.get_vital_slot(), {"caption": "HP", "value": 7.0, "max_value": 12.0, "level": Meter.Level.WOUNDED})
		var plain = page.scene(Demo.path("data/identity_plate"), row, {"title": "Grave Hound", "detail": "Beast", "portrait": load("res://rookframe/ui/icons/person.svg"), "compact": compact})
		for target in [plate, plain]:
			target.pressed.connect(func(): status.text = "pressed: " + target.title)
	var copy = page.section("Long names", "Name and detail wrap; the portrait stays visible.")
	page.scene(Demo.path("data/identity_plate"), page.flow(copy), {"title": "Archivist of the Northern Observatory", "detail": "Keeper of the long winter ledger", "initials": "AO"})
	var unavailable = page.section("Disabled", "A disabled identity stays readable.")
	page.scene(Demo.path("data/identity_plate"), page.flow(unavailable), {"title": "Wanderer", "detail": "Resting", "initials": "WA", "disabled": true})
