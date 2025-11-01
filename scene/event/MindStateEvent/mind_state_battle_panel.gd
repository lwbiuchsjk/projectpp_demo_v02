extends Control
class_name MindStateBattlePanel

signal load_battleCard()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("show mind state battle panel")
	connect('load_battleCard', _on_load_battleCard)
	$CloseButton.pressed.connect(_on_close_button)

	## 初始化 seat 数据
	## TODO 此处暂用 ID = 1 的Seat数据强制赋值。后续需要指定专用 SeatID，或根据功能支持配置指定 SeatID
	$CardArea/InputCardSeat/Seat.set_seat_data(0, '1')


func _on_close_button() -> void:
	GameInfo.mindStateManager.emit_signal('close_mindStateBattle_panel')

func _on_load_battleCard(cardToAdd: card) -> void:
	$CardArea/MindStateSwarmCardRoot.add_child(cardToAdd)
