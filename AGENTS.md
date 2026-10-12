# UI Kit agent workflow

Before changing components, themes, composition or their contracts, read
[the design contract](docs/design-system/principles.md), then the affected public
component's documentation. Use stock Godot facilities.

Keep runtime resources in `rookframe/ui/` and component tests in `tests/`.
Native visual examples and catalogue integration checks belong in
[rookframe-design-specimen](https://github.com/rookframe/rookframe-design-specimen); update its dependency pin when reviewing
a changed kit. Keep human discussion and review captures in [Linear](https://linear.app/rookframe/document/silkbound-ledger-design-examples-and-distribution-d2dd1e70a906).

Complete relevant component checks and inspect the changed native specimen states
before claiming visual acceptance. Preserve public paths/UIDs and asset licenses.
