extends SceneTree
## Standalone core-only integration check: no optional packages are installed.
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var paths: Array[String] = []
	_collect("res://rookframe/ui", paths)
	for path in paths:
		var resource := load(path) as PackedScene
		if resource == null:
			failures.append("Cannot load " + path)
			continue
		var instance := resource.instantiate()
		if instance is Window:
			instance.visible = false
		for property in instance.get_property_list():
			if property.name == "reduced_motion": instance.set("reduced_motion", true)
			if property.name == "animate_open": instance.set("animate_open", false)
		root.add_child(instance)
		await process_frame
		_inspect(instance, path)
		root.remove_child(instance)
		instance.free()
	print("Core-only scenes checked: ", paths.size())
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)

func _collect(directory: String, paths: Array[String]) -> void:
	for file in DirAccess.get_files_at(directory):
		if file.ends_with(".tscn"): paths.append(directory.path_join(file))
	for child in DirAccess.get_directories_at(directory):
		_collect(directory.path_join(child), paths)

func _inspect(node: Node, source: String) -> void:
	if node is Control or node is Window:
		if node.theme != null:
			failures.append(source + ": assigns Theme on " + str(node.name))
	for child in node.get_children(): _inspect(child, source)
