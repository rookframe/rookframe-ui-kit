# UI Kit composition and optional appearance contract

## Authority and theme scope

The shared UI Kit is unthemed. Core scenes at `res://rookframe/ui/components/`
retain native Godot controls, composition, input and semantic variation names,
but assign no Theme, palette, custom font, material or scene-local skin.
They inherit the consumer's Theme or Godot's defaults. Installing a theme does
not change the base scenes or select it globally.

Silkbound Ledger is an explicit optional package at `themes/silkbound-ledger/`.
Its native inherited scenes live at `res://rookframe/ui/silkbound-ledger/` and
own leather leaves, typography, decoration and presentation hooks. The showcase
opts into those scenes. The Main Menu's product choice remains Silkbound Ledger;
hosts must now select it explicitly. Fantasy/Cyberpunk remain auxiliary shell
experiments with shared optional mappings in `themes/shell-common/`.

## Compose the existing resources

- Choose the public component by purpose from `rookframe/ui/catalogue.json`.
  Use native Controls/Containers for content. Public slots own layout and material;
  callers own game rules, labels, data and actions.
- With Silkbound Ledger selected, use linked leather leaves for compact action/HUD composition. Use ledger reading
  surfaces for dense text; put the cloth on the owner rather than each record.
- Keep bindings mechanically plausible and attached while a HUD leaf is folded.
  Preserve the component's surface outline in hover, pressed and focus states.
- Keep category names visible. Let long names and translated text wrap. Yield
  ornament/gaps before readable content; keep touch targets at least 44 × 44.
- Preserve keyboard focus, hover, pressed, disabled, selected and error distinctions.
  Selected/primary surfaces use their contrasting foreground, including icons.
- Reuse native themes and material resources for colors, fonts, edges and spacing.
  In Silkbound Ledger, use EB Garamond and explicit locale companion resources; avoid eager all-locale
  font chains. Extend shared material treatment instead of adding local skins.

## Themeable recipes

Usage describes purpose, State describes interaction/availability, and Material
holds concrete visual values. Theme mappings reference Material for each relevant
Usage, State and property. Theme variations preserve meaning and interaction.
The existing auxiliary recipes demonstrate this separation; they do not establish
shell theme selection, persistence, permissions or a supported Main Menu override.

## Motion

Use `hinged_leaf/hinged_leaf.tscn` for the HUD's gather, impact and rebound;
use `action_panel/action_panel.tscn` for ordered drops from upper bindings followed
by content ink. Reuse these timelines, including cancellation and reduced motion.
Changing content/layout must preserve child identity and native input connections.
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
in [Linear](https://linear.app/rookframe/document/silkbound-ledger-design-examples-and-distribution-d2dd1e70a906). Retain legal notices and machine-readable asset provenance with
the shipped resources. An asset replacement keeps its stable ID and atlas/UID
contract, updates origin/checksum, and receives native visual verification.
