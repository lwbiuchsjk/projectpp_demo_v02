extends Control
class_name MindStateBattleInputPanel

@onready var selectSeat: MindStateSelectSeat:
	get(): return $SelectSeat
@onready var bgImage: ColorRect = $MindStateColor
@onready var seatMask: Control = $Mask
@onready var confirmButton: Button = $ConfirmTargetButton
@onready var increaseHint: Control = $IncreaseHint
@onready var decreaseHint: Control = $DecreaseHint

var selectCard: card

signal show_inputCard_change_direction()	## mindStateSelectSeat 中被调用
signal clean_change_direction()				## mindStateSelectSeat 中被调用

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	selectSeat.visible = false
	confirmButton.pressed.connect(_on_confirm_select_card)
	show_inputCard_change_direction.connect(_show_change_direction)
	clean_change_direction.connect(_clean_change_direction)
	_clean_change_direction()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## 初始化各类信息
func init_panel_info(propertyName:String, index: int) -> void:
	bgImage.color = Color(GameInfo.mindStateManager.get_mindStateColor(propertyName))
	seatMask.visible = false
	close_panel()
	_set_seatIndex(index)
	pass

## 关闭面板，以防他人代用
func close_panel() -> void:
	self.visible = false
	selectSeat.visible = false
	seatMask.visible = false

## 开启面板，供他人调用
func open_panel() -> void:
	self.visible = true
	selectSeat.visible = true
	if selectCard == null:
		confirmButton.visible = true
	else:
		seatMask.visible = true

## 用于确认选择的功能按钮，需要判断 seat 中是否有卡牌
func _on_confirm_select_card() -> void:
	if confirmButton.visible and selectSeat.seat_card != null:
		seatMask.visible = true
		confirmButton.visible = false
		selectCard = selectSeat.seat_card

## 根据传入的 inputCard 参数与 battleNowTargetCard 之间的关系，显示 changeDirection 对应信息。
func _show_change_direction(inputCard: card, propertyIndex: int) -> void:
	var attributerManager = inputCard.cardAttributeManager as MindStateCardAttributeManager
	var propertyLevelKey = GameInfo.propertyList[propertyIndex] + attributerManager.ATTRIBUTE_LEVEL_NAME
	var isIncrease = _check_change_direction_increase(GameInfo.mindStateManager.battleNowTargetCard, inputCard, propertyLevelKey)
	increaseHint.visible = isIncrease
	decreaseHint.visible = !isIncrease

## 将 panel 的 index 传入 seat，方便标记序号
func _set_seatIndex(index: int) -> void:
	selectSeat.seat_index = index

## 内部方法，用于根据传入的两个卡牌来决定是增加还是减少。targetCard 使用 attributeLevelKey 进行判断，inputCard 直接使用其 rarity 来判断
func _check_change_direction_increase(targetCard: card, inputCard: card, targetAttributerLevelKey: String) -> bool:
	var targetLevel = targetCard.cardInfo[targetAttributerLevelKey]
	var selectLevel = inputCard.cardInfo['rarity']
	if targetLevel >= selectLevel:
		return true
	else:
		return false

## 清除改变方向外显，即将 Increase 和 Decrease 设为不显示。通过 signal 调用
func _clean_change_direction() -> void:
	increaseHint.visible = false
	decreaseHint.visible = false
