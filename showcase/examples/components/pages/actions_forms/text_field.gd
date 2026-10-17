extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	Demo.input_examples(page, "res://rookframe/ui/components/forms/text_field.tscn", false, false)
