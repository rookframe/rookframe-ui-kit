extends RefCounted
## Authored Theme mapping: semantic selectors and Material references only.
## No visual values belong here. The native Theme is derived by menu_theme.gd.
const Usage = preload("../menu_usage.gd")
const State = preload("../menu_state.gd")

const DEFAULTS = {"font": "type.ui", "font_size": "default.font_size"}
const ELEMENTS = {
	"menu.buttons": {
		"base_type": &"MarginContainer",
		"constants/margin_left": "alloy.buttons.inset",
		"constants/margin_right": "alloy.buttons.inset",
		"constants/margin_top": "alloy.buttons.inset",
		"constants/margin_bottom": "alloy.buttons.inset",
	},
	"menu.buttons@compact": {"base_type": &"menu.buttons"},
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
		"font_sizes/font_size": "worldtitle.font_size",
		"colors/font_color": "worldtitle.font_color",
	},
	"menu.world.description": {
		"base_type": &"Label",
		"fonts/font": "type.ui",
		"font_sizes/font_size": "worldbody.font_size",
		"colors/font_color": "worldbody.font_color",
	},
	"menu.world.metadata": {
		"base_type": &"Label",
		"fonts/font": "type.ui.medium",
		"font_sizes/font_size": "worldmeta.font_size",
		"colors/font_color": "worldmeta.font_color",
	},
	"menu.world.status@online": {
		"base_type": &"menu.world.metadata",
		"colors/font_color": "worldsuccess.font_color",
	},
	"menu.structure": {
		"base_type": &"Panel",
		"styles/panel": "chassis.structure",
		"icons/grain": "chassis.grain",
		"colors/grain_tint": "chassis.grain.tint",
	},
	"menu.group": {
		"base_type": &"Panel",
		"styles/panel": "chassis.tray",
		"icons/grain": "chassis.grain",
		"colors/grain_tint": "chassis.grain.tint",
		"styles/edge": "chassis.inner_edge",
	},
	"menu.world.record": {
		"base_type": &"Panel",
		"styles/panel": "glass.record",
		"icons/grain": "glass.grain",
		"colors/grain_tint": "glass.grain.tint",
	},
	"menu.divider": {
		"base_type": &"HSeparator",
		"constants/separation": "rule.separation",
		"styles/separator": "signal.rule",
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
		"styles/panel": "signal.perimeter",
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
	"menu.symbol.worlds": {"base_type": &"TextureRect", "icons/image": "image.worlds"},
	"menu.symbol.packages": {"base_type": &"TextureRect", "icons/image": "image.packages"},
	"menu.symbol.settings": {"base_type": &"TextureRect", "icons/image": "image.settings"},
	"menu.symbol.open": {"base_type": &"TextureRect", "icons/image": "image.open"},
	"menu.surface": {"base_type": &"Panel", "constants/grain_inset": "surface.grain_inset", "constants/edge_inset": "surface.edge_inset"},
}

