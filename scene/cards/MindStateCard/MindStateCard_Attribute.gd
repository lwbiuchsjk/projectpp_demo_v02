extends Node

@export var character_name: String

#var attribute_component: AttributeComponent
@onready var attribute_component: AttributeComponent = %AttributeComponent
@onready var cardRoot = self.get_parent()

const HAPPY_ATTRIBUTE_NAME = "Happiness"
const SADNESS_ATTRIBUTE_NAME = "Sadness"
const ANGER_ATTRIBUTE_NAME = "Anger"
const FEAR_ATTRIBUTE_NAME = "Fear"
const DISGUST_ATTRIBUTE_NAME = "Disgust"
const SURPRISE_ATTRIBUTE_NAME = "Surprise"
const RARITY_ATTRIBUTE_NAME = "rarity"

var happy
var sad
var anger
var fear
var disgust
var surprise
var rarity

func _ready() -> void:
	# 初始化信息显示
	_init_mindState_info()

	print("设置卡牌属性")
	# 绑定信息改变信号
	_bind_attibute_signal()
	pass

##TODO 对AttributeSet的设置，还需要支持通过表格实现。当前是直接在场景中编辑，很不方便灵活。
func get_attribute_set() -> AttributeSet:
	return attribute_component.attribute_set


func get_attribute(_attribute_name: String) -> Attribute:
	return attribute_component.find_attribute(_attribute_name)


func _init_mindState_info() -> void:
	var attribute_set = get_attribute_set() as AttributeSet

	happy = attribute_set.attributes_runtime_dict[HAPPY_ATTRIBUTE_NAME] as MindStateAttribute
	sad = attribute_set.attributes_runtime_dict[SADNESS_ATTRIBUTE_NAME] as MindStateAttribute
	anger = attribute_set.attributes_runtime_dict[ANGER_ATTRIBUTE_NAME] as MindStateAttribute
	fear = attribute_set.attributes_runtime_dict[FEAR_ATTRIBUTE_NAME] as MindStateAttribute
	disgust = attribute_set.attributes_runtime_dict[DISGUST_ATTRIBUTE_NAME] as MindStateAttribute
	surprise = attribute_set.attributes_runtime_dict[SURPRISE_ATTRIBUTE_NAME] as MindStateAttribute

	rarity = attribute_set.attributes_runtime_dict[RARITY_ATTRIBUTE_NAME] as Attribute

	_set_mindState_info(attribute_set)
	_set_rarity_info(attribute_set)

	pass

func _set_mindState_info(attribute_set: AttributeSet) -> void:
	cardRoot.get_node("MindStateInfo/Happy/Label").text = str(int(happy.get_value()))
	cardRoot.get_node("MindStateInfo/Sad/Label").text = str(int(sad.get_value()))
	cardRoot.get_node("MindStateInfo/Anger/Label").text = str(int(anger.get_value()))
	cardRoot.get_node("MindStateInfo/Fear/Label").text = str(int(fear.get_value()))
	cardRoot.get_node("MindStateInfo/Disgust/Label").text = str(int(disgust.get_value()))
	cardRoot.get_node("MindStateInfo/Surprise/Label").text = str(int(surprise.get_value()))

	pass

func _on_mindState_attribute_change() -> void:
	var attribute_set = get_attribute_set() as AttributeSet
	_set_mindState_info(attribute_set)
	pass

func _set_rarity_info(attribute_set: AttributeSet) -> void:
	#rarity = attribute_set.attributes_runtime_dict[RARITY_ATTRIBUTE_NAME] as SpiritAttribute
	#$SpiritInfo/SpiritBar.value = (spirit.get_value() - spirit.get_min_value()) / (spirit.get_max_value() - spirit.get_min_value()) * $SpiritInfo/SpiritBar.max_value
	#$SpiritInfo/SpiritString.text = str(int(spirit.get_value()))
	pass

func _on_rarity_attribute_change() -> void:
	var attribute_set = get_attribute_set() as AttributeSet
	_set_rarity_info(attribute_set)
	pass


## 信号绑定函数
func _bind_attibute_signal() -> void:
	# 绑定精神状态属性函数
	happy.attribute_changed.connect(_on_mindState_attribute_change)
	sad.attribute_changed.connect(_on_mindState_attribute_change)
	anger.attribute_changed.connect(_on_mindState_attribute_change)
	fear.attribute_changed.connect(_on_mindState_attribute_change)
	disgust.attribute_changed.connect(_on_mindState_attribute_change)
	surprise.attribute_changed.connect(_on_mindState_attribute_change)

	# 绑定稀有度属性函数
	rarity.attribute_changed.connect(_on_rarity_attribute_change)

	## 测试函数
	print("HAPPY: ", happy.get_value())

	pass
