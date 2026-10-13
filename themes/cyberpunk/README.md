# Cyberpunk theme

Optional native Godot theme package. Depends only on the sibling UI Kit.
The kit supplies controls, semantic mappings, geometry and the Theme compiler;
this package owns its material values, artwork and theme-specific mapping.

Install from the monorepo root:

```sh
python3 tools/workspace.py install --destination /path/to/godot-project --theme cyberpunk
```

Assign `res://rookframe/ui/menu/cyberpunk/CyberpunkTheme.tres` to the owning Control.
Runtime paths and existing UIDs are preserved; resources are merged into the
consumer's `rookframe/ui/`. Review this package through `../../showcase`.
See the [recipe contract](../../ui-kit/docs/native-controls-and-recipes.md).
Source and generated art use [MIT](LICENSE); shipped fonts retain their licenses.
