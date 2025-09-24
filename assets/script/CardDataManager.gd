extends Node
class_name CardDataManager

var seatedCardList:Array
var eventResultCondition:Array = []
var nextResultIndex:int = -1
signal trans_card_to_handDeck()
signal gen_result_index()

const eventResultConditionScore: Dictionary =  {
	"CardEqual" = 10,
	"TypeEqual" = 5,
	"Typeof" = 1
}
const blankConditionScore = -10

enum genResult{Property, AddCard, GenFromMindSwarn}
var genResultEnum = []

@onready var handDeck:deck = get_tree().root.get_node("testScean/site1/handDeck")
@onready var resultDeck:deck = get_tree().root.get_node("testScean/site1/handDeck")

func _ready() -> void:
	connect("trans_card_to_handDeck", card_to_handDeck)
	connect("gen_result_index", gen_event_result_index_from_eventResultCondition)
	## 将 genResult 写入 genResultEnum，方便外部调用
	for key in genResult:
		genResultEnum.append(key)

## 跟剧传入 index 的情况，处理作为列表
func CleanSeatedCardList(index:int = -1) -> void:
	if index < 0:
		seatedCardList.clear()
	elif index > seatedCardList.size():
		return
	else:
		seatedCardList[index] = null

## 根据参数，创建对应长度的seatedCardList
func InitSeatedCardList(size: int) -> void:
	## 对非法的数据进行处理
	if size < 0 :
		return
	## 实际重置 seatedCardList
	var arr = []
	arr.resize(size)
	seatedCardList = arr

## 在指定位置设置卡牌
func SetCardToListFromIndex(index:int, target) -> void:
	## 边界情况处理
	if index >= seatedCardList.size() or index < 0:
		#TODO 此处可以添加报错
		return

	seatedCardList[index] = target


func card_to_handDeck(cardToAdd) -> void:
	handDeck.add_card(cardToAdd)

## 将 eventResultCondition 设置为指定列表，通常被 avg 设置调用。参数默认为空列表。
func set_eventResultCondition(condition:Array = []) -> void:
	eventResultCondition = condition

## 传入参数用于控制是否为初始化模式。如果是，那么将 index 初始化为 -1，防止被错误调用。否则从 eventResultCondition 中选择最匹配的结果。默认关闭初始化模式。
func gen_event_result_index_from_eventResultCondition(initMode:bool = false) -> void:
	if initMode:
		nextResultIndex = -1
		return

	## TODO 待功能实现参数
	if eventResultCondition.size() == 0:
		## TODO 此处为配置错误，应当有报错或保底实现
		nextResultIndex = eventResultCondition[0]
		return
	## 正式功能。遍历所有 eventResultCondition，计分。将得分最高的 index 返回
	var maxPoint = 0
	var maxPointIndex = -1
	var blankConditionIndex = -1
	for index in range(0, eventResultCondition.size()):
		var condition = eventResultCondition[index]
		var nowPoint =  _check_segment_condition_point_gen(condition)
		print("EventResultCondiont 得分判断，[%s] = %s, 得分：%s"%[index, condition, nowPoint])
		if nowPoint > maxPoint:
			maxPointIndex = index
			maxPoint = nowPoint
			continue
		if nowPoint == blankConditionScore:
			blankConditionIndex = index
			continue
	## 根据得分进行分支判断。如果有匹配到的分支（得分 > 0），那么前往分支。否则前往空白配置的默认分支。
	if maxPoint > 0:
		nextResultIndex = maxPointIndex
	else:
		## TODO 此处有可能 blankConditionIndex = -1。需要报错，或配置检查处理
		nextResultIndex = blankConditionIndex
	print("下一步分支：", nextResultIndex)

## 条件计分函数。通过最终得分，来给condition的匹配情况进行评价。分数越高，评价结果越好。正常 condition 的得分都会大于 0 。
## 但特别的，condition 只有全部被满足，才会得分，否则计分为 -999。
## 特别的，对于【全空条件】，计分自动为 -1。
func _check_segment_condition_point_gen(index) -> int:
	## 如果 index 未配置，那么默认返回最小得分 -999
	if not index in GameInfo.eventResultInfo.keys():
		return -999
	## 如果是全空的结果，那么得分为 -1
	var rawCondition = GameInfo.eventResultInfo[index]['condition']
	var conditionList = rawCondition.split(",")

	## 空字典自动给最小分数，会被忽略
	if conditionList.size() == 0:
		return -999

	## 其他情况下，从0开始积分，每有一个 condition_pair 被 seatPair 中结果匹配，那么就得到1分。
	##TODO 如果有更细致的匹配结果，例如【类型继承】的匹配，那么此处计分规则需要改变
	var point = 0
	for condition in conditionList:
		var conditionScore = _check_single_event_condition(condition)
		## 检索默认空配置
		if point == 0 and conditionScore == blankConditionScore:
			return blankConditionScore
		if conditionScore > 0:
			point += conditionScore
	return point

## 内部函数，用于实际判断一个 eventCondition 的得分情况
func _check_single_event_condition(condition:String) -> int:
	## 使用【:】来分割配置
	var config = condition.split(":")
	## 检查枚举
	match config[0]:
		"CardEqual":
			return _check_cardEqualCondition(config)
		"TypeEqual":
			return _check_typeEqualCondition(config)
		"Typeof":
			## TODO 暂不实现功能，使用 TypeEqual 代替
			return _check_typeEqualCondition(config)
		_:
			if config[0].is_empty():
				return blankConditionScore
			## TODO 此处可以报错.检查是否配置了错误的枚举
			print("发现错误的 eventResultCondition 枚举：", config[0])
			return -999

