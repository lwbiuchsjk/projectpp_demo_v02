extends Node
class_name MindStateCardAttributeManager

@export var character_name: String

#var attribute_component: AttributeComponent
@onready var cardRoot = self.get_parent() as card
@onready var attribute_component: AttributeComponent = %AttributeComponent

##const ATTRIBUTE_LEVEL_NAME = "Level"
const ATTRIBUTE_EXP_NAME = 'Exp'

func _ready() -> void:
	# 将本 manager 绑定至 card 父节点上
	cardRoot.cardAttributeManager = self

	# 绑定信息改变信号
	_bind_attribute_signal()

	# 初始化信息显示
	_show_mindState_info()
	_init_mindState_info()

	_get_card_rarity_from_mindStateCard_mainAttribute()
	_check_propertyExp_from_propertyLevl()
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

	#var levelInstance = attributeSet.find_attribute(ATTRIBUTE_LEVEL_NAME)
	#if levelInstance != null:
	#	levelInstance.set_value(float(cardRoot.cardInfo[ATTRIBUTE_LEVEL_NAME]))

	#var expInstance = attributeSet.find_attribute(ATTRIBUTE_EXP_NAME)
	#if expInstance != null:
	#	expInstance.set_value(float(cardRoot.cardInfo[ATTRIBUTE_EXP_NAME]))

	return attributeSet

## 待废弃
func get_attribute(_attribute_name: String) -> Attribute:
	return attribute_component.find_attribute(_attribute_name)

## 取得 MindStateProperty 的 level 数值
func get_propertyLevel(propertyName: String) -> int:
	var key = propertyName
	return _get_value_from_CardInto(key).to_int()

## 取得 MindStateProperty 的 exp 数值
func get_propertyExp(propertyName: String) -> int:
	var key = propertyName + ATTRIBUTE_EXP_NAME
	return _get_value_from_CardInto(key).to_int()

## 内部通用取值方法
func _get_value_from_CardInto(key: String) -> String:
	if not key in cardRoot.cardInfo.keys():
		return "-1"
	else:
		return str(cardRoot.cardInfo[key])

## 内部方法，用于初始化 MindState 相关信息。
## 待扩展
func _init_mindState_info() -> void:
	var attribute_set = get_attribute_set() as AttributeSet
	for property in GameInfo.propertyList:
		_set_mindState_info(property)
	#var levelInstance = get_attribute(ATTRIBUTE_LEVEL_NAME)
	#_set_level_info(levelInstance)

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

func _set_level_info(attribute: Attribute) -> void:
	#rarity = attribute_set.attributes_runtime_dict[RARITY_ATTRIBUTE_NAME] as SpiritAttribute
	#$SpiritInfo/SpiritBar.value = (spirit.get_value() - spirit.get_min_value()) / (spirit.get_max_value() - spirit.get_min_value()) * $SpiritInfo/SpiritBar.max_value
	#$SpiritInfo/SpiritString.text = str(int(spirit.get_value()))
	pass

func _on_level_attribute_change(attribute: Attribute) -> void:
	_set_level_info(attribute)
	pass


## 信号绑定函数
func _bind_attribute_signal() -> void:
	# 绑定精神状态属性函数
	for property in GameInfo.propertyList:
		var propertyInstance = attribute_component.attribute_set.find_attribute(property) as MindStateAttribute
		propertyInstance.attribute_changed.connect(_on_mindState_attribute_change)

	# 绑定稀有度属性函数
	#var levelAttribute = attribute_component.attribute_set.find_attribute(ATTRIBUTE_LEVEL_NAME) as Attribute
	#levelAttribute.attribute_changed.connect(_on_level_attribute_change)
	pass

## 处理 MindStateProperty 升级的逻辑。通过返回值判断等级是否变化，返回值即为等级变动数值。
func add_MindStateProperty_exp(propertyName: String, addedExp: int) -> int:
	var propertyLevel = get_propertyLevel(propertyName)
	var levelKey = propertyName
	## 空逻辑处理，返回值 = 0，即不升级
	if propertyLevel < 0:
		return 0
	## 正式逻辑
	var propertyExp = get_propertyExp(propertyName)
	var afterExp = _check_max_exp(propertyExp + addedExp)
	var expKey = propertyName + ATTRIBUTE_EXP_NAME
	## 判断是否升级
	var afterLevel = _search_property_level(afterExp)
	cardRoot.cardInfo[levelKey] = str(afterLevel)
	cardRoot.cardInfo[expKey] = str(afterExp)

	return afterLevel - propertyLevel

## 通过查询 exp 配置值，得到对应的 level。
## 配置时，每个等级检索其经验上限。按等级从低到高索引，检索到第一个当前经验小于经验上限的等级。
func _search_property_level(nowExp: int) -> int:
	var nowLevel = 1
	for config in GameInfo.mindStateLevelExp.values():
		if config['Exp'] == "":
			break
		var levelEndExp = config['Exp'].to_int()
		if nowExp <= levelEndExp:
			nowLevel = config['ID'].to_int()
			break

	return nowLevel

## 检查是否已经达到最大经验值
func _check_max_exp(nowExp: int) -> int:
	var maxLevel = GameInfo.mindStateLevelExp.keys()[GameInfo.mindStateLevelExp.keys().size() - 1]
	var maxExp = GameInfo.mindStateLevelExp[maxLevel]['Exp'].to_int()
	if nowExp > maxExp:
		return maxExp
	return nowExp

