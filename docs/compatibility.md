# Compatibility model

The Rookframe UI Kit has its own Semantic Versioning contract. It does not use
SDK Editions or SDK Additive Revisions, and a UI Kit version is not a second
runtime dependency declaration for a Package.

## What UI Kit SemVer protects

Within one UI Kit major line, compatible releases preserve:

- every normal path and Godot resource UID under `res://rookframe/ui/`;
- every semantic Theme variation name and purpose;
- every public component scene identity and root-node type;
- documented exported properties, signals, methods, slots, variants, states,
  defaults, layout, focus, input, accessibility, and observable behavior; and
- the meaning of every semantic icon identity.

Only `res://rookframe/ui/_internal/` is unsupported. Exact colors, fonts,
borders, shadows, spacing values, private helpers, and undocumented internal
child-node structure may evolve compatibly when the public semantics and
behavior above remain intact.

Compatible additions use a minor release, compatible corrections use a patch
release, and an incompatible public-contract change requires a major release
with concrete migration notes. Visual refinement alone is not breaking when
it preserves the documented semantic interface and behavior.

## Authoring provenance and runtime compatibility

A Package Authoring Project materializes a full UI Kit Git commit through
gd-plug at `res://rookframe/ui/`. Its authoring metadata records both the
human-readable UI Kit SemVer and that exact commit as provenance: they answer
which source the Publisher used while constructing and reviewing the Package.

The materialized UI Kit is excluded from the published Package artifact. At
runtime, the selected Rookframe Version supplies its compatible UI Kit at the
same canonical paths before Package-owned scenes load. The Package therefore
declares compatible Rookframe Versions only; it does not declare a runtime UI
Kit version or range. A newer compatible Rookframe may supply a newer
SemVer-compatible UI Kit than the one used during authoring.

This keeps one owner for `res://rookframe/ui/`, prevents Packages from
colliding with each other at canonical resource paths, and lets a Rookframe
release update engine-sensitive kit resources centrally.

## Direct Godot use

Native-first authoring deliberately lets Package scenes and scripts serialize
or invoke Godot Controls, properties, signals, resources, import behavior, and
file formats directly. Those calls do not cross a Rookframe-owned facade where
an adapter could preserve old behavior, so direct Godot API and format use is
outside Rookframe's backwards-compatibility guarantee.

For Package Publishers, that has concrete consequences:

1. Do not infer complete-Package compatibility from the UI Kit version used
   during authoring.
2. Review and exercise the complete Package against every Rookframe Version it
   declares compatible, including the Godot version supplied by that release.
3. Treat native Godot API, serialized-scene, imported-asset, and PCK changes as
   part of the Package's own compatibility judgment.
4. Publish a new Package release and adjust its Rookframe Compatibility
   Declaration when a native breaking change requires scene, script, or import
   migration.
5. Do not vendor an older UI Kit to compensate; the running Rookframe Version
   remains the sole runtime owner of the canonical UI Kit subtree.

Rookframe Compatibility Declarations cover the whole authored Package: public
UI Kit contracts and every direct native Godot dependency it contains.

## Release identities

An immutable UI Kit Release has one SemVer tag and one exact source commit.
Branches are not release identities, and immutable release tags are never
moved or reused.

The initial `v1.0.0-rc.1` candidate is a pre-user exception: its annotated tag
identifies one exact candidate commit at a time but may be updated in place by
the owner while there are no external users. Consumers still pin the full
commit, so moving the candidate label never changes an existing authoring
lock. Stable `v1.0.0` is published only through a deliberate owner action.
