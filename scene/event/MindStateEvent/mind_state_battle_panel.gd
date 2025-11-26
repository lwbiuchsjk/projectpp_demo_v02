extends Control
class_name MindStateBattlePanel

signal load_battleCard()

@onready var targetMindStateCardSeat = $CardArea/InputCardSeat/Seat as Seat
@onready var mindStateSelectArea = $CardArea/MindStateSelectArea as Control
@onready var selectCardMask = $CardArea/InputCardSeat/Mask as Control
@onready var selectCardConfirmButton = $CardArea/ConfirmTargetButton as Control

@export var inputCardList:Array[Control]

var isIncreaseCardFlag: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("show mind state battle panel")
	connect('load_battleCard', _on_load_battleCard)
	$CloseButton.pressed.connect(_on_close_button)
	$CardArea/ConfirmTargetButton.pressed.connect(_on_confirm_button)

	## 设置组件初始状态
	mindStateSelectArea.visible = false

	## 初始化 seat 数据
	## TODO 此处暂用 ID = 998 的Seat数据强制赋值。后续需要指定专用 SeatID，或根据功能支持配置指定 SeatID
	$CardArea/InputCardSeat/Seat.set_seat_data(0, '998')


func _on_close_button() -> void:
	GameInfo.mindStateManager.emit_signal('close_mindStateBattle_panel')

func _on_load_battleCard(cardToAdd: card) -> void:
	var battleInfo = $CardArea/MindStateSwarmCardRoot/TargetCardName as Label
	battleInfo.text = cardToAdd.cardInfo['base_displayName']
	mindStateSelectArea.visible = true

	_show_CardInfo(GameInfo.mindStateManager.battleNowTargetCard, true)

func get_input_targetCard() -> card:
	var output = targetMindStateCardSeat.seat_card
	return output

func _on_confirm_button() -> void:
	var seatCard = get_input_targetCard()
	if seatCard == null:
		print("设置卡牌为空")
		return
	GameInfo.mindStateManager.playerSelectCard = seatCard

	## 处理 selectCard 信息显示
	_show_CardInfo(seatCard, false)
	## 处理后续组件显示
	selectCardConfirmButton.visible = false
	selectCardMask.visible = true

## 用于显示 targetCard 和 inputCard 的主属性、副属性提示信息
func _show_CardInfo(targetCard: card, isBattleTargetCard: bool) -> void:
	for index in range(0, len(GameInfo.propertyList)):
		var inputCardSeat = inputCardList[index] as MindStateBattleSeat
		var propertyKey = GameInfo.propertyList[index]
		var propertyTemplate: Dictionary

		## 外显 seat 中的 mindState 相关信息
		inputCardSeat.emit_signal("init_MindStateInfo", propertyKey, targetCard.cardInfo[propertyKey])
		## 读取主属性、副属性配置
		propertyTemplate = GameInfo.get_mindStateTemplaterData(targetCard.cardInfo["TypeName"])
		var mainVisible = GameInfo.check_property_mainProperty(propertyTemplate, propertyKey)
		var assistVisible = GameInfo.check_property_assistProperty(propertyTemplate, propertyKey)

		if isBattleTargetCard:
			inputCardSeat.targetInfoArea.visible = true
			inputCardSeat.set_TargetInfo_visible(mainVisible, assistVisible)
		else:
			inputCardSeat.inputInfoArea.visible = true
			inputCardSeat.set_InputInfo_visible(mainVisible, assistVisible)
