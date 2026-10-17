extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	for count in [3, 4]:
		var section = page.section("%d related metrics" % count, "Resize the browser to see the same facts wrap into fewer columns.")
		var strip = page.scene(Demo.path("data/metric_strip"), section, {"maximum_columns": count, "minimum_column_width": 180.0})
		for index in count:
			page.scene(Demo.path("data/metric"), strip, {"label_text": ["Health", "Mana", "Armor", "Speed"][index], "value_text": ["75 / 100", "20 / 50", "16", "9 m"][index], "detail_text": ["Recovering", "Rested", "Medium", "Walking"][index]})
