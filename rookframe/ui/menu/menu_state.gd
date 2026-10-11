extends RefCounted
## Independent semantic dimensions. Native Button owns transitions and input.
const ENABLED: StringName = &"enabled"
const DISABLED: StringName = &"disabled"
const RESTING: StringName = &"resting"
const HOVERED: StringName = &"hovered"
const PRESSED: StringName = &"pressed"
const UNFOCUSED: StringName = &"unfocused"
const FOCUSED: StringName = &"focused"
const OUTSIDE: StringName = &"outside"
const INSIDE: StringName = &"inside"
# Presentation density is separate from availability, interaction and focus.
const REGULAR: StringName = &"regular"
const COMPACT: StringName = &"compact"

static func button(availability: StringName = ENABLED, interaction: StringName = RESTING,
        focus: StringName = UNFOCUSED, density: StringName = REGULAR,
        pointer: StringName = OUTSIDE) -> Dictionary:
    return {"availability": availability, "interaction": interaction, "focus": focus, "density": density, "pointer": pointer}