const BUTTON_COMMON = {
    "texture_visible": "alloy.texture_visible",
    "font": "type.control",
    "outline_size": "button.standard.outline_size",
    "focus": "outline.none",
    "hover_ms": "switch.motion.hover_ms",
    "press_ms": "switch.motion.press_ms",
    "release_ms": "switch.motion.release_ms",
    "transition": "switch.motion.transition",
    "ease": "switch.motion.ease",
    "cap": "alloy.cap",
    "cap_tint": "alloy.cap.tint",
    "edge_tint": "alloy.edge.tint",
    "shadow_tint": "alloy.shadow.tint",
    "adornment": "signal.adornment",
    "groove_color": "signal.inlay.groove",
    "cut_edge_color": "signal.inlay.cut_edge",
    "groove_size": "signal.inlay.outline_size",
    "groove_offset_x": "signal.inlay.shadow_offset_x",
    "groove_offset_y": "signal.inlay.shadow_offset_y",
    "groove_shadow_size": "signal.inlay.shadow_outline_size",
    "cap_depth": "alloy.cap_depth",
    "shadow_drop": "alloy.shadow_drop",
    "patch_side": "alloy.patch_side",
    "patch_rail": "alloy.patch_rail",
    "ornament_width": "alloy.ornament_width",
    "ornament_height": "alloy.ornament_height",
    "ornament_travel": "alloy.ornament_travel",
    "ornament_ms": "alloy.ornament_ms",
    "icons_visible": "alloy.icons_visible",
}
const BUTTON_MATERIALS = {
    Usage.PRIMARY: {"ornament_rest": "signal.primary.ornament_rest"},
    Usage.STANDARD: {"ornament_rest": "signal.standard.ornament_rest"},
    Usage.DESTRUCTIVE: {
        "ornament_rest": "signal.standard.ornament_rest",
        "ornament_width": "signal.destructive.ornament_width",
        "ornament_travel": "signal.destructive.ornament_travel",
    },
}
const BUTTON_DENSITY = {
    State.REGULAR: {
        "font_size": "button.standard.font_size",
        "h_separation": "button.standard.h_separation",
        "icon_max_width": "button.standard.icon_max_width",
    },
    State.COMPACT: {
        "font_size": "button.compact.font_size",
        "h_separation": "button.compact.h_separation",
        "icon_max_width": "button.compact.icon_max_width",
    },
}
const BUTTON_FOCUS = {
    Usage.PRIMARY: {
        "focus": "signal.adornment.focus",
        "label": "button.primary.font_focus_color",
        "icon": "button.primary.font_focus_color",
    },
    Usage.STANDARD: {
        "focus": "signal.adornment.focus",
        "label": "button.standard.font_focus_color",
        "icon": "button.standard.icon_focus_color",
    },
    Usage.DESTRUCTIVE: {
        "focus": "warning.focus",
        "label": "button.destructive.font_focus_color",
        "icon": "button.destructive.font_focus_color",
    },
}
const BUTTON_STATES = {
    Usage.STANDARD: {
        State.RESTING: {
            "surface": "alloy.resting.surface",
            "border": "alloy.resting.border",
            "label": "button.standard.font_color",
            "icon": "button.standard.icon_normal_color",
        },
        State.HOVERED: {
            "surface": "alloy.hovered.surface",
            "border": "alloy.hovered.border",
            "label": "button.standard.font_hover_color",
            "icon": "button.standard.icon_hover_color",
        },
        State.PRESSED: {
            "surface": "alloy.pressed.surface",
            "border": "alloy.pressed.border",
            "label": "button.standard.font_pressed_color",
            "icon": "button.standard.icon_pressed_color",
        },
        State.DISABLED: {
            "surface": "alloy.disabled.surface",
            "border": "alloy.disabled.border",
            "label": "button.standard.font_disabled_color",
            "icon": "button.standard.icon_disabled_color",
        },
    },
    Usage.PRIMARY: {
        State.RESTING: {
            "surface": "emissive.resting.surface",
            "border": "emissive.resting.border",
            "label": "button.primary.font_color",
            "icon": "button.primary.font_color",
        },
        State.HOVERED: {
            "surface": "emissive.hovered.surface",
            "border": "emissive.hovered.border",
            "label": "button.primary.font_hover_color",
            "icon": "button.primary.font_hover_color",
        },
        State.PRESSED: {
            "surface": "emissive.pressed.surface",
            "border": "emissive.pressed.border",
            "label": "button.primary.font_pressed_color",
            "icon": "button.primary.font_pressed_color",
        },
        State.DISABLED: {
            "surface": "emissive.disabled.surface",
            "border": "emissive.disabled.border",
            "label": "button.primary.font_disabled_color",
            "icon": "button.primary.font_disabled_color",
        },
    },
    Usage.DESTRUCTIVE: {
        State.RESTING: {
            "surface": "warning.resting.surface",
            "border": "warning.resting.border",
            "label": "button.destructive.font_color",
            "icon": "button.destructive.font_color",
        },
        State.HOVERED: {
            "surface": "warning.hovered.surface",
            "border": "warning.hovered.border",
            "label": "button.destructive.font_hover_color",
            "icon": "button.destructive.font_hover_color",
        },
        State.PRESSED: {
            "surface": "warning.pressed.surface",
            "border": "warning.pressed.border",
            "label": "button.destructive.font_pressed_color",
            "icon": "button.destructive.font_pressed_color",
        },
        State.DISABLED: {
            "surface": "warning.disabled.surface",
            "border": "warning.disabled.border",
            "label": "button.destructive.font_disabled_color",
            "icon": "button.destructive.font_disabled_color",
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
const BUTTON_HEIGHT = {
    Usage.PRIMARY: {State.REGULAR: "button.primary.height", State.COMPACT: "button.primary.height.compact"},
    Usage.STANDARD: {State.REGULAR: "button.standard.height", State.COMPACT: "button.standard.height.compact"},
    Usage.DESTRUCTIVE: {State.REGULAR: "button.standard.height", State.COMPACT: "button.standard.height.compact"},
}

static func button(usage: StringName, state: Dictionary) -> Dictionary:
    assert(usage in BUTTON_STATES, "Unknown menu button usage")
    var condition: StringName = State.DISABLED if state.availability == State.DISABLED else state.interaction
    var references: Dictionary = BUTTON_COMMON.duplicate()
    references.merge(BUTTON_DENSITY[state.density], true)
    references.merge(BUTTON_MATERIALS[usage], true)
    references.merge(BUTTON_STATES[usage][condition], true)
    references["padding"] = BUTTON_PADDING[state.density][condition]
    references["minimum_height"] = BUTTON_HEIGHT[usage][state.density]
    if state.focus == State.FOCUSED:
        references["focus"] = BUTTON_FOCUS[usage].focus
        # Match native Button: focus ink applies at rest; hover/press keep their ink.
        if state.availability == State.ENABLED and state.interaction == State.RESTING:
            references["label"] = BUTTON_FOCUS[usage].label
            references["icon"] = BUTTON_FOCUS[usage].icon
    return references
