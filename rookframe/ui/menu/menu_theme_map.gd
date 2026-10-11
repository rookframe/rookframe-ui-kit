extends RefCounted
## Authored Theme mapping: semantic selectors and Material references only.
## No visual values belong here. The native Theme is derived by menu_theme.gd.
const Usage = preload("menu_usage.gd")
const State = preload("menu_state.gd")

const DEFAULTS = {"font": "type.ui", "font_size": "default.font_size"}
const ELEMENTS = {
	"menu.buttons": {
		"base_type": &"MarginContainer",
		"constants/margin_left": "wood.buttons.inset",
		"constants/margin_right": "wood.buttons.inset",
		"constants/margin_top": "wood.buttons.vertical_inset",
		"constants/margin_bottom": "wood.buttons.vertical_inset",
	},
	"menu.buttons@compact": {
		"base_type": &"menu.buttons",
		"constants/margin_left": "wood.buttons.inset.compact",
		"constants/margin_right": "wood.buttons.inset.compact",
	},
	"menu.heading": {
		"base_type": &"Label",
		"fonts/font": "type.display.medium",
		"font_sizes/font_size": "title.font_size",
		"colors/font_color": "title.font_color",
		"colors/font_shadow_color": "title.font_shadow_color",
		"constants/shadow_offset_y": "title.shadow_offset_y",
		"constants/line_spacing": "title.line_spacing",
	},
	"menu.identity.label": {
		"base_type": &"Label",
		"fonts/font": "type.display.medium",
		"font_sizes/font_size": "subtitle.font_size",
		"colors/font_color": "subtitle.font_color",
	},
	"menu.description": {
		"base_type": &"Label",
		"fonts/font": "type.ui",
		"font_sizes/font_size": "body.font_size",
		"colors/font_color": "body.font_color",
	},
	"menu.metadata": {
		"base_type": &"Label",
		"fonts/font": "type.ui",
		"font_sizes/font_size": "meta.font_size",
		"colors/font_color": "meta.font_color",
	},
	"menu.world.title": {
		"base_type": &"Label",
		"fonts/font": "type.display.medium",
		"font_sizes/font_size": "papertitle.font_size",
		"colors/font_color": "papertitle.font_color",
	},
	"menu.world.description": {
		"base_type": &"Label",
		"fonts/font": "type.ui",
		"font_sizes/font_size": "paperbody.font_size",
		"colors/font_color": "paperbody.font_color",
	},
	"menu.world.metadata": {
		"base_type": &"Label",
		"fonts/font": "type.ui.medium",
		"font_sizes/font_size": "papermeta.font_size",
		"colors/font_color": "papermeta.font_color",
	},
	"menu.world.status@online": {
		"base_type": &"menu.world.metadata",
		"colors/font_color": "papersuccess.font_color",
	},
	"menu.structure": {
		"base_type": &"Panel",
		"styles/panel": "stone.structure",
		"icons/grain": "stone.grain",
		"colors/grain_tint": "stone.grain.tint",
	},
	"menu.group": {
		"base_type": &"Panel",
		"styles/panel": "stone.tray",
		"icons/grain": "stone.grain",
		"colors/grain_tint": "stone.grain.tint",
		"styles/edge": "stone.inner_edge",
	},
	"menu.world.record": {
		"base_type": &"Panel",
		"styles/panel": "paper.record",
		"icons/grain": "paper.grain",
		"colors/grain_tint": "paper.grain.tint",
	},
	"menu.divider": {
		"base_type": &"HSeparator",
		"constants/separation": "rule.separation",
		"styles/separator": "brass.rule",
	},
	"menu.heading@compact": {
		"base_type": &"menu.heading",
		"font_sizes/font_size": "compacttitle.font_size",
	},
	"menu.identity.label@compact": {
		"base_type": &"menu.identity.label",
		"font_sizes/font_size": "brandcompact.font_size",
	},
	"menu.perimeter": {
		"base_type": &"Panel",
		"styles/panel": "brass.perimeter",
	},
	"menu.atmosphere": {
		"base_type": &"TextureRect",
		"icons/image": "image.atmosphere",
	},
	"menu.identity.symbol": {
		"base_type": &"TextureRect",
		"icons/image": "image.identity",
		"colors/tint": "identity.tint",
	},
	"menu.surface": {"base_type": &"Panel", "constants/grain_inset": "surface.grain_inset", "constants/edge_inset": "surface.edge_inset"},
}

