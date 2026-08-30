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
