# UI Kit composition and optional appearance contract

## Authority and theme scope

The shared UI Kit is unthemed. Core scenes at `res://rookframe/ui/components/`
retain native Godot controls, composition, input and semantic variation names,
but assign no Theme, palette, custom font, material or scene-local skin.
They inherit the consumer's Theme or Godot's defaults. Installing a theme does
not change the base scenes or select it globally.

Every optional package exposes `res://rookframe/ui/themes/<theme-name>/theme.tres`,
a native Theme that supplies both Theme items and optional presentation resources.
Consumers select it on the owning Control and always use the core component scenes.
The shared presentation hooks apply existing appearance without replacing behavior,
content, signals, focus or motion contracts.

Concrete theme resources, presentation strategies and documentation belong to
their owning packages outside the core. Hosts select appearance explicitly.
Shared optional dependencies belong outside the directory of theme projects.

## Compose the existing resources

- Choose the public component by purpose from `rookframe/ui/catalogue.json`.
  All Rookframe UI is available through the kit, including proxies for standard
  Godot controls and recipes. Use those public resources and preserve native
  behavior as specified by [the proxy contract](../native-controls-and-recipes.md).
  Native Controls/Containers may compose caller-owned content. Public slots own layout;
  callers own game rules, labels, data and actions.
- Keep category names visible. Let long names and translated text wrap. Yield
  ornament/gaps before readable content; keep touch targets at least 44 × 44.
- Preserve keyboard focus, hover, pressed, disabled, selected and error distinctions.
  Selected/primary surfaces use their contrasting foreground, including icons.
- Use native Themes and resource inheritance for optional appearance.
  Core components must not depend on a concrete theme or its assets.

## Component boundaries and variation names

- Add a public component only for structure (children, slots), behavior or an
  accessibility contract that Godot and the kit lack. A difference in appearance
  alone is a variation of the existing component; a preset of native properties
  may be an inherited scene without a script, like Toggle.
- Model a component's appearance as independent axes, such as emphasis, content
  layout and density. Each axis is one property. The component composes one name
  from them in a fixed order with density last, for example
  `components_button_primary__stacked__compact`. Published names keep their spelling.
- The core assigns names only. A theme declares each name's base, because Godot
  resolves a variation only when a Theme in the tree declares it; otherwise the
  native class items apply.
- Context belongs to the container. A child carries no usage for where it is
  placed; a theme styles it through a profile Theme scoped to the container.
  Godot asks the nearest Theme first for every type in a lookup chain, so a
  profile that defines a native type's items hides variations declared further
  up; such a profile repeats the variations its descendants use.

## Themeable recipes

Usage describes purpose, State describes interaction/availability, and Material
holds concrete visual values. Theme mappings reference Material for each relevant
Usage, State and property. Theme variations preserve meaning and interaction.
Theme packages supply mappings to the shared compiler. The core does not select
a product's appearance or implement theme selection and persistence.

## Motion

Use `hinged_leaf/hinged_leaf.tscn` for folding content and
`action_panel/action_panel.tscn` for ordered section presentation.
Reuse their cancellation and reduced-motion behavior. Changing content/layout
must preserve child identity and native input connections. Optional presentation
resources belong to the selected theme or consumer.
See [the slot and motion contract](../action-panel.md) before composing either.

## Verification and maintenance

Run the affected component suites and inspect the native specimen at desktop
1920 × 1080, tablet 1024 × 768 and phone landscape 844 × 390. Exercise long content,
disabled/focus states, interruptions and reduced motion against bright/dark scenes.
The [sibling showcase](../../../showcase/README.md) consumes current local packages;
run `python3 tools/workspace.py prepare` from the workspace root after changes.
It must instance production resources. Product placement and routes remain the host's responsibility.

Keep one owning contract per behavior. Repository prose supplies agent instructions,
public interface meaning and checks. Put proposals, rationale and review captures
in the Linear document linked from the [workspace README](../../../README.md).
Retain legal notices and machine-readable asset provenance with shipped resources.
An asset replacement keeps its stable ID and atlas/UID contract, updates
origin/checksum, and receives native visual verification.
