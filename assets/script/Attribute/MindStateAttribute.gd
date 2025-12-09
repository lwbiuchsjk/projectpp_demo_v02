class_name MindStateAttribute extends Attribute

@export var enemy_attribute_name:String

## 精神属性计算时，应当独立处理对抗值。也即，通过属性管道获得【主属性】和【对抗属性】后，将两者再单独进行结算。在属性管道中，双方不应当随时互相处理。
## 这是因为，在属性管道中，关联属性一旦发生变动，也会对【主属性】进行变更。这导致对抗属性会多次参与计算。

## 自定义计算公式
#func custom_compute(_operated_value: float, _compute_params: Array[Attribute]) -> float:
#	var enemy_attribute = _compute_params[0]
#	print(enemy_attribute.get_value())
#	return _operated_value - enemy_attribute.get_value()

## TODO 此处应当添加经验值与品质之间的自动换算关系

## 属性依赖列表
func derived_from() -> Array[String]:
	return [
#		enemy_attribute_name,
	]
