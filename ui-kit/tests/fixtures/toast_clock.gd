extends "res://rookframe/ui/components/feedback/toast_stack.gd"
var now := 1000
func _clock_ms() -> int:
	return now
func advance(milliseconds: int) -> void:
	now += milliseconds
