extends Control
class_name MindStateBattleInputPanel

@onready var seat = $Seat as Seat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	seat.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## 初始化各类信息
func init_panel_info() -> void:
	pass
