extends Control
class_name SeatBrief

signal change_seat_brief_status()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("change_seat_brief_status", set_seat_brief_status)
	$SetStatus.visible = false
	pass # Replace with function body.

func set_seat_brief_status(status: bool) -> void:
	$SetStatus.visible = status
