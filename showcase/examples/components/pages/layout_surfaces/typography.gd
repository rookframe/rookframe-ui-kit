extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	var roles = page.section("Semantic hierarchy")
	for entry in [["RookframeHeading", "Beyond the horizon"], ["RookframeBody", "The expedition sets out at dawn, following the old road into the northern reaches."], ["RookframeMuted", "Session 12 · recorded today"]]:
		var text = page.scene("res://rookframe/ui/components/data/typography.tscn", roles, {"text": entry[1]})
		text.theme_type_variation = entry[0]
	var long = page.section("Readable long content", "Native text wraps with the available width; no horizontal reading scroll is needed.")
	page.scene("res://rookframe/ui/components/data/typography.tscn", long, {"text": "At the edge of the valley, the road turns toward an observatory built before anyone remembers. Every window faces a different constellation, and every room holds a story waiting to be discovered."})
	var multilingual = page.section("Regional text", "The consumer supplies regional font coverage.")
	for copy in ["English · Journey beyond the horizon", "Русский · Путешествие за горизонт", "日本語 · 地平線の向こうへの旅"]:
		page.scene("res://rookframe/ui/components/data/typography.tscn", multilingual, {"text": copy})
