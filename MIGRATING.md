# Migration notes

There is no stable release to migrate from yet.

The initial pre-user `v1.0.0-rc.1` candidate may change in place while every
consumer pins an exact commit. When the owner publishes a stable release:

- compatible visual refinements keep public paths, UIDs, semantic variation
  meanings, root types, properties, signals, defaults, slots, focus, input,
  accessibility, and observable behavior;
- compatible additions use a minor release;
- compatible corrections use a patch release; and
- any incompatible public contract change requires a major release and a new
  entry here with a concrete before/after migration.

Direct Godot APIs and Package-owned scene/resource formats remain part of a
Package Publisher's Rookframe compatibility judgment; UI Kit SemVer cannot
intercept or adapt them.
