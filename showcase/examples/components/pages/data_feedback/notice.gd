extends RefCounted

const Demo = preload("res://examples/components/pages/data_feedback/demo.gd")

static func build(page) -> void:
	var tones = page.section("Information, pending, success, and error")
	for index in 4:
		page.scene(Demo.path("feedback/notice"), tones, {"tone": index, "title": ["A new route is available", "Preparing the expedition", "Changes saved", "The map could not be loaded"][index], "description": ["Review the route before leaving camp.", "You can continue reviewing your equipment.", "Your party can now see the updated itinerary.", "The last saved map is still available."][index]})
	var interactive = page.section("Dismissal and recovery")
	var notice = page.scene(Demo.path("feedback/notice"), interactive, {"tone": 3, "title": "Connection interrupted", "description": "Retry when you are ready.", "dismissible": true})
	var status = page.note(interactive, "Waiting for an action.")
	page.button(notice.get_action_slot(), "Retry connection", func():
		notice.tone = 2
		notice.title = "Connection restored"
		status.text = "Retry completed in this preview.")
	notice.dismissed.connect(func():
		notice.hide()
		status.text = "Notice dismissed.")
	page.button(interactive, "Restore notice", func(): notice.show())