## 自动设置 card 的 rarity。方法为，获得卡牌的主属性，将主属性的 rarity 设置为 card 的 rarity
func _get_card_rarity_from_mindStateCard_mainAttribute() -> void:
	var mindStateClass = cardRoot.cardInfo['TypeName']
	var mindStateTemplate = GameInfo.get_mindStateTemplaterData(mindStateClass)
	var mainAttributeKey: String
	for property in GameInfo.propertyList:
		if GameInfo.check_property_mainProperty(mindStateTemplate, property):
			mainAttributeKey = property
			break
	if mainAttributeKey == null:
		cardRoot.cardInfo['rarity'] = 0
		return
	else:
		## 如果得到的 mindStateMainProperty 的 Level 属性不为0，那么将其直接设置为 card 的 rarity 属性
		cardRoot.cardInfo['rarity'] = cardRoot.cardInfo[mainAttributeKey]

## 根据配置的 level 自动矫正 exp 配置。要求 exp 配置能够正确换算至 level 配置。否则将使用 level 配置的 exp 数值覆盖回 exp 配置。
func _check_propertyExp_from_propertyLevl() -> void:
	for property in GameInfo.propertyList:
		var configLevel = get_propertyLevel(property)
		var propertyExpKey = property + ATTRIBUTE_EXP_NAME
		var checkLevelFromExp = _search_property_level(cardRoot.cardInfo[propertyExpKey].to_int())
		## 无法换算时的覆盖逻辑
		if configLevel != checkLevelFromExp:
			for config in GameInfo.mindStateLevelExp.values():
				var tempLevel = config['ID'].to_int()
				if configLevel == 1:
					cardRoot.cardInfo[propertyExpKey] = "0"
					break
				if tempLevel == configLevel - 1:
					cardRoot.cardInfo[propertyExpKey] = config['Exp']
					break

## 检查等级变动后的，属性在属性模板中的标志，是否与 inputCard 的属性模板一致。如果一致，那么恢复精神，否则消耗精神。
func check_propertyTemplate_flag(playerInputCard:card, propertyIndex:int) -> bool:
	var propertyKey = GameInfo.propertyList[propertyIndex]
	var propertySortIndexList = get_mindStateProperty_rank()

	print("变更后 targetCard 的 mindState 属性排序情况：", propertySortIndexList)

	var mindStateClass = playerInputCard.cardInfo['TypeName']
	var mindStateTemplate = GameInfo.get_mindStateTemplaterData(mindStateClass)
	if GameInfo.check_property_mainProperty(mindStateTemplate, propertyKey):
		if GameInfo.mindStateManager.check_mainProperty_satisfied(propertySortIndexList, propertyIndex):
			return true

	if GameInfo.check_property_secondProperty(mindStateTemplate, propertyKey):
		if GameInfo.mindStateManager.check_secondProperty_satisfied(propertySortIndexList, propertyIndex):
			return true

	return false


## 	稳定排序：相同值时保持原始顺序
func _get_stable_sorted_indices(arr: Array) -> Array:
	# 创建带原始索引的数组
	var indexed_arr = []
	for i in range(arr.size()):
		indexed_arr.append({
			"value": arr[i],
			"original_index": i
		})

	# 排序：先按值，再按原始索引
	indexed_arr.sort_custom(func(a, b):
		if a.value == b.value:
			return a.original_index < b.original_index
		return a.value < b.value
	)

	# 提取排序后的索引
	var indices = []
	for item in indexed_arr:
		indices.append(item.original_index)

	return indices

## 通用方法。可以返回本卡牌，MindStateProperty 的数值排序结果
func get_mindStateProperty_rank() -> Array:
	var propertyValueList = []
	for property in GameInfo.propertyList:
		propertyValueList.append(cardRoot.cardInfo[property].to_int())

	print("变更后 targetCard 的 mindState 属性情况：", propertyValueList)

	return _get_ranks_with_ties(propertyValueList)

##	获取数组元素的排名，相同值排名相同
##	排名从1开始（1表示最高或最低，取决于排序方式）
func _get_ranks_with_ties(arr: Array) -> Array:
	if arr.is_empty():
		return []

	# 创建带索引的数组
	var indexed_arr = []
	for i in range(arr.size()):
		indexed_arr.append({
			"value": arr[i],
			"original_index": i
		})

	# 降序排序（值大的排名高，排名从1开始）
	indexed_arr.sort_custom(func(a, b): return a.value > b.value)

	# 计算排名
	var ranks = []
	ranks.resize(arr.size())

	var current_rank = 1
	for i in range(indexed_arr.size()):
		var current_item = indexed_arr[i]
		var current_index = current_item.original_index

		# 如果是第一个元素，直接赋值
		if i == 0:
			ranks[current_index] = current_rank
		else:
			var prev_item = indexed_arr[i - 1]
			# 如果当前值与上一个值相同，则排名相同
			if current_item.value == prev_item.value:
				ranks[current_index] = current_rank
			else:
				current_rank = i + 1
				ranks[current_index] = current_rank

	return ranks

##	获取第二小的值，如果不存在则返回 null
##	考虑值相等的情况
func _get_second_smallest_sort(arr: Array) -> Variant:
	if arr.size() < 2:
		print("数组元素不足2个")
		return null

	# 创建副本并排序
	var sorted_arr = arr.duplicate()
	sorted_arr.sort()  # 升序排序

	var smallest = sorted_arr[0]

	# 寻找第一个不等于最小值的元素
	for i in range(1, sorted_arr.size()):
		if sorted_arr[i] != smallest:
			return sorted_arr[i]

	# 所有值都相同
	print("所有值都相同，没有第二小的值")
	return null
