extends Control
class_name MindStateBattleInfoPanel

@onready var targetInfoArea: Control = $TargetInfoArea
@onready var inputInfoArea: Control = $InputInfoArea
@onready var bgImage: ColorRect = $CardInfoArea/BgImage
@onready var showName: Label = $CardInfoArea/InputHint

var mindStateName:String
var mindStateValue:String

signal init_MindStateInfo()
signal show_MindStateColor()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	targetInfoArea.visible = false
	inputInfoArea.visible = false
	init_MindStateInfo.connect(_show_mindStateInfo)
	show_MindStateColor.connect(_show_mindStateColor)

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

## 显示当前组件的 mindState 相关信息，例如 name
func _show_mindStateInfo(propertyName:String, propertyValue:String) -> void:
	mindStateName = propertyName
	mindStateValue = propertyValue
	showName.text = GameInfo.mindStateManager.get_mindStateName(mindStateName)

## 显示当前组件的 mindState 相关信息，例如 color
func _show_mindStateColor(propertyName:String) -> void:
	bgImage.color = Color(GameInfo.mindStateManager.get_mindStateColor(propertyName))

