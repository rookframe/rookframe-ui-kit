@tool
extends Window

## Rookframe file selection with native Godot focus, keyboard, and filesystem APIs.
##
## The public seam is deliberately small: configure the initial location and
## filters, open the picker, and consume `file_selected`. Navigation, search,
## selection preview, and history remain internal to this composition.

signal file_selected(path: String)
signal cancelled
signal directory_changed(path: String)

const FOLDER_ICON := preload("res://rookframe/ui/icons/folder.svg")
const DOCUMENT_ICON := preload("res://rookframe/ui/icons/document.svg")

@export var heading := "Open a file":
	set(value):
		heading = value
		_refresh_copy()

@export_multiline var description := "Choose a file from your project or computer.":
	set(value):
		description = value
		_refresh_copy()

@export_dir var initial_directory := "res://"

@export var allowed_extensions := PackedStringArray():
	set(value):
		allowed_extensions = value
		_refresh_filter_label()
		if is_inside_tree() and not _directory.is_empty():
			_clear_selection()
			_refresh_entries()

@export var confirm_label := "Open":
	set(value):
		confirm_label = value
		_refresh_copy()

@export var show_hidden := false:
	set(value):
		show_hidden = value
		if is_inside_tree() and not _directory.is_empty():
			_clear_selection()
			_refresh_entries()

var _directory := ""
var _selected_path := ""
var _entries: Array[Dictionary] = []
var _history: Array[String] = []
var _history_index := -1


func _ready() -> void:
	close_requested.connect(_cancel)
	%Cancel.pressed.connect(_cancel)
	%Open.pressed.connect(_confirm_selection)
	%Back.pressed.connect(_go_back)
	%Up.pressed.connect(_go_up)
	%Places.item_activated.connect(_activate_place)
	%FileList.item_selected.connect(_select_entry)
	%FileList.item_activated.connect(_activate_entry)
	%Search.value_changed.connect(_on_search_changed)
	_refresh_copy()
	_populate_places()
	_refresh_filter_label()


func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_cancel"):
		_cancel()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_accept") and not _selected_path.is_empty():
		_confirm_selection()
		get_viewport().set_input_as_handled()


func open_picker(directory: String = "") -> void:
	var requested := directory if not directory.is_empty() else initial_directory
	if requested.is_empty():
		requested = _home_directory()
	_history.clear()
	_history_index = -1
	_set_directory(requested, true)
	popup_centered(Vector2i(1120, 800))
	call_deferred(&"_focus_initial")


func current_directory() -> String:
	return _directory


func selected_path() -> String:
	return _selected_path


func _focus_initial() -> void:
	%Search.focus_editor()


func _populate_places() -> void:
	%Places.clear()
	_add_place("Project", "Godot project files", ProjectSettings.globalize_path("res://"), preload("res://rookframe/ui/icons/rook.svg"))
	_add_place("Home", "Your home folder", _home_directory(), preload("res://rookframe/ui/icons/home.svg"))
	var documents := OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	if not documents.is_empty():
		_add_place("Documents", "Documents folder", documents, DOCUMENT_ICON)


func _add_place(label: String, tooltip: String, path: String, icon: Texture2D) -> void:
	var index: int = %Places.item_count
	%Places.add_item(label, icon)
	%Places.set_item_metadata(index, path)
	%Places.set_item_tooltip(index, tooltip)


func _activate_place(index: int) -> void:
	var path := str(%Places.get_item_metadata(index))
	_set_directory(path, true)


func _set_directory(requested_path: String, push_history: bool) -> void:
	var access := DirAccess.open(requested_path)
	if access == null:
		%BrowserStatus.text = "That location is not available."
		return
	_directory = access.get_current_dir()
	if push_history:
		if _history_index < _history.size() - 1:
			_history.resize(_history_index + 1)
		if _history.is_empty() or _history.back() != _directory:
			_history.append(_directory)
		_history_index = _history.size() - 1
	_clear_selection()
	_build_breadcrumbs()
	_refresh_entries()
	_refresh_navigation()
	_sync_place_selection()
	directory_changed.emit(_directory)


