@tool
extends RefCounted
## Shared reading density. The material providers own padding around their edges.
static func geometry() -> Dictionary:
	return {
		"chronicle.heading.size": 28, "chronicle.heading.size.compact": 24,
		"chronicle.body.size": 18, "chronicle.body.size.compact": 16,
		"chronicle.meta.size": 13, "chronicle.meta.size.compact": 12,
		"chronicle.rule_gap": 16, "chronicle.rule_gap.compact": 12,
	}
