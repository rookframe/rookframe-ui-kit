extends RefCounted

const Demo = preload("res://examples/components/pages/layout_surfaces/demo.gd")

static func build(page) -> void:
	var regular = page.section("Route with context")
	Demo.component(page, "components/layout/compact_route_heading.tscn", regular, {"kicker_text": "LIBRARY / MAPS", "title_text": "The northern reaches", "detail_text": "12 maps · updated today"})
	var minimal = page.section("Title only")
	Demo.component(page, "components/layout/compact_route_heading.tscn", minimal, {"title_text": "Session notes"})
	var long = page.section("Long route title", "The category stays visible while the title wraps.")
	Demo.component(page, "components/layout/compact_route_heading.tscn", long, {"kicker_text": "CHRONICLE", "title_text": "A record of the expedition beyond the mountain observatory", "detail_text": "Explore discoveries, correspondence and unfinished plans from every session."})
