extends Control
class_name MindStateBattleInfoPanel

@onready var targetInfoArea: Control = $TargetInfoArea
@onready var inputInfoArea: Control = $InputInfoArea
@onready var bgImage: ColorRect = $CardInfoArea/BgImage
@onready var showName: Label = $CardInfoArea/InputHint
@onready var selectButton: Button = $CardInfoArea/SelectMindStateButton

var mindStateName:String
var mindStateValue:String
var nowMovingCard: card
var inputCardList:Array[card]
var cardMoveFromSeat: MindStateBattleInputPanel

signal init_MindStateInfo()
signal show_MindStateColor()
signal select_MindState()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	targetInfoArea.visible = false
	inputInfoArea.visible = false
	init_MindStateInfo.connect(_show_mindStateInfo)
	show_MindStateColor.connect(_show_mindStateColor)
	selectButton.pressed.connect(_select_this_mindState)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if nowMovingCard != null:
		if _check_position_same(self, nowMovingCard):
			clean_card_from_parent(cardMoveFromSeat)

## 检测是否满足停止条件。停止条件即 target 与 now 之间的差异不超过 3 像素
func _check_position_same(target:Control, now:Control) -> bool:
	var circle = 3
	if abs(target.global_position.x - now.global_position.x) <= circle and abs(target.global_position.y - now.global_position.y) <= circle:
		return true
	return false

## 设置目标卡牌相关信息展示，主要用于控制主属性、副属性展示
func set_TargetInfo_visible(isMainVisible: bool, isAssistVisible:bool) -> void:
	targetInfoArea.get_node("MainPropertyMark").visible = isMainVisible
	targetInfoArea.get_node("AssistPropertyMark").visible = isAssistVisible

## 设置输入卡牌相关信息展示，主要用于控制主属性、副属性展示
func set_InputInfo_visible(isMainVisible: bool, isAssistVisible:bool) -> void:
	inputInfoArea.get_node("MainPropertyMark").visible = isMainVisible
	inputInfoArea.get_node("AssistPropertyMark").visible = isAssistVisible

## 显示当前组件的 mindState 相关信息，例如 name
func _show_mindStateInfo(propertyName:String, propertyValue:String) -> void:
	mindStateName = propertyName
	mindStateValue = propertyValue
	showName.text = GameInfo.mindStateManager.get_mindStateName(mindStateName) + ":" + str(propertyValue)

## 显示当前组件的 mindState 相关信息，例如 color。并且开启设置按钮功能，允许后续进行选择。如果输入的 propertyName 无法被检测到，那么显示默认颜色
func _show_mindStateColor(propertyName:String) -> void:
	var defaultColor = Color("#9c9c9c")
	var propertyColorCode = GameInfo.mindStateManager.get_mindStateColor(propertyName)
	if propertyColorCode == "":
		bgImage.color = defaultColor
	else:
		bgImage.color = Color(GameInfo.mindStateManager.get_mindStateColor(propertyName))
	selectButton.visible = true

## 触发选择功能。通过 MindStateManger 进行全局影响
func _select_this_mindState() -> void:
	if not self.visible:
		return

	GameInfo.mindStateManager.emit_signal("select_mindState_to_change", mindStateName)

## 移动卡牌功能。通过复用 card 的 follow 模式来实现
func move_card(cardToAdd: card, cardParent: MindStateBattleInputPanel) -> void:
	nowMovingCard = cardToAdd
	## 在此处进行保存，但并不将 cardToAdd 添加至 self 的 child
	inputCardList.append(cardToAdd)
	cardToAdd.follow_target = self

	cardMoveFromSeat = cardParent

## 卡牌移动到目标位置后，需要将其从原 MindStateBattleInputPanel 结构中清除。
func clean_card_from_parent(parent: MindStateBattleInputPanel) -> void:
	## 从 seat 结构中移除。处理 seat 相关各种显示问题
	var seat = parent.inputSeat
	seat.clear_children(seat.cardDeck)
	seat.clear_children(seat.cardPoiDeck)
	seat.clean_seat_card()
	seat.update_weight()
	seat.trigger_deck_sort()
	## 还原 MindStateBattleInputPanel 中部分状态，以支持后续继续添加卡牌
	parent.confirmButton.visible = true
	parent.seatMask.visible = false
	## 将 self 中与 move_card 功能相关的部分进行设置
	nowMovingCard = null
	cardMoveFromSeat = null
