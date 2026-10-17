# Fantasy theme

Optional native Godot theme package. The sibling UI Kit supplies controls and
the Theme compiler. `shared/fonts` and `shared/shell-common` supply optional fonts,
semantic mappings and geometry. This package owns materials, artwork and its mapping.

Install from the monorepo root:

```sh
python3 tools/workspace.py install --destination /path/to/godot-project --theme fantasy
```

Assign `res://rookframe/ui/themes/fantasy/theme.tres` to the owning Control
in code or the Inspector. Use the same `res://rookframe/ui/components/...` scenes
as every other theme. The shared native Theme entry wraps this package's existing
mapping compiler. Installation does not activate it; hosts own selection and
persistence. `res://rookframe/ui/menu/MenuTheme.tres` remains a compatibility resource.
See [the common activation contract](../../ui-kit/docs/world-theme-styling.md).
Runtime paths and existing UIDs are preserved; resources are merged into the
consumer's `rookframe/ui/`. Review this package through `../../showcase`.
See the [recipe contract](../../ui-kit/docs/native-controls-and-recipes.md).
Shared appearance rules live in [shell styling](../../shared/shell-common/docs/styling.md)
and [Chronicle styling](../../shared/shell-common/docs/chronicle.md).
Source and generated art use [MIT](LICENSE); shipped fonts retain their licenses.