## 内部函数，CardEqual 枚举功能实现
func _check_cardEqualCondition(config:Array) -> int:
	## 配置长度错误。此处可以报错
	if config.size() != 3:
		return -999
	## 检查配置项。此处可以报错。
	if not config[1].is_valid_int():
		return -999
	## 检查配置项 p1 是否为合法的 index
	var index = config[1].to_int()
	if index >= seatedCardList.size():
		return -999
	## 检测座位是否为空
	var seatedCard = seatedCardList[index] as card
	if seatedCard == null:
		return -1
	if seatedCard.cardInfo.ID == config[2]:
		return eventResultConditionScore[config[0]]
	else:
		return -999

## 内部函数，TypeEqual 枚举功能实现
func _check_typeEqualCondition(config:Array) -> int:
	## 配置长度错误。此处可以报错
	if config.size() != 3:
		return -999
	## 检查配置项。此处可以报错。
	if not config[1].is_valid_int():
		return -999
	## 检查配置项 p1 是否为合法的 index
	var index = config[1].to_int()
	if index >= seatedCardList.size():
		return -999
	## 检测座位是否为空
	var seatedCard = seatedCardList[index] as card
	if seatedCard == null:
		return -1
	if seatedCard.cardInfo['base_cardType'] == config[2]:
		return eventResultConditionScore[config[0]]
	else:
		return -999

## TODO 根据 nextResultIndex 来生成实际的 eventResultCardList
func gen_card_from_eventResult() -> Array:
	## 获取 result 相关的卡牌配置
	var resultID = eventResultCondition[nextResultIndex]
	var rawResult = GameInfo.eventResultInfo[resultID]['result']
	## 正式功能
	var resultList = rawResult.split(",")
	var propertyFunc = genResultEnum[0]
	var addCardFunc = genResultEnum[1]
	var genFromMindSwarnFunc = genResultEnum[2]
	var output = []
	for result in resultList:
		var config = result.split(":")
		match config[0]:
			## TODO 属性相关设计，之后统一处理
			propertyFunc:
				print(propertyFunc)
				var addedCard = _setProperty_to_result(config)
				if addedCard != null:
					output.append(addedCard)
			addCardFunc:
				print(addCardFunc)
				var addedCard = _addCard_to_result(config[1])
				if addedCard != null:
					output.append(addedCard)
			## TODO 临时占位。对于从心相世界生成卡牌规则，之后与属性统一处理。
			genFromMindSwarnFunc:
				print(genFromMindSwarnFunc)
			_:
				print("完成")

	return output

## addCard 功能函数。还存在部分问题。
func _addCard_to_result(cardID:String) -> card:
	if not cardID in GameInfo.cardInfo.keys():
		print("不存在对应的卡牌。ID: %s"%[cardID])
		return null
	var targetCard = GameInfo.cardInfo[cardID]
	#var searchCard = GameInfo.search_card_from_cardName(targetCard['base_cardName'])
	## TODO 这样添加的卡牌，收回至手牌时，位置会发生变化。
	var searchCard = PlayerInfo.add_new_card(targetCard['base_cardName'],handDeck,)
	return searchCard

func _setProperty_to_result(config:Array) -> card:
	## 检查参数配置
	if config.size() != 4:
		print("result = property 参数数量错误：%s"%[config.size()])
		return

	var seatIndex = config[1]
	var cardType = config[2]
	var mindStatePropertyTemplate = config[3]

	if not seatIndex.is_valid_int():
		print("result = property 座位索引配置非法：%s"%[seatIndex])
		return
	seatIndex = seatIndex.to_int()
	if seatIndex >= seatedCardList.size():
		print("result = property 座位长度 = %s，索引配置 = %s"%[seatedCardList.size(), seatIndex])
		return
	if not cardType in GameType.CardType:
		print("result = property 检测卡牌类型配置错误，%s"%[cardType])
		return
	if not mindStatePropertyTemplate in GameInfo.mindStateProperty.keys():
		print("result = property 配置 MindStateProperty 模板 ID 错误，%s"%[mindStatePropertyTemplate])
		return

	## 正式功能
	var targetCard = seatedCardList[seatIndex] as card
	if targetCard == null:
		print("result = property，座位中没有检测到卡牌，index = %s"%[seatIndex])
		return

	var property = GameInfo.mindStateProperty[mindStatePropertyTemplate]
	_mindStateAttribute_changer(targetCard, property)
	print(targetCard.cardInfo)

	return targetCard

## 实际属性改变功能函数。对 targetCard 进行 property 对应的修改。
func _mindStateAttribute_changer(targetCard:card, property:Dictionary) -> void:
	var attribute =  targetCard.get_node("Attribute") as MindStateCardAttribute
	for item in attribute.propertyList:
		if not item in property.keys():
			continue
		var targetAttribute = attribute.attribute_component.find_attribute(item)
		targetAttribute.add(property[item].to_int())
		targetCard.cardInfo[item] = str(targetAttribute.get_value())
	pass
