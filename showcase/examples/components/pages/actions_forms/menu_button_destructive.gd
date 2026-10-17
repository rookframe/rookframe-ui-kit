extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")

static func build(page) -> void:
	Demo.menu_button_examples(page, "res://rookframe/ui/menu/MenuButtonDestructive.tscn", "Delete draft", true)
