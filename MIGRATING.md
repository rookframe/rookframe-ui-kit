# Migration notes

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

## Silkbound Ledger foundation

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
