extends Control
class_name MindStateBattleSeat

@onready var targetInfoArea: Control = $TargetInfoArea
@onready var inputInfoArea: Control = $InputInfoArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	targetInfoArea.visible = false
	inputInfoArea.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## 设置目标卡牌相关信息展示，主要用于控制主属性、副属性展示
func set_TargetInfo_visible(isMainVisible: bool, isAssistVisible:bool) -> void:
	targetInfoArea.get_node("MainPropertyMark").visible = isMainVisible
	targetInfoArea.get_node("AssistPropertyMark").visible = isAssistVisible

## 设置输入卡牌相关信息展示，主要用于控制主属性、副属性展示
func set_InputInfo_visible(isMainVisible: bool, isAssistVisible:bool) -> void:
	inputInfoArea.get_node("MainPropertyMark").visible = isMainVisible
	inputInfoArea.get_node("AssistPropertyMark").visible = isAssistVisible
