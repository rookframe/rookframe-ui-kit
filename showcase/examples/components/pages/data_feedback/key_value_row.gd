extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var facts = page.section("Compact facts")
	for pair in [["CREATED", "17 October"], ["PLAYERS", "4 of 6"], ["REGION", "Northern coast"]]:
		page.scene(Demo.path("data/key_value_row"), facts, {"key_text": pair[0], "value_text": pair[1]})
	var long_copy = page.section("Long values", "Keys and values remain a single readable fact.")
	page.scene(Demo.path("data/key_value_row"), long_copy, {"key_text": "DESTINATION", "value_text": "The observatory beyond the northern mountains"})
	page.scene(Demo.path("data/key_value_row"), long_copy, {"key_text": "REFERENCE", "value_text": "Not assigned"})
