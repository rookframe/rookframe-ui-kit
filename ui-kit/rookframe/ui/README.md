# Unthemed public runtime

This subtree installs at `res://rookframe/ui/`. Components retain their public
paths and UIDs, slots, input and behavior. They assign no Theme, custom fonts,
colors or material resources. Native Godot Theme inheritance supplies appearance.
Semantic variation names are hooks for a consumer Theme, not default styling.

`components/` contains compositions Godot does not supply as one native Control;
`menu/`, `editor/` and `chronicle/` provide theme-aware interaction recipes.
`icons/` supplies semantic icons and their licenses. `_internal/` is unsupported.
`catalogue.json` indexes the core API and identifies optional theme contracts.

Install `--theme silkbound-ledger` and explicitly instance scenes under
`res://rookframe/ui/silkbound-ledger/` to opt into Silkbound Ledger. These inherit
the corresponding core scenes. Theme resources, tokens and material assets are
owned by that package and keep their existing installed paths/UIDs. Merely
installing it never styles the core components.