func _refresh_navigation() -> void:
	%Back.disabled = _history_index <= 0
	var parent := _directory.get_base_dir()
	%Up.disabled = parent.is_empty() or parent == _directory


func _go_back() -> void:
	if _history_index <= 0:
		return
	_history_index -= 1
	_set_directory(_history[_history_index], false)


func _go_up() -> void:
	var parent := _directory.get_base_dir()
	if not parent.is_empty() and parent != _directory:
		_set_directory(parent, true)


func _build_breadcrumbs() -> void:
	for child in %Breadcrumbs.get_children():
		%Breadcrumbs.remove_child(child)
		child.queue_free()

	var targets: Array[Dictionary] = []
	if _directory.begins_with("res://"):
		targets.append({"label": "Project", "path": "res://"})
		var relative := _directory.trim_prefix("res://").trim_suffix("/")
		var current := "res://"
		for part in relative.split("/", false):
			current = current.path_join(part)
			targets.append({"label": part, "path": current})
	else:
		targets.append({"label": "Computer", "path": "/"})
		var current := ""
		for part in _directory.trim_prefix("/").split("/", false):
			current += "/" + part
			targets.append({"label": part, "path": current})
	if targets.size() > 6:
		var collapsed: Array[Dictionary] = [{
			"label": "…",
			"path": str(targets[targets.size() - 5]["path"]),
		}]
		for index in range(targets.size() - 4, targets.size()):
			collapsed.append(targets[index])
		targets = collapsed

	for index in range(targets.size()):
		if index > 0:
			var separator := Label.new()
			separator.text = "›"
			separator.theme_type_variation = &"RookframeMeta"
			separator.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
			%Breadcrumbs.add_child(separator)
		var crumb := Button.new()
		crumb.text = str(targets[index]["label"])
		crumb.theme_type_variation = &"RookframeQuietButton"
		crumb.custom_minimum_size.y = 44
		crumb.tooltip_text = str(targets[index]["path"])
		crumb.pressed.connect(_set_directory.bind(str(targets[index]["path"]), true))
		%Breadcrumbs.add_child(crumb)


func _sync_place_selection() -> void:
	%Places.deselect_all()
	var best_index := -1
	var best_length := -1
	for index in range(%Places.item_count):
		var place_path := str(%Places.get_item_metadata(index))
		if place_path != "/":
			place_path = place_path.trim_suffix("/")
		if _directory.begins_with(place_path) and place_path.length() > best_length:
			best_index = index
			best_length = place_path.length()
	if best_index >= 0:
		%Places.select(best_index)


func _refresh_entries() -> void:
	%FileList.clear()
	_entries.clear()
	var access := DirAccess.open(_directory)
	if access == null:
		%BrowserStatus.text = "This location could not be read."
		return
	var query := str(%Search.value).strip_edges().to_lower()
	access.list_dir_begin()
	var entry_name := access.get_next()
	while not entry_name.is_empty():
		var is_directory := access.current_is_dir()
		if entry_name != "." and entry_name != ".." and (show_hidden or not entry_name.begins_with(".")):
			var matches_query := query.is_empty() or query in entry_name.to_lower()
			var matches_type := is_directory or _extension_allowed(entry_name)
			if matches_query and matches_type:
				_entries.append({
					"name": entry_name,
					"path": _directory.path_join(entry_name),
					"directory": is_directory,
				})
		entry_name = access.get_next()
	access.list_dir_end()
	_entries.sort_custom(_entry_before)
	for entry in _entries:
		var item_icon: Texture2D = FOLDER_ICON if entry["directory"] else DOCUMENT_ICON
		var index: int = %FileList.item_count
		%FileList.add_item(str(entry["name"]), item_icon)
		%FileList.set_item_metadata(index, entry)
	var item_count := _entries.size()
	%BrowserStatus.text = "No matching files" if item_count == 0 else "%d item%s" % [item_count, "" if item_count == 1 else "s"]


func _entry_before(left: Dictionary, right: Dictionary) -> bool:
	if left["directory"] != right["directory"]:
		return bool(left["directory"])
	return str(left["name"]).naturalnocasecmp_to(str(right["name"])) < 0


