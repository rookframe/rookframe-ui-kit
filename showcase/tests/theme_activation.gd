extends SceneTree
const THEMES = ["fantasy", "cyberpunk", "silkbound-ledger"]
var failures: Array[String] = []
func _initialize() -> void:
	verify.call_deferred()
func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)
func verify() -> void:
	for name in THEMES:
		var appearance = load("res://rookframe/ui/themes/%s/theme.tres" % name)
		check(appearance is Theme, name + " is a native Theme")
		var host := Control.new()
		host.size = Vector2(1024, 768)
		host.theme = appearance
		root.add_child(host)
		var panel = load("res://rookframe/ui/components/surfaces/action_panel/action_panel.tscn").instantiate()
		panel.reduced_motion = true
		host.add_child(panel)
		await process_frame
		check(panel.get_script().resource_path == "res://rookframe/ui/components/surfaces/action_panel/action_panel.gd", "Retained core script")
		if name == "silkbound-ledger":
			check(panel.get_node("Header/Leaf/Skin").visible, "Leather visible")
			check(panel.get_node("DropMotion").ink_shader != null, "Ink supplied")
			host.theme = null
			await process_frame
			check(not panel.get_node("Header/Leaf/Skin").visible, "Leather removed")
			check(panel.get_node("DropMotion").ink_shader == null, "Ink removed")
		host.free()
	var ledger = load("res://rookframe/ui/themes/silkbound-ledger/theme.tres")
	for path in ledger.presentations:
		var host := Control.new()
		host.size = Vector2(1024, 768)
		host.theme = ledger
		root.add_child(host)
		var component = load(path).instantiate()
		if component is Control: component.size = Vector2(900, 600)
		for property in component.get_property_list():
			if property.name == "reduced_motion": component.set("reduced_motion", true)
			if property.name == "animate_open": component.set("animate_open", false)
		if component is Window: component.visible = false
		var original_script: Script = component.get_script()
		host.add_child(component)
		await process_frame
		check(component.get_script() == original_script, "Core script retained: " + path)
		host.theme = load("res://rookframe/ui/themes/fantasy/theme.tres")
		await process_frame
		host.theme = ledger
		await process_frame
		host.free()
		await process_frame
	print("THEME ACTIVATION: %d presentation scenes; %d failures" % [ledger.presentations.size(), failures.size()])
	quit(0 if failures.is_empty() else 1)
