# Public foundation reference

The filesystem is authoritative: normal resources under
`res://rookframe/ui/` are public; only `_internal/` is unsupported.

## Resource identities

| Resource | Stable identity | Purpose |
| --- | --- | --- |
| `theme/rookframe_theme.tres` | `uid://s4dv3jijmvy1` | Shared Theme for built-in Godot Controls and semantic variations |
| `tokens.gd` | `uid://bx5kfbojp1jkc` | Semantic palette, spacing, geometry, type, and responsive values for public relationships |
| `catalogue.json` | Stable path and schema version | Machine-readable Theme and public component contract index |
| `components/**/*.tscn` | Scene UID in the [component reference](public-components.md#public-identities) | Editor-authored relationship that Godot does not provide as one built-in node |
| `components/**/*.gd` | Script UID in the [component reference](public-components.md#public-identities) | Small behavior required by its associated public relationship |
| `assets/fonts/*.ttf` | Path and import UID below | UI and display typography assigned by the shared Theme |
| `assets/frames/*.png` | Semantic path and import UID below | Nine-slice managed surface, section, primary/secondary action, and focus frames |
| `icons/<semantic-name>.svg` | Path and import UID in the [semantic icon reference](semantic-icons.md) | Stable, context-neutral interface pictogram |
| `icons/manifest.json` | Stable path | Ordered semantic registry and upstream provenance |

The two font license texts under `assets/fonts/` and the Tabler license at
`icons/LICENSE` are also public installed resources. Preserve them whenever
redistributing the subtree.

### Font identities

| Resource | Import UID | Purpose and composition |
| --- | --- | --- |
| `assets/fonts/Inter-VariableFont_opsz,wght.ttf` | `uid://cje80i18uults` | Readable copy, values, fields, and actions; assigned by the shared Theme rather than per-screen overrides |
| `assets/fonts/Exo2-VariableFont_wght.ttf` | `uid://14n2hjuakwcl` | Condensed managed hierarchy for titles and headings; use through the documented text variations |

### Frame identities

These are Theme implementation assets with public identities. Compose them by
using the shared Theme or corresponding semantic variation; do not assign them
directly to build a consumer-specific style family.

| Resource | Import UID | Purpose |
| --- | --- | --- |
| `assets/frames/focus.png` | `uid://uvxy33oi4hw` | Visible keyboard/controller focus perimeter |
| `assets/frames/managed-surface.png` | `uid://dagjtw6shmycu` | Managed Surface outer frame |
| `assets/frames/section.png` | `uid://kb5ymfnsphu8` | Framed semantic section |
| `assets/frames/primary-normal.png` | `uid://dk6pxo6xexy1o` | Primary action normal state |
| `assets/frames/primary-hover.png` | `uid://dnxx0x7tampxd` | Primary action hover/focus state |
| `assets/frames/primary-pressed.png` | `uid://dm66depbepm10` | Primary action pressed state |
| `assets/frames/secondary-normal.png` | `uid://cpt1i157jj7iq` | Secondary action normal state |
| `assets/frames/secondary-hover.png` | `uid://cxhc7awkc20y6` | Secondary action hover/focus state |
| `assets/frames/secondary-pressed.png` | `uid://m0emy4xyavc0` | Secondary action pressed state |

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

Set `theme_type_variation` on a native node of the documented base type; keep
the node's native behavior and compose normal containers, properties, and
signals around it. Do not copy a variation into a feature-local Theme. The
meaning in each table is its supported purpose and composition role; choosing
a variation only for its current color or font is unsupported.

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

| Variation | Base type | Meaning |
| --- | --- | --- |
| `RookframeTitle` | `Label` | Surface identity |
| `RookframeSubtitle` | `Label` | Current task title |
| `RookframeHeading` | `Label` | Section identity |
| `RookframeLabel` | `Label` | Concise field or statistic label |
| `RookframeValue` | `Label` | Prominent live value |
| `RookframeBody` | `Label` | Readable rules or descriptive copy |
| `RookframeMeta` | `Label` | Help, provenance, or secondary facts |
| `RookframeStatus` | `Label` | Compact neutral live state |
| `RookframePending` | `Label` | Visible in-progress state |
| `RookframeSuccess` | `Label` | Confirmed positive state |
| `RookframeError` | `Label` | Actionable failure |
| `RookframeIdentity` | `Label` | Row or record name |
| `RookframeBadgeText` | `Label` | Text inside a classification chip |

Text roles express meaning, not a request for one color or font size. Their
exact visual values may change compatibly while the role's purpose remains.

### Actions

| Variation | Base type | Meaning |
| --- | --- | --- |
| `RookframePrimaryButton` | `Button` | Advances or commits the current task |
| `RookframeSecondaryButton` | `Button` | Important alternative that does not advance the task |
| `RookframeQuietButton` | `Button` | Compact reveal, retry, or row-local action |
| `RookframeDangerButton` | `Button` | Destructive or abandoning action |
| `RookframeTabButton` | `Button` | Changes a visible section without changing domain state |
| `RookframeChoiceRow` | `Button` | Complete detailed or compact choice target |

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

The [semantic icon reference](semantic-icons.md) documents all 62 public paths,
import UIDs, purposes, accessible labels, and composition rules.
`icons/manifest.json` records the same names and the pinned Tabler source.
Consumers load the semantic path, for example:

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
