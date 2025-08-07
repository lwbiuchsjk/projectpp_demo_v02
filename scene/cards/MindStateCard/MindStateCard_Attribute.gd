extends Node

@export var character_name: String

#var attribute_component: AttributeComponent
@onready var attribute_component: AttributeComponent = %AttributeComponent

const MAX_HEALTH_ATTRIBUTE_NAME = "max_health"
const HEALTH_ATTRIBUTE_NAME = "health"
const ATTACK_ATTRIBUTE_NAME = "attack"
const STRENGTH_ATTRIBUTE_NAME = "strength"
const INTELL_ATTRIBUTE_NAME = "intell"
const SPIRIT_ATTRIBUTE_NAME = "spirit"


func _ready() -> void:
	# 初始化信息显示
	##_init_player_info()

	print("设置卡牌属性")
	# 绑定信息改变信号
	_bind_attibute_signal()
	pass


func get_attribute_set() -> AttributeSet:
	return attribute_component.attribute_set


func get_attribute(_attribute_name: String) -> Attribute:
	return attribute_component.find_attribute(_attribute_name)


func _init_player_info() -> void:
	var attribute_set = get_attribute_set() as AttributeSet
	_set_health_info(attribute_set)
	_set_spirit_info(attribute_set)

	pass

func _set_health_info(attribute_set: AttributeSet) -> void:
	var max_health = attribute_set.attributes_runtime_dict[MAX_HEALTH_ATTRIBUTE_NAME] as Attribute
	var health = attribute_set.attributes_runtime_dict[HEALTH_ATTRIBUTE_NAME] as Attribute
	#$HealthInfo/HealthBar.value = health.get_value() / max_health.get_value() * $HealthInfo/HealthBar.max_value
	#$HealthInfo/HealthString.text = str(int(health.get_value())) + '/' + str(int(max_health.get_value()))
	pass

func _on_health_attribute_change() -> void:
	var attribute_set = get_attribute_set() as AttributeSet
	_set_health_info(attribute_set)
	pass

func _set_spirit_info(attribute_set: AttributeSet) -> void:
	var spirit = attribute_set.attributes_runtime_dict[SPIRIT_ATTRIBUTE_NAME] as SpiritAttribute
	#$SpiritInfo/SpiritBar.value = (spirit.get_value() - spirit.get_min_value()) / (spirit.get_max_value() - spirit.get_min_value()) * $SpiritInfo/SpiritBar.max_value
	#$SpiritInfo/SpiritString.text = str(int(spirit.get_value()))
	pass

func _on_spirit_attribute_change() -> void:
	var attribute_set = get_attribute_set() as AttributeSet
	_set_spirit_info(attribute_set)
	pass


## 信号绑定函数
func _bind_attibute_signal() -> void:
	var attribute_set = get_attribute_set() as AttributeSet
	# 绑定生命属性函数
	var heal_attribute = attribute_set.find_attribute(HEALTH_ATTRIBUTE_NAME) as Attribute
	var max_heal_attribute = attribute_set.find_attribute(MAX_HEALTH_ATTRIBUTE_NAME) as Attribute
	heal_attribute.attribute_changed.connect(_on_health_attribute_change)
	max_heal_attribute.attribute_changed.connect(_on_health_attribute_change)

	# 绑定精神属性函数
	var spirit_attribute = attribute_set.find_attribute(SPIRIT_ATTRIBUTE_NAME) as Attribute
	spirit_attribute.attribute_changed.connect(_on_spirit_attribute_change)
	pass
