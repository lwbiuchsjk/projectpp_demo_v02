extends Control
class_name MindStateBattleInputPanel

@onready var inputSeat: MindStateInputSeat:
	get(): return $SelectSeat
@onready var bgImage: ColorRect = $MindStateColor
@onready var seatMask: Control = $Mask
@onready var confirmButton: Button = $ConfirmTargetButton
@onready var increaseHint: Control = $IncreaseHint
@onready var decreaseHint: Control = $DecreaseHint

var selectCard: card

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	inputSeat.visible = false
	confirmButton.pressed.connect(_on_confirm_select_card)
	set_change_direction_status(false, false)


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
	inputSeat.visible = false
	seatMask.visible = false

## 开启面板，供他人调用
func open_panel() -> void:
	self.visible = true
	inputSeat.visible = true
	if selectCard == null:
		confirmButton.visible = true
	else:
		seatMask.visible = true

## 用于确认选择的功能按钮，需要判断 seat 中是否有卡牌
func _on_confirm_select_card() -> void:
	if confirmButton.visible and inputSeat.seat_card != null:
		seatMask.visible = true
		confirmButton.visible = false
		selectCard = inputSeat.seat_card

		## TODO 此处暂定固定消耗 5 精神。后续可根据卡牌配置或level情况进行变化
		PlayerInfo.gamePlayerInfoManager.settle_spiritAttribute(-5)

		## 通过信号调用后续处理逻辑
		GameInfo.mindStateManager.emit_signal("process_targetCard_property", selectCard, inputSeat.seat_index)
		var infoPanel = GameInfo.mindStateManager.battlePanel.mindStateInfoArea.get_child(inputSeat.seat_index) as MindStateBattleInfoPanel
		infoPanel.move_card(selectCard, self)

## 将 panel 的 index 传入 seat，方便标记序号
func _set_seatIndex(index: int) -> void:
	inputSeat.seat_index = index

## 清除改变方向外显，即将 Increase 和 Decrease 设为不显示。通过 signal 调用
func set_change_direction_status(increaseVisible: bool, decreaseVisible: bool) -> void:
	increaseHint.visible = increaseVisible
	decreaseHint.visible = decreaseVisible
