extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	Demo.input_examples(page, "res://rookframe/ui/silkbound-ledger/components/forms/task_text_area.tscn", true, true)
