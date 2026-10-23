extends RefCounted

const Demo = preload("res://examples/components/pages/actions_forms/support.gd")
const Tile = preload("res://rookframe/ui/components/actions/icon_tile.gd")
const SCENE := "res://rookframe/ui/components/actions/icon_tile.tscn"
const ICONS := "res://rookframe/ui/icons/"
const USAGES := [
	{"name": "Category", "usage": Tile.Usage.CATEGORY, "entries": [["Abilities", "bolt"], ["Attacks", "swords"], ["Items", "pack"]], "toggle": true},
	{"name": "Tool", "usage": Tile.Usage.TOOL, "entries": [["Select", "crosshair"], ["Add", "add"], ["Connect", "link"]], "toggle": true},
	{"name": "Choice", "usage": Tile.Usage.CHOICE, "entries": [["d4", "dice"], ["d6", "dice"], ["d20", "dice"]], "toggle": false},
]

static func build(page) -> void:
	for compact in [false, true]:
		var main = page.section("Compact" if compact else "Normal", "Category and tool tiles share one ButtonGroup each; choice tiles press once per activation.")
		var status = page.note(main, "No tile activated.")
		for item in USAGES:
			page.note(main, item.name)
			var row = page.flow(main)
			var group: ButtonGroup = load("res://rookframe/ui/components/forms/selection_group.tres").duplicate() if item.toggle else null
			if group != null:
				group.allow_unpress = true
			for entry in item.entries:
				var tile = page.scene(SCENE, row, {"usage": item.usage, "compact": compact, "text": entry[0], "icon": load(ICONS + entry[1] + ".svg"), "toggle_mode": item.toggle, "button_group": group})
				if item.toggle:
					tile.toggled.connect(func(on: bool): status.text = "toggled(%s): %s" % [on, entry[0]])
				else:
					tile.pressed.connect(func(): status.text = "pressed: " + entry[0])
	var unavailable = page.section("Disabled", "Unavailable tiles keep their icon and label.")
	var row = page.flow(unavailable)
	for item in USAGES:
		page.scene(SCENE, row, {"usage": item.usage, "text": item.entries[0][0], "icon": load(ICONS + item.entries[0][1] + ".svg"), "disabled": true})
	var copy = page.section("Long and translated labels", "Labels wrap between words; the tile grows instead of trimming.")
	var labels = page.flow(copy)
	for title in ["Companions and hirelings", "Восстановление", "Begleiter"]:
		page.scene(SCENE, labels, {"text": title, "icon": load(ICONS + "people.svg")})
