# Unthemed public runtime

This subtree installs at `res://rookframe/ui/`. Components provide composition,
slots, input and behavior. They assign no Theme, custom fonts, colors or material
resources. Native Godot Theme inheritance supplies appearance. Semantic variation
names are hooks for a consumer Theme.

`components/` contains compositions Godot does not supply as one native Control;
`menu/`, `editor/` and `chronicle/` provide theme-aware interaction recipes.
`icons/` supplies semantic icons and their licenses. `_internal/` is unsupported.
`catalogue.json` indexes the core API. `themes/` holds the shared Theme
subclass and the semantic token contract with its neutral set.

Consumers can assign native Themes or inherit these scenes to supply appearance.
Installing an optional theme package never changes the base component resources.
