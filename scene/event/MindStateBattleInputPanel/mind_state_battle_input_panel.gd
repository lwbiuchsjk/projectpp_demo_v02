extends Control
class_name MindStateBattleInputPanel

@onready var selectSeat: MindStateSelectSeat:
	get(): return $SelectSeat
@onready var bgImage: ColorRect = $MindStateColor
@onready var seatMask: Control = $Mask
@onready var confirmButton: Button = $ConfirmTargetButton

var selectCard: card

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	selectSeat.visible = false
	confirmButton.pressed.connect(_on_confirm_select_card)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## 初始化各类信息
func init_panel_info(propertyName:String) -> void:
	bgImage.color = Color(GameInfo.mindStateManager.get_mindStateColor(propertyName))
	seatMask.visible = false
	close_panel()
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

		print(selectCard.cardInfo['rarity'])