func _extension_allowed(file_name: String) -> bool:
	if allowed_extensions.is_empty():
		return true
	var extension := file_name.get_extension().to_lower()
	for allowed in allowed_extensions:
		if extension == allowed.trim_prefix(".").to_lower():
			return true
	return false


func _on_search_changed(_value: String) -> void:
	_clear_selection()
	_refresh_entries()


func _select_entry(index: int) -> void:
	var entry: Dictionary = %FileList.get_item_metadata(index)
	if bool(entry["directory"]):
		_selected_path = ""
		%FileName.text = ""
		%Open.disabled = true
		%PreviewIcon.texture = FOLDER_ICON
		%PreviewEyebrow.text = "FOLDER"
		%PreviewTitle.text = str(entry["name"])
		%PreviewDetail.text = "Open this folder to browse its contents."
		%PreviewPath.text = str(entry["path"])
	else:
		_selected_path = str(entry["path"])
		%FileName.text = str(entry["name"])
		%Open.disabled = false
		var preview := _preview_texture(_selected_path)
		%PreviewIcon.texture = preview
		%PreviewEyebrow.text = "SELECTED FILE"
		%PreviewTitle.text = str(entry["name"])
		var extension := str(entry["name"]).get_extension()
		var type_label := extension.to_upper() if not extension.is_empty() else "Document"
		if preview == DOCUMENT_ICON:
			%PreviewDetail.text = "%s file · ready to open" % type_label
		else:
			var dimensions := preview.get_size()
			%PreviewDetail.text = "%s image · %d × %d" % [type_label, roundi(dimensions.x), roundi(dimensions.y)]
		%PreviewPath.text = _selected_path


func _preview_texture(path: String) -> Texture2D:
	var project_root := ProjectSettings.globalize_path("res://").trim_suffix("/")
	if path.begins_with(project_root + "/"):
		var resource_path := "res://" + path.trim_prefix(project_root + "/")
		if ResourceLoader.exists(resource_path):
			var resource := load(resource_path)
			if resource is Texture2D:
				return resource as Texture2D
	var image := Image.load_from_file(path)
	if image != null and not image.is_empty():
		return ImageTexture.create_from_image(image)
	return DOCUMENT_ICON


func _activate_entry(index: int) -> void:
	var entry: Dictionary = %FileList.get_item_metadata(index)
	if bool(entry["directory"]):
		_set_directory(str(entry["path"]), true)
	else:
		_select_entry(index)
		_confirm_selection()


func _clear_selection() -> void:
	_selected_path = ""
	if not is_inside_tree():
		return
	%FileName.text = ""
	%Open.disabled = true
	%PreviewIcon.texture = DOCUMENT_ICON
	%PreviewEyebrow.text = "NO FILE SELECTED"
	%PreviewTitle.text = "Select a file"
	%PreviewDetail.text = "Choose a file to inspect its name, type, and location."
	%PreviewPath.text = ""


func _refresh_copy() -> void:
	if not is_inside_tree():
		return
	%Title.text = heading
	%Description.text = description
	%Description.visible = not description.is_empty()
	%Open.text = confirm_label
	%Open.accessibility_name = confirm_label
	title = heading
	accessibility_name = heading
	accessibility_description = description


func _refresh_filter_label() -> void:
	if not is_inside_tree():
		return
	if allowed_extensions.is_empty():
		%FilterSummary.text = "All files"
	else:
		var labels := PackedStringArray()
		for extension in allowed_extensions:
			labels.append(".%s" % extension.trim_prefix(".").to_lower())
		%FilterSummary.text = " · ".join(labels)


func _confirm_selection() -> void:
	if _selected_path.is_empty():
		return
	var result := _selected_path
	hide()
	file_selected.emit(result)


func _cancel() -> void:
	hide()
	cancelled.emit()


func _home_directory() -> String:
	var home := OS.get_environment("HOME")
	if not home.is_empty():
		return home
	var documents := OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	return documents.get_base_dir() if not documents.is_empty() else ProjectSettings.globalize_path("res://")
