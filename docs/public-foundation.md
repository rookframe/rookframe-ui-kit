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
| `assets/fonts/*.ttf` | Path and import UID below | Legacy font assets retained for source compatibility |
| `assets/frames/*.png` | Semantic path and import UID below | Legacy nine-slice assets retained for source compatibility |
| `icons/<semantic-name>.svg` | Path and import UID in the [semantic icon reference](semantic-icons.md) | Stable, context-neutral interface pictogram |
| `icons/compass_rose.svg` | `uid://beea526jspe3i` | Rookframe-owned decorative navigation motif; it is non-semantic and never the only carrier of status, meaning, or an action label |
| `icons/manifest.json` | Stable path | Ordered semantic registry and upstream provenance |

All font license texts under `assets/fonts/` and the Tabler license at
`icons/LICENSE` are also public installed resources. Preserve them whenever
redistributing the subtree.

### Font identities

| Resource | Import UID | Purpose and composition |
| --- | --- | --- |
| `assets/fonts/Inter-VariableFont_opsz,wght.ttf` | `uid://cje80i18uults` | Legacy face; retained at its public path, no longer assigned by the default Theme |
| `assets/fonts/Exo2-VariableFont_wght.ttf` | `uid://14n2hjuakwcl` | Legacy face; retained at its public path, no longer assigned by the default Theme |

### Frame identities

These legacy assets keep their public identities for existing consumers. The
default Theme now uses native square StyleBoxFlat controls and 6px copper owning
rules. New compositions use semantic variations, not these old frame textures.

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

The three Theme resources share palette and native control roles.
`rookframe_theme.tres` is the general profile; `silkbound_theme.tres` and the
retained `fullscreen_task_theme.tres` path supply the task/sheet density profile.
They are authored native resources, with no runtime theme engine or picker.

When an exact value changes, maintainers update all three Themes and tokens in one
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
| `RookframePackageInk` | `PanelContainer` | Opaque package-authored task canvas with no outer frame |
| `RookframePackageFrame` | `PanelContainer` | Opaque package-authored task canvas with its package edge |
| `RookframeSurface` | `PanelContainer` | Ordinary content surface |
| `RookframeRaisedSurface` | `PanelContainer` | Elevated local surface |
| `RookframeRaisedFrame` | `PanelContainer` | Elevated frame whose caller owns the inner inset |
| `RookframeActiveSurface` | `PanelContainer` | Prominent current-item surface with an active top rule |
| `RookframeInsetFrame` | `PanelContainer` | Low-emphasis inset frame whose caller owns the inner inset |
| `RookframeTaskFrame` | `PanelContainer` | Deep framed workflow surface whose caller owns the inner inset |
| `RookframeSubtleFrame` | `PanelContainer` | Quiet framed record or collection surface whose caller owns the inner inset |
| `RookframeInsetSurface` | `PanelContainer` | Sunken or nested content region |
| `RookframeSection` | `PanelContainer` | Framed semantic section |
| `RookframeManagedSurface` | `PanelContainer` | Outer frame for a reusable managed presentation |
| `RookframeGoldFrame` | `PanelContainer` | Prominent framed shell or blocking overlay whose caller owns the inner inset |
| `RookframeGoldBadge` | `PanelContainer` | Short live-session or shell-status chip |
| `RookframeShellRail` | `PanelContainer` | Narrow vertical shell rail whose caller owns the action stack |
| `RookframeManagedChrome` | `PanelContainer` | Wide fixed chrome region within a managed task surface |
| `RookframeManagedChromeCompact` | `PanelContainer` | Compact fixed chrome region within a managed task surface |
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
The default Theme uses EB Garamond regular, medium and semibold, with real Latin
italics and tabular figures. General roles use 40px title, 30px subtitle/value,
24px heading, 22px identity, 21px body, 20px label/input/action and 18px meta/status.
The task/sheet Theme keeps its explicitly authored responsive density. Callers
may adjust size when their layout requires that documented hierarchy.

### Fields

| Variation | Base type | Meaning |
| --- | --- | --- |
| `RookframeSearchInput` | `LineEdit` | Native compact search input with shared field perimeter and focus treatment |

Use the public `SearchField` scene when the field needs a visible label, clear
action, or shared composite focus perimeter. Use this native variation for a
compact search control already situated in a screen-authored toolbar.

### Actions

