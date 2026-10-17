extends RefCounted

static func build(page) -> void:
	var main = page.section("Immediate setting", "Changes take effect immediately in this preview.")
	var setting := CheckButton.new()
	setting.text = "Session reminders"
	setting.custom_minimum_size.y = 44
	main.add_child(setting)
	var status = page.note(main, "Session reminders are off.")
	setting.toggled.connect(func(enabled: bool): status.text = "Session reminders are on." if enabled else "Session reminders are off.")
	page.button(page.flow(main), "Focus switch", setting.grab_focus)
	var states = page.section("Locked settings", "Disabled settings preserve both their on and off states.")
	for enabled in [true, false]:
		var locked := CheckButton.new()
		locked.text = "Shared updates — locked on" if enabled else "Live sync — unavailable"
		locked.button_pressed = enabled
		locked.disabled = true
		locked.custom_minimum_size.y = 44
		states.add_child(locked)
