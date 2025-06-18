class_name SpiritAttribute extends Attribute

const MAX_SPIRIT_VALUE = 100
const MIN_SPIRIT_VALUE = -100

func post_attribute_value_changed(_value: float) -> float:
	_value = clamp(_value, MIN_SPIRIT_VALUE, MAX_SPIRIT_VALUE)
	return _value


func custom_compute(operated_value: float, _compute_params: Array[Attribute]) -> float:
	return clamp(operated_value, MIN_SPIRIT_VALUE, MAX_SPIRIT_VALUE)

func get_max_value() -> int:
	return MAX_SPIRIT_VALUE
	
func get_min_value() -> int:
	return MIN_SPIRIT_VALUE

## 属性依赖列表
## @ return: 返回依赖属性的名称数组
func derived_from() -> Array[String]:
	return [	]
