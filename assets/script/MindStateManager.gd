extends Node
class_name MindStateManager

var battleID

signal start_mindStateBattle()
signal show_mindStateBattle_panel()		## event中连接

func _ready() -> void:
	connect("start_mindStateBattle", _on_start_mindStateBattle)


func _on_start_mindStateBattle() -> void:
	print("battle start")
	emit_signal("show_mindStateBattle_panel")