const BUTTON_COMMON = {
    "texture_visible": "wood.texture_visible",
    "icons_visible": "wood.icons_visible",
    "font": "type.inlay",
    "outline_size": "button.standard.outline_size",
    "focus": "outline.none",
    "hover_ms": "metal.motion.hover_ms",
    "press_ms": "metal.motion.press_ms",
    "release_ms": "metal.motion.release_ms",
    "transition": "metal.motion.transition",
    "ease": "metal.motion.ease",
    "cap": "wood.brass.cap",
    "cap_tint": "wood.cap.tint",
    "rest_tint": "wood.resting.cap_tint",
    "edge_tint": "wood.edge.tint",
    "shadow_tint": "wood.shadow.tint",
    "adornment": "brass.adornment",
    "groove_color": "brass.inlay.groove",
    "cut_edge_color": "brass.inlay.cut_edge",
    "groove_size": "brass.inlay.outline_size",
    "groove_offset_x": "brass.inlay.shadow_offset_x",
    "groove_offset_y": "brass.inlay.shadow_offset_y",
    "groove_shadow_size": "brass.inlay.shadow_outline_size",
    "cap_depth": "wood.cap_depth",
    "shadow_drop": "wood.shadow_drop",
    "patch_side": "wood.patch_side",
    "patch_rail": "wood.patch_rail",
    "ornament_width": "wood.ornament_width",
    "ornament_height": "wood.ornament_height",
    "ornament_travel": "wood.ornament_travel",
    "ornament_ms": "wood.ornament_ms",
}
const BUTTON_MATERIALS = {
    Usage.PRIMARY: {"ornament_rest": "brass.primary.ornament_rest"},
    Usage.STANDARD: {
        "ornament_rest": "brass.standard.ornament_rest",
        "cap": "wood.plain.cap",
        "patch_side": "wood.plain.patch_side",
        "patch_rail": "wood.plain.patch_rail",
        "ornament_width": "wood.plain.ornament_width",
        "ornament_travel": "wood.plain.ornament_travel",
    },
}
const BUTTON_DENSITY = {
    State.REGULAR: {
        "font_size": "button.standard.font_size",
    },
    State.COMPACT: {
        "font_size": "button.compact.font_size",
    },
}
const BUTTON_FOCUS = {
    "focus": "brass.adornment.focus",
    "label": "button.standard.font_focus_color",
}
const BUTTON_STATES = {
    Usage.STANDARD: {
        State.RESTING: {
            "surface": "wood.resting.surface",
            "border": "wood.resting.border",
            "label": "button.standard.font_color",
        },
        State.HOVERED: {
            "surface": "wood.hovered.surface",
            "border": "wood.hovered.border",
            "label": "button.standard.font_hover_color",
        },
        State.PRESSED: {
            "surface": "wood.pressed.surface",
            "border": "wood.pressed.border",
            "label": "button.standard.font_pressed_color",
        },
        State.DISABLED: {
            "surface": "wood.disabled.surface",
            "border": "wood.disabled.border",
            "label": "button.standard.font_disabled_color",
        },
    },
    Usage.PRIMARY: {
        State.RESTING: {
            "surface": "wood.resting.surface",
            "border": "wood.resting.border",
            "label": "button.primary.font_color",
        },
        State.HOVERED: {
            "surface": "wood.hovered.surface",
            "border": "wood.hovered.border",
            "label": "button.primary.font_hover_color",
        },
        State.PRESSED: {
            "surface": "wood.pressed.surface",
            "border": "wood.pressed.border",
            "label": "button.primary.font_pressed_color",
        },
        State.DISABLED: {
            "surface": "wood.disabled.surface",
            "border": "wood.disabled.border",
            "label": "button.primary.font_disabled_color",
        },
    },
}
const BUTTON_PADDING = {
    State.REGULAR: {
        State.RESTING: "control.resting.padding",
        State.HOVERED: "control.hovered.padding",
        State.PRESSED: "control.pressed.padding",
        State.DISABLED: "control.disabled.padding",
    },
    State.COMPACT: {
        State.RESTING: "control.resting.padding.compact",
        State.HOVERED: "control.hovered.padding.compact",
        State.PRESSED: "control.pressed.padding.compact",
        State.DISABLED: "control.disabled.padding.compact",
    },
}
const STANDARD_PADDING = {
    State.REGULAR: {
        State.RESTING: "wood.plain.resting.padding",
        State.HOVERED: "wood.plain.resting.padding",
        State.PRESSED: "wood.plain.pressed.padding",
        State.DISABLED: "wood.plain.pressed.padding",
    },
    State.COMPACT: {
        State.RESTING: "wood.plain.resting.padding.compact",
        State.HOVERED: "wood.plain.resting.padding.compact",
        State.PRESSED: "wood.plain.pressed.padding.compact",
        State.DISABLED: "wood.plain.pressed.padding.compact",
    },
}
const BUTTON_HEIGHT = {
    Usage.PRIMARY: {State.REGULAR: "button.primary.height", State.COMPACT: "button.primary.height.compact"},
    Usage.STANDARD: {State.REGULAR: "button.standard.height", State.COMPACT: "button.standard.height.compact"},
}

static func button(usage: StringName, state: Dictionary) -> Dictionary:
    assert(usage in BUTTON_STATES, "Unknown menu button usage")
    var condition: StringName = State.DISABLED if state.availability == State.DISABLED else state.interaction
    var references: Dictionary = BUTTON_COMMON.duplicate()
    references.merge(BUTTON_DENSITY[state.density], true)
    references.merge(BUTTON_MATERIALS[usage], true)
    references.merge(BUTTON_STATES[usage][condition], true)
    references["padding"] = (STANDARD_PADDING if usage == Usage.STANDARD else BUTTON_PADDING)[state.density][condition]
    references["minimum_height"] = BUTTON_HEIGHT[usage][state.density]
    if state.focus == State.FOCUSED:
        references["focus"] = "wood.plain.focus" if usage == Usage.STANDARD else BUTTON_FOCUS.focus
        # Match native Button: focus ink applies at rest; hover/press keep their ink.
        if state.availability == State.ENABLED and state.interaction == State.RESTING:
            references["label"] = BUTTON_FOCUS.label
    return references
