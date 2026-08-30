# Public runtime subtree

This directory is installed verbatim at `res://rookframe/ui/` and is the public
support boundary of the Rookframe UI Kit.

- `theme/rookframe_theme.tres` is the shared native Godot Theme.
- `tokens.gd` exposes semantic values required by reusable kit relationships.
- `assets/fonts/` contains the licensed UI and display fonts.
- `assets/frames/` contains Rookframe-owned nine-slice surface, action, and
  focus frames.
- `icons/` contains the semantic icon registry and one SVG per semantic role.
- `_internal/` is the only unsupported subtree.

Everything else in this directory is public even if its documentation is
accidentally incomplete. Public paths, Godot resource UIDs, Theme variation
names, and documented meanings are stable within a SemVer major line.

Examples and repository development material intentionally live outside this
subtree and are not copied by the documented gd-plug declaration.
