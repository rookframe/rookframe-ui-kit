# Public foundation reference

The filesystem is authoritative: normal resources under
`res://rookframe/ui/` are public; only `_internal/` is unsupported.

## Resource identities

| Resource | Stable identity | Purpose |
| --- | --- | --- |
| `theme/rookframe_theme.tres` | `uid://s4dv3jijmvy1` | Shared Theme for built-in Godot Controls and semantic variations |
| `tokens.gd` | `uid://bx5kfbojp1jkc` | Semantic palette, spacing, geometry, type, and responsive values for public relationships |
| `catalogue.json` | Stable path and schema version | Machine-readable Theme and public component contract index |
| `components/**/*.tscn` | Documented scene UID | Editor-authored relationship that Godot does not provide as one built-in node |
| `components/**/*.gd` | Documented script UID | Small behavior required by its associated public relationship |
| `assets/fonts/Inter-VariableFont_opsz,wght.ttf` | Path plus committed import UID | Readable UI copy, values, fields, and actions |
| `assets/fonts/Exo2-VariableFont_wght.ttf` | Path plus committed import UID | Condensed hierarchy for managed-surface titles and headings |
| `assets/frames/*.png` | Semantic path plus committed import UID | Nine-slice managed surface, section, primary/secondary action, and focus frames |
| `icons/<semantic-name>.svg` | Manifest name, path, and committed import UID | Stable, context-neutral interface pictogram |
| `icons/manifest.json` | Stable path | Ordered semantic registry and upstream provenance |

## Token authority

`rookframe_theme.tres` is the visual authority for native Controls.
`tokens.gd` is its public companion for the reusable relationships that cannot
express layout or state through Theme items alone. Godot serializes StyleBox
values directly and cannot reference script constants from a `.tres`, so some
exact colors and geometry appear in both files deliberately.

When an exact value changes, maintainers update both representations in one
change and review the visual catalogue for drift. The semantic names and
purposes are the compatibility contract; exact visual values may change within
a SemVer major line. The manual review seam is intentionally not an automated
validation or release gate.

## Theme variation names

### Surfaces

| Variation | Base type | Meaning |
| --- | --- | --- |
| `RookframeCanvas` | `PanelContainer` | Full application or catalogue canvas |
| `RookframeSurface` | `PanelContainer` | Ordinary content surface |
| `RookframeRaisedSurface` | `PanelContainer` | Elevated local surface |
| `RookframeInsetSurface` | `PanelContainer` | Sunken or nested content region |
| `RookframeSection` | `PanelContainer` | Framed semantic section |
| `RookframeManagedSurface` | `PanelContainer` | Outer frame for a reusable managed presentation |
| `RookframeNotice` | `PanelContainer` | Compact in-place status or recovery region |
| `RookframeNoticeInfo` | `PanelContainer` | Informational Notice tone |
| `RookframeNoticePending` | `PanelContainer` | In-progress Notice tone |
| `RookframeNoticeSuccess` | `PanelContainer` | Successful Notice tone |
| `RookframeNoticeError` | `PanelContainer` | Recoverable-error Notice tone |
| `RookframeBadge` | `PanelContainer` | Short classification or compatibility chip |
| `RookframeSearchField` | `PanelContainer` | Composite Search Field perimeter |
| `RookframeSearchFieldFocus` | `PanelContainer` | Focused Search Field perimeter |
| `RookframeStructuredRow` | `PanelContainer` | Neutral structured record frame |
| `RookframeStructuredRowSelected` | `PanelContainer` | Selected structured record frame |
| `RookframeStepPending` | `PanelContainer` | Pending workflow-step marker |
| `RookframeStepCurrent` | `PanelContainer` | Current workflow-step marker |
| `RookframeStepComplete` | `PanelContainer` | Completed workflow-step marker |
| `RookframeDialogSurface` | `PanelContainer` | Outer frame for designed modal compositions |

### Text

| Variation | Meaning |
| --- | --- |
| `RookframeTitle` | Surface identity |
| `RookframeSubtitle` | Current task title |
| `RookframeHeading` | Section identity |
| `RookframeLabel` | Concise field or statistic label |
| `RookframeValue` | Prominent live value |
| `RookframeBody` | Readable rules or descriptive copy |
| `RookframeMeta` | Help, provenance, or secondary facts |
| `RookframeStatus` | Compact neutral live state |
| `RookframePending` | Visible in-progress state |
| `RookframeSuccess` | Confirmed positive state |
| `RookframeError` | Actionable failure |
| `RookframeIdentity` | Row or record name |
| `RookframeBadgeText` | Text inside a classification chip |

Text roles express meaning, not a request for one color or font size. Their
exact visual values may change compatibly while the role's purpose remains.

### Actions

| Variation | Meaning |
| --- | --- |
| `RookframePrimaryButton` | Advances or commits the current task |
| `RookframeSecondaryButton` | Important alternative that does not advance the task |
| `RookframeQuietButton` | Compact reveal, retry, or row-local action |
| `RookframeDangerButton` | Destructive or abandoning action |
| `RookframeTabButton` | Changes a visible section without changing domain state |
| `RookframeChoiceRow` | Complete detailed or compact choice target |

Use native `Button`; these are Theme variations, not wrappers. Ordinary icon-
only actions retain a semantic accessible name and at least a 44×44 interaction
target.

## Native defaults covered by the foundation

The Theme directly styles `Button`, `CheckBox`, `CheckButton`, `LineEdit`,
`TextEdit`, `SpinBox`, `HSlider`, `VSlider`, `MenuButton`, `OptionButton`,
`PopupMenu`, `PopupPanel`, `ProgressBar`, `TabBar`, `TabContainer`, `ItemList`,
`Tree`, `Window`, dialogs, panels, separators, scrollbars, and the native
row/flow/grid containers. Compose ordinary behavior with these built-ins. The
kit adds a public scene only when Godot lacks the reusable relationship; see
[the component reference](public-components.md).

## Semantic icons

`icons/manifest.json` documents all 62 public names, accessible labels, and
the pinned Tabler source. Consumers load the semantic path, for example:

```gdscript
var retry_icon := load("res://rookframe/ui/icons/retry.svg")
```

Choose the meaning (`retry`, `close`, `dock`, `warning`) rather than an
upstream drawing or a consuming screen's name. Every semantic role has distinct
source geometry; for example, `clear.svg` uses a backspace drawing while
`close.svg` uses a plain close mark. No Manager-, Character Sheet-, or
Package-named alias is present.

## Compatibility

The UI Kit uses independent SemVer, not SDK Editions. Within a major line,
public paths and UIDs, variation names and meanings, and documented observable
behavior remain stable. Exact visual values and `_internal/` implementation may
change compatibly. Direct Godot API use is outside Rookframe's compatibility
guarantee and remains part of a Package Publisher's Rookframe Version judgment.
