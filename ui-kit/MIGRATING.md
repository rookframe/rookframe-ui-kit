# Migration notes

## Explicit Silkbound Ledger selection

The core now installs without any Theme, font, material or local skin. Add
`--theme silkbound-ledger` to installation and change styled component scene
references from `res://rookframe/ui/components/...` to
`res://rookframe/ui/silkbound-ledger/components/...`. Base paths and UIDs keep their
behavior and composition; they now inherit native Godot defaults. Merely installing
the theme does not apply it. Existing Theme/material/font paths and UIDs are
provided by the optional package, not the core.

Silkbound variants use native scene/script inheritance and inject themed dynamic
row scenes through exported PackedScene properties. Ink/reveal shaders are optional
inputs with null defaults; core-only components settle without those effects. Ordinary consumer Controls
can inherit the optional native Theme directly. `ActionLink.title_font_size` and
`SearchField.editor_font_size` now default to zero (inherit); positive values still
provide an explicit caller override. Silkbound variants retain their prior sizes.

The optional `fonts` dependency avoids coupling Fantasy/Cyberpunk to Silkbound.
Their shared mappings/geometry live in `shell-common`; the core compiler accepts
an optional array of additional mapping scripts instead of preloading them.

Component suites run in an isolated prepared consumer; see `ui-kit/README.md`.

## `next` monorepo layout

Source previously at `rookframe/ui/` now lives under `ui-kit/rookframe/ui/`.
The design specimen is imported into `showcase/`. Fantasy and Cyberpunk materials
are optional packages in `themes/fantasy/` and `themes/cyberpunk/`; consumers that
use them must explicitly install the corresponding package alongside UI Kit.
Installed `res://rookframe/ui/` paths, asset bytes and existing UIDs are retained.

Use `python3 tools/workspace.py install --destination /path/to/project` from a
checkout of the desired monorepo revision; add `--theme fantasy` and/or
`--theme cyberpunk` as needed. The old gd-plug `include: ["rookframe/ui"]` declaration
applies only to pre-monorepo revisions. The showcase uses local packages instead
of the former external Git pin; run `prepare` after editing them.

The shared `menu/menu_theme.gd` compiler no longer selects Fantasy implicitly:
pass mapping/material scripts to its constructor, or load the optional
`menu/MenuTheme.tres` entry point. Cyberpunk installs its shared optional font and shell-recipe dependencies.
Theme integration suites moved from `ui-kit/tests` to `showcase/tests`.

There is no stable release to migrate from yet.

The initial pre-user `v1.0.0-rc.1` candidate may change in place while every
consumer pins an exact commit. The candidate tag identifies one commit at a
time; moving it does not update an existing gd-plug lock. When the owner
publishes a stable release:

- compatible visual refinements keep public paths, UIDs, semantic variation
  meanings, root types, properties, signals, defaults, slots, focus, input,
  accessibility, and observable behavior;
- compatible additions use a minor release;
- compatible corrections use a patch release; and
- any incompatible public contract change requires a major release and a new
  entry here with a concrete before/after migration.

Direct Godot APIs and Package-owned scene/resource formats remain part of a
Package Publisher's Rookframe compatibility judgment; UI Kit SemVer cannot
intercept or adapt them. The exact UI Kit version and commit recorded during
authoring are provenance, not a runtime dependency declaration. A published
Package declares compatible Rookframe Versions only, excludes its materialized
UI Kit, and is tested as a whole against each declared Rookframe Version and
its Godot runtime. If native Godot compatibility breaks, migrate the Package,
publish a new Package release, and adjust that Rookframe compatibility
declaration; do not vendor an old UI Kit into the artifact.

See [the complete compatibility model](docs/compatibility.md) for the protected
public contract and the direct-Godot consequences.

## Earlier Silkbound Ledger foundation (superseded by explicit selection)

All three existing Theme paths now supply Silkbound. No path, UID, scene root,
signal, slot, domain operation or placement state has been removed. Historical
font/frame assets remain installed for compatibility. The `silkbound` flags on
common task components remain readable/serializable, but no longer select old
typography. General visual defaults are larger (SearchField editor 20px,
ActionLink title 20px, ordinary metadata 18px). Explicit caller density overrides
remain a caller responsibility; remove old per-screen color/font overrides as
each screen is reviewed.

Repin the exact UI Kit commit, materialize it, then inspect each authored screen
at its native viewport. Do not scale an entire desktop layout to fit touch.
Use the [regional typography resources](docs/public-foundation.md#regional-typography)
when text locale distinguishes Simplified and Traditional Chinese.

This is an unpublished candidate change; it does not move candidate tags or
publish SDK/application/Package releases.
