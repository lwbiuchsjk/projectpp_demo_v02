extends Node
class_name MindStateCardAttribute

@export var character_name: String

#var attribute_component: AttributeComponent
@onready var cardRoot = self.get_parent() as card
@onready var attribute_component: AttributeComponent = %AttributeComponent

const RARITY_ATTRIBUTE_NAME = "rarity"

func _ready() -> void:
	# 绑定信息改变信号
	_bind_attibute_signal()

	# 初始化信息显示
	_show_mindState_info()
	_init_mindState_info()

	print("设置卡牌属性")

	pass

##TODO 对AttributeSet的设置，还需要支持通过表格实现。当前是直接在场景中编辑，很不方便灵活。
func get_attribute_set() -> AttributeSet:
	var attributeSet = attribute_component.attribute_set as AttributeSet
	for property in GameInfo.propertyList:
		if property in cardRoot.cardInfo.keys():
			var attributeInstance = attributeSet.find_attribute(property)
			if attributeInstance != null:
				attributeInstance.set_value(float(cardRoot.cardInfo[property]))

	var rarityInstance = attributeSet.find_attribute(RARITY_ATTRIBUTE_NAME)
	if rarityInstance != null:
		rarityInstance.set_value(float(cardRoot.cardInfo[RARITY_ATTRIBUTE_NAME]))

	return attributeSet


func get_attribute(_attribute_name: String) -> Attribute:
	return attribute_component.find_attribute(_attribute_name)


func _init_mindState_info() -> void:
	var attribute_set = get_attribute_set() as AttributeSet
	for property in GameInfo.propertyList:
		_set_mindState_info(property)
	var rarityAttibute = get_attribute(RARITY_ATTRIBUTE_NAME)
	_set_rarity_info(rarityAttibute)

	pass

## 用于对卡牌相关的 mindState 外显进行设置
func _show_mindState_info() -> void:
	for key in GameInfo.propertyList:
		## 设置颜色，颜色由 const 配置决定
		var colorCode = GameInfo.search_const_value(key + "Color")['valueString']
		var colorRectNode = cardRoot.get_node("MindStateInfo/" + key + "/ColorRect") as ColorRect
		colorRectNode.color = Color(colorCode)
	pass

func _set_mindState_info(propertyName: String) -> void:
	var scenePath = 'MindStateInfo/' + propertyName + '/Label'
	var propertyInstance = attribute_component.attribute_set.find_attribute(propertyName) as MindStateAttribute
	cardRoot.get_node(scenePath).text = str(int(propertyInstance.get_value()))

	pass

func _on_mindState_attribute_change(attribute: Attribute) -> void:
	_set_mindState_info(attribute.attribute_name)
	pass

func _set_rarity_info(attribute: Attribute) -> void:
	#rarity = attribute_set.attributes_runtime_dict[RARITY_ATTRIBUTE_NAME] as SpiritAttribute
	#$SpiritInfo/SpiritBar.value = (spirit.get_value() - spirit.get_min_value()) / (spirit.get_max_value() - spirit.get_min_value()) * $SpiritInfo/SpiritBar.max_value
	#$SpiritInfo/SpiritString.text = str(int(spirit.get_value()))
	pass

func _on_rarity_attribute_change(attribute: Attribute) -> void:
	_set_rarity_info(attribute)
	pass


## 信号绑定函数
func _bind_attibute_signal() -> void:
	# 绑定精神状态属性函数
	for property in GameInfo.propertyList:
		var propertyInstance = attribute_component.attribute_set.find_attribute(property) as MindStateAttribute
		propertyInstance.attribute_changed.connect(_on_mindState_attribute_change)

	# 绑定稀有度属性函数
	var rarityAttribute = attribute_component.attribute_set.find_attribute(RARITY_ATTRIBUTE_NAME) as Attribute
	rarityAttribute.attribute_changed.connect(_on_rarity_attribute_change)
	pass
