extends Control
class_name MindStateBattleInputPanel

@onready var seat: Seat = $Seat
@onready var bgImage: ColorRect = $MindStateColor
@onready var seatMask: Control = $Mask

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	seat.visible = false
	pass # Replace with function body.


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
	seat.visible = false

## 开启面板，供他人调用
func open_panel() -> void:
	self.visible = true
	seat.visible = true
