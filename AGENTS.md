# UI workspace workflow

Before changing components, themes, composition or their contracts, read
[the design contract](ui-kit/docs/design-system/principles.md), then the affected
public component documentation. Use stock Godot facilities.

Shared runtime resources belong in `ui-kit/rookframe/ui/`; optional theme
materials and mappings belong in `themes/<name>/rookframe/ui/`. Component tests
belong in `ui-kit/tests/`. Native examples and integration checks belong in
`showcase/`. Prepare local dependencies with `python3 tools/workspace.py prepare`
after package changes; edit the owning package rather than generated copies.

Complete relevant checks and inspect changed native showcase states before
claiming visual acceptance. Preserve installed public paths/UIDs and asset
licenses. Keep human discussion and review captures in
[Linear](https://linear.app/rookframe/document/silkbound-ledger-design-examples-and-distribution-d2dd1e70a906).