| Variation | Base type | Meaning |
| --- | --- | --- |
| `RookframePrimaryButton` | `Button` | Advances or commits the current task |
| `RookframeGoldButton` | `Button` | Legacy name for the neutral filled commitment action within a staged workflow |
| `RookframeSecondaryButton` | `Button` | Important alternative that does not advance the task |
| `RookframeQuietButton` | `Button` | Compact reveal, retry, or row-local action |
| `RookframeDangerButton` | `Button` | Destructive or abandoning action |
| `RookframeShellControl` | `Button` | Compact icon-only shell navigation or action |
| `RookframeManagedControl` | `Button` | Bordered contextual action inside a managed task or shell overlay |
| `RookframeManagedAffirm` | `Button` | Bordered affirmative action inside a managed task or shell overlay |
| `RookframeManagedCommit` | `Button` | Filled commitment action that saves the current managed-task state |
| `RookframeManagedSelected` | `Button` | Persistent selected disclosure or mutually exclusive choice inside a managed task |
| `RookframeDangerOutline` | `Button` | Low-emphasis destructive or abandoning action |
| `RookframeTabButton` | `Button` | Changes a visible section without changing domain state |
| `RookframeChoiceRow` | `Button` | Complete detailed or compact choice target |
| `RookframeCircularAction` | `Button` | Circular icon action with neutral edges, brass pictogram, raised hover/pressed fill, distinct outer focus ring, and muted disabled state |
| `RookframeCompactAction` | `Button` | Intrinsic outlined action in a managed task; 18px EB Garamond and 18px horizontal padding |
| `RookframeCompactActionTouch` | `Button` | Touch density of the same compact action; 18px EB Garamond and 16px horizontal padding |

Use native `Button`; these are Theme variations, not wrappers. Ordinary icon-
only actions retain a semantic accessible name and at least a 44×44 interaction
target.

Circular actions use a square minimum target of 62px on desktop, 56px on
tablet, or 48px on phone, with a 30/28/24px semantic icon respectively.
Consumers set `custom_minimum_size`, `expand_icon`, and `icon_max_width` for
their active density, set `icon_alignment = HORIZONTAL_ALIGNMENT_CENTER`,
supply an icon and accessible name, and connect native
`pressed`. Keep visible text empty. Compact actions use a minimum height of
44px on desktop and 48px for touch. Their containing row owns placement and
focus order. These appearances project the approved RFG-177 Tabletop authority;
they add no custom input handler or Package-specific callback API.

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
`icons/compass_rose.svg` is intentionally outside that semantic registry: it is
a Rookframe-owned decorative backdrop, has no default accessible label, and
must not be used as an icon-only control or status indicator.
Consumers load the semantic path, for example:

```gdscript
var retry_icon := load("res://rookframe/ui/icons/retry.svg")
```

Choose the meaning (`retry`, `close`, `dock`, `warning`) rather than an
upstream drawing or a consuming screen's name. Semantic paths remain distinct
even when the approved context shares a drawing: `clear.svg` and `close.svg`
use the close mark, while `minimize.svg` and `remove.svg` use the minus mark.
No Manager-, Character Sheet-, or Package-named alias is present.

## Compatibility

The UI Kit uses independent SemVer, not SDK Editions. Within a major line,
public paths and UIDs, variation names and meanings, and documented observable
behavior remain stable. Exact visual values and `_internal/` implementation may
change compatibly. Direct Godot API use is outside Rookframe's compatibility
guarantee and remains part of a Package Publisher's Rookframe Version judgment.

## Regional typography

`theme/silkbound_{regular,medium,semibold,italic}.tres` uses EB Garamond first.
Full licensed Noto Serif JP/KR/SC/TC companions are installed with the kit,
but the general fonts and Themes do not load them. Godot's native system-font
fallback handles otherwise unsupported text on supported platforms.
For text with a known regional locale, assign the corresponding native Font
resource and set the Control's `language` property:

```gdscript
label.language = "zh_TW"
label.add_theme_font_override("font",
    load("res://rookframe/ui/theme/locales/zh_TW_regular.tres"))
```

The supported locale resource prefixes are `ja`, `ko`, `zh_CN` (also use for
`zh_Hans`/`zh_SG`) and `zh_TW` (also use for `zh_Hant`). Each has `regular`,
`medium`, `semibold` and `italic` variants. Latin stays EB Garamond; CJK uses
the regional upright serif companion at the matching weight. There is no
synthetic CJK italic. Applications may use stock resource localization remaps
for a uniform application locale, or explicit font assignments for mixed locales.

Godot 4.7's fallback priority considers the base language, so `language` alone
cannot choose between SC and TC. Load the named regional resource when that
locale is needed, rather than preloading all companions for every English UI.
Use text locale as well as application locale: user-entered names and notes can
be multilingual. System fallback appearance depends on the platform; use the
explicit bundled regional fonts when their precise forms are required. Other
scripts and Hong Kong forms need an appropriate companion and native review.

## Silkbound surface grammar

Owning surfaces use ink, a single faint linen layer, and 6px copper top/bottom
bands. Interior rows and sections use neutral rules. Pictograms are brass, counts
are copper, selection is neutral, danger is coral and success is muted green.
Selected/primary light fills use ink foregrounds; selected record rows use raised
fill and a left rule. Keep focus, disabled, hover and error states distinct.
The ribbon, rule, pictogram, count and ornament token roles remain independent.
