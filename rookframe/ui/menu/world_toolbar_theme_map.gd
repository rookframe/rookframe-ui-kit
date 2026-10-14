extends RefCounted
## Application usages compose shared button and group treatments.
const ELEMENTS = {
	"components.backdrop": {
		"base_type": &"ColorRect",
		"colors/color": "backdrop.color",
	},
	"world.escapeMenu.layout": {
		"base_type": &"Control",
		"constants/surface_width": "escape.surface_width",
		"constants/inset": "worlds.inset",
		"constants/inset_compact": "worlds.inset_compact",
		"constants/breakpoint_compact": "worlds.breakpoint_compact",
	},
	"world.escapeMenu.surface": {
		"base_type": &"PanelContainer",
		"styles/panel": "escape.padding",
	},
	"world.escapeMenu.surface@compact": {
		"base_type": &"world.escapeMenu.surface",
		"styles/panel": "escape.padding.compact",
	},
	"world.escapeMenu.content": {
		"base_type": &"VBoxContainer",
		"constants/separation": "worlds.gap",
	},
	"world.escapeMenu.content@compact": {
		"base_type": &"world.escapeMenu.content",
		"constants/separation": "worlds.gap_compact",
	},
}
