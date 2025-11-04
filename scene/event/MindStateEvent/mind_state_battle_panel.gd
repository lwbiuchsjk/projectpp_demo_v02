extends Control
class_name MindStateBattlePanel

signal load_battleCard()

@onready var targetMindStateCardSeat = $CardArea/InputCardSeat/Seat as Seat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("show mind state battle panel")
	connect('load_battleCard', _on_load_battleCard)
	$CloseButton.pressed.connect(_on_close_button)
	$CardArea/ConfirmTargetButton.pressed.connect(_on_confirm_button)

	## 初始化 seat 数据
	## TODO 此处暂用 ID = 998 的Seat数据强制赋值。后续需要指定专用 SeatID，或根据功能支持配置指定 SeatID
	$CardArea/InputCardSeat/Seat.set_seat_data(0, '998')


func _on_close_button() -> void:
	GameInfo.mindStateManager.emit_signal('close_mindStateBattle_panel')

func _on_load_battleCard(cardToAdd: card) -> void:
	$CardArea/MindStateSwarmCardRoot.add_child(cardToAdd)

func get_input_targetCard() -> card:
	var output = targetMindStateCardSeat.seat_card
	return output

func _on_confirm_button() -> void:
	var seatCard = get_input_targetCard()
	## TODO 此处应当改为正式切换功能
	if seatCard != null:
		print(seatCard.cardName)
	else:
		print("设置卡牌为空")
