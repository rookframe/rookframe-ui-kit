# Unsupported implementation details

Files beneath `res://rookframe/ui/_internal/` belong to the UI Kit but are not
public API and receive no compatibility promise. Package scenes must not depend
on them.

Rookframe application screens, workflows, domain state, host registries, and
orchestration do not belong here; they stay in their consuming application.
