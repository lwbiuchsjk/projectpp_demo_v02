extends Control
class_name MindStateBattlePanel

signal load_battleCard()

@onready var targetMindStateCardSeat = $CardArea/InputCardSeat/Seat as Seat
@onready var mindStateSelectArea = $CardArea/MindStateSelectArea as Control
@onready var selectCardMask = $CardArea/InputCardSeat/Mask as Control
@onready var selectCardConfirmButton = $CardArea/ConfirmTargetButton as Control
@onready var mindStateInputRoot = $CardArea/InpuCardArea/InputRoot as Control
@onready var mindStateInputHintPanel = $CardArea/InpuCardArea/NormalStatus as Control
@onready var mindStateEmptyStatue = $CardArea/InpuCardArea/NormalStatus as Control

@export var mindStateList:Array[Control]
var mindStateInputList:Array[MindStateBattleInputPanel]

var isIncreaseCardFlag: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("show mind state battle panel")
	connect('load_battleCard', _on_load_battleCard)
	$CloseButton.pressed.connect(_on_close_button)
	$CardArea/ConfirmTargetButton.pressed.connect(_on_confirm_button)
	GameInfo.mindStateManager.select_mindState_to_change.connect(select_mindStateInputPanel)

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
	mindStateInputHintPanel.visible = true
	## mindState相关信息重点展示
	for index in range(0, len(GameInfo.propertyList)):
		var mindStatePanel = mindStateList[index] as MindStateBattleInfoPanel
		var propertyKey = GameInfo.propertyList[index]
		mindStatePanel.emit_signal("show_MindStateColor", propertyKey)

	## 初始化 mindStateInpuPanelList 结构，将6个 panel 添加进入 root
	_init_mindStateInputPanelList()

	## TODO 输入选择模板卡牌后，选择模板卡牌状态应当有变化，否则后续操作会误以为是在指向选择模板卡牌，而不是 battleTargetCard

## 用于显示 targetCard 和 inputCard 的主属性、副属性提示信息
func _show_CardInfo(targetCard: card, isBattleTargetCard: bool) -> void:
	for index in range(0, len(GameInfo.propertyList)):
		var mindStatePanel = mindStateList[index] as MindStateBattleInfoPanel
		var propertyKey = GameInfo.propertyList[index]
		var propertyTemplate: Dictionary

		## 外显 seat 中的 mindState 相关信息
		mindStatePanel.emit_signal("init_MindStateInfo", propertyKey, targetCard.cardInfo[propertyKey])
		## 读取主属性、副属性配置
		propertyTemplate = GameInfo.get_mindStateTemplaterData(targetCard.cardInfo["TypeName"])
		var mainVisible = GameInfo.check_property_mainProperty(propertyTemplate, propertyKey)
		var assistVisible = GameInfo.check_property_assistProperty(propertyTemplate, propertyKey)

		if isBattleTargetCard:
			mindStatePanel.targetInfoArea.visible = true
			mindStatePanel.set_TargetInfo_visible(mainVisible, assistVisible)
		else:
			mindStatePanel.inputInfoArea.visible = true
			mindStatePanel.set_InputInfo_visible(mainVisible, assistVisible)

## 用于初始化 MindStateInputPanel，将其实例化后，方便对其内容进行操作
func _init_mindStateInputPanelList() -> void:
	if mindStateInputRoot.get_child_count() == 0:
		for index in range(len(GameInfo.propertyList)):
			var property = GameInfo.propertyList[index]
			var inputPanel = preload("res://scene/event/MindStateBattleInputPanel/MindStateBattleInputPanel.tscn").instantiate() as MindStateBattleInputPanel
			mindStateInputRoot.add_child(inputPanel)
			mindStateInputList.append(inputPanel)
			## 初始化面板信息
			inputPanel.init_panel_info(property, index)
			inputPanel.selectSeat.set_seat_data(index, GameInfo.search_const_value("MindStateInputSeatID")['value'])

## 在 mindStateInput 面板列表中，选择一个打开，其余关闭。通过信号调用本功能
func select_mindStateInputPanel(property: String) -> void:
	## 关闭输入提示信息
	mindStateEmptyStatue.visible = false
	mindStateInputRoot.visible = true
	## 正式功能
	for i in range(len(GameInfo.propertyList)):
		var nowProperty = GameInfo.propertyList[i]
		var inputPanel = mindStateInputList[i]
		if nowProperty == property:
			inputPanel.open_panel()
		else:
			inputPanel.close_panel()
