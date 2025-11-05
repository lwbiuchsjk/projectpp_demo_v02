extends Control
class_name MindStateBattlePanel

signal load_battleCard()

@onready var targetMindStateCardSeat = $CardArea/InputCardSeat/Seat as Seat
@onready var inputCardArea = $InputCardArea as Control
@onready var inceaseCardArea = $IncreaseCardArea as Control

var isIncreaseCardFlag: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("show mind state battle panel")
	connect('load_battleCard', _on_load_battleCard)
	$CloseButton.pressed.connect(_on_close_button)
	$CardArea/ConfirmTargetButton.pressed.connect(_on_confirm_button)

	## 设置组件初始状态
	inceaseCardArea.visible = false
	inputCardArea.visible = false

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
	if seatCard == null:
		print("设置卡牌为空")
		return
	GameInfo.mindStateManager.playerSelectCard = seatCard
	inputCardArea.visible = true
	if GameInfo.mindStateManager.check_isIncreaseCard():
		inceaseCardArea.visible = true
	else:
		print("为decrease流程预留")

	_show_baseCardInfo()

## 显示面板上 battleTargetCard 和 playerSelectCard 的基础信息
func _show_baseCardInfo() -> void:
	var targetCardName: Label
	var selectCardName: Label

	if GameInfo.mindStateManager.check_isIncreaseCard():
		targetCardName = $IncreaseCardArea/BottomBgImage/TargetCardName
		selectCardName = $IncreaseCardArea/TopBgImage/SelectCardName
	else:
		return

	targetCardName.text = GameInfo.mindStateManager.battleNowTargetCard.cardName
	selectCardName.text = GameInfo.mindStateManager.playerSelectCard.cardName
