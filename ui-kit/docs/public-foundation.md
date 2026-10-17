# Public foundation reference

Normal resources under `res://rookframe/ui/` are public; `_internal/` is unsupported.
The core supplies components, native interaction recipes, a Theme compiler and
semantic icons. It supplies no Theme resources, material assets, fonts or palette.

## Resource identities

| Resource | Identity | Purpose |
| --- | --- | --- |
| `catalogue.json` | Path and schema version | Public component and recipe contracts |
| `components/**/*.tscn` | Path and scene UID | Reusable native composition |
| `components/**/*.gd` | Path and script UID | Component behavior |
| `themes/component_theme.gd` | Path and script UID | Native Theme with optional component presentation |
| `menu/menu_theme.gd` | Path and script UID | Compile caller-supplied Theme mappings |
| `icons/<semantic-name>.svg` | Path and import UID | Interface pictogram |
| `icons/manifest.json` | Path | Semantic registry and upstream provenance |

The [component reference](public-components.md) documents public identities,
properties, signals and slots. The [semantic icon reference](semantic-icons.md)
documents icon meanings, licenses and accessible labels.

## Theme inheritance

Set a native Theme on the owning Control. Components inherit its resources and
semantic variations through Godot. Without that Theme, Godot defaults apply.
`theme_type_variation` describes purpose; it does not select a concrete appearance.
Keep the native node type and behavior when supplying a variation.

The canonical activation resource is `themes/<theme-name>/theme.tres`.
Assign it to the owning Control in code or the Inspector, and keep using the same
public component scenes. The shared Theme subclass also supplies optional
presentation resources through generic core hooks; package-specific setup and
scene selection are unnecessary. Existing inherited skin scenes remain supported
compatibility resources. See [Theme activation](world-theme-styling.md).
